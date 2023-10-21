//
//  TodoService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/17/23.
//

import Foundation
import Swinject
import Combine

struct TodoState {
    var todoItems: [Todo] = []
    var draftTodo: Todo = Todo()
    var isTodoListInitialized: Bool = false
    var isHoveringAddButton: Bool = false
    var isHoveringDeleteButtons: [Bool] = []
    var isEditingTextField: [Bool] = []
}

class TodoService: TodoServiceProtocol, ObservableObject {
    @Published private var state = TodoState()
    
    @Published var storeService: StoreServiceProtocol
    @Published var authService: AuthServiceProtocol
    
    @Published var delayedTasks: [DispatchWorkItem?] = []
    
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
        self.state.todoItems = todos.filter({!$0.completed}).sorted(by: { $1.updatedAt.seconds > $0.updatedAt.seconds })
        
        self.state.isHoveringDeleteButtons = todos.map({_ in false})
        self.state.isHoveringDeleteButtons.append(false)
        
        self.state.isEditingTextField = todos.map({_ in false})
        
        self.delayedTasks = todos.map({_ in nil})
        self.delayedTasks.append(nil)
        
        self.state.isTodoListInitialized = true
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
    
    func checkTodoCompleted(index: Int, completed: Bool) {
        self.delayedTasks[index]?.cancel()
        if completed {
            let task = DispatchWorkItem {
                if (index >= self.state.todoItems.count) {
                    self.state.draftTodo.completed = completed
                    return
                }
                var updatedTodo = self.state.todoItems[index]
                updatedTodo.completed = completed
                self.storeService.updateTodoByTodoId(updatedTodo: updatedTodo)
            }
            self.delayedTasks[index] = task
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: task)
        }
    }
    
}
