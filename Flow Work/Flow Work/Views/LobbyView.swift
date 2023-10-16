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
        .errorOverlay(errorService: viewModel.errorService)
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
        VStack{
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
            
            HStack(spacing: 10) {
                Button(action: {
                    viewModel.returnToHome()
                }) {
                    Text("Back")
                }
                Button(action: {
                    let userIds = [self.viewModel.authState.currentUser!.id]
                    if (!viewModel.newSessionName.isEmpty) {
                        viewModel.createSession(userIds: userIds)
                    }
                }) {
                    Text("Create")
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
        VStack() {
            TextField("Enter session code or URL", text:  $viewModel.joinSessionCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            List(viewModel.availableSessions) { session in
                HStack {
                    Text(session.name)
                        .foregroundColor(selectedSessionId == session.id ? Color.white : Color.primary)
                    Spacer()
                }
                .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
                .contentShape(Rectangle())
                .background(selectedSessionId == session.id ? Color.blue : Color.clear)
                .gesture(TapGesture(count: 2).onEnded {
                    viewModel.joinSession(session.id)
                })
                .simultaneousGesture(TapGesture().onEnded {
                    selectedSessionId = session.id
                })
            }
            .frame(minHeight: 240)
            .cornerRadius(5)
            .listStyle(.plain)
            
            HStack(spacing: 10) {
                Button(action: {
                    viewModel.returnToHome()
                }) {
                    Text("Back")
                }
                Button(action: {
                    viewModel.joinSession(selectedSessionId)
                }) {
                    Text("Join")
                }
            }
        }
        .padding(10)
    }
}
