//
//  SessionView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct SessionView: View {
    @ObservedObject var viewModel: SessionViewModel
    
    var body: some View {
        let todoListCount = viewModel.todoState.todoItems.count
        VStack {
            if (viewModel.sessionState.currentSession == nil || !viewModel.authState.isSignedIn) {
                VStack(spacing: 10) {
                    Spacer()
                    ProgressView()
                    Spacer()
                    Button(action: {
                        viewModel.leaveSession()
                    }) {
                        HStack {
                            Text("Back")
                        }
                    }
                }
                .padding()
                .standardFrame()
            } else {
                VStack {
                    HStack(spacing: 10) {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(viewModel.networkService.connected ? (viewModel.sessionState.isConnected ? .green : .yellow) : .gray)
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
//                    MARK: - WebRTC Audio Room
//                    VStack {
//                        HStack {
//                            Button(action: {
//                                viewModel.createAudioRoom()
//                            }) {
//                                Text("Create Audio Room")
//                            }
//                            .padding()
//                            Button(action: {
//                                viewModel.joinAudioRoom()
//                            }) {
//                                Text("Join Audio Room")
//                            }
//                            .padding()
//                        }
//                    }
                    Group {
                        if (viewModel.todoState.isTodoListInitialized) {
                            VStack(alignment: .leading) {
                                ForEach(0..<viewModel.todoState.todoItems.count, id: \.self) { index in
                                    TodoItem(
                                        todo: $viewModel.todoState.todoItems[index],
                                        isEditing: viewModel.todoState.isEditingTextField[index],
                                        isHoveringAction: viewModel.todoState.isHoveringActionButtons[index],
                                        onCheck: { value in
                                            viewModel.todoService.checkTodoCompleted(index: index, completed: value)
                                        },
                                        onChange: { newValue in
                                            viewModel.todoState.isEditingTextField[index] = !newValue.isEmpty
                                        },
                                        onSubmit: {
                                            if (viewModel.todoState.isEditingTextField[index]) {
                                                viewModel.storeService.updateTodoByTodoId(updatedTodo: viewModel.todoState.todoItems[index])
                                                viewModel.todoState.isEditingTextField[index] = false
                                            }
                                        },
                                        onDelete: {
                                            viewModel.storeService.removeTodo(todoId: viewModel.todoState.todoItems[index].id!)
                                        },
                                        onAdd: {
                                            viewModel.storeService.updateTodoByTodoId(updatedTodo: viewModel.todoState.todoItems[index])
                                        },
                                        onHoverAction: { isHovering in
                                            viewModel.todoState.isHoveringActionButtons[index] = isHovering
                                        },
                                        showActionButton: !viewModel.todoState.todoItems[index].completed
                                    )
                                }
                                
                                if (viewModel.todoState.todoItems.count < 10) {
                                    TodoItem(
                                        todo: $viewModel.todoState.draftTodo,
                                        isEditing: !viewModel.todoState.draftTodo.title.isEmpty,
                                        isHoveringAction: viewModel.todoState.isHoveringAddButton,
                                        onCheck: { value in
                                            viewModel.todoService.checkTodoCompleted(index: todoListCount, completed: value)
                                        },
                                        onSubmit: {
                                            viewModel.addDraftTodo()
                                        },
                                        onDelete: {
                                            viewModel.addDraftTodo()
                                        },
                                        onAdd: {
                                            viewModel.addDraftTodo()
                                        },
                                        onHoverAction: { isHovering in
                                            viewModel.todoState.isHoveringAddButton = isHovering
                                        },
                                        showActionButton: !viewModel.todoState.draftTodo.title.isEmpty && !viewModel.todoState.draftTodo.completed
                                    )
                                }
                                Spacer()
                            }
                        } else {
                            VStack {
                                Spacer()
                                ProgressView()
                                Spacer()
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
                .padding()
                .standardFrame()
                .onAppear() {
                    viewModel.fetchTodoList()
                }
                .onDisappear() {
                    viewModel.todoState.isTodoListInitialized = false
                    if (viewModel.authState.isSignedIn) {
                        viewModel.todoService.checkTodoCompleted(index: todoListCount, completed: false)
                    }
                }
            }
        }
    }
}
