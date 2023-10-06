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
    var errorPublisher: ErrorPublisher
    
    init(webSocketManager: WebSocketManager, errorPublisher: ErrorPublisher) {
        self.webSocketManager = webSocketManager
        self.errorPublisher = errorPublisher
    }
    
    func joinSession() {
        var code: String
        
        if let url = URL(string: inputText), let host = url.host, host == "flowwork.xyz" {
            let pathComponents = url.pathComponents
            if pathComponents.count > 2 && pathComponents[1] == "s" {
                code = pathComponents[2]
            } else {
                errorPublisher.publish(error: AppError.invalidURLFormat)
                return
            }
        } else {
            code = inputText
        }
        
        let jsonObject: [String: Any] = [
            "topic": "coworking_session:lobby",
            "event": "join_session",
            "payload": ["code": code],
            "ref": "1"
        ]
        webSocketManager.sendJSON(jsonObject)
    }
}
