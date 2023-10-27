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
                        HStack(spacing: 10) {
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        isSidebarVisible.toggle()
                                    }
                                }) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "line.3.horizontal")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(Color("Primary").opacity(0.75))
                                        Text(viewModel.categoryState.selectedCategory?.title ?? "All")
                                            .font(.body)
                                            .fontWeight(.medium)
                                    }
                                    .padding(5)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(self.isHoveringSidebarButton ? Color.secondary.opacity(0.25) : Color.clear )
                                .cornerRadius(5)
                                .padding(.horizontal, 5)
                                .onHover { isHovering in
                                    self.isHoveringSidebarButton = isHovering
                                }
                                Spacer()
                            }
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
                        .padding(.top, 20)
                        .padding(.leading, 10)
                        .padding(.trailing, 20)
                        
                        HStack(spacing: 10) {
                            Text("\(viewModel.sessionState.currentSession?.name ?? "Session")")
                                .fontWeight(.bold)
                                .font(.title2)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            if (viewModel.networkService.connected) {
                                Image(systemName: "cloud.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(Color.secondary)
                                    .opacity(viewModel.isUpdating ? 0.75 : 0)
                                    .animation(Animation.default, value: viewModel.isUpdating)
                            } else {
                                Image(systemName: "icloud.slash.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(Color.secondary)
                            }
                            Spacer()
                        }
                        
                        .padding(.horizontal, 20)
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
                                                if let newIndex = newIndex, newIndex < self.viewModel.todoState.todoItems.count {
                                                    withAnimation(Animation.linear(duration: Double(viewModel.todoState.todoItems.count) * 0.5)) {
                                                        scrollView.scrollTo(newIndex, anchor: .bottom)
                                                    }
                                                    self.scrollToTodoIndex = nil
                                                }
                                            }
                                        }
                                        .frame(minHeight: 150)
                                        Divider()
                                        VStack {
                                            let draftTodo = viewModel.todoState.draftTodo
                                            TodoItem(
                                                viewModel: viewModel,
                                                todo: $viewModel.todoState.draftTodo,
                                                isEditingDraft: !draftTodo.title.isEmpty,
                                                isHoveringAction: viewModel.todoState.isHoveringAddButton,
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
                                if (!viewModel.networkService.connected || !viewModel.sessionState.isConnected || (viewModel.sessionState.currentSessionUsers ?? []).isEmpty) {
                                    ZStack {
                                        AvatarView(avatarURL: viewModel.authState.currentUser?.avatarURL)
                                            .opacity(0.5)
                                        if (!viewModel.networkService.connected) {
                                            Circle()
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.gray)
                                                .offset(x: 10, y: 10)
                                        }
                                    }
                                    .frame(width: 30, height: 30)
                                } else  {
                                    if let currentSessionUsers = viewModel.sessionState.currentSessionUsers {
                                        ScrollView(.horizontal) {
                                            LazyHStack {
                                                ForEach(currentSessionUsers) { user in
                                                    Menu {
                                                        Text("\(user.name)")
                                                    } label: {
                                                        if user.id == viewModel.authState.currentUser?.id {
                                                            ZStack {
                                                                AvatarView(avatarURL: user.avatarURL)
                                                                Circle()
                                                                    .frame(width: 10, height: 10)
                                                                    .foregroundColor(viewModel.sessionState.isConnected ? .green : .yellow)
                                                                    .offset(x: 10, y: 10)
                                                            }
                                                            .frame(width: 30, height: 30)
                                                        } else {
                                                            AvatarView(avatarURL: user.avatarURL)
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
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
                        if !viewModel.categoryState.isCategoryListInitialized {
                            viewModel.fetchCategoryList()
                            viewModel.todoService.selectCategory(category: nil)
                        }
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
                    .onChange(of: viewModel.categoryState.selectedCategory?.id) { [oldCategory = viewModel.categoryState.selectedCategory] newCategoryId in
                        focusedTodoIndex = nil
                        focusedCategoryIndex = nil
                        isEditingDraftCategory = false
                        scrollToTodoIndex = nil
                        scrollToCategoryIndex = nil
                        viewModel.todoState.isTodoListInitialized = false
                        if (oldCategory?.id != newCategoryId) {
                            viewModel.fetchTodoList(categoryId: newCategoryId)
                        }
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
                                                selectedCategory: $viewModel.categoryState.selectedCategory,
                                                isSidebarVisible: $isSidebarVisible,
                                                onSelect: {
                                                    viewModel.todoService.selectCategory(category: nil)
                                                }
                                            )
                                            ForEach(viewModel.categoryState.categoryItems, id: \.id) { category in
                                                CategoryItem(
                                                    category: category,
                                                    selectedCategory: $viewModel.categoryState.selectedCategory,
                                                    isSidebarVisible: $isSidebarVisible,
                                                    onSelect: {
                                                        viewModel.todoService.selectCategory(category: category)
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
                                    if let newIndex = newIndex, newIndex < viewModel.categoryState.categoryItems.count {
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
                    VStack(alignment: .center) {
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
        .onChange(of: viewModel.networkService.connected) { value in
            guard let userId = viewModel.authState.currentUser?.id else { return }
            if (viewModel.networkService.connected) {
                viewModel.reconnectToSession(userId)
            }
        }
        .onChange(of: viewModel.sessionState.isConnected ) { value in
            guard let userId = viewModel.authState.currentUser?.id else { return }
            if (viewModel.sessionState.isConnected) {
                viewModel.reconnectToSession(userId)
            }
        }
        .onAppear() {
            guard let userId = viewModel.authState.currentUser?.id else { return }
            if viewModel.sessionState.maxRetriesReached {
                viewModel.reconnectToSession(userId)
            }
        }
        .onDisappear() {
            if (viewModel.todoState.isTodoListInitialized) {
                viewModel.todoService.sanitizeTodoItems()
            }
            if (viewModel.categoryState.isCategoryListInitialized) {
                viewModel.todoService.sanitizeCategoryItems()
                viewModel.todoService.selectCategory(category: nil)
            }
            switch (viewModel.sessionState.selectedMode) {
            case .lounge:
                break
            case .pomodoro:
                viewModel.resetTimer()
            case .focus:
                viewModel.restoreSessionGlobal()
            }
            viewModel.storeService.stopTodoListListener()
            viewModel.storeService.stopCategoryListListener()
        }
    }
}
