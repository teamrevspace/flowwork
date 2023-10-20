//
//  LoginView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack{
            Button(action: {
                viewModel.signInWithGoogle()
            }) {
                Text("Sign in with Google")
            }
        }
        .padding()
        .standardFrame()
    }
}
