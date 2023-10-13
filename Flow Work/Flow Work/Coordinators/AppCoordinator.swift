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
    }
    
    func showHomeView() {
        let homeView = HomeView(viewModel: homeViewModel)
        currentView = AnyView(homeView)
    }
    
    func showLoginView() {
        let loginView = LoginView(viewModel: loginViewModel)
        currentView = AnyView(loginView)
    }
    
    func showLobbyView() {
        let lobbyView = LobbyView(viewModel: lobbyViewModel)
        currentView = AnyView(lobbyView)
    }
    
    func showSessionView() {
        let sessionView = SessionView(viewModel: sessionViewModel)
        currentView = AnyView(sessionView)
    }
}

extension AppCoordinator: AuthServiceDelegate {
    func didSignIn() {
        showHomeView()
    }
    
    func didSignOut() {
        showLoginView()
    }
}

