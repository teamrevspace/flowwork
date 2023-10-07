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
    }
    
    func joinSession() {
        var code: String
        
        if let url = URL(string: inputText), let host = url.host, host == "flowwork.xyz" {
            let pathComponents = url.pathComponents
            if pathComponents.count > 2 && pathComponents[1] == "s" {
                code = pathComponents[2]
            } else {
                self.errorPublisher.publish(error: AppError.invalidURLFormat)
                return
            }
        } else {
            code = inputText
        }
        
        self.webSocketManager.connect()
        
        let jsonObject: [String: Any] = [
            "topic": "coworking_session:lobby",
            "event": "join_session",
            "payload": ["id": code],
            "ref": "1"
        ]
        self.webSocketManager.sendJSON(jsonObject)
    }
    
    func returnToHome() {
        self.appCoordinator.showHomeView()
    }
}
