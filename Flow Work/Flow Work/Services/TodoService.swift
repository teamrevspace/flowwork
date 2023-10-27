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
    @Published private var todoState = TodoState()
    @Published private var categoryState = CategoryState()
    
    @Published var authState = AuthState()
    @Published var storeService: StoreServiceProtocol
    @Published var authService: AuthServiceProtocol
    
    private let resolver: Resolver
    private var cancellables = Set<AnyCancellable>()
    
    var todoStatePublisher: AnyPublisher<TodoState, Never> {
        $todoState.eraseToAnyPublisher()
    }
    var categoryStatePublisher: AnyPublisher<CategoryState, Never> {
        $categoryState.eraseToAnyPublisher()
    }
    
    init(resolver: Resolver) {
        self.resolver = resolver
        
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        
        authService.statePublisher
            .assign(to: \.authState, on: self)
            .store(in: &cancellables)
    }
    
    func initTodoList(todos: [Todo]) {
        let todoList = todos.filter({!$0.completed}).sorted(by: { $1.createdAt.seconds > $0.createdAt.seconds })
        DispatchQueue.main.async {
            self.todoState.todoItems = todoList
            self.todoState.isTodoListInitialized = true
            self.todoState.isHoveringActionButtons = Array(repeating: false, count: todoList.count + 1)
        }
    }
    
    func sanitizeTodoItems() {
        if (self.todoState.todoItems.count > 1) {
            DispatchQueue.main.async {
                self.todoState.todoItems = self.todoState.todoItems.enumerated().filter { (index, item) in
                    return !item.title.isEmpty
                }.map { $0.element }
            }
        }
    }
    
    func updateDraftTodo(todo: Todo) {
        DispatchQueue.main.async {
            self.todoState.draftTodo = todo
        }
    }
    
    func initCategoryList(categories: [Category]) {
        let categoryList = categories.sorted(by: { $1.createdAt.seconds > $0.createdAt.seconds })
        DispatchQueue.main.async {
            self.categoryState.categoryItems = categoryList
            self.categoryState.isCategoryListInitialized = true
        }
    }
    
    func sanitizeCategoryItems() {
        if (self.categoryState.categoryItems.count > 1) {
            DispatchQueue.main.async {
                self.categoryState.categoryItems = self.categoryState.categoryItems.enumerated().filter { (index, item) in
                    return !item.title.isEmpty
                }.map { $0.element }
            }
        }
    }
    
    func updateDraftCategory(category: Category) {
        DispatchQueue.main.async {
            self.categoryState.draftCategory = category
        }
    }
    
    func selectCategory(category: Category?) {
        guard let currentUserId = self.authState.currentUser?.id else { return }
        DispatchQueue.main.async {
            self.categoryState.selectedCategory = category ?? Category(id: currentUserId, title: "All")
        }
        
    }
}
