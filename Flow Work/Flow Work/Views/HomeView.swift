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
//                    Image("FlowWorkLogo")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .scaledToFit()
//                    Text("Flow Work")
//                        .font(.title)
//                        .fontWeight(.bold)
                    Text("Choose your work mode")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
                
                AccountMenu(viewModel: viewModel)
            }
            if (viewModel.authState.isSignedIn) {
                VStack(alignment: .leading, spacing: 10) {
                    Button(action: {
                        viewModel.sessionService.updateWorkMode(.lounge)
                    }) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 5) {
                                Image(systemName: "sofa.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                Text("Lounge Mode")
                                    .font(.headline)
                            }
                            Text("Cowork with others in a virtual lounge. Join audio room or share screen to collaborate on tasks.")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(10)
                        .background(viewModel.sessionState.selectedMode == .lounge ? Color.blue.opacity(0.9) : Color.secondary.opacity(0.1))
                        .foregroundColor(viewModel.sessionState.selectedMode == .lounge ? Color.white : Color("Primary").opacity(0.75))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        viewModel.sessionService.updateWorkMode(.pomodoro)
                    }) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 5) {
                                Image(systemName: "deskclock.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                Text("Pomodoro Mode")
                                    .font(.headline)
                            }
                            Text("Set a timer to focus on your task. Take a 5 minute break after each Pomodoro.")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(10)
                        .background(viewModel.sessionState.selectedMode == .pomodoro ? Color.red.opacity(0.9) : Color.secondary.opacity(0.1))
                        .foregroundColor(viewModel.sessionState.selectedMode == .pomodoro ? Color.white : Color("Primary").opacity(0.75))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        viewModel.sessionService.updateWorkMode(.focus)
                    }) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 5) {
                                Image(systemName: "moon.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                Text("Focus Mode")
                                    .font(.headline)
                            }
                            Text("Hide all your apps to focus on your task. Restore them after your session.")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(10)
                        .background(viewModel.sessionState.selectedMode == .focus ? Color.indigo.opacity(0.9) : Color.secondary.opacity(0.1))
                        .foregroundColor(viewModel.sessionState.selectedMode == .focus ? Color.white : Color("Primary").opacity(0.75))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
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
                        Text("List your daily tasks to organize your workflow and prioritize your day. Add up to 8 tasks at a time.")
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
                Button(action: {
                    if viewModel.authState.isSignedIn {
                        viewModel.todoService.sanitizeTodoItems()
                        viewModel.goToLobby()
                    } else {
                        viewModel.signInWithGoogle()
                    }
                }) {
                    Text(viewModel.authState.isSignedIn ? "Start Your Flow" : "Get Started")
                }
            }
        }
        .padding()
        .standardFrame()
    }
}


