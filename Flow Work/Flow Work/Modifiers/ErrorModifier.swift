//
//  ErrorModifier.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import SwiftUI

struct ErrorOverlayModifier: ViewModifier {
    var errorService: ErrorServiceProtocol
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if let errorMessage = errorService.errorMessage {
                        Text(errorMessage)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            )
            .onReceive(errorService.errorPublisher) { error in
                Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                    self.errorService.clearError()
                }
            }
    }
}

extension View {
    func errorOverlay(errorService: ErrorServiceProtocol) -> some View {
        self.modifier(ErrorOverlayModifier(errorService: errorService))
    }
}
