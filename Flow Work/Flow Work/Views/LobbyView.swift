//
//  LobbyView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct LobbyView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State private var selectedSessionId: String?
    
    var body: some View {
        VStack() {
            TextField("Enter session code or URL", text:  $viewModel.inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: viewModel.inputText) { _ in
                    viewModel.errorService.clearError()
                }
                List(viewModel.availableSessions) { session in
                    HStack {
                        Text(session.name)
                            .foregroundColor(selectedSessionId == session.id ? Color.white : Color.black)
                        Spacer()
                    }
                    .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .contentShape(Rectangle())
                    .background(selectedSessionId == session.id ? Color.blue : Color.clear)
                    .onTapGesture {
                        selectedSessionId = session.id
                    }
                }
                .frame(height: 240)
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
        .standardFrame()
        .errorOverlay(errorService: viewModel.errorService)
        .onAppear() {
            viewModel.inputText = ""
            viewModel.fetchSessionList()
        }
    }
}
