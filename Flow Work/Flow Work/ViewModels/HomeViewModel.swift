//
//  HomeViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Combine
import LoremSwiftum
import Swinject

protocol HomeViewModelDelegate: AnyObject {
    func showSessionView()
    func showLobbyView()
}

class HomeViewModel: ObservableObject {
    weak var delegate: HomeViewModelDelegate?
    
    @Published var authService: AuthServiceProtocol
    @Published var sessionService: SessionServiceProtocol
    @Published var storeService: StoreServiceProtocol
    @Published var errorService: ErrorServiceProtocol
    
    @Published var sessionState = SessionState()
    @Published var authState = AuthState()
    
    private var cancellables = Set<AnyCancellable>()
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.errorService = resolver.resolve(ErrorServiceProtocol.self)!
        
        sessionService.statePublisher
            .assign(to: \.sessionState, on: self)
            .store(in: &cancellables)
        authService.statePublisher
            .assign(to: \.authState, on: self)
            .store(in: &cancellables)
    }
    
    func generateSlug() -> String {
        let words = Lorem.words(3)
        let slug = words.replacingOccurrences(of: " ", with: "-").lowercased()
        return slug
    }
    
    func createSession(sessionName: String, userIds: [String]) {
        let session = Session(id: "_", name: sessionName, userIds: userIds)
        self.sessionService.createSession(session)
        
        self.delegate?.showSessionView()
    }
    
    func goToLobby() {
        self.delegate?.showLobbyView()
    }
    
    func signOut() {
        self.authService.signOut()
    }
}
