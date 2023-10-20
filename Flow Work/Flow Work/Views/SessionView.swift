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
                    HStack{
                        Text("\(viewModel.sessionState.currentSession!.name)")
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
                                    }
                                    .padding(.vertical, 2.5)
                                }
                                
                                Button(action: {
                                    if (!viewModel.todoState.draftTodo.title.isEmpty) {
                                        guard let currentUserId = self.viewModel.authState.currentUser?.id else { return }
                                        let draftTodo = Todo(title: viewModel.todoState.draftTodo.title, completed: viewModel.todoState.draftTodo.completed, userIds: [currentUserId])
                                        self.viewModel.storeService.addTodo(todo: draftTodo)
                                        let emptyTodo = Todo(title: "", completed: false)
                                        self.viewModel.todoService.updateDraftTodo(todo: emptyTodo)
                                        self.viewModel.todoState.isHoveringDeleteButtons.append(false)
                                    }
                                    focusedField = todoListCount + 1
                                }) {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "plus")
                                        Spacer()
                                    }
                                    .background(Color.clear)
                                    .padding(.vertical, 5)
                                }
                                .buttonStyle(.borderless)
                                .contentShape(Rectangle())
                                .background(viewModel.todoState.draftTodo.title.isEmpty ? Color.secondary.opacity(0.1) : !viewModel.todoState.isHoveringAddButton ? Color.secondary.opacity(0.25) : Color.secondary.opacity(0.4))
                                .cornerRadius(5)
                                .disabled(viewModel.todoState.draftTodo.title.isEmpty)
                                .onHover { isHovering in
                                    if (!viewModel.todoState.draftTodo.title.isEmpty) {
                                        viewModel.todoState.isHoveringAddButton = isHovering
                                    }
                                }
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
