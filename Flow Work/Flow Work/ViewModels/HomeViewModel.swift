//
//  HomeViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Combine
import Swinject

protocol HomeViewModelDelegate: AnyObject {
    func showSessionView()
    func showLobbyView()
    func showSettingsView()
    func showProfileView()
}

class HomeViewModel: ObservableObject {
    weak var delegate: HomeViewModelDelegate?
    
    @Published var authService: AuthServiceProtocol
    @Published var sessionService: SessionServiceProtocol
    @Published var storeService: StoreServiceProtocol
    @Published var networkService: NetworkServiceProtocol
    
    @Published var sessionState = SessionState()
    @Published var authState = AuthState()
    
    @Published var hoverIndex: Int? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.networkService = resolver.resolve(NetworkServiceProtocol.self)!
        
        sessionService.statePublisher
            .assign(to: \.sessionState, on: self)
            .store(in: &cancellables)
        authService.statePublisher
            .assign(to: \.authState, on: self)
            .store(in: &cancellables)
    }
    
    func goToSettings() {
        self.delegate?.showSettingsView()
    }
    
    func goToLobby() {
        self.delegate?.showLobbyView()
    }
    
    func signInWithGoogle() {
        self.authService.signInWithGoogle()
    }
    
    func signOut() {
        self.authService.signOut()
    }
    
    func goToProfile() {
        self.delegate?.showProfileView()
    }
}
