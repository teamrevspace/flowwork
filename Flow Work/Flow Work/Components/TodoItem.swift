//
//  TodoItem.swift
//  Flow Work
//
//  Created by Allen Lin on 10/21/23.
//

import SwiftUI
import Combine

struct TodoItem: View {
    @ObservedObject var viewModel: SessionViewModel
    
    @Binding var todo: Todo
    var isEditingDraft: Bool?
    var isHoveringAction: Bool
    var onAdd: (() -> Void)?
    var onHoverAction: (Bool) -> Void
    var showActionButton: Bool
    
    @State private var isEditing: Bool = false
    @State private var showManageAccessPopover = false
    @State private var showCollaboratorsPopover = false
    
    var body: some View {
        HStack(alignment: .top) {
            if (todo.id != nil) {
                Toggle("", isOn: Binding(
                    get: { todo.completed },
                    set: { newValue in
                        withAnimation {
                            todo.completed = newValue
                            viewModel.checkTodoCompleted(todo: todo, completed: newValue)
                        }
                    }
                ))
                .padding(1.5)
                .labelsHidden()
            } else {
                Button(action: {
                    isEditing = false
                    withAnimation {
                        onAdd?()
                    }
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .padding(1.5)
                    }
                    .background(Color.clear)
                }
                .buttonStyle(.borderless)
                .contentShape(Rectangle())
                .foregroundColor((isEditingDraft ?? false) ? Color.white : Color("Primary").opacity(0.5))
                .background(isHoveringAction && (isEditingDraft ?? false) ? Color.blue : (isEditingDraft ?? false) ? Color.blue.opacity(0.75) : Color.clear)
                .cornerRadius(5)
                .onHover { isHovering in
                    onHoverAction(isHovering)
                }
            }
            
            TextField("Add new to-do here", text: $todo.title, axis: .vertical)
                .lineLimit(todo.id == nil ? 3 : nil)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(todo.completed ? Color("Primary").opacity(0.5) : Color("Primary"))
                .frame(maxWidth: .infinity)
                .onChange(of: todo.title) { _ in
                    if (todo.id != nil) {
                        isEditing = true
                    }
                }
                .onReceive(Just(todo.title)) { _ in
                    if (isEditing) {
                        viewModel.syncToCloud() {
                            viewModel.updateTodo(todo: todo)
                        }
                        isEditing = false
                    }
                }
                .onSubmit {
                    isEditing = false
                    withAnimation {
                        onAdd?()
                    }
                }
            
            if todo.userIds?.count ?? 0 > 1 {
                Button(action: {
                    showCollaboratorsPopover.toggle()
                }) {
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                        .popover(isPresented: $showCollaboratorsPopover, content: {
                            ShowCollaboratorsPopover(viewModel: viewModel, todo: $todo)
                                .zIndex(5)
                                .onDisappear {
                                    showCollaboratorsPopover = false
                                }
                        })
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if showActionButton && todo.id != nil {
                Menu {
                    if viewModel.sessionState.currentSessionUsers != nil {
                        Button("Manage Access") {
                            showManageAccessPopover = true
                        }
                    }
                    Button("Delete") {
                        isEditing = false
                        viewModel.removeTodo(todoId: todo.id)
                    }
                } label: {
                    SmallIcon(image: "ellipsis")
                        .padding(1.5)
                        .foregroundColor(isHoveringAction ? Color.white : Color.secondary.opacity(0.75))
                        .background(isHoveringAction ? Color.secondary.opacity(0.25) : Color.clear)
                        .onHover { isHovering in
                            onHoverAction(isHovering)
                        }
                }
                .buttonStyle(PlainButtonStyle())
                .cornerRadius(5)
                .popover(isPresented: $showManageAccessPopover, content: {
                    if viewModel.sessionState.currentSessionUsers != nil {
                        ManageAccessPopover(viewModel: viewModel, todo: $todo, showPopover: $showManageAccessPopover)
                            .zIndex(5)
                            .onDisappear {
                                showManageAccessPopover = false
                            }
                    }
                })
            }
        }
        .padding(.vertical, 2.5)
    }
}

struct ShowCollaboratorsPopover: View {
    @ObservedObject var viewModel: SessionViewModel
    @Binding var todo: Todo
    
    @State private var collaborators: [User] = []
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 5) {
                ForEach(collaborators) { collaborator in
                    HStack {
                        Avatar(avatarURL: collaborator.avatarURL)
                        Text(collaborator.name)
                    }
                    .contentShape(Rectangle())
                }
            }
        }
        .frame(width: 240, height: 240)
        .padding()
        .onAppear(perform: initState)
    }
    
    private func initState() {
        if let userIds = todo.userIds {
            viewModel.storeService.findUsersByUserIds(userIds: userIds) { users in
                collaborators = users
            }
        }
    }
}

