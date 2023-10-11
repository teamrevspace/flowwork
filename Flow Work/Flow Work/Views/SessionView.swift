//
//  SessionView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import SwiftUI
import URLImage

struct SessionView: View {
    @ObservedObject var viewModel: SessionViewModel
    @ObservedObject var errorPublisher: ErrorPublisher
    
    init(viewModel: SessionViewModel, errorPublisher: ErrorPublisher) {
        self.viewModel = viewModel
        self.errorPublisher = errorPublisher
    }
    
    var body: some View {
        VStack{
            if viewModel.isLoading {
                Text("Loading...")
            } else {
                Group {
                    HStack{
                        Text("https://flowwork.xyz/s/\(viewModel.currentSession?.id ?? "...")")
                        Spacer()
                        Button(action: {
                            viewModel.copyToClipboard(textToCopy: "https://flowwork.xyz/s/\(viewModel.currentSession?.id ?? "...")")
                        }) {
                            Image(systemName: "doc.on.doc")
                        }
                    
                    }
                    Text("\(viewModel.currentSession?.name ?? "...")")
                    HStack {
                        if let avatarUrl = viewModel.getCurrentUser()?.avatarURL {
                            URLImage(avatarUrl) { image in
                                image
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(.infinity)
                                    .aspectRatio(contentMode: .fit)
                            }
                        } else {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .cornerRadius(.infinity)
                                .aspectRatio(contentMode: .fit)
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
        .errorOverlay(errorPublisher: errorPublisher)
    }
}
