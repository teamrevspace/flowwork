//
//  TodoServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/19/23.
//

import Foundation
import Combine

protocol TodoServiceProtocol {
    var todoStatePublisher: AnyPublisher<TodoState, Never> { get }
    var categoryStatePublisher: AnyPublisher<CategoryState, Never> { get }
    
    func initTodoList(todos: [Todo])
    func sanitizeTodoItems()
    func updateDraftTodo(todo: Todo)
    
    func initCategoryList(categories: [Category])
    func sanitizeCategoryItems()
    func updateDraftCategory(category: Category)
    func selectCategory(category: Category?)
}
