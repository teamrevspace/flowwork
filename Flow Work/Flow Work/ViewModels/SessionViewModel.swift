//
//  SessionViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import Combine
import SwiftUI
import Firebase

class SessionViewModel: ObservableObject {
    @Published var authManager: AuthManager
    @Published var webSocketManager: WebSocketManager
    var appCoordinator: AppCoordinator
    
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManager, webSocketManager: WebSocketManager, appCoordinator: AppCoordinator) {
        self.authManager = authManager
        self.webSocketManager = webSocketManager
        self.appCoordinator = appCoordinator
    }
    
    func leaveSession() {
        self.webSocketManager.disconnect()
        self.appCoordinator.showHomeView()
    }
}
