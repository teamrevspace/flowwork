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

protocol SessionViewModelDelegate: AnyObject {
    func showHomeView()
}

class SessionViewModel: ObservableObject {
    weak var delegate: SessionViewModelDelegate?
    
    @Published var authService: AuthServiceProtocol
    @Published var sessionService: SessionServiceProtocol
    @Published var storeService: StoreServiceProtocol
    @Published var errorService: ErrorServiceProtocol
    
    @Published var authState = AuthState()
    @Published var sessionState = SessionState() {
        didSet {
            fetchData()
        }
    }
    @Published var sessionUsers: [User] = []
    
    private let resolver: Resolver
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.errorService = resolver.resolve(ErrorServiceProtocol.self)!
        
        sessionService.delegate = self
        
        authService.statePublisher
            .assign(to: \.authState, on: self)
            .store(in: &cancellables)
        sessionService.statePublisher
            .assign(to: \.sessionState, on: self)
            .store(in: &cancellables)
    }
    
    func fetchData() {
        guard let currentUserId = self.authState.currentUser?.id else {
            return
        }
        self.storeService.findUsersByUserIds(userIds: self.sessionState.currentSession?.userIds ?? [currentUserId]) { users in
            self.sessionUsers = users
        }
    }
    
    func copyToClipboard(textToCopy: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(textToCopy, forType: .string)
    }
    
    func leaveSession() {
        if let currentSessionId = self.sessionState.currentSession?.id {
            self.sessionService.leaveSession(currentSessionId)
        }
        self.delegate?.showHomeView()
    }
}

extension SessionViewModel: SessionServiceDelegate {
    func didJoinSession(_ sessionId: String) {}
    func sessionNotFound() {}
    func newUserJoined() {
        self.fetchData()
    }
}
