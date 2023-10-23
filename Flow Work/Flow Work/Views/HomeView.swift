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
        let todoListCount = viewModel.todoState.todoItems.count
        VStack {
            HStack {
                HStack {
                    Image("FlowWorkLogo")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                    Text("Flow Work")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
                
                AccountMenu(viewModel: viewModel)
            }
            if (viewModel.authState.isSignedIn) {
                VStack(alignment: .leading, spacing: 10) {
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
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
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
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
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
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
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
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .standardFrame()
        .onAppear() {
            viewModel.selectedMode = .lounge
        }
    }
}


