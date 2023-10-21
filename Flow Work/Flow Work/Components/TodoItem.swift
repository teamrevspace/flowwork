//
//  TodoItem.swift
//  Flow Work
//
//  Created by Allen Lin on 10/21/23.
//

import Foundation
import SwiftUI

struct TodoItem: View {
    @Binding var todo: Todo
    var isEditing: Bool
    var isHoveringAction: Bool
    var onCheck: (Bool) -> Void
    var onChange: ((String) -> Void)?
    var onSubmit: () -> Void
    var onDelete: () -> Void
    var onAdd: () -> Void
    var onHoverAction: (Bool) -> Void
    var showActionButton: Bool
    
    var body: some View {
        HStack {
            Toggle("", isOn: $todo.completed)
                .onChange(of: todo.completed) { value in
                    onCheck(value)
                }
                .labelsHidden()
            
            TextField("Add new to-do here", text: $todo.title)
                .lineLimit(1)
                .truncationMode(.tail)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(todo.completed ? Color.primary.opacity(0.5) : Color.primary)
                .frame(maxWidth: .infinity)
                .onChange(of: todo.title) { newValue in
                    onChange?(newValue)
                }
                .onSubmit {
                    onSubmit()
                }
            
            if showActionButton {
                if isEditing {
                    Button(action: {
                        onAdd()
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .padding(1.5)
                        }
                        .background(Color.clear)
                    }
                    .buttonStyle(.borderless)
                    .contentShape(Rectangle())
                    .foregroundColor(isHoveringAction ? Color.white : isEditing ? Color.white.opacity(0.75) : Color.secondary.opacity(0.5))
                    .background(isHoveringAction ? (isEditing ? Color.blue : Color.secondary.opacity(0.4) ) : isEditing ? Color.blue.opacity(0.75) : Color.clear)
                    .cornerRadius(5)
                    .onHover { isHovering in
                        onHoverAction(isHovering)
                    }
                } else {
                    Button(action: {
                        onDelete()
                    }) {
                        Image(systemName: "xmark")
                            .padding(1.5)
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(isHoveringAction ? Color.white : Color.secondary.opacity(0.5))
                    .background(isHoveringAction ? Color.secondary.opacity(0.4) : Color.clear)
                    .cornerRadius(5)
                    .onHover { isHovering in
                        onHoverAction(isHovering)
                    }
                }
            }
        }
        .padding(.vertical, 2.5)
    }
}
