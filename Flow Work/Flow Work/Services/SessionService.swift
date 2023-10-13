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

class SessionService: SessionServiceProtocol, ObservableObject {
    @Published var errorService: ErrorServiceProtocol
    
    @Published var isConnected: Bool = false
    @Published var hasJoinedSession: Bool = false
    @Published var currentSession: Session? = nil
    
    private let resolver: Swinject.Resolver
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var webSocketSession: URLSession
    private var pingTimer: Timer?
    
    init(resolver: Swinject.Resolver) {
        self.resolver = resolver
        self.errorService = resolver.resolve(ErrorServiceProtocol.self)!
        
        webSocketSession = URLSession(configuration: .default)
        self.schedulePing()
    }
    
    deinit {
        pingTimer?.invalidate()
        self.disconnect()
    }
    
    func connect(_ userId: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "ws"
        urlComponents.host = "localhost"
        urlComponents.port = 4000
        urlComponents.path = "/session/websocket"
        urlComponents.queryItems = [
            URLQueryItem(name: "user_id", value: userId),
        ]
        
        guard let url = urlComponents.url else { return }
        
        let request = URLRequest(url: url)
        
        webSocketTask = webSocketSession.webSocketTask(with: request)
        webSocketTask?.resume()
        self.isConnected = true
        print("Connected to websocket")
        
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        self.isConnected = false
        print("Disconnected from websocket")
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
        if session.joinCode != nil {
            createSessionPayload.updateValue(session.joinCode!, forKey: "joinCode")
        }
        
        let createSessionMessage = Message(
            topic: "coworking_session:lobby",
            event: "create_session",
            payload: createSessionPayload
        )
        self.sendMessage(message: createSessionMessage)
        print("Created session: \(session.name)")
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
        self.hasJoinedSession = true
        print("Joined session: \(sessionId)")
    }
    
    func leaveSession(_ sessionId: String) {
        let leaveSessionMessage = Message(
            topic: "coworking_session:\(sessionId)",
            event: "phx_leave",
            payload: [:] as [String: Any]
        )
        self.sendMessage(message: leaveSessionMessage)
        self.hasJoinedSession = false
        print("Left session: \(sessionId)")
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
    
    private func receiveMessage() {
        webSocketTask?.receive(completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                self?.handleError(error)
            case .success(let message):
                self?.handleMessage(message)
            }
            self?.receiveMessage()
        })
    }
    
    private func handleError(_ error: Error) {
        self.errorService.publish(AppError.networkError(error.localizedDescription))
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            let data = Data(text.utf8)
            handleDecodedMessage(MessageType(data: data))
        case .data(let data):
            print("Received data: \(data)")
        @unknown default:
            print("Unknown message type")
        }
    }
    
    private func handleDecodedMessage(_ messageType: MessageType) {
        switch messageType {
        case .sessionResponse(let messageObject):
            handleSessionResponse(messageObject)
        case .lobbyResponse(let messageObject):
            handleLobbyResponse(messageObject)
        case .errorResponse(let messageObject):
            handleErrorResponse(messageObject)
        case .unknown:
            print("Unknown message type")
        }
    }
    
    
    private func schedulePing() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    private func sendPing() {
        webSocketTask?.sendPing { (error) in
            if let error = error {
                self.isConnected = false
                print("Failed to send ping: \(error)")
            } else {
                self.isConnected = true
                print("Ping sent")
            }
        }
    }
}


extension SessionService {
    
    private func handleSessionResponse(_ response: SessionResponse) {
        if response.topic.starts(with: "coworking_session:") && response.event == "phx_reply" && response.payload.status == "ok"  {
            let id = response.payload.response.name.components(separatedBy: "/").last!
            let sessionFields = response.payload.response.fields
            let name = sessionFields.name.stringValue
            let description = sessionFields.description?.stringValue
            let joinCode = sessionFields.joinCode?.stringValue
            let userIds = sessionFields.userIds.arrayValue.values.map { $0.stringValue }
            
            let session = Session(
                id: id,
                name: name,
                description: description,
                joinCode: joinCode,
                userIds: userIds
            )
            self.currentSession = session
            print("Received session: \(session)")
        }
    }
    
    private func handleLobbyResponse(_ response: LobbyResponse) {
        if response.topic.starts(with: "coworking_session:") && response.event == "lobby_update" {
            self.currentSession?.userIds = response.payload.userIds
            print("Received session user ids: \(response.payload.userIds)")
        }
    }
    
    private func handleErrorResponse(_ response: ErrorResponse) {
        if response.payload.status == "error" {
            self.currentSession = nil
            print("Received error: \(response.payload.response)")
        }
    }
}

enum MessageType {
    case sessionResponse(SessionResponse)
    case lobbyResponse(LobbyResponse)
    case errorResponse(ErrorResponse)
    case unknown
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
        } else {
            self = .unknown
        }
    }
}
