//
//  WebSocketManager.swift
//  Flow Work
//
//  Created by Allen Lin on 10/5/23.
//

import Foundation

import Foundation
import SwiftUI
import Combine

class WebSocketManager: ObservableObject {
    var socket: URLSessionWebSocketTask?
    var cancellable: AnyCancellable?
    var authToken: String?
    
    init(url: URL, authToken: String? = nil) {
        self.authToken = authToken
        var request = URLRequest(url: url)
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        socket = URLSession.shared.webSocketTask(with: request)
        print("WebSocket connection initiated")
    }
    
    func connectCoworkingSession() {
        socket?.resume()
        let payload: [String: Any] = [:]
        
        let joinLobbyMessage: [String: Any] = [
            "topic": "coworking_session:lobby",
            "event": "phx_join",
            "payload": payload,
            "ref": "1"
        ]
        sendJSON(joinLobbyMessage)
        print("Coworking Session socket connected")
    }
    
    func sendJSON(_ dictionary: [String: Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Failed to serialize JSON")
            return
        }
        socket?.send(.string(jsonString)) { error in
            if let error = error {
                print("WebSocket sending error: \(error)")
            }
        }
    }
    
    func disconnect() {
        socket?.cancel()
    }
}
