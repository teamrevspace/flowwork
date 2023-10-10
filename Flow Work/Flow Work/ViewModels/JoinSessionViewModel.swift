//
//  JoinSessionViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import Combine
import SwiftUI

class JoinSessionViewModel: ObservableObject {
    @Published var webSocketManager: WebSocketManager
    @Published var inputText: String = ""
    @Published var errorPublisher: ErrorPublisher
    var appCoordinator: AppCoordinator
    
    init(webSocketManager: WebSocketManager, errorPublisher: ErrorPublisher, appCoordinator: AppCoordinator) {
        self.webSocketManager = webSocketManager
        self.errorPublisher = errorPublisher
        self.appCoordinator = appCoordinator
        
        self.setupWebSocketHandlers()
    }
    
    private func setupWebSocketHandlers() {
        
    }
    
    func joinSession() {
        var sessionId: String
        
        if let url = URL(string: inputText), let host = url.host, host == "flowwork.xyz" {
            let pathComponents = url.pathComponents
            if pathComponents.count > 2 && pathComponents[1] == "s" {
                sessionId = pathComponents[2]
            } else {
                self.errorPublisher.publish(error: AppError.invalidURLFormat)
                return
            }
        } else {
            sessionId = inputText
        }
        
        if !self.webSocketManager.hasJoinedSession {
            self.webSocketManager.joinSessionLobby()
        }
        
        let payload = ["id": sessionId]
        let message = Message(
            topic: "coworking_session:lobby",
            event: "join_session",
            payload: payload,
            ref: "1")
        self.webSocketManager.sendMessage(message: message)
        print("Joined session: \(sessionId)")
    }
    
    func returnToHome() {
        self.webSocketManager.leaveSessionLobby()
        self.appCoordinator.showHomeView()
    }
}
