//
//  HomeView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import SwiftUI
import Firebase

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var errorPublisher: ErrorPublisher
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Hi \(viewModel.displayName)!")
                    Spacer()
                    HStack(spacing: 10) {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(viewModel.isConnected ? .green : .red)
                        Text(viewModel.isConnected ? "connected" : "not connected")
                    }
                }
                Spacer()
            }
            VStack{
                Button("Create a session") {
                    let sessionName = self.viewModel.generateSlug()
                    viewModel.createSession(sessionName: sessionName)
                }
                Button("Join a session") {
                    viewModel.joinSession()
                }
                Button("Log out") {
                    viewModel.signOut()
                }
            }
        }
        .padding(10)
        .standardFrame()
            .errorOverlay(errorPublisher: errorPublisher)
    }
}
