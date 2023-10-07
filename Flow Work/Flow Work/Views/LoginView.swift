//
//  LoginView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @ObservedObject var errorPublisher: ErrorPublisher
    
    var body: some View {
        VStack{
            Button(action: {
                viewModel.signInWithGoogle()
            }) {
                Text("Sign in with Google")
            }
        }.standardFrame()
            .errorOverlay(errorPublisher: errorPublisher)
    }
}
