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
    @State private var shakeTrigger: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                //                HStack(spacing: 5) {
                //                    Circle()
                //                        .frame(width: 10, height: 10)
                //                        .foregroundColor(viewModel.sessionState.isConnected ? .green : .red)
                //                    Text(viewModel.sessionState.isConnected ? "connected" : "not connected")
                //                }
                HStack {
                    Image("FlowWorkLogo")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                    Text("Flow Work")
                        .font(.title)
                        .fontWeight(.bold)
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
            VStack(alignment: .leading) {
                ForEach(0..<viewModel.todoItems.count, id: \.self) { index in
                    HStack {
                        Toggle("", isOn: .constant(false))
                            .labelsHidden()
                        
                        TextField("New to-do", text: $viewModel.todoItems[index])
                            .textFieldStyle(PlainTextFieldStyle())
                            .focused($focusedField, equals: index)
                            .frame(maxWidth: .infinity)
                        
                        if (viewModel.todoItems.count > 1 && !viewModel.todoItems[index].isEmpty) {
                            Button(action: {
                                viewModel.todoItems.remove(at: index)
                            }) {
                                Image(systemName: "xmark")
                                    .padding(2)
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(viewModel.isHoveringDeleteButtons[index] ? Color.secondary : Color.secondary.opacity(0.5))
                            .background(viewModel.isHoveringDeleteButtons[index] ? Color.secondary.opacity(0.25) : Color.clear)
                            .cornerRadius(5)
                            .onHover { isHovering in
                                viewModel.isHoveringDeleteButtons[index] = isHovering
                            }
                            
                        }
                    }
                    .padding(.vertical, 2.5)
                }
                
                if viewModel.todoItems.count < 3 {
                    Button(action: {
                        if !(viewModel.todoItems.last?.isEmpty ?? true) {
                            viewModel.todoItems.append("")
                            focusedField = viewModel.todoItems.count - 1
                        } else {
                            focusedField = viewModel.todoItems.count - 1
                        }
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
                    .background((viewModel.todoItems.last?.isEmpty ?? false) ? Color.secondary.opacity(0.1) : !viewModel.isHoveringAddButton ? Color.secondary.opacity(0.25) : Color.secondary.opacity(0.4))
                    .cornerRadius(5)
                    .disabled(viewModel.todoItems.last?.isEmpty ?? false)
                    .onHover { isHovering in
                        if (!(viewModel.todoItems.last?.isEmpty ?? true)) {
                            viewModel.isHoveringAddButton = isHovering
                        }
                    }
                }
                Spacer()
            }
            .padding(.bottom, 10)
            
            HStack{
                Button(action: {
                    if viewModel.authState.isSignedIn {
                        viewModel.sanitizeTodoItems()
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
