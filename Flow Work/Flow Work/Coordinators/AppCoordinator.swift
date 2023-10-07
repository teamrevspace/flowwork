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
    @Published var errorPublisher: ErrorPublisher
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let authManager = AuthManager()
        let errorPublisher = ErrorPublisher()
        let loginViewModel = LoginViewModel(authManager: authManager)
        
        self.authManager = authManager
        self.webSocketManager = WebSocketManager(url: URL(string: "ws://flowwork.fly.dev/session/websocket")!)
        self.errorPublisher = errorPublisher
        self.currentView = AnyView(LoginView(viewModel: loginViewModel, errorPublisher: errorPublisher))
        
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
        let homeViewModel = HomeViewModel(authManager: authManager, webSocketManager: webSocketManager, appCoordinator: self)
        let homeView = HomeView(viewModel: homeViewModel, errorPublisher: errorPublisher)
        currentView = AnyView(homeView)
    }
    
    func showLoginView() {
        let loginViewModel = LoginViewModel(authManager: authManager)
        let loginView = LoginView(viewModel: loginViewModel, errorPublisher: errorPublisher)
        currentView = AnyView(loginView)
    }
    
    func showJoinSessionView() {
        let joinSessionViewModel = JoinSessionViewModel(webSocketManager: webSocketManager, errorPublisher: errorPublisher, appCoordinator: self)
        let joinSessionView = JoinSessionView(viewModel: joinSessionViewModel, errorPublisher: errorPublisher)
        currentView = AnyView(joinSessionView)
    }
    
    func showSessionView() {
        let sessionViewModel = SessionViewModel(authManager: authManager, webSocketManager: webSocketManager, appCoordinator: self)
        let sessionView = SessionView(viewModel: sessionViewModel, errorPublisher: errorPublisher)
        currentView = AnyView(sessionView)
    }
    
    func isSignedIn() -> Bool {
        return authManager.isSignedIn
    }
    
}
