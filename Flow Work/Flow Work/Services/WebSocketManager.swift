import Foundation
import SwiftUI
import Combine
import NIO
import NIOHTTP1
import NIOWebSocket

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession
    private var isConnected: Bool = false
    @Published var authToken: String?
    
    init(authToken: String? = nil) {
        self.authToken = authToken
        self.session = URLSession(configuration: .default)
    }
    
    func connect() {
        guard let url = URL(string: "wss://flowwork.fly.dev/session/websocket") else { return }
        
        var request = URLRequest(url: url)
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        print("Connected to websocket")
        
        receiveMessage()
    }
    
    private func joinSessionLobby() {
        let payload: [String: Any] = [:]
        let message: [String: Any] = [
            "topic": "coworking_session:lobby",
            "event": "phx_join",
            "payload": payload,
            "ref": "1"
        ]
        self.sendMessage(message: message)
        self.isConnected = true
        print("Joined session lobby")
    }
    
    func leaveSessionLobby() {
        let payload: [String: Any] = [:]
        let message: [String: Any] = [
            "topic": "coworking_session:lobby",
            "event": "phx_leave",
            "payload": payload,
            "ref": "1"
        ]
        self.sendMessage(message: message)
        self.isConnected = false
        print("Left session lobby")
    }
    
    func createSession(sessionName: String) {
        if !self.isConnected {
            self.joinSessionLobby()
        }
        
        let payload: [String: Any] = [
            "name": sessionName
        ]
        let message: [String: Any] = [
            "topic": "coworking_session:lobby",
            "event": "create_session",
            "payload": payload,
            "ref": "1"
        ]
        self.sendMessage(message: message)
        print("Created session \"\(sessionName)\"")
    }
    
    func joinSession(sessionId: String) {
        if !self.isConnected {
            self.joinSessionLobby()
        }
        
        let payload: [String: Any] = [
            "id": sessionId
        ]
        let message: [String: Any] = [
            "topic": "coworking_session:lobby",
            "event": "join_session",
            "payload": payload,
            "ref": "1"
        ]
        self.sendMessage(message: message)
        print("Joined session \"\(sessionId)\"")
    }
    
    private func receiveMessage() {
        webSocketTask?.receive(completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                print("WebSocket received error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received string: \(text)")
                    // Handle string message
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
    
    func sendMessage(message: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
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
        if self.isConnected {
            self.leaveSessionLobby()
        }
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("Disconnected from websocket")
    }
}
