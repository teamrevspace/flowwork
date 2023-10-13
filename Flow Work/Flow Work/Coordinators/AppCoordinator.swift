//
//  AppCoordinator.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import Combine
import Swinject
import SwiftUI

enum NavigationEvent {
    case Home
    case Login
    case Lobby
    case Session
}

class AppCoordinator: ObservableObject {
    @Published var currentView: AnyView
    
    @Published var authService: AuthServiceProtocol
    @Published var sessionService: SessionServiceProtocol
    @Published var storeService: StoreServiceProtocol
    @Published var errorService: ErrorServiceProtocol
    
    @Published var loginViewModel: LoginViewModel
    @Published var homeViewModel: HomeViewModel
    @Published var sessionViewModel: SessionViewModel
    @Published var lobbyViewModel: LobbyViewModel
    
    private let resolver: Resolver
    
    private let navigationSubject = PassthroughSubject<NavigationEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.resolver = resolver
        
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.errorService = resolver.resolve(ErrorServiceProtocol.self)!
        
        self.loginViewModel = resolver.resolve(LoginViewModel.self)!
        self.homeViewModel = resolver.resolve(HomeViewModel.self)!
        self.sessionViewModel = resolver.resolve(SessionViewModel.self)!
        self.lobbyViewModel = resolver.resolve(LobbyViewModel.self)!
        
        self.currentView = AnyView(EmptyView())
        
        self.setupNavigation()
        self.setupDelegates()
    }
    
    func navigate(to event: NavigationEvent) {
        navigationSubject.send(event)
    }
    
    private func setupNavigation() {
        self.currentView = AnyView(LoginView(viewModel: self.loginViewModel))
        
        navigationSubject
            .sink { event in
                switch event {
                case .Home:
                    self.currentView = AnyView(HomeView(viewModel: self.homeViewModel))
                case .Login:
                    self.currentView = AnyView(LoginView(viewModel: self.loginViewModel))
                case .Lobby:
                    self.currentView = AnyView(LobbyView(viewModel: self.lobbyViewModel))
                case .Session:
                    self.currentView = AnyView(SessionView(viewModel: self.sessionViewModel))
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupDelegates() {
        authService.delegate = self
        sessionService.delegate = self
        homeViewModel.delegate = self
        sessionViewModel.delegate = self
        lobbyViewModel.delegate = self
    }
}

extension AppCoordinator: AuthServiceDelegate {
    func didSignIn() {
        navigate(to: .Home)
    }
    
    func didSignOut() {
        navigate(to: .Login)
    }
}

extension AppCoordinator: SessionServiceDelegate {
    func didJoinSession(_ sessionId: String) {}
    
    func sessionNotFound() {
        navigate(to: .Lobby)
    }
}

extension AppCoordinator: HomeViewModelDelegate, LobbyViewModelDelegate, SessionViewModelDelegate {
    func showSessionView() {
        navigate(to: .Session)
    }
    
    func showLobbyView() {
        navigate(to: .Lobby)
    }
    
    func showHomeView() {
        navigate(to: .Home)
    }
}
