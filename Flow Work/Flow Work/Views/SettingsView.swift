//
//  SettingsView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/21/23.
//

import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            VStack(spacing: 20) {
                HStack {
                    Text("Launch Flow Work at login")
                    Spacer()
                    Toggle("", isOn: $viewModel.launchAtLogin)
                        .onChange(of: viewModel.launchAtLogin) { value in
                            viewModel.handleLaunchAtLoginToggle()
                        }
                        .labelsHidden()
                }
                HStack {
                    Link(destination: URL(string: "https://flowwork.xyz")!) {
                        HStack(spacing: 5) {
                            Image(systemName: "safari.fill")
                            Text("Visit Website")
                        }
                    }
                    Spacer()
                    Text("v\(viewModel.appVersion).\(viewModel.appBuildNumber)")
                }
            }
            Spacer()
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
        .onAppear() {
            viewModel.initLaunchAtLogin()
        }
    }
}
