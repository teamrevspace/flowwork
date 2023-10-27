//
//  LobbyView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct LobbyView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State private var tabSelection: Int = 2
    
    var body: some View {
        TabView(selection: $tabSelection) {
            CreateSessionView(viewModel: viewModel)
                .tabItem {
                    Text("Host")
                }
                .tag(1)
            JoinSessionView(viewModel: viewModel)
                .tabItem {
                    Text("Lobby")
                }
                .tag(2)
        }
        .padding()
        .standardFrame()
        .onAppear() {
            viewModel.fetchSessionList()
        }
        .onDisappear() {
            viewModel.joinSessionCode = ""
            viewModel.newSessionName = ""
            viewModel.newSessionPassword = ""
            viewModel.storeService.stopLobbyListener()
        }
    }
}

struct CreateSessionView: View {
    @ObservedObject var viewModel: LobbyViewModel
    
    var body: some View {
        VStack {
            TextField("Session name", text:  $viewModel.newSessionName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack{
                Group {
                    if viewModel.showPassword {
                        TextField("Set password (optional)", text:  $viewModel.newSessionPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Set password (optional)", text:  $viewModel.newSessionPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                    }
                }
                Button(action: {
                    viewModel.showPassword.toggle()
                }) {
                    Image(systemName: viewModel.showPassword ? "eye.slash" : "eye")
                        .accentColor(.gray)
                }
            }
            Spacer()
            HStack(spacing: 10) {
                FButton(text: "Back") {
                    viewModel.returnToHome()
                }
                FButton(text: "Create") {
                    if (!viewModel.newSessionName.isEmpty) {
                        guard let currentUserId = viewModel.authState.currentUser?.id else { return }
                        viewModel.createSession(userIds: [currentUserId])
                    }
                }
            }
        }
        .padding(10)
    }
}

struct JoinSessionView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State private var selectedSessionId: String?
    
    var body: some View {
        VStack {
            TextField("Enter session code or URL", text:  $viewModel.joinSessionCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    viewModel.joinSession(viewModel.joinSessionCode)
                }
            
            Group {
                if viewModel.isSessionListLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    List(viewModel.sessionState.availableSessions) { session in
                        HStack {
                            SessionItem(session: session)
                                .foregroundColor(selectedSessionId == session.id ? Color.white : Color.primary)
                                .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
                                .contentShape(Rectangle())
                                .background(selectedSessionId == session.id ? Color.blue : Color.clear)
                                .gesture(TapGesture(count: 2).onEnded {
                                    viewModel.joinSession(session.id)
                                })
                                .simultaneousGesture(TapGesture().onEnded {
                                    selectedSessionId = session.id
                                })
                                .contextMenu {
                                    Button("Remove") {
                                        guard let userId = viewModel.authState.currentUser?.id else { return }
                                        viewModel.storeService.removeUserFromSession(userId: userId, sessionId: session.id)
                                    }
                                }
                        }
                    }
                    .background(Color.clear)
                    .padding(0)
                    .frame(minHeight: 200)
                    .cornerRadius(5)
                    .listStyle(.plain)
                }
            }
            
            HStack(spacing: 10) {
                FButton(text: "Back") {
                    viewModel.returnToHome()
                }
                FButton(text: "Join") {
                    viewModel.joinSession(selectedSessionId)
                }
            }
        }
        .padding(10)
    }
}
