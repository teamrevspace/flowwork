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
                        .foregroundColor(viewModel.sessionState.isConnected ? .green : .yellow)
                    Text(viewModel.sessionState.isConnected ? "connected" : "connecting")
                }
                Spacer()
                AvatarView(avatarURL: viewModel.authState.currentUser?.avatarURL)
                    .onTapGesture {
                        viewModel.showProfilePopover.toggle()
                    }
                    .popover(isPresented: self.$viewModel.showProfilePopover) {
                        ProfilePopover(viewModel: viewModel)
                    }
            }
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
                                    let draftTodo = Todo(title: viewModel.todoState.draftTodo.title, completed: viewModel.todoState.draftTodo.completed, userIds: [currentUserId])
                                    self.viewModel.storeService.addTodo(todo: draftTodo)
                                    let emptyTodo = Todo(title: "", completed: false)
                                    self.viewModel.todoService.updateDraftTodo(todo: emptyTodo)
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
                    
//                    Button(action: {
//                        if (!viewModel.todoState.draftTodo.title.isEmpty) {
//                            guard let currentUserId = self.viewModel.authState.currentUser?.id else { return }
//                            let draftTodo = Todo(title: viewModel.todoState.draftTodo.title, completed: viewModel.todoState.draftTodo.completed, userIds: [currentUserId])
//                            self.viewModel.storeService.addTodo(todo: draftTodo)
//                            let emptyTodo = Todo(title: "", completed: false)
//                            self.viewModel.todoService.updateDraftTodo(todo: emptyTodo)
//                            self.viewModel.todoState.isHoveringDeleteButtons.append(false)
//                        }
//                        focusedField = todoListCount + 1
//                    }) {
//                        HStack {
//                            Spacer()
//                            Image(systemName: "plus")
//                            Spacer()
//                        }
//                        .background(Color.clear)
//                        .padding(.vertical, 5)
//                    }
//                    .buttonStyle(.borderless)
//                    .contentShape(Rectangle())
//                    .background(viewModel.todoState.draftTodo.title.isEmpty ? Color.secondary.opacity(0.1) : !viewModel.todoState.isHoveringAddButton ? Color.secondary.opacity(0.25) : Color.secondary.opacity(0.4))
//                    .cornerRadius(5)
//                    .disabled(viewModel.todoState.draftTodo.title.isEmpty)
//                    .onHover { isHovering in
//                        if (!viewModel.todoState.draftTodo.title.isEmpty) {
//                            viewModel.todoState.isHoveringAddButton = isHovering
//                        }
//                    }
                    Spacer()
                }
                .padding(.bottom, 10)
            }
            
            HStack{
                Button(action: {
                    if viewModel.authState.isSignedIn {
                        viewModel.todoService.sanitizeTodoItems()
                        viewModel.goToLobby()
                    } else {
                        viewModel.showProfilePopover.toggle()
                    }
                }) {
                    FText("Start Your Flow")
                }
            }
        }
        .padding()
        .standardFrame()
        .errorOverlay(errorService: viewModel.errorService)
        .onChange(of: viewModel.authState.currentUser?.id) { value in
            viewModel.fetchTodoList()
        }
        .onAppear() {
            viewModel.fetchTodoList()
        }
        .onDisappear() {
            viewModel.todoState.isTodoListInitialized = false
        }
    }
}

struct ProfilePopover: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            if viewModel.authState.currentUser != nil {
                Text("Hi \(viewModel.authState.currentUser!.name)!")
                Button("Log out") {
                    viewModel.signOut()
                }
            } else {
                Text("Hi there!")
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
