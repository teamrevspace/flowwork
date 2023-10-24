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
        let todoList = todos.filter({!$0.completed}).sorted(by: { $1.createdAt.seconds > $0.createdAt.seconds })
        self.state.todoItems = todoList
        self.resetTodoList(todos: todoList)
        self.state.isTodoListInitialized = true
    }
    
    private func resetTodoList(todos: [Todo]) {
        self.state.isHoveringActionButtons = todos.map({_ in false})
        self.state.isHoveringActionButtons.append(false)
        
        self.delayedTasks = todos.map({_ in nil})
        self.delayedTasks.append(nil)
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
    
    func checkTodoCompleted(index: Int, completed: Bool, completion: @escaping () -> Void) {
        self.delayedTasks[index]?.cancel()
        if completed {
            let task = DispatchWorkItem {
                if (index >= self.state.todoItems.count) {
                    self.state.draftTodo.completed = completed
                    return
                }
                var updatedTodo = self.state.todoItems[index]
                updatedTodo.completed = completed
                self.storeService.updateTodo(todo: updatedTodo)
            }
            self.delayedTasks[index] = task
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                task.perform()
                completion()
            }
        }
    }
    
}
