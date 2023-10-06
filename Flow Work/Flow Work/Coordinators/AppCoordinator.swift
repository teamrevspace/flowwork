//
//  AppCoordinator.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import SwiftUI
import Combine

class AppCoordinator: ObservableObject {
    @Published var currentView: AnyView
    @Published var authManager: AuthManager
    @Published var webSocketManager: WebSocketManager
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let authManager = AuthManager()
        let webSocketManager = WebSocketManager(url: URL(string: "ws://localhost:4000/session/websocket")!)
        let loginViewModel = LoginViewModel(authManager: authManager)
        
        self.authManager = authManager
        self.webSocketManager = webSocketManager
        self.currentView = AnyView(LoginView(viewModel: loginViewModel))
        
        authManager.$isSignedIn
            .sink { [weak self] isSignedIn in
                if isSignedIn {
                    self?.showHomeView()
                } else {
                    self?.showLoginView()
                }
            }
            .store(in: &cancellables)
    }
    
    func showHomeView() {
        let homeViewModel = HomeViewModel(authManager: authManager, webSocketManager: webSocketManager)
        let homeView = HomeView(viewModel: homeViewModel)
        currentView = AnyView(homeView)
    }
    
    func showLoginView() {
        let loginViewModel = LoginViewModel(authManager: authManager)
        let loginView = LoginView(viewModel: loginViewModel)
        currentView = AnyView(loginView)
    }
    
    func isSignedIn() -> Bool {
        return authManager.isSignedIn
    }
    
}
