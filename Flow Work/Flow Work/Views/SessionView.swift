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
            if viewModel.sessionService.currentSession == nil {
                VStack {
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
                        Text("https://flowwork.xyz/s/\(viewModel.sessionService.currentSession!.id)")
                        Spacer()
                        Button(action: {
                            viewModel.copyToClipboard(textToCopy: "https://flowwork.xyz/s/\(viewModel.sessionService.currentSession!.id)")
                        }) {
                            Image(systemName: "doc.on.doc")
                        }
                        
                    }
                    Text("\(viewModel.sessionService.currentSession!.name)")
                    HStack {
                        ForEach(viewModel.sessionUsers) { user in
                            AvatarView(avatarURL: user.avatarURL)
                        }
                        Spacer()
                        Button(action: {
                            viewModel.leaveSession()
                        }) {
                            Text("Leave")
                        }
                    }
                }
            }
        }
        .padding(10)
        .standardFrame()
        .errorOverlay(errorService: viewModel.errorService)
    }
}
