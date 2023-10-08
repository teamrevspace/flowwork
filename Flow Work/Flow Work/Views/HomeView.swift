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
            Text("Hi \(viewModel.displayName)!")
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
        }.standardFrame()
            .errorOverlay(errorPublisher: errorPublisher)
    }
}
