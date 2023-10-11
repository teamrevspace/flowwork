//
//  ErrorModifier.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import SwiftUI

struct ErrorOverlayModifier: ViewModifier {
    @ObservedObject var errorPublisher: ErrorPublisher
    @State private var errorMessage: String? = nil
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if self.errorPublisher.showError {
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            )
            .onReceive(errorPublisher.errorPublisher) { error in
                self.errorMessage = error
                Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                    self.errorPublisher.clearError()
                }
            }
    }
}

extension View {
    func errorOverlay(errorPublisher: ErrorPublisher) -> some View {
        self.modifier(ErrorOverlayModifier(errorPublisher: errorPublisher))
    }
}
