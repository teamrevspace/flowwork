//
//  SessionService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import Combine
import NIO
import NIOHTTP1
import NIOWebSocket
import Swinject
import Firebase

class SessionService: SessionServiceProtocol, ObservableObject {
    weak var delegate: SessionServiceDelegate?
    
    @Published private var state = SessionState()
    
    private let resolver: Swinject.Resolver
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var webSocketSession: URLSession
    private var pingTimer: Timer?
    private var authToken: String?
    private var retryCount = 0
    private let maxRetries = 5
    
    var statePublisher: AnyPublisher<SessionState, Never> {
        $state.eraseToAnyPublisher()
    }
    
    init(resolver: Swinject.Resolver) {
        self.resolver = resolver
        
        webSocketSession = URLSession(configuration: .default)
        self.schedulePing()
    }
    
    deinit {
        pingTimer?.invalidate()
        self.disconnect()
    }
    
    func initSessionList(sessions: [Session], defaultSession: Session?) {
        if let defaultSession = defaultSession {
            if !sessions.contains(where: { $0.id == defaultSession.id }) {
                self.state.availableSessions = [defaultSession] + sessions
            } else {
                self.state.availableSessions = sessions
            }
        } else {
            self.state.availableSessions = sessions
        }
    }
    
    func updateAuthToken(_ authToken: String?) {
        self.authToken = authToken
    }
    
    func connect(_ userId: String?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "wss"
        urlComponents.host = "api.flowwork.xyz"
        urlComponents.path = "/session/websocket"
        if (userId != nil) {
            urlComponents.queryItems = [
                URLQueryItem(name: "user_id", value: userId),
            ]
        }
        
        guard let url = urlComponents.url else {
            print(AppError.invalidURLFormat)
            return
        }
        
        var request = URLRequest(url: url)
        if let token = self.authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        webSocketTask = webSocketSession.webSocketTask(with: request)
        webSocketTask?.resume()
        
        sendPing()
        receiveMessage(userId)
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        DispatchQueue.main.async {
            self.state.isConnected = false
            self.state.currentSessionUsers = nil
        }
    }
    
    func createSession(_ session: Session) {
        let joinLobbyMessage = Message(
            topic: "coworking_session:lobby",
            event: "phx_join",
            payload: [:] as [String: Any]
        )
        self.sendMessage(message: joinLobbyMessage)
        
        var createSessionPayload: [String: Any] = [
            "name": session.name,
            "userIds": session.userIds ?? []
        ]
        if session.description != nil {
            createSessionPayload.updateValue(session.description!, forKey: "description")
        }
        if session.password != nil {
            createSessionPayload.updateValue(session.password!, forKey: "password")
        }
        
        let createSessionMessage = Message(
            topic: "coworking_session:lobby",
            event: "create_session",
            payload: createSessionPayload
        )
        self.sendMessage(message: createSessionMessage)
        self.delegate?.didJoinSession(session.id)
    }
    
    func joinSession(_ sessionId: String) {
        let joinLobbyMessage = Message(
            topic: "coworking_session:\(sessionId)",
            event: "phx_join",
            payload: [:] as [String: Any]
        )
        self.sendMessage(message: joinLobbyMessage)
        
        let joinSessionMessage = Message(
            topic: "coworking_session:\(sessionId)",
            event: "join_session",
            payload: [:] as [String: Any]
        )
        self.sendMessage(message: joinSessionMessage)
        self.state.hasJoinedSession = true
        self.delegate?.didJoinSession(sessionId)
    }
    
    func leaveSession(_ sessionId: String) {
        let leaveSessionMessage = Message(
            topic: "coworking_session:\(sessionId)",
            event: "phx_leave",
            payload: [:] as [String: Any]
        )
        self.sendMessage(message: leaveSessionMessage)
        self.state.currentSession = nil
        self.state.currentSessionUsers = nil
        self.state.hasJoinedSession = false
    }
    
    func sendMessage(message: Message) {
        do {
            let messageDictionary = message.toDictionary()
            let jsonData = try JSONSerialization.data(withJSONObject: messageDictionary, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let message = URLSessionWebSocketTask.Message.string(jsonString)
                webSocketTask?.send(message, completionHandler: { error in
                    if let error = error {
                        print("WebSocket send error: \(error)")
                    }
                })
            } else {
                print("Failed to convert JSON data to string")
            }
        } catch {
            print("Failed to serialize message to JSON: \(error)")
        }
    }
    
