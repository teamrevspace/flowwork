import Foundation
import SwiftUI
import Combine
import NIO
import NIOHTTP1
import NIOWebSocket

protocol WebSocketManagerDelegate: AnyObject {
    func didJoinSession(_ session: Session)
}

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    weak var delegate: WebSocketManagerDelegate?
    private var session: URLSession
    private var pingTimer: Timer?
    @Published var isConnected: Bool = false
    @Published var hasJoinedSession: Bool = false
    @Published var authToken: String?
    
    init(authToken: String? = nil) {
        self.authToken = authToken
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
    
    func handle(message: Message) {
        if message.topic == "coworking_session:lobby" && message.event == "join_session",
           let response = message.payload as? Session {
            delegate?.didJoinSession(response)
        }
    }
    
    func connect() {
        guard let url = URL(string: "ws://localhost:4000/session/websocket") else { return }
        
        var request = URLRequest(url: url)
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
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
            payload: payload,
            ref: "1"
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
            payload: payload,
            ref: "1"
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
