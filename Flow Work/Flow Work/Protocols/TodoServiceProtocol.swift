//
//  TodoServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/19/23.
//

import Foundation
import Combine

protocol TodoServiceProtocol {
    var statePublisher: AnyPublisher<TodoState, Never> { get }
    var delayedTasks: [DispatchWorkItem?] { get set }
    
    func initTodoList(todos: [Todo])
    func sanitizeTodoItems()
    func updateDraftTodo(todo: Todo)
    func checkTodoCompleted(index: Int, completed: Bool)
}