    private func receiveMessage(_ userId: String?) {
        webSocketTask?.receive(completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.state.isConnected = false
                }
                self?.handleError(error)
                self?.disconnect()
                self?.retryConnection(userId)
                
            case .success(let message):
                DispatchQueue.main.async {
                    self?.state.isConnected = true
                }
                self?.handleMessage(message)
                self?.retryCount = 0
                self?.receiveMessage(userId)
            }
        })
    }
    
    private func retryConnection(_ userId: String?) {
        guard retryCount < maxRetries else {
            DispatchQueue.main.async {
                self.state.maxRetriesReached = true
            }
            print("Max retry attempts reached. Stopping reconnection attempts.")
            return
        }
        self.resetMaxRetries()
        let delayInterval = Double(pow(2, Double(retryCount)))
        DispatchQueue.global().asyncAfter(deadline: .now() + delayInterval) {
            self.retryCount += 1
            self.connect(userId)
        }
    }
    
    func resetMaxRetries() {
        DispatchQueue.main.async {
            self.state.maxRetriesReached = false
        }
    }
    
    private func handleError(_ error: Error) {
        print(AppError.networkError(error.localizedDescription))
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            let data = Data(text.utf8)
            handleDecodedMessage(MessageType(data: data))
        case .data(let data):
            print("Received data: \(data)")
        @unknown default:
            print("Unknown message type: \(message)")
        }
    }
    
    private func handleDecodedMessage(_ messageType: MessageType) {
        switch messageType {
        case .socketResponse(let messageObject):
            handleSocketResponse(messageObject)
        case .sessionResponse(let messageObject):
            handleSessionResponse(messageObject)
        case .lobbyResponse(let messageObject):
            handleLobbyResponse(messageObject)
        case .errorResponse(let messageObject):
            handleErrorResponse(messageObject)
        case .unknown(let messageObject):
            handleUnknownResponse(messageObject)
        }
    }
    
    
    private func schedulePing() {
        pingTimer?.invalidate()
        pingTimer = nil
        
        pingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    private func sendPing() {
        webSocketTask?.sendPing { (error) in
            DispatchQueue.main.async {
                if error != nil {
                    self.state.isConnected = false
                } else {
                    self.state.isConnected = true
                }
            }
        }
    }
}

// MARK: work mode implementation
extension SessionService {
    func updateWorkMode(_ mode: WorkMode) {
        DispatchQueue.main.async {
            self.state.selectedMode = mode
        }
    }
}

// MARK: socket implementation
extension SessionService {
    private func handleSocketResponse(_ response: SocketResponse) {
        DispatchQueue.main.async {
            if response.topic.starts(with: "coworking_session:") && response.event == "phx_join" && response.payload?.status == "ok" {
                self.state.hasJoinedSession = true
            } else if response.topic.starts(with: "coworking_session:") && response.event == "phx_close" {
                self.state.currentSessionUsers = nil
            }
        }
    }
    
    private func handleSessionResponse(_ response: SessionResponse) {
        DispatchQueue.main.async {
            if response.topic.starts(with: "coworking_session:lobby") && response.event == "phx_reply" && response.payload.status == "ok" {
                let id = response.payload.response.name.components(separatedBy: "/").last!
                self.leaveSession("lobby")
                self.joinSession(id)
            } else if response.topic.starts(with: "coworking_session:") && response.event == "phx_reply" && response.payload.status == "ok"  {
                let id = response.payload.response.name.components(separatedBy: "/").last!
                let sessionFields = response.payload.response.fields
                let name = sessionFields.name.stringValue
                let description = sessionFields.description?.stringValue
                let password = sessionFields.password?.stringValue
                // MARK: userIds are ignored in view
                let userIds = sessionFields.userIds.arrayValue.values.map { $0.stringValue }
                
                let session = Session(
                    id: id,
                    name: name,
                    description: description,
                    password: password,
                    userIds: userIds
                )
                self.state.currentSession = session
                self.state.hasJoinedSession = true
            }
        }
    }
    
    private func handleLobbyResponse(_ response: LobbyResponse) {
        DispatchQueue.main.async {
            if response.topic.starts(with: "coworking_session:") && response.event == "lobby_update" {
                if (response.payload.userIds.isEmpty) { return }
                self.delegate?.didUpdateLobby(response.payload.userIds, completion: { users in
                    self.state.currentSessionUsers = users
                })
            }
        }
    }
    
    private func handleErrorResponse(_ response: ErrorResponse) {
        DispatchQueue.main.async {
            if response.payload.status == "error" {
                print(AppError.sessionNotFound)
                self.delegate?.sessionNotFound()
            }
        }
    }
    
    private func handleUnknownResponse(_ response: Any) {
        if let data = response as? Data, let string = String(data: data, encoding: .utf8) {
            print("Received unknown response: \(string)")
        } else {
            print("Received unknown response: \(response)")
        }
    }
}

extension MessageType {
    init(data: Data) {
        let decoder = JSONDecoder()
        if let messageObject = try? decoder.decode(SessionResponse.self, from: data) {
            self = .sessionResponse(messageObject)
        } else if let messageObject = try? decoder.decode(LobbyResponse.self, from: data) {
            self = .lobbyResponse(messageObject)
        } else if let messageObject = try? decoder.decode(ErrorResponse.self, from: data) {
            self = .errorResponse(messageObject)
        } else if let messageObject = try? decoder.decode(SocketResponse.self, from: data) {
            self = .socketResponse(messageObject)
        } else {
            self = .unknown(data)
        }
    }
}
