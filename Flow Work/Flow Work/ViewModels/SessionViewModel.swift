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
    @Published var currentSession: Session?
    @Published var isLoading: Bool = false
    var appCoordinator: AppCoordinator
    
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManager, webSocketManager: WebSocketManager, appCoordinator: AppCoordinator) {
        self.authManager = authManager
        self.webSocketManager = webSocketManager
        self.appCoordinator = appCoordinator
        
        self.webSocketManager.$currentSession
            .assign(to: \.currentSession, on: self)
            .store(in: &cancellables)
        
        self.webSocketManager.$currentSession
            .sink { session in
                if session == nil {
                    self.isLoading = true
                } else {
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
    
    func getCurrentUser() -> User? {
        return self.authManager.currentUser
    }
    
    func copyToClipboard(textToCopy: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(textToCopy, forType: .string)
    }
    
    func leaveSession() {
        self.webSocketManager.leaveSessionLobby()
        self.appCoordinator.showJoinSessionView()
    }
}
