//
//  SessionViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import Combine
import Swinject
import AppKit

class SessionViewModel: ObservableObject {
    @Published var authService: AuthServiceProtocol
    @Published var sessionService: SessionServiceProtocol
    @Published var storeService: StoreServiceProtocol
    @Published var errorService: ErrorServiceProtocol
    @Published var coordinator: AppCoordinator
    
    @Published var sessionUsers: [User] = []
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.errorService = resolver.resolve(ErrorServiceProtocol.self)!
        self.coordinator = resolver.resolve(AppCoordinator.self)!
        
        self.fetchData()
    }
    
    func fetchData() {
        guard let currentUserIds = self.sessionService.currentSession?.userIds else { return }
        self.storeService.findUsersByUserIds(currentUserIds) { users in
            self.sessionUsers = users ?? []
        }
    }
    
    func copyToClipboard(textToCopy: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(textToCopy, forType: .string)
    }
    
    func leaveSession() {
        if let currentSessionId = self.sessionService.currentSession?.id {
            self.sessionService.leaveSession(currentSessionId)
        }
        self.coordinator.showHomeView()
    }
}
