//
//  HomeView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var scrollToIndex: Int? = nil
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    if viewModel.authState.isSignedIn {
                        Text("Choose your work mode")
                            .font(.title)
                            .fontWeight(.bold)
                    } else {
                        Image("FlowWorkLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .scaledToFit()
                        Text("Flow Work")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                Spacer()
                AccountMenu(viewModel: viewModel)
            }
            if (viewModel.authState.isSignedIn) {
                Spacer()
                VStack(alignment: .leading, spacing: 10) {
                    WorkModeButton(viewModel: viewModel, mode: .lounge, iconName: "sofa.fill", title: "Lounge Mode", description: "Cowork with others in a virtual lounge. Join audio room or share screen to collaborate on tasks.")
                    
                    WorkModeButton(viewModel: viewModel, mode: .pomodoro, iconName: "deskclock.fill", title: "Pomodoro Mode", description: "Set a timer to focus on your task. Take a short break after each Pomodoro.")
                    
                    WorkModeButton(viewModel: viewModel, mode: .focus, iconName: "moon.fill", title: "Focus Mode (Beta)", description: "Hide all your apps to focus on your task. Restore them after your session.")
                }
            }
            VStack(spacing: 20) {
                if viewModel.authState.isSignedIn {
                    Button(action: {
                        viewModel.goToLobby()
                    }) {
                        LargeIcon(icon: "arrow.right.circle.fill", foregroundColor: Color("Primary").opacity(0.75))
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Spacer()
                    FButton(image: "GoogleLogo", text: "Sign in with Google") {
                        viewModel.signInWithGoogle()
                    }
                    .fontWeight(.medium)
                    Button(action: {
                        viewModel.signInWithApple()
                    }) {
                        HStack(alignment: .center, spacing: 5) {
                            FButton(image: "AppleLogo", text: "Sign in with Apple") {
                                viewModel.signInWithApple()
                            }
                            .foregroundColor(Color("Secondary"))
                        }
                        
                    }
                    .background(Color("Primary"))
                    .cornerRadius(5)
                    .buttonStyle(PlainButtonStyle())
                    .fontWeight(.medium)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .standardFrame()
    }
}


