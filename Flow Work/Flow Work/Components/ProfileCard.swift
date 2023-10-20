//
//  ProfileInfoPopup.swift
//  Flow Work
//
//  Created by Allen Lin on 10/20/23.
//

import Foundation

struct ProfileInfoPopup: View {
    var user: User
    
    var body: some View {
        VStack {
            if viewModel.authState.currentUser != nil {
                Text("Hi \(viewModel.authState.currentUser!.name)!")
                Button("Log out") {
                    viewModel.signOut()
                }
            } else {
                Text("Hi there!")
                Button(action: {
                    viewModel.signInWithGoogle()
                }) {
                    Text("Sign in with Google")
                }
            }
        }
        .padding(15)
    }
}
