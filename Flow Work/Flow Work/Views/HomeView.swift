//
//  HomeView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @FocusState private var focusedField: Int?
    
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
                HStack(spacing: 5) {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(viewModel.sessionState.isConnected ? .green : viewModel.authState.isSignedIn ? .yellow : .gray)
                    Text(viewModel.sessionState.isConnected ? "connected" : viewModel.authState.isSignedIn ? "connecting" : "disconnected")
                }
                Spacer()
                Button(action: {
                    viewModel.showAccountPopover.toggle()
                }) {
                    AvatarView(avatarURL: viewModel.authState.currentUser?.avatarURL)
                }
                .buttonStyle(PlainButtonStyle())
                .popover(isPresented: self.$viewModel.showAccountPopover) {
                    ProfilePopover(viewModel: viewModel)
                }
            }
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
                .padding(.bottom, 10)
            } else {
                if (viewModel.authState.isSignedIn) {
                    VStack {
                        ProgressView()
                    }
                    .padding(.vertical, 10)
                }
            }
            Spacer()
            HStack{
                Button(action: {
                    if viewModel.authState.isSignedIn {
                        viewModel.todoService.sanitizeTodoItems()
                        viewModel.goToLobby()
                    } else {
                        viewModel.showAccountPopover.toggle()
                    }
                }) {
                    FText("Start Your Flow")
                }
            }
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
            viewModel.todoService.checkTodoCompleted(index: todoListCount, completed: false)
        }
    }
}

struct ProfilePopover: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            Text("Hi \(viewModel.authState.currentUser?.name ?? "there")!")
            Button(action: {
                viewModel.goToSettings()
            }) {
                Text("Settings")
            }
            if (viewModel.authState.isSignedIn) {
                Button(action: {
                    viewModel.signOut()
                }) {
                    Text("Log out")
                }
            } else {
                Button(action: {
                    viewModel.signInWithGoogle()
                }) {
                    Text("Sign in with Google")
                }
            }
        }
        .padding(15)
    }
}
