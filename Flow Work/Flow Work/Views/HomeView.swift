//
//  HomeView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Hi \(viewModel.authService.currentUser!.name)!")
                    Spacer()
                    HStack(spacing: 10) {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(viewModel.sessionService.isConnected ? .green : .red)
                        Text(viewModel.sessionService.isConnected ? "connected" : "not connected")
                    }
                }
                Spacer()
            }
            VStack{
                Button("Create a session") {
                    let sessionName = self.viewModel.generateSlug()
                    let userIds = [self.viewModel.authService.currentUser!.id]
                    viewModel.createSession(sessionName: sessionName, userIds: userIds)
                }
                Button("Join a session") {
                    viewModel.goToLobby()
                }
                Button("Log out") {
                    viewModel.signOut()
                }
            }
        }
        .padding(10)
        .standardFrame()
        .errorOverlay(errorService: viewModel.errorService)
    }
}
