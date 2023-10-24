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
            Spacer()
            if (viewModel.authState.isSignedIn) {
                VStack(alignment: .leading, spacing: 10) {
                    WorkModeButton(viewModel: viewModel, mode: .lounge, iconName: "sofa.fill", title: "Lounge Mode", description: "Cowork with others in a virtual lounge. Join audio room or share screen to collaborate on tasks.")
                    
                    WorkModeButton(viewModel: viewModel, mode: .pomodoro, iconName: "deskclock.fill", title: "Pomodoro Mode", description: "Set a timer to focus on your task. Take a short break after each Pomodoro.")
                    
                    WorkModeButton(viewModel: viewModel, mode: .focus, iconName: "moon.fill", title: "Focus Mode", description: "Hide all your apps to focus on your task. Restore them after your session.")
                }
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 5) {
                            Image(systemName: "person.fill")
                            Text("Set up your account")
                                .font(.headline)
                        }
                        Text("Sign in to sync tasks, join coworking sessions, and track your productivity streaks.")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 5) {
                            Image(systemName: "checkmark.square.fill")
                            Text("Add a task")
                                .font(.headline)
                        }
                        Text("List your daily tasks to organize your workflow and prioritize your day. Complete tasks each day to keep up your streaks.")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 5) {
                            Image(systemName: "link")
                            Text("Join a Session")
                                .font(.headline)
                        }
                        Text("Start or join a coworking session in one click. Invite your friends to kickstart your collaborative productivity journey.")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            Spacer()
            HStack {
                if viewModel.authState.isSignedIn {
                    Button(action: {
                        viewModel.goToLobby()
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color("Primary").opacity(0.75))
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Button(action: {
                        viewModel.signInWithGoogle()
                    }) {
                        Text("Sign in with Google")
                    }
                }
            }
        }
        .padding()
        .standardFrame()
    }
}


