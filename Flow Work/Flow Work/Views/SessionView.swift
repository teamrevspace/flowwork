//
//  SessionView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct SessionView: View {
    @ObservedObject var viewModel: SessionViewModel
    @State var scrollToIndex: Int? = nil
    @FocusState private var focusedIndex: Int?
    
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
                            .font(.title2)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                        Menu {
                            Button(action: {
                                viewModel.copyToClipboard(textToCopy: "https://flowwork.xyz/s/\(viewModel.sessionState.currentSession!.id)")
                            }) {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Invite Link")
                            }
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    Group {
                        if (viewModel.todoState.isTodoListInitialized) {
                            ScrollViewReader { scrollView in
                                VStack {
                                    ScrollView(.vertical) {
                                        LazyVStack(alignment: .leading) {
                                            ForEach(0..<viewModel.todoState.todoItems.count, id: \.self) { index in
                                                let sessionId = viewModel.todoState.todoItems[index].id
                                                TodoItem(
                                                    todo: $viewModel.todoState.todoItems[index],
                                                    isEditing: viewModel.todoState.isEditingTextField[index],
                                                    isHoveringAction: viewModel.todoState.isHoveringActionButtons[index],
                                                    onCheck: { value in
                                                        viewModel.todoService.checkTodoCompleted(index: index, completed: value)
                                                    },
                                                    onChange: { newValue in
                                                        viewModel.todoState.isEditingTextField[index] = true
                                                    },
                                                    onSubmit: {
                                                        if (viewModel.todoState.isEditingTextField[index]) {
                                                            viewModel.storeService.updateTodo(todo: viewModel.todoState.todoItems[index])
                                                            viewModel.todoState.isEditingTextField[index] = false
                                                        }
                                                    },
                                                    onDelete: {
                                                        viewModel.storeService.removeTodo(todoId: sessionId!)
                                                        viewModel.todoState.isHoveringActionButtons.remove(at: index)
                                                        viewModel.todoState.isEditingTextField[index] = false
                                                    },
                                                    onAdd: {
                                                        if (viewModel.todoState.isEditingTextField[index]) {
                                                            viewModel.storeService.updateTodo(todo: viewModel.todoState.todoItems[index])
                                                            viewModel.todoState.isEditingTextField[index] = false
                                                        }
                                                    },
                                                    onHoverAction: { isHovering in
                                                        viewModel.todoState.isHoveringActionButtons[index] = isHovering
                                                    },
                                                    showActionButton: !viewModel.todoState.todoItems[index].completed
                                                )
                                                .focused($focusedIndex, equals: index)
                                                .onSubmit {
                                                    if index < viewModel.todoState.todoItems.count - 1 {
                                                        focusedIndex = index + 1
                                                    } else if index == viewModel.todoState.todoItems.count - 1 {
                                                      focusedIndex = -2
                                                    } else {
                                                        focusedIndex = nil
                                                    }
                                                }
                                                .id(index)
                                            }
                                            Spacer()
                                                .frame(height: 20)
                                                .id(-1)
                                        }
                                        .padding(.horizontal, 20)
                                        .onChange(of: self.scrollToIndex) { newIndex in
                                            if let newIndex = newIndex {
                                                withAnimation(Animation.linear(duration: Double(viewModel.todoState.todoItems.count) * 0.5)) {
                                                    scrollView.scrollTo(newIndex, anchor: .bottom)
                                                }
                                                self.scrollToIndex = nil
                                            }
                                        }
                                    }
                                    .frame(minHeight: 180)
                                    Divider()
                                    VStack {
                                        TodoItem(
                                            todo: $viewModel.todoState.draftTodo,
                                            isEditing: !viewModel.todoState.draftTodo.title.isEmpty,
                                            isHoveringAction: viewModel.todoState.isHoveringAddButton,
                                            onCheck: { value in
                                                viewModel.todoService.checkTodoCompleted(index: todoListCount, completed: value)
                                            },
                                            onSubmit: {
                                                viewModel.addDraftTodo()
                                                if (!viewModel.todoState.draftTodo.title.isEmpty) {
                                                    self.scrollToIndex = -1
                                                }
                                            },
                                            onAdd: {
                                                viewModel.addDraftTodo()
                                                if (!viewModel.todoState.draftTodo.title.isEmpty) {
                                                    self.scrollToIndex = -1
                                                }
                                            },
                                            onHoverAction: { isHovering in
                                                viewModel.todoState.isHoveringAddButton = isHovering
                                            },
                                            showActionButton: !viewModel.todoState.draftTodo.title.isEmpty && !viewModel.todoState.draftTodo.completed
                                        )
                                        .focused($focusedIndex, equals: -2)
                                        .id(-2)
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        } else {
                            VStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding(.vertical, 10)
                        }
                    }
                    VStack(spacing: 10) {
                        Group {
                            switch viewModel.sessionState.selectedMode {
                            case .lounge:
                                HStack {
                                    //                        MARK: - WebRTC Audio Room
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
                                    //                    .padding(.horizontal, 20)
                                    //                    .scrollIndicators(.never)
                                }
                            case .pomodoro:
                                HStack {
                                    PomodoroTimer(viewModel: viewModel)
                                }
                            case .focus:
                                HStack {}
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        HStack {
                            ScrollView(.horizontal) {
                                LazyHStack {
                                    ForEach(viewModel.sessionState.currentSessionUsers ?? []) { user in
                                        Menu {
                                            Text("\(user.name)")
                                        } label: {
                                            AvatarView(avatarURL: user.avatarURL)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            Button(action: {
                                viewModel.leaveSession()
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Leave Session")
                            }
                        }
                        .frame(height: 30)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .padding(0)
                .standardFrame()
                .onChange(of: viewModel.networkService.connected) { value in
                    guard let userId = viewModel.authState.currentUser?.id else { return }
                    viewModel.todoState.isTodoListInitialized = false
                    if (viewModel.networkService.connected) {
                        viewModel.sessionService.connect(userId)
                        viewModel.fetchTodoList()
                    } else {
                        viewModel.sessionService.disconnect()
                        viewModel.todoState.isTodoListInitialized = false
                    }
                }
                .onAppear() {
                    viewModel.fetchTodoList()
                    switch (viewModel.sessionState.selectedMode) {
                    case .lounge:
                        break
                    case .pomodoro:
                        viewModel.resetTimer()
                    case .focus:
                        viewModel.saveSessionGlobal()
                    }
                }
                .onDisappear() {
                    if (viewModel.todoState.isTodoListInitialized) {
                        viewModel.todoService.sanitizeTodoItems()
                        viewModel.todoService.checkTodoCompleted(index: todoListCount, completed: false)
                    }
                    switch (viewModel.sessionState.selectedMode) {
                    case .lounge:
                        break
                    case .pomodoro:
                        viewModel.resetTimer()
                    case .focus:
                        viewModel.restoreSessionGlobal()
                    }
                }
            }
        }
    }
}
