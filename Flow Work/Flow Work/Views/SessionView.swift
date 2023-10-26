//
//  SessionView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct SessionView: View {
    @ObservedObject var viewModel: SessionViewModel
    
    @State private var scrollToTodoIndex: Int? = nil
    @State private var scrollToCategoryIndex: Int? = nil
    
    @FocusState private var focusedTodoIndex: Int?
    @FocusState private var focusedCategoryIndex: Int?
    
    @State private var isSidebarVisible: Bool = false
    @State private var isEditingDraftCategory: Bool = false
    @State private var isHoveringSidebarButton: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                if (viewModel.sessionState.hasJoinedSession) {
                    VStack {
                        HStack(spacing: 5) {
                            Button(action: {
                                withAnimation {
                                    isSidebarVisible.toggle()
                                }
                            }) {
                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(Color("Primary").opacity(0.75))
                                    .padding(5)
                                    .contentShape(Rectangle())
                                    .opacity(!isSidebarVisible ? 1 : 0)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .background(self.isHoveringSidebarButton ? Color.secondary.opacity(0.25) : Color.clear )
                            .cornerRadius(5)
                            .padding(.horizontal, 5)
                            .onHover { isHovering in
                                self.isHoveringSidebarButton = isHovering
                            }
                            
                            HStack(spacing: 10) {
                                Text("\(viewModel.sessionState.currentSession?.name ?? "Session")")
                                    .fontWeight(.bold)
                                    .font(.title2)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(viewModel.networkService.connected ? (viewModel.sessionState.isConnected ? .green : .yellow) : .gray)
                                Spacer()
                                if (viewModel.networkService.connected) {
                                    Image(systemName: "cloud.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(Color.secondary)
                                        .opacity(viewModel.isUpdating ? 1 : 0)
                                        .animation(Animation.default, value: viewModel.isUpdating)
                                } else {
                                    Image(systemName: "icloud.slash.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(Color.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
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
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.leading, 10)
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                        Group {
                            if (viewModel.todoState.isTodoListInitialized) {
                                if (viewModel.timerType == .pomodoro) {
                                    ScrollViewReader { scrollView in
                                            ScrollView(.vertical) {
                                                LazyVStack(alignment: .leading) {
                                                    ForEach(0..<viewModel.todoState.todoItems.count, id: \.self) { index in
                                                        let todo = viewModel.todoState.todoItems[index]
                                                        TodoItem(
                                                            viewModel: viewModel,
                                                            todo: $viewModel.todoState.todoItems[index],
                                                            isHoveringAction: viewModel.todoState.isHoveringActionButtons[index],
                                                            onCheck: { value in
                                                                viewModel.checkTodoCompleted(todo: todo, completed: value)
                                                            },
                                                            onUpdate: {
                                                                viewModel.updateTodo(todo: todo)
                                                            },
                                                            onDelete: {
                                                                viewModel.removeTodo(todoId: todo.id)
                                                            },
                                                            onHoverAction: { isHovering in
                                                                viewModel.todoState.isHoveringActionButtons[index] = isHovering
                                                            },
                                                            showActionButton: !todo.completed
                                                        )
                                                        .focused($focusedTodoIndex, equals: index)
                                                        .onSubmit {
                                                            if index < viewModel.todoState.todoItems.count - 1 {
                                                                focusedTodoIndex = index + 1
                                                            } else if index == viewModel.todoState.todoItems.count - 1 {
                                                                focusedTodoIndex = -2
                                                            } else {
                                                                focusedTodoIndex = nil
                                                            }
                                                        }
                                                        .id(index)
                                                    }
                                                    Spacer()
                                                        .frame(height: 20)
                                                        .id(-1)
                                                }
                                                .padding(.horizontal, 20)
                                                .onChange(of: self.scrollToTodoIndex) { newIndex in
                                                    if let newIndex = newIndex {
                                                        withAnimation(Animation.linear(duration: Double(viewModel.todoState.todoItems.count) * 0.5)) {
                                                            scrollView.scrollTo(newIndex, anchor: .bottom)
                                                        }
                                                        self.scrollToTodoIndex = nil
                                                    }
                                                }
                                            }
                                            .frame(minHeight: 180)
                                            Divider()
                                            VStack {
                                                let draftTodo = viewModel.todoState.draftTodo
                                                TodoItem(
                                                    viewModel: viewModel,
                                                    todo: $viewModel.todoState.draftTodo,
                                                    isEditingDraft: !draftTodo.title.isEmpty,
                                                    isHoveringAction: viewModel.todoState.isHoveringAddButton,
                                                    onCheck: { value in
                                                        viewModel.checkTodoCompleted(todo: draftTodo, completed: value)
                                                    },
                                                    onAdd: {
                                                        viewModel.addDraftTodo()
                                                        self.scrollToTodoIndex = -1
                                                    },
                                                    onHoverAction: { isHovering in
                                                        viewModel.todoState.isHoveringAddButton = isHovering
                                                    },
                                                    showActionButton: !draftTodo.title.isEmpty && !draftTodo.completed
                                                )
                                                .focused($focusedTodoIndex, equals: -2)
                                                .id(-2)
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.top, 0)
                                    }
                                } else {
                                    VStack {
                                        Spacer()
                                        Image(systemName: "cup.and.saucer.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(Color.secondary)
                                        Text("Take a break")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.secondary)
                                        Spacer()
                                    }
                                    .padding(.vertical, 10)
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
                                if (!viewModel.networkService.connected || !viewModel.sessionState.isConnected) {
                                    AvatarView(avatarURL: viewModel.authState.currentUser?.avatarURL)
                                        .opacity(0.5)
                                } else  {
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
                                }
                                Spacer()
                                FButton(image: "hand.wave.fill", text: "Leave quietly") {
                                    viewModel.leaveSession()
                                }
                            }
                            .frame(height: 30)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                    .padding(0)
                    .standardFrame()
                    .onAppear() {
                        viewModel.fetchTodoList()
                        viewModel.fetchCategoryList()
                        switch (viewModel.sessionState.selectedMode) {
                        case .lounge:
                            viewModel.playDoorSound()
                        case .pomodoro:
                            viewModel.resetTimer()
                            viewModel.startTimer()
                            viewModel.playTickSound()
                        case .focus:
                            viewModel.saveSessionGlobal()
                            viewModel.playCongaSound()
                        }
                    }
                    .onDisappear() {
                        if (viewModel.todoState.isTodoListInitialized) {
                            viewModel.todoService.sanitizeTodoItems()
                        }
                        if (viewModel.categoryState.isCategoryListInitialized) {
                            viewModel.todoService.sanitizeCategoryItems()
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
                    .onChange(of: viewModel.categoryState.selectedCategoryId) { categoryId in
                        viewModel.filterTodoListByCategoryId(categoryId: categoryId)
                    }
                } else {
                    VStack(spacing: 10) {
                        Spacer()
                        if (!viewModel.networkService.connected) {
                            Image(systemName: "icloud.slash.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color.secondary)
                            Text("No internet connection. Try again later.")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.secondary)
                        } else if (viewModel.sessionState.maxRetriesReached) {
                            Image(systemName: "sailboat.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color.secondary)
                            Text("Disconnected.")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.secondary)
                        } else {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color.secondary)
                            Text("Joining...")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.secondary)
                        }
                        Spacer()
                        HStack {
                            FButton(text: "Back") {
                                viewModel.leaveSession()
                            }
                            if (viewModel.sessionState.maxRetriesReached) {
                                FButton(text: "Reconnect") {
                                    guard let userId = viewModel.authState.currentUser?.id else { return }
                                    viewModel.sessionService.resetMaxRetries()
                                    viewModel.sessionService.connect(userId)
                                    viewModel.rejoinSession()
                                }
                            }
                        }
                    }
                    .padding()
                    .standardFrame()
                }
            }
            .onChange(of: viewModel.networkService.connected) { value in
                guard let userId = viewModel.authState.currentUser?.id else { return }
                if (viewModel.networkService.connected) {
                    viewModel.sessionService.resetMaxRetries()
                    viewModel.sessionService.connect(userId)
                    viewModel.rejoinSession()
                }
            }
            .onChange(of: viewModel.sessionState.isConnected ) { value in
                guard let userId = viewModel.authState.currentUser?.id else { return }
                if (viewModel.sessionState.isConnected) {
                    viewModel.sessionService.resetMaxRetries()
                    viewModel.sessionService.connect(userId)
                    viewModel.rejoinSession()
                }
            }
            .onAppear {
                guard let userId = viewModel.authState.currentUser?.id else { return }
                if viewModel.sessionState.maxRetriesReached {
                    viewModel.sessionService.resetMaxRetries()
                    viewModel.sessionService.connect(userId)
                    viewModel.rejoinSession()
                }
            }
            
            // MARK: sidebar
            VStack(alignment: .leading) {
                Button(action: {
                    withAnimation {
                        isSidebarVisible.toggle()
                    }
                }) {
                    Image(systemName: "chevron.left.2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .foregroundColor(Color("Primary").opacity(0.75))
                        .padding(5)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .background(self.isHoveringSidebarButton ? Color.secondary.opacity(0.25) : Color.clear )
                .cornerRadius(5)
                .onHover { isHovering in
                    self.isHoveringSidebarButton = isHovering
                }
                if (viewModel.categoryState.isCategoryListInitialized) {
                    Group {
                        ScrollViewReader { scrollView in
                            ScrollView(.vertical) {
                                LazyVStack(alignment: .leading, spacing: 0) {
                                    if let userId = viewModel.authState.currentUser?.id {
                                        Group {
                                            CategoryItem(
                                                category: Category(id: userId, title: "All"),
                                                selectedCategoryId: $viewModel.categoryState.selectedCategoryId,
                                                isSidebarVisible: $isSidebarVisible,
                                                onSelect: {
                                                    viewModel.todoService.selectCategory(categoryId: userId)
                                                    focusedCategoryIndex = nil
                                                }
                                            )
                                            ForEach(viewModel.categoryState.categoryItems, id: \.id) { category in
                                                CategoryItem(
                                                    category: category,
                                                    selectedCategoryId: $viewModel.categoryState.selectedCategoryId,
                                                    isSidebarVisible: $isSidebarVisible,
                                                    onSelect: {
                                                        viewModel.todoService.selectCategory(categoryId: category.id)
                                                        focusedCategoryIndex = nil
                                                    }
                                                )
                                                .contextMenu {
                                                    Button("Removed") {
                                                        self.viewModel.storeService.removeUserFromCategory(userId: userId, categoryId: category.id ?? userId)
                                                    }
                                                }
                                            }
                                            if (self.isEditingDraftCategory) {
                                                TextField("New list", text: $viewModel.categoryState.draftCategory.title, axis: .vertical)
                                                    .padding(5)
                                                    .textFieldStyle(PlainTextFieldStyle())
                                                    .listRowBackground(Color.clear)
                                                    .foregroundColor(Color("Primary"))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .contentShape(Rectangle())
                                                    .onSubmit {
                                                        self.isEditingDraftCategory = false
                                                        self.scrollToCategoryIndex = -1
                                                        withAnimation {
                                                            viewModel.addDraftCategory()
                                                        }
                                                    }
                                                    .focused($focusedCategoryIndex, equals: -2)
                                                    .id(-2)
                                            }
                                            Spacer()
                                                .frame(height: 30)
                                                .id(-1)
                                        }
                                    }
                                }
                                .onChange(of: self.scrollToCategoryIndex) { newIndex in
                                    if let newIndex = newIndex {
                                        withAnimation(Animation.linear(duration: Double(viewModel.categoryState.categoryItems.count) * 0.5)) {
                                            scrollView.scrollTo(newIndex, anchor: .bottom)
                                        }
                                        self.scrollToCategoryIndex = nil
                                    }
                                }
                            }
                            .padding(0)
                            .listStyle(.plain)
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
                Divider()
                HStack {
                    FButton(image: "plus", text: "New List") {
                        self.isEditingDraftCategory = true
                        self.focusedCategoryIndex = -2
                        self.scrollToCategoryIndex = -2
                    }
                }
                .frame(height: 30)
                .padding(.horizontal, 5)
            }
            .contentShape(Rectangle())
            .padding(.vertical, 20)
            .padding(.horizontal, 15)
            .background(.ultraThinMaterial, in: Rectangle())
            .frame(width: 180)
            .offset(x: isSidebarVisible ? -90 : -360)
            .zIndex(10)
        }
    }
}
