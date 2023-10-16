//
//  LobbyView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct LobbyView: View {
    @ObservedObject var viewModel: LobbyViewModel
    
    var body: some View {
        TabView {
            CreateSessionView(viewModel: viewModel)
                .tabItem {
                    Text("Create")
                }
            JoinSessionView(viewModel: viewModel)
                .tabItem {
                    Text("Join")
                }
        }
        .padding(10)
        .standardFrame()
        .onAppear() {
            viewModel.fetchSessionList()
        }
        .onDisappear() {
            viewModel.inputText = ""
        }
    }
}

struct CreateSessionView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State private var newSessionName: String = ""
    @State private var newSessionPassword: String = ""
    @State private var showPassword: Bool = false
    @FocusState var focus1: Bool
    @FocusState var focus2: Bool
    
    var body: some View {
        VStack{
            TextField("Enter session name", text:  $newSessionName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            ZStack {
                HStack{
                    Group {
                        if showPassword {
                            TextField("Set password (optional)", text:  $newSessionPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .focused($focus1)
                        }else {
                            SecureField("Set password (optional)", text:  $newSessionPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .focused($focus2)
                        }
                    }
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: self.showPassword ? "eye.slash" : "eye")
                            .accentColor(.gray)
                    }
                }
            }
            
        }
        .padding(10)
        .errorOverlay(errorService: viewModel.errorService)
    }
}

struct JoinSessionView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State private var selectedSessionId: String?
    
    var body: some View {
        VStack() {
            TextField("Enter session code or URL", text:  $viewModel.inputText)
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
        .errorOverlay(errorService: viewModel.errorService)
    }
}
