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
    case Lobby
    case Session
    case Settings
    case Profile
}

class AppCoordinator: ObservableObject {
    @Published var currentView: AnyView
    
    @Published var authService: AuthServiceProtocol
    @Published var todoService: TodoServiceProtocol
    @Published var sessionService: SessionServiceProtocol
    @Published var storeService: StoreServiceProtocol
    @Published var apiService: APIServiceProtocol
    
    @Published var homeViewModel: HomeViewModel
    @Published var sessionViewModel: SessionViewModel
    @Published var lobbyViewModel: LobbyViewModel
    @Published var settingsViewModel: SettingsViewModel
    @Published var profileViewModel: ProfileViewModel
    
    @Published var authState = AuthState()
    @Published var sessionState = SessionState()
    
    private let resolver: Resolver
    private var appDelegate = NSApplication.shared.delegate as? AppDelegate
    
    private let navigationSubject = PassthroughSubject<NavigationEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.resolver = resolver
        
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.todoService = resolver.resolve(TodoServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.apiService = resolver.resolve(APIServiceProtocol.self)!
        
        self.homeViewModel = resolver.resolve(HomeViewModel.self)!
        self.sessionViewModel = resolver.resolve(SessionViewModel.self)!
        self.lobbyViewModel = resolver.resolve(LobbyViewModel.self)!
        self.settingsViewModel = resolver.resolve(SettingsViewModel.self)!
        self.profileViewModel = resolver.resolve(ProfileViewModel.self)!
        
        self.currentView = AnyView(EmptyView())
        
        self.setupNavigation()
        self.setupDelegates()
        
        authService.statePublisher
            .assign(to: \.authState, on: self)
            .store(in: &cancellables)
        sessionService.statePublisher
            .assign(to: \.sessionState, on: self)
            .store(in: &cancellables)
    }
    
    func navigate(to event: NavigationEvent) {
        navigationSubject.send(event)
    }
    
    private func setupNavigation() {
        self.currentView = AnyView(HomeView(viewModel: self.homeViewModel))
        
        navigationSubject
            .sink { event in
                switch event {
                case .Home:
                    self.currentView = AnyView(HomeView(viewModel: self.homeViewModel))
                case .Lobby:
                    self.currentView = AnyView(LobbyView(viewModel: self.lobbyViewModel))
                case .Session:
                    self.currentView = AnyView(SessionView(viewModel: self.sessionViewModel))
                case .Settings:
                    self.currentView = AnyView(SettingsView(viewModel: self.settingsViewModel))
                case .Profile:
                    self.currentView = AnyView(ProfileView(viewModel: self.profileViewModel))
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
        settingsViewModel.delegate = self
        profileViewModel.delegate = self
    }
}

extension AppCoordinator: AuthServiceDelegate {
    func didSignIn() {
        navigate(to: .Home)
    }
    
    func didSignOut() {
        navigate(to: .Home)
        self.sessionService.disconnect()
    }
    
    func redirectToApp() {
        self.appDelegate?.openMenuPopover()
    }
}

extension AppCoordinator: SessionServiceDelegate {
    func didJoinSession(_ sessionId: String) {
        guard let userId = self.authState.currentUser?.id else {
            navigate(to: .Home)
            return
        }
        self.storeService.addUserToSession(userId: userId, sessionId: sessionId)
        navigate(to: .Session)
    }
    
    func sessionNotFound() {
        navigate(to: .Lobby)
    }
    
    func didUpdateLobby(_ userIds: [String], completion: @escaping ([User]) -> Void) {
        self.storeService.findUsersByUserIds(userIds: userIds) { users in
            completion(users)
        }
    }
}

extension AppCoordinator: HomeViewModelDelegate, LobbyViewModelDelegate, SessionViewModelDelegate, SettingsViewModelDelegate, ProfileViewModelDelegate {
    func showSessionView() {
        navigate(to: .Session)
    }
    
    func showLobbyView() {
        navigate(to: .Lobby)
    }
    
    func showHomeView() {
        navigate(to: .Home)
    }
    
    func showSettingsView() {
        navigate(to: .Settings)
    }
    
    func showProfileView() {
        navigate(to: .Profile)
    }
}
