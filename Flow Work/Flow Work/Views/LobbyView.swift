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
        VStack() {
            TextField("Enter session code or URL", text:  $viewModel.inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: viewModel.inputText) { _ in
                    viewModel.errorService.clearError()
                }
                List(viewModel.availableSessions) { session in
                    HStack {
                        Text(session.name)
                        Spacer()
                    }.onTapGesture {
                        viewModel.joinSession(session.id)
                    }
                }
                .frame(height: 240)
                .cornerRadius(5)
            HStack(spacing: 10) {
                Button(action: {
                    viewModel.returnToHome()
                }) {
                    Text("Back")
                }
                Button(action: {
                    viewModel.joinSession()
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
            viewModel.fetchData()
        }
    }
}
