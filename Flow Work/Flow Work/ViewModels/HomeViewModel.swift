//
//  HomeViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Combine
import SwiftUI
import Firebase
import LoremSwiftum

class HomeViewModel: ObservableObject {
    @Published var authManager: AuthManager
    @Published var webSocketManager: WebSocketManager
    @Published var isSignedIn: Bool = false
    @Published var isConnected: Bool = false
    @Published var displayName: String = "there"
    var appCoordinator: AppCoordinator
    
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManager, webSocketManager: WebSocketManager, appCoordinator: AppCoordinator) {
        self.authManager = authManager
        self.webSocketManager = webSocketManager
        self.appCoordinator = appCoordinator
        
        self.webSocketManager.$isConnected
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)
        
        self.authManager.$isSignedIn
            .assign(to: \.isSignedIn, on: self)
            .store(in: &cancellables)
        
        Auth.auth().addStateDidChangeListener { auth, user in
            self.displayName = user?.displayName ?? "there"
        }
    }
    
    func generateSlug() -> String {
        let words = Lorem.words(3)
        let slug = words.replacingOccurrences(of: " ", with: "-").lowercased()
        return slug
    }
    
    func createSession(sessionName: String) {
        if !self.webSocketManager.hasJoinedSession {
            self.webSocketManager.joinSessionLobby()
        }
        
        let payload = ["name": sessionName]
        let message = Message(
            topic: "coworking_session:lobby",
            event: "create_session",
            payload: payload,
            ref: "1"
        )
        self.webSocketManager.sendMessage(message: message)
        print("Created session: \(sessionName)")
        
        self.appCoordinator.showSessionView()
    }
    
    func joinSession() {
        self.appCoordinator.showJoinSessionView()
    }
    
    func signOut() {
        self.authManager.signOut()
    }
}
