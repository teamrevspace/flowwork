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
    @Published var webSocketManager: WebSocketManager?
    @Published var isSignedIn: Bool = false
    @Published var displayName: String = "there"
    
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManager, webSocketManager: WebSocketManager) {
        self.authManager = authManager
        self.webSocketManager = webSocketManager
        
        self.authManager.$isSignedIn
            .assign(to: \.isSignedIn, on: self)
            .store(in: &cancellables)
        
        Auth.auth().addStateDidChangeListener { auth, user in
            self.displayName = user?.displayName ?? "there"
        }
    }
    
    func createSession() {
        let jsonObject: [String: Any] = [
            "topic": "coworking_session:lobby",
            "event": "create_session",
            "payload": ["name": "rev"],
            "ref": "1"
        ]
        webSocketManager?.sendJSON(jsonObject)
    }
    
    func joinSession() {
        
    }
    
    func signOut() {
        authManager.signOut()
    }
    
    
}
