//
//  TodoState.swift
//  Flow Work
//
//  Created by Allen Lin on 10/21/23.
//

struct TodoState {
    var todoItems: [Todo] = []
    var draftTodo: Todo = Todo()
    var isTodoListInitialized: Bool = false
    var isHoveringAddButton: Bool = false
    var isHoveringActionButtons: [Bool] = []
}
