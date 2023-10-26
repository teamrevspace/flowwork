//
//  TodoService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/17/23.
//

import Foundation
import Swinject
import Combine
import Firebase

class TodoService: TodoServiceProtocol, ObservableObject {
    @Published private var state = TodoState()
    
    @Published var storeService: StoreServiceProtocol
    @Published var authService: AuthServiceProtocol
    
    private let resolver: Resolver
    
    var statePublisher: AnyPublisher<TodoState, Never> {
        $state.eraseToAnyPublisher()
    }
    
    init(resolver: Resolver) {
        self.resolver = resolver
        
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
    }
    
    func initTodoList(todos: [Todo]) {
        let todoList = todos.filter({!$0.completed}).sorted(by: { $1.createdAt.seconds > $0.createdAt.seconds })
        self.state.todoItems = todoList
        self.resetTodoList(todos: todoList)
        self.state.isTodoListInitialized = true
    }
    
    private func resetTodoList(todos: [Todo]) {
        self.state.isHoveringActionButtons = Array(repeating: false, count: todos.count + 1)
    }
    
    func sanitizeTodoItems() {
        if (self.state.todoItems.count > 1) {
            self.state.todoItems = self.state.todoItems.enumerated().filter { (index, item) in
                return !item.title.isEmpty
            }.map { $0.element }
        }
    }
    
    func updateDraftTodo(todo: Todo) {
        self.state.draftTodo = todo
    }
}
