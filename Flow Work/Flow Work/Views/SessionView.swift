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
        VStack{
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
                                                print(value)
                                                // TODO: mark item as completed
                                            }
                                            .labelsHidden()
                                        
                                        TextField("Add new to-do here", text: $viewModel.todoState.todoItems[index].title)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .focused($focusedField, equals: index)
                                            .frame(maxWidth: .infinity)
                                        
                                        if (!viewModel.todoState.todoItems[index].title.isEmpty) {
                                            Button(action: {
                                                viewModel.storeService.removeTodo(todoId: viewModel.todoState.todoItems[index].id!)
                                            }) {
                                                Image(systemName: "xmark")
                                                    .padding(2)
                                            }
                                            .buttonStyle(.borderless)
                                            .foregroundColor(viewModel.todoState.isHoveringDeleteButtons[index] ? Color.secondary : Color.secondary.opacity(0.5))
                                            .background(viewModel.todoState.isHoveringDeleteButtons[index] ? Color.secondary.opacity(0.25) : Color.clear)
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
                                            print(value)
                                            // TODO: mark item as completed
                                            focusedField = todoListCount + 1
                                        }
                                        .labelsHidden()
                                    
                                    TextField("Add new to-do here", text: $viewModel.todoState.draftTodo.title)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .focused($focusedField, equals: todoListCount + 1)
                                        .frame(maxWidth: .infinity)
                                    
                                    if (!viewModel.todoState.draftTodo.title.isEmpty) {
                                        Button(action: {
                                            if (!viewModel.todoState.draftTodo.title.isEmpty) {
                                                guard let currentUserId = self.viewModel.authState.currentUser?.id else { return }
                                                var draftTodo = viewModel.todoState.draftTodo
                                                draftTodo.userIds = [currentUserId]
                                                self.viewModel.storeService.addTodo(todo: draftTodo)
                                                self.viewModel.todoService.updateDraftTodo(todo: Todo())
                                                self.viewModel.todoState.isHoveringDeleteButtons.append(false)
                                            }
                                            focusedField = todoListCount + 1
                                        }) {
                                            HStack {
                                                Image(systemName: "plus")
                                                    .padding(2)
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
                .padding()
                .standardFrame()
                .errorOverlay(errorService: viewModel.errorService)
                .onAppear() {
                    viewModel.fetchTodoList()
                }
                .onDisappear() {
                    viewModel.todoState.isTodoListInitialized = false
                }
            }
        }
    }
}
