//
//  LobbyViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import Combine
import Swinject

class LobbyViewModel: ObservableObject {
    @Published var sessionService: SessionServiceProtocol
    @Published var authService: AuthServiceProtocol
    @Published var storeService: StoreServiceProtocol
    @Published var errorService: ErrorServiceProtocol
    @Published var coordinator: AppCoordinator
    
    @Published var inputText: String = ""
    @Published var availableSessions: [Session] = []
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.errorService = resolver.resolve(ErrorServiceProtocol.self)!
        self.coordinator = resolver.resolve(AppCoordinator.self)!
        
        self.fetchData()
    }
    
    func fetchData() {
        guard let currentUserId = self.authService.currentUser?.id else { return }
        self.storeService.findSessionsByUserId(currentUserId) { sessions in
            self.availableSessions = sessions ?? []
        }
    }
    
    func joinSession(_ id: String? = nil) {
        var sessionId: String
        
        if let url = URL(string: inputText), let host = url.host, host == "flowwork.xyz" {
            let pathComponents = url.pathComponents
            if pathComponents.count > 2 && pathComponents[1] == "s" {
                // parsed URL is of the form flowwork.xyz/s/<sessionId>
                sessionId = pathComponents[2]
            } else {
                self.errorService.publish(AppError.invalidURLFormat)
                return
            }
        } else {
            guard let id = id ?? (inputText.isEmpty ? nil : inputText) else {
                self.errorService.publish(AppError.invalidURLFormat)
                return
            }
            sessionId = id
        }
        
        self.sessionService.joinSession(sessionId)
    }
    
    func returnToHome() {
        self.coordinator.showHomeView()
    }
}
