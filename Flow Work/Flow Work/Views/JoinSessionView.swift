//
//  JoinSessionView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import SwiftUI

struct JoinSessionView: View {
    @ObservedObject var viewModel: JoinSessionViewModel
    @ObservedObject var errorPublisher: ErrorPublisher
    
    var body: some View {
        VStack() {
            TextField("Enter session code or URL", text:  $viewModel.inputText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            HStack(spacing: 10) {
                Button(action: {
                    viewModel.returnToHome()
                }) {
                    Text("Back")
                }
                Button(action: {
                    viewModel.joinSession()
                }) {
                    Text("Join")
                }
            }
        }.standardFrame()
            .errorOverlay(errorPublisher: errorPublisher)
    }
}
