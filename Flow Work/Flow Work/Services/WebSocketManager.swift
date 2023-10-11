import Foundation
import SwiftUI
import Combine
import NIO
import NIOHTTP1
import NIOWebSocket

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession
    private var pingTimer: Timer?
    @Published var isConnected: Bool = false
    @Published var hasJoinedSession: Bool = false
    @Published var authToken: String?
    @Published var currentSession: Session?
    @Published var userId: String?
    
    init(authToken: String? = nil, userId: String? = nil) {
        self.authToken = authToken
        self.userId = userId
        self.session = URLSession(configuration: .default)
        schedulePing()
    }
    
    deinit {
        pingTimer?.invalidate()
        self.disconnect()
    }
    
    func updateConnectionStatus(_ isConnected: Bool) {
        DispatchQueue.main.async {
            self.isConnected = isConnected
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
                self.updateConnectionStatus(false)
                print("Failed to send ping: \(error)")
            } else {
                self.updateConnectionStatus(true)
                print("Ping sent")
            }
        }
    }
    
    func updateSession(_ session: Session) {
        DispatchQueue.main.async {
            self.currentSession = session
        }
    }
    
    func connect() {
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
        //        if let token = authToken {
        //            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        //        }
        
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        print("Connected to websocket")
        
        self.updateConnectionStatus(true)
        self.joinSessionLobby()
        
        receiveMessage()
    }
    
    func joinSessionLobby() {
        let payload: [String: Any] = [:]
        let message = Message(
            topic: "coworking_session:lobby",
            event: "phx_join",
            payload: payload
        )
        self.sendMessage(message: message)
        self.hasJoinedSession = true
        print("Joined session lobby")
    }
    
    func leaveSessionLobby() {
        let payload: [String: Any] = [:]
        let message = Message(
            topic: "coworking_session:lobby",
            event: "phx_leave",
            payload: payload
        )
        self.sendMessage(message: message)
        self.hasJoinedSession = false
        print("Left session lobby")
    }
    
    private func receiveMessage() {
        webSocketTask?.receive(completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                print("WebSocket received error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    let data = Data(text.utf8)
                    let decoder = JSONDecoder()
                    do {
                        let messageObject = try decoder.decode(SessionResponse.self, from: data)
                        self?.handleSessionResponse(messageObject)
                    } catch {
                        do {
                            let messageObject = try decoder.decode(LobbyResponse.self, from: data)
                            self?.handleLobbyResponse(messageObject)
                        } catch {
                            print("Received message: \(message)")
                        }
                    }
                case .data(let data):
                    print("Received data: \(data)")
                    // Handle binary data
                @unknown default:
                    print("Unknown message type")
                }
            }
            self?.receiveMessage()
        })
    }
    
    private func handleSessionResponse(_ response: SessionResponse) {
        if response.topic == "coworking_session:lobby" && response.event == "phx_reply" && response.payload.status == "ok" {
            let sessionFields = response.payload.response.fields
            let sessionUsers = sessionFields.users.arrayValue.values.map { $0.stringValue }
            let sessionId = response.payload.response.name.components(separatedBy: "/").last!
            let session = Session(
                id: sessionId,
                name: sessionFields.name.stringValue,
                description: sessionFields.description?.stringValue,
                joinCode: sessionFields.joinCode?.stringValue,
                users: sessionUsers
            )
            self.updateSession(session)
            print("Received session: \(session)")
        }
    }
    
    private func handleLobbyResponse(_ response: LobbyResponse) {
        if response.topic == "coworking_session:lobby" && response.event == "lobby_update" {
            
        }
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
    
    func disconnect() {
        if self.hasJoinedSession {
            self.leaveSessionLobby()
        }
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("Disconnected from websocket")
    }
}
