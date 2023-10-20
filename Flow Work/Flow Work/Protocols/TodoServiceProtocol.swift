//
//  TodoServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/19/23.
//

import Combine

protocol TodoServiceProtocol {
    var statePublisher: AnyPublisher<TodoState, Never> { get }
    
    func sanitizeTodoItems()
    func updateDraftTodo(todo: Todo)
}
