//
//  TodoItem.swift
//  Flow Work
//
//  Created by Allen Lin on 10/21/23.
//

import SwiftUI
import Combine

struct TodoItem: View {
    @ObservedObject var viewModel: SessionViewModel
    
    @Binding var todo: Todo
    var isEditingDraft: Bool?
    var isHoveringAction: Bool
    var onAdd: (() -> Void)?
    var onHoverAction: (Bool) -> Void
    var showActionButton: Bool
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            if (todo.id != nil) {
                Toggle("", isOn: Binding(
                    get: { todo.completed },
                    set: { newValue in
                        withAnimation {
                            todo.completed = newValue
                            viewModel.checkTodoCompleted(todo: todo, completed: newValue)
                        }
                    }
                ))
                .padding(1.5)
                .labelsHidden()
            } else {
                Button(action: {
                    isEditing = false
                    withAnimation {
                        onAdd?()
                    }
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .padding(1.5)
                    }
                    .background(Color.clear)
                }
                .buttonStyle(.borderless)
                .contentShape(Rectangle())
                .foregroundColor((isEditingDraft ?? false) ? Color.white : Color("Primary").opacity(0.5))
                .background(isHoveringAction && (isEditingDraft ?? false) ? Color.blue : (isEditingDraft ?? false) ? Color.blue.opacity(0.75) : Color.clear)
                .cornerRadius(5)
                .onHover { isHovering in
                    onHoverAction(isHovering)
                }
            }
            
            TextField("Add new to-do here", text: $todo.title, axis: .vertical)
                .lineLimit(todo.id == nil ? 3 : nil)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(todo.completed ? Color("Primary").opacity(0.5) : Color("Primary"))
                .frame(maxWidth: .infinity)
                .onChange(of: todo.title) { _ in
                    if (todo.id != nil) {
                        isEditing = true
                    }
                }
                .onReceive(Just(todo.title)) { _ in
                    if (isEditing) {
                        viewModel.syncToCloud() {
                            viewModel.updateTodo(todo: todo)
                        }
                        isEditing = false
                    }
                }
                .onSubmit {
                    isEditing = false
                    withAnimation {
                        onAdd?()
                    }
                }
            
            if showActionButton && todo.id != nil {
                Button(action: {
                    isEditing = false
                    withAnimation {
                        viewModel.removeTodo(todoId: todo.id)
                    }
                }) {
                    Image(systemName: "xmark")
                        .padding(1.5)
                }
                .buttonStyle(.borderless)
                .foregroundColor(isHoveringAction ? Color.white : Color.secondary.opacity(0.75))
                .background(isHoveringAction ? Color.secondary.opacity(0.4) : Color.clear)
                .cornerRadius(5)
                .onHover { isHovering in
                    onHoverAction(isHovering)
                }
            }
        }
        .padding(.vertical, 2.5)
    }
}
