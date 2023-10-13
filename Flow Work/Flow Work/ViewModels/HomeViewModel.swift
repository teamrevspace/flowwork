//
//  HomeViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Combine
import LoremSwiftum
import Swinject

class HomeViewModel: ObservableObject {
    @Published var authService: AuthServiceProtocol
    @Published var sessionService: SessionServiceProtocol
    @Published var errorService: ErrorServiceProtocol
    @Published var coordinator: AppCoordinator
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.errorService = resolver.resolve(ErrorServiceProtocol.self)!
        self.coordinator = resolver.resolve(AppCoordinator.self)!
    }
    
    func generateSlug() -> String {
        let words = Lorem.words(3)
        let slug = words.replacingOccurrences(of: " ", with: "-").lowercased()
        return slug
    }
    
    func createSession(sessionName: String, userIds: [String]) {
        let session = Session(id: "_", name: sessionName, userIds: userIds)
        self.sessionService.createSession(session)
        
        self.coordinator.showSessionView()
    }
    
    func goToLobby() {
        self.coordinator.showLobbyView()
    }
    
    func signOut() {
        self.authService.signOut()
    }
}
