//
//  SessionViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import Combine
import Swinject
import AppKit

protocol SessionViewModelDelegate: AnyObject {
    func showLobbyView()
}

class SessionViewModel: ObservableObject {
    weak var delegate: SessionViewModelDelegate?
    
    @Published var authService: AuthServiceProtocol
    @Published var sessionService: SessionServiceProtocol
    @Published var roomService: RoomServiceProtocol
    @Published var storeService: StoreServiceProtocol
    @Published var todoService: TodoServiceProtocol
    @Published var networkService: NetworkServiceProtocol
    
    @Published var authState = AuthState()
    @Published var sessionState = SessionState()
    @Published var todoState = TodoState()
    
    private let resolver: Resolver
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.roomService = resolver.resolve(RoomServiceProtocol.self)!
        self.todoService = resolver.resolve(TodoServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.networkService = resolver.resolve(NetworkServiceProtocol.self)!
        
        authService.statePublisher
            .assign(to: \.authState, on: self)
            .store(in: &cancellables)
        sessionService.statePublisher
            .assign(to: \.sessionState, on: self)
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
    
    func copyToClipboard(textToCopy: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(textToCopy, forType: .string)
    }
    
    func addDraftTodo() {
        if (!self.todoState.draftTodo.title.isEmpty) {
            guard let currentUserId = self.authState.currentUser?.id else { return }
            var newTodo = self.todoState.draftTodo
            newTodo.userIds = [currentUserId]
            self.storeService.addTodo(todo: newTodo)
            self.todoService.updateDraftTodo(todo: Todo())
            self.todoState.isHoveringActionButtons.append(false)
        }
    }
    
    func leaveSession() {
        if let currentSessionId = self.sessionState.currentSession?.id {
            self.sessionService.leaveSession(currentSessionId)
        }
        self.delegate?.showLobbyView()
    }
    
    func createAudioRoom() {
        guard let roomId = self.sessionState.currentSession?.id else {
            print("No room Id available.")
            return
        }
        
        roomService.createRoom(roomId: roomId)
    }
    
    func joinAudioRoom() {
        guard let roomId = self.sessionState.currentSession?.id else {
            print("No room Id available.")
            return
        }
        
        roomService.joinRoom(roomId: roomId)
    }
}
