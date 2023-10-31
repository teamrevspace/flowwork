//
//  SessionView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

private struct Constants {
    static let sidebarWidth: CGFloat = 180
}

struct SessionView: View {
    @ObservedObject var viewModel: SessionViewModel
    
    @State private var scrollToTodoIndex: Int? = nil
    @FocusState private var focusedTodoIndex: Int?
    
    @State private var isHoveringSidebarButton: Bool = false
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .opacity(viewModel.isSidebarVisible ? 1 : 0)
                .onTapGesture {
                    withAnimation {
                        viewModel.isSidebarVisible.toggle()
                        viewModel.isEditingDraftCategory = false
                        viewModel.todoService.updateDraftCategory(category: Category())
                    }
                }
                .zIndex(9)
            
            VStack {
                if (viewModel.sessionState.hasJoinedSession) {
                    VStack {
                        HStack(spacing: 10) {
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        viewModel.isSidebarVisible.toggle()
                                        viewModel.isEditingDraftCategory = false
                                        viewModel.todoService.updateDraftCategory(category: Category())
                                    }
                                }) {
                                    HStack(spacing: 5) {
                                        SmallIcon(icon: "line.3.horizontal", foregroundColor: Color("Primary").opacity(0.75))
                                        Text(viewModel.categoryState.selectedCategory?.title ?? "All")
                                            .font(.body)
                                            .fontWeight(.medium)
                                    }
                                    .padding(5)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(self.isHoveringSidebarButton ? Color.secondary.opacity(0.25) : Color.secondary.opacity(0.1))
                                .cornerRadius(5)
                                .onHover { isHovering in
                                    self.isHoveringSidebarButton = isHovering
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 5)
                            Menu {
                                Button(action: {
                                    viewModel.sessionService.updateWorkMode(.lounge)
                                }) {
                                    Image(systemName: "sofa.fill")
                                    Text("Lounge Mode")
                                }
                                .disabled(viewModel.sessionState.selectedMode == .lounge)
                                
                                Button(action: {
                                    viewModel.sessionService.updateWorkMode(.pomodoro)
                                }) {
                                    Image(systemName: "deskclock.fill")
                                    Text("Pomodoro Mode")
                                }
                                .disabled(viewModel.sessionState.selectedMode == .pomodoro)
                                
                                Button(action: {
                                    viewModel.sessionService.updateWorkMode(.focus)
                                }) {
                                    Image(systemName: "moon.fill")
                                    Text("Focus Mode (Beta)")
                                }
                                .disabled(viewModel.sessionState.selectedMode == .focus)
                            } label: {
                                HStack(spacing: 5) {
                                    SmallIcon(icon: viewModel.sessionState.selectedMode == .lounge ? "sofa.fill" : viewModel.sessionState.selectedMode == .pomodoro ? "deskclock.fill" : "moon.fill")
                                    Text(viewModel.sessionState.selectedMode == .lounge ? "Lounge" : viewModel.sessionState.selectedMode == .pomodoro ? "Pomodoro" : "Focus")
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                                .padding(5)
                                .background(viewModel.sessionState.selectedMode == .lounge ? Color.blue.opacity(0.25) : viewModel.sessionState.selectedMode == .pomodoro ? Color.red.opacity(0.25) : Color.indigo.opacity(0.25))
                                .contentShape(Rectangle())
                                .cornerRadius(5)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.top, 20)
                        .padding(.leading, 10)
                        .padding(.trailing, 20)
                        
                        HStack(spacing: 10) {
                            if viewModel.defaultSessionId == viewModel.sessionState.currentSession?.id {
                                SmallIcon(icon: "checkmark.seal.fill", foregroundColor: Color.blue)
                            }
                            Text(viewModel.sessionState.currentSession?.name ?? "Loading...")
                                .fontWeight(.bold)
                                .font(.title2)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            if (viewModel.networkService.connected) {
                                SmallIcon(icon: "cloud.fill")
                                    .opacity(viewModel.isCloudSyncing ? 0.75 : 0)
                                    .animation(Animation.default, value: viewModel.isCloudSyncing)
                            } else {
                                SmallIcon(icon: "icloud.slash.fill")
                            }
                            
                            Spacer()
                            
                            Menu {
                                Button(action: {
                                    viewModel.copyToClipboard(textToCopy: "https://flowwork.xyz/s/\(viewModel.sessionState.currentSession!.id)")
                                }) {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copy Invite Link")
                                }
                            } label: {
                                SmallIcon(icon: "gearshape.fill")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        .padding(.horizontal, 20)
                        Group {
                            if (viewModel.todoState.isTodoListInitialized) {
                                if (viewModel.timerType == .pomodoro) {
                                    ScrollViewReader { scrollView in
                                        ScrollView(.vertical) {
                                            LazyVStack(alignment: .leading) {
                                                ForEach(0..<viewModel.todoState.todoItems.count, id: \.self) { index in
                                                    if index < viewModel.todoState.todoItems.count {
                                                        TodoItem(
                                                            viewModel: viewModel,
                                                            todo: $viewModel.todoState.todoItems[index],
                                                            isHoveringAction: viewModel.todoState.isHoveringActionButtons[index],
                                                            onHoverAction: { isHovering in
                                                                viewModel.todoState.isHoveringActionButtons[index] = isHovering
                                                            },
                                                            showActionButton: !viewModel.todoState.todoItems[index].completed
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
                                                }
                                                Spacer()
                                                    .frame(height: 20)
                                                    .id(-1)
                                            }
                                            .padding(.horizontal, 20)
                                            .onChange(of: self.scrollToTodoIndex) { newIndex in
                                                if let newIndex = newIndex, newIndex < viewModel.todoState.todoItems.count {
                                                    withAnimation(.easeIn(duration: 0.3)) {
                                                        scrollView.scrollTo(newIndex, anchor: .bottom)
                                                    }
                                                    self.scrollToTodoIndex = nil
                                                }
                                            }
                                        }
                                        .frame(minHeight: 120)
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
                                        LargeIcon(icon: "cup.and.saucer.fill")
                                        LargeText(text: "Take a break")
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
                                        Avatar(avatarURL: viewModel.authState.currentUser?.avatarURL)
                                            .opacity(0.5)
                                            Circle()
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(viewModel.networkService.connected ? .yellow : .gray)
                                                .offset(x: 10, y: 10)
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
                                                                Avatar(avatarURL: user.avatarURL)
                                                                Circle()
                                                                    .frame(width: 10, height: 10)
                                                                    .foregroundColor(.green)
                                                                    .offset(x: 10, y: 10)
                                                            }
                                                            .frame(width: 30, height: 30)
                                                        } else {
                                                            Avatar(avatarURL: user.avatarURL)
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                Spacer()
                                FButton(icon: "hand.wave.fill", text: "Leave quietly") {
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
                        }
                        viewModel.launchSession()
                    }
                    .onChange(of: viewModel.sessionState.selectedMode) { workMode in
                        viewModel.launchSession()
                    }
                    .onChange(of: viewModel.categoryState.selectedCategory?.id) { [oldCategory = viewModel.categoryState.selectedCategory] newCategoryId in
                        focusedTodoIndex = nil
                        viewModel.isEditingDraftCategory = false
                        scrollToTodoIndex = nil
                        viewModel.todoState.isTodoListInitialized = false
                        if (oldCategory?.id != newCategoryId) {
                            viewModel.fetchTodoList(categoryId: newCategoryId)
                        }
                    }
                } else {
                    VStack(spacing: 10) {
                        Spacer()
                        if (!viewModel.networkService.connected) {
                            LargeIcon(icon: "icloud.slash.fill")
                            LargeText(text: "No internet connection. Try again later.")
                        } else if (viewModel.sessionState.maxRetriesReached) {
                            LargeIcon(icon: "sailboat.fill")
                            LargeText(text: "Disconnected")
                        } else {
                            LargeIcon(icon: "antenna.radiowaves.left.and.right")
                            LargeText(text: "Joining...")
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
            SidebarView(viewModel: viewModel)
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


struct SidebarView: View {
    @ObservedObject var viewModel: SessionViewModel
    
    @FocusState private var focusedCategoryIndex: Int?
    @State private var scrollToCategoryIndex: Int? = nil
    
    @State private var isHoveringSidebarButton: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                withAnimation {
                    viewModel.isSidebarVisible.toggle()
                    viewModel.isEditingDraftCategory = false
                    viewModel.todoService.updateDraftCategory(category: Category())
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
                                            isSidebarVisible: $viewModel.isSidebarVisible,
                                            onSelect: {
                                                viewModel.todoService.selectCategory(category: nil)
                                            }
                                        )
                                        ForEach(viewModel.categoryState.categoryItems, id: \.id) { category in
                                            CategoryItem(
                                                category: category,
                                                selectedCategory: $viewModel.categoryState.selectedCategory,
                                                isSidebarVisible: $viewModel.isSidebarVisible,
                                                onSelect: {
                                                    viewModel.todoService.selectCategory(category: category)
                                                }
                                            )
                                            .contextMenu {
                                                Button("Remove") {
                                                    viewModel.storeService.removeUserFromCategory(userId: userId, categoryId: category.id ?? userId)
                                                }
                                            }
                                        }
                                        TextField("New list", text: $viewModel.categoryState.draftCategory.title, axis: .vertical)
                                            .padding(5)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .listRowBackground(Color.clear)
                                            .foregroundColor(Color("Primary"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .opacity(viewModel.isEditingDraftCategory ? 1 : 0)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .contentShape(Rectangle())
                                            .onSubmit {
                                                if (viewModel.isEditingDraftCategory) {
                                                    viewModel.isEditingDraftCategory = false
                                                    self.scrollToCategoryIndex = -1
                                                    withAnimation {
                                                        viewModel.addDraftCategory()
                                                    }
                                                }
                                            }
                                            .focused($focusedCategoryIndex, equals: -2)
                                            .id(-2)
                                        Spacer()
                                        //                                            .frame(height: 30)
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
                FButton(icon: "plus", text: "New List") {
                    viewModel.isEditingDraftCategory.toggle()
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
        .frame(width: Constants.sidebarWidth)
        .offset(x: viewModel.isSidebarVisible ? -(Constants.sidebarWidth / 2) : -(Constants.sidebarWidth * 2))
        .zIndex(10)
    }
}
