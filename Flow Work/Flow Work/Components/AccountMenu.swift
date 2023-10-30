//
//  AccountMenu.swift
//  Flow Work
//
//  Created by Allen Lin on 10/22/23.
//

import SwiftUI

struct AccountMenu: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        Menu {
            Text("Hi \(viewModel.authState.currentUser?.name ?? "there")!")
            if viewModel.authState.isSignedIn {
                Button("Profile") {
                    viewModel.goToProfile()
                }
            }
            Button("Settings") {
                viewModel.goToSettings()
            }
            if viewModel.authState.isSignedIn {
                Button("Log out") {
                    viewModel.signOut()
                }
            }
        } label: {
            Avatar(avatarURL: viewModel.authState.currentUser?.avatarURL)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
