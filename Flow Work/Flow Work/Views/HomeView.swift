//
//  HomeView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        let todoListCount = viewModel.todoState.todoItems.count
        VStack {
            HStack {
                HStack {
                    Image("FlowWorkLogo")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                    Text("Flow Work")
                        .font(.title)
                        .fontWeight(.bold)
                }
                if (viewModel.authState.isSignedIn) {
                    HStack(spacing: 5) {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(viewModel.networkService.connected ? (viewModel.sessionState.isConnected ? .green : .yellow) : .gray)
                        Text(viewModel.networkService.connected ? (viewModel.sessionState.isConnected ? "connected" : "connecting") : "disconnected")
                    }
                }
                Spacer()
                
                AccountMenu(viewModel: viewModel)
            }
            .padding(.bottom, 10)
            Spacer()
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
                    if (viewModel.todoState.todoItems.count < 8) {
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
                if (viewModel.authState.isSignedIn) {
                    VStack {
                        ProgressView()
                    }
                    .padding(.vertical, 10)
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("👤 Set up your account")
                                .font(.headline)
                            Text("Sign in to sync tasks, join coworking sessions, and track your productivity streaks.")
                        }
                        .backgroundStyle(.secondary.opacity(0.5))
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("✅ Add a task")
                                .font(.headline)
                            Text("List your daily tasks to organize your workflow and prioritize your day. Add up to 8 tasks at a time.")
                        }
                        .backgroundStyle(.secondary.opacity(0.5))
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("🔗 Join a Session")
                                .font(.headline)
                            Text("Start or join a coworking session in one click. Invite your friends to kickstart your collaborative productivity journey.")
                        }
                    }
                }
            }
            Spacer()
            HStack {
                Button(action: {
                    if viewModel.authState.isSignedIn {
                        viewModel.todoService.sanitizeTodoItems()
                        viewModel.goToLobby()
                    } else {
                        viewModel.signInWithGoogle()
                    }
                }) {
                    FText("Start Your Flow")
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .standardFrame()
        .onChange(of: viewModel.authState.isSignedIn) { value in
            viewModel.todoState.isTodoListInitialized = false
            if (viewModel.authState.isSignedIn) {
                viewModel.fetchTodoList()
            } else {
                viewModel.sessionService.disconnect()
            }
        }
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


