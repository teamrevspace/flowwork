//
//  SessionView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct SessionView: View {
    @ObservedObject var viewModel: SessionViewModel
    @FocusState private var focusedField: Int?
    
    var body: some View {
        VStack {
            if viewModel.sessionState.currentSession == nil {
                VStack(spacing: 10) {
                    ProgressView()
                    Button(action: {
                        viewModel.leaveSession()
                    }) {
                        HStack {
                            Text("Back")
                        }
                    }
                }
            } else {
                VStack {
                    HStack(spacing: 10) {
                        Text("\(viewModel.sessionState.currentSession!.name)")
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                        Button(action: {
                            viewModel.copyToClipboard(textToCopy: "https://flowwork.xyz/s/\(viewModel.sessionState.currentSession!.id)")
                        }) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Invite Link")
                        }
                    }
                    Group {
                        if (viewModel.todoState.isTodoListInitialized) {
                            VStack(alignment: .leading) {
                                let todoListCount = viewModel.todoState.todoItems.count
                                ForEach(0..<viewModel.todoState.todoItems.count, id: \.self) { index in
                                    HStack {
                                        Toggle("", isOn: $viewModel.todoState.todoItems[index].completed)
                                            .onChange(of: viewModel.todoState.todoItems[index].completed) { value in
                                                viewModel.todoService.checkTodoCompleted(index: index, completed: value)
                                            }
                                            .labelsHidden()
                                        
                                        TextField("Add new to-do here", text: $viewModel.todoState.todoItems[index].title)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .foregroundColor(viewModel.todoState.todoItems[index].completed ? Color.primary.opacity(0.5) : Color.primary)
                                            .focused($focusedField, equals: index)
                                            .frame(maxWidth: .infinity)
                                            .onChange(of: viewModel.todoState.todoItems[index].title) { newValue in
                                                viewModel.todoState.isEditingTextField[index] = !newValue.isEmpty
                                            }
                                            .onSubmit {
                                                if (viewModel.todoState.isEditingTextField[index]) {
                                                    viewModel.storeService.updateTodoByTodoId(updatedTodo: viewModel.todoState.todoItems[index])
                                                    viewModel.todoState.isEditingTextField[index] = false
                                                }
                                                focusedField = index + 1
                                            }
                                        
                                        if (!viewModel.todoState.todoItems[index].completed) {
                                            Button(action: {
                                                if (viewModel.todoState.isEditingTextField[index]) {
                                                    viewModel.storeService.updateTodoByTodoId(updatedTodo: viewModel.todoState.todoItems[index])
                                                    viewModel.todoState.isEditingTextField[index] = false
                                                } else {
                                                    viewModel.storeService.removeTodo(todoId: viewModel.todoState.todoItems[index].id!)
                                                }
                                            }) {
                                                Image(systemName: viewModel.todoState.isEditingTextField[index] ? "checkmark" : "xmark")
                                                    .padding(1.5)
                                            }
                                            .buttonStyle(.borderless)
                                            .foregroundColor(viewModel.todoState.isHoveringDeleteButtons[index] ? Color.secondary : viewModel.todoState.isEditingTextField[index] ? Color.secondary.opacity(0.75) : Color.secondary.opacity(0.5))
                                            .background(viewModel.todoState.isHoveringDeleteButtons[index] ? Color.secondary.opacity(0.4) : viewModel.todoState.isEditingTextField[index] ? Color.secondary.opacity(0.25) : Color.clear)
                                            .cornerRadius(5)
                                            .onHover { isHovering in
                                                viewModel.todoState.isHoveringDeleteButtons[index] = isHovering
                                            }
                                        }
                                    }
                                    .padding(.vertical, 2.5)
                                }
                                
                                HStack {
                                    Toggle("", isOn: $viewModel.todoState.draftTodo.completed)
                                        .onChange(of: viewModel.todoState.draftTodo.completed) { value in
                                            viewModel.todoService.checkTodoCompleted(index: todoListCount, completed: value)
                                        }
                                        .labelsHidden()
                                    
                                    TextField("Add new to-do here", text: $viewModel.todoState.draftTodo.title)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .foregroundColor(viewModel.todoState.draftTodo.completed ? Color.primary.opacity(0.5) : Color.primary)
                                        .focused($focusedField, equals: todoListCount)
                                        .frame(maxWidth: .infinity)
                                        .onSubmit {
                                            viewModel.addDraftTodo()
                                            focusedField = todoListCount
                                        }
                                    
                                    if (!viewModel.todoState.draftTodo.title.isEmpty && !viewModel.todoState.draftTodo.completed) {
                                        Button(action: {
                                            viewModel.addDraftTodo()
                                            focusedField = todoListCount
                                        }) {
                                            HStack {
                                                Image(systemName: "plus")
                                                    .padding(1.5)
                                            }
                                            .background(Color.clear)
                                        }
                                        .buttonStyle(.borderless)
                                        .contentShape(Rectangle())
                                        .foregroundColor(viewModel.todoState.isHoveringAddButton ? Color.secondary : Color.secondary.opacity(0.75))
                                        .background(viewModel.todoState.isHoveringAddButton ? Color.secondary.opacity(0.4) : Color.secondary.opacity(0.25))
                                        .cornerRadius(5)
                                        .disabled(viewModel.todoState.draftTodo.title.isEmpty)
                                        .onHover { isHovering in
                                            if (!viewModel.todoState.draftTodo.title.isEmpty) {
                                                viewModel.todoState.isHoveringAddButton = isHovering
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 2.5)
                                
                                Spacer()
                            }
                        } else {
                            VStack {
                                ProgressView()
                            }
                            .padding(.vertical, 10)
                        }
                        
                        HStack {
                            ForEach(viewModel.sessionState.currentSessionUsers ?? []) { user in
                                AvatarView(avatarURL: user.avatarURL)
                            }
                            Spacer()
                            Button(action: {
                                viewModel.leaveSession()
                            }) {
                                Text("Leave Session")
                            }
                        }
                    }
                }
                .onAppear() {
                    viewModel.fetchTodoList()
                }
                .onDisappear() {
                    viewModel.todoState.isTodoListInitialized = false
                }
            }
        }
        .padding()
        .standardFrame()
        .errorOverlay(errorService: viewModel.errorService)
    }
}
