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
                Button(action: {
                    viewModel.goToProfile()
                }) {
                    Text("Profile")
                }
            }
            Button(action: {
                viewModel.goToSettings()
            }) {
                Text("Settings")
            }
            Button(action: {
                NSApp.terminate(nil)
            }) {
                Text("Quit App")
            }
        } label: {
            AvatarView(avatarURL: viewModel.authState.currentUser?.avatarURL)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
