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
}

class HomeViewModel: ObservableObject {
    weak var delegate: HomeViewModelDelegate?
    
    @Published var authService: AuthServiceProtocol
    @Published var sessionService: SessionServiceProtocol
    @Published var todoService: TodoServiceProtocol
    @Published var storeService: StoreServiceProtocol
    @Published var errorService: ErrorServiceProtocol
    
    @Published var sessionState = SessionState()
    @Published var authState = AuthState()
    @Published var todoState = TodoState()
    
    @Published var showProfilePopover: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.todoService = resolver.resolve(TodoServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.errorService = resolver.resolve(ErrorServiceProtocol.self)!
        
        sessionService.statePublisher
            .assign(to: \.sessionState, on: self)
            .store(in: &cancellables)
        authService.statePublisher
            .assign(to: \.authState, on: self)
            .store(in: &cancellables)
        todoService.statePublisher
            .assign(to: \.todoState, on: self)
            .store(in: &cancellables)
    }
    
    func fetchTodoList() {
        guard let currentUserId = self.authState.currentUser?.id else { return }
        self.storeService.findTodosByUserId(userId: currentUserId) { todos in
            self.todoService.initTodoList(todos: todos)
        }
    }
    
    func goToLobby() {
        self.delegate?.showLobbyView()
    }
    
    func signInWithGoogle() {
        self.authService.signInWithGoogle()
    }
    
    func signOut() {
        self.showProfilePopover.toggle()
        self.authService.signOut()
    }
}
