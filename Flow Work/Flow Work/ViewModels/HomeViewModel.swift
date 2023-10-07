//
//  HomeViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Combine
import SwiftUI
import Firebase

class HomeViewModel: ObservableObject {
    @Published var authManager: AuthManager
    @Published var webSocketManager: WebSocketManager
    @Published var isSignedIn: Bool = false
    @Published var displayName: String = "there"
    var appCoordinator: AppCoordinator
    
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManager, webSocketManager: WebSocketManager, appCoordinator: AppCoordinator) {
        self.authManager = authManager
        self.webSocketManager = webSocketManager
        self.appCoordinator = appCoordinator
        
        self.authManager.$isSignedIn
            .assign(to: \.isSignedIn, on: self)
            .store(in: &cancellables)
        
        Auth.auth().addStateDidChangeListener { auth, user in
            self.displayName = user?.displayName ?? "there"
        }
    }
    
    func createSession() {
        self.webSocketManager.connect()
        
        let jsonObject: [String: Any] = [
            "topic": "coworking_session:lobby",
            "event": "create_session",
            "payload": ["name": "rev"],
            "ref": "1"
        ]
        webSocketManager.sendJSON(jsonObject)
        self.appCoordinator.showSessionView()
    }
    
    func joinSession() {
        self.appCoordinator.showJoinSessionView()
    }
    
    func signOut() {
        self.authManager.signOut()
    }
    
    
}
