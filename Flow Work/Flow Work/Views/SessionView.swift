//
//  SessionView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import SwiftUI

struct SessionView: View {
    @ObservedObject var viewModel: SessionViewModel
    @ObservedObject var errorPublisher: ErrorPublisher
    
    var body: some View {
        VStack{
            Button(action: {
                viewModel.leaveSession()
            }) {
                Text("Leave")
            }
        }.standardFrame()
            .errorOverlay(errorPublisher: errorPublisher)
    }
}
