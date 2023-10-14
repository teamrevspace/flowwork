//
//  SessionView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct SessionView: View {
    @ObservedObject var viewModel: SessionViewModel
    
    var body: some View {
        VStack{
            if viewModel.sessionState.currentSession == nil {
                VStack(spacing: 10) {
                    ProgressView()
                    Button(action: {
                        viewModel.leaveSession()
                    }) {
                        HStack {
                            Text("Back")
                        }
                    }
                }
            } else {
                Group {
                    HStack{
                        Text("\(viewModel.sessionState.currentSession!.name)")
                        Spacer()
                        Button(action: {
                            viewModel.copyToClipboard(textToCopy: "https://flowwork.xyz/s/\(viewModel.sessionState.currentSession!.id)")
                        }) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Invite Link")
                        }
                        
                    }
                    Spacer()
                    HStack {
                        ForEach(viewModel.sessionUsers) { user in
                            AvatarView(avatarURL: user.avatarURL)
                        }
                        Spacer()
                        Button(action: {
                            viewModel.leaveSession()
                        }) {
                            Text("Leave Session")
                        }
                    }
                }
            }
        }
        .padding(10)
        .standardFrame()
        .errorOverlay(errorService: viewModel.errorService)
        .onAppear() {
            viewModel.fetchData()
        }
    }
}
