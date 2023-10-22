//
//  ProfileView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/22/23.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Profile")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            if (viewModel.authState.isSignedIn) {
                Group {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Account: \(viewModel.authState.currentUser!.emailAddress)")
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Spacer()
                            Button(action: {
                                viewModel.signOut()
                            }) {
                                Text("Log out")
                            }
                        }
                    }
                }
                Spacer()
            }
            HStack(spacing: 10) {
                Button(action: {
                     viewModel.returnToHome()
                }) {
                    Text("Done")
                }
            }
        }
        .padding()
        .standardFrame()
    }
}
