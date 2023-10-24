//
//  TodoItem.swift
//  Flow Work
//
//  Created by Allen Lin on 10/21/23.
//

import SwiftUI
import Combine

struct TodoItem: View {
    @Binding var todo: Todo
    var isEditingDraft: Bool?
    var isHoveringAction: Bool
    var onCheck: (Bool) -> Void
    var onAdd: (() -> Void)?
    var onUpdate: (() -> Void)?
    var onDelete: (() -> Void)?
    var onHoverAction: (Bool) -> Void
    var showActionButton: Bool
    
    @State private var isEditing: Bool = false
    
    private let savePublisher = PassthroughSubject<Void, Never>()
    private let throttleSavePublisher = PassthroughSubject<Void, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    init(todo: Binding<Todo>,
         isEditingDraft: Bool = false,
         isHoveringAction: Bool = false,
         onCheck: @escaping (Bool) -> Void,
         onAdd: (() -> Void)? = nil,
         onUpdate: (() -> Void)? = nil,
         onDelete: (() -> Void)? = nil,
         onHoverAction: @escaping (Bool) -> Void,
         showActionButton: Bool) {
        
        self._todo = todo
        self.isEditingDraft = isEditingDraft
        self.isHoveringAction = isHoveringAction
        self.onCheck = onCheck
        self.onAdd = onAdd
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        self.onHoverAction = onHoverAction
        self.showActionButton = showActionButton
        
        savePublisher
            .debounce(for: 0.25, scheduler: DispatchQueue.main)
            .sink { _ in
                onUpdate?()
            }
            .store(in: &cancellables)
    }
    
    var body: some View {
        HStack {
            if (todo.id != nil) {
                Toggle("", isOn: $todo.completed)
                    .onChange(of: todo.completed) { value in
                        withAnimation {
                            onCheck(value)
                        }
                    }
                    .padding(1.5)
                    .labelsHidden()
            } else {
                Button(action: {
                    onUpdate?()
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
            
            TextField("Add new to-do here", text: $todo.title)
                .lineLimit(1)
                .truncationMode(.tail)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(todo.completed ? Color("Primary").opacity(0.5) : Color("Primary"))
                .frame(maxWidth: .infinity)
                .onChange(of: todo.title) { _ in
                    isEditing = true
                }
                .onReceive(Just(todo.title)) { _ in
                    if (isEditing) {
                        savePublisher.send(())
                        isEditing = false
                    }
                }
                .onSubmit {
                    isEditing = false
                    withAnimation {
                        onAdd?()
                        onUpdate?()
                    }
                }
            
            if showActionButton && todo.id != nil {
                Button(action: {
                    isEditing = false
                    withAnimation {
                        onDelete?()
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