struct ManageAccessPopover: View {
    @ObservedObject var viewModel: SessionViewModel
    @Binding var todo: Todo
    @Binding var showPopover: Bool
    
    @State private var searchText: String = ""
    @State private var selectedUserIds: Set<String> = []
    @State private var isHoveringUser: [String: Bool] = [:]
    @State private var users: [User] = []
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Add people", text: $searchText)
                    .lineLimit(1)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(Color("Primary"))
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            Divider()
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(users.filter { user in
                        user.name.contains(searchText) || user.emailAddress.contains(searchText) || searchText.isEmpty
                    }) { user in
                        let hasCollaborators = !(selectedUserIds.count <= 1 && user.id == viewModel.authState.currentUser?.id)
                        HStack {
                            Avatar(avatarURL: user.avatarURL)
                            Text(user.name)
                            Spacer()
                            if selectedUserIds.contains(user.id) {
                                SmallIcon(image: "checkmark.circle.fill", foregroundColor: Color.blue.opacity(0.75))
                            }
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, 5)
                        .padding(.horizontal, 20)
                        .opacity(hasCollaborators ? 1.0 : 0.5)
                        .background(hasCollaborators && isHoveringUser[user.id] == true ? Color.secondary.opacity(0.25) : Color.clear)
                        .onHover { hovering in
                            isHoveringUser[user.id] = hovering
                        }
                        .id(user.id)
                        .onTapGesture {
                            if (hasCollaborators) {
                                toggleUserSelection(user: user)
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 300, height: 400)
        .onAppear(perform: initState)
        .onDisappear(perform: resetState)
        .alert(isPresented: $showAlert, content: {
            Alert(
                title: Text("Are you sure?"),
                message: Text("You will be removed as a collaborator and will no longer be able to see the task."),
                primaryButton: .default(Text("Yes").fontWeight(.bold), action: {
                    if let todoId = todo.id, let currentUserId = viewModel.authState.currentUser?.id {
                        viewModel.storeService.removeUserFromTodo(userId: currentUserId, todoId: todoId) {
                            selectedUserIds.remove(currentUserId)
                            showPopover = false
                        }
                    }
                }),
                secondaryButton: .cancel()
            )
        })
    }
    
    private func toggleUserSelection(user: User) {
        guard let todoId = todo.id else { return }
        
        if selectedUserIds.contains(user.id) {
            if user.id == viewModel.authState.currentUser?.id {
                DispatchQueue.main.async {
                    self.showAlert = true
                }
            } else {
                viewModel.storeService.removeUserFromTodo(userId: user.id, todoId: todoId) {
                    selectedUserIds.remove(user.id)
                }
            }
        } else {
            viewModel.storeService.addUserToTodo(userId: user.id, todoId: todoId) {
                selectedUserIds.insert(user.id)
            }
        }
    }
    
    private func initState() {
        if let sessionUserIds = viewModel.sessionState.currentSession?.userIds {
            viewModel.storeService.findUsersByUserIds(userIds: sessionUserIds) { fetchedUsers in
                users = fetchedUsers
            }
        }
        if let todoUserIds = todo.userIds {
            selectedUserIds = Set(todoUserIds)
        }
    }
    
    private func resetState() {
        isHoveringUser = [:]
        selectedUserIds = []
        users = []
    }
}
