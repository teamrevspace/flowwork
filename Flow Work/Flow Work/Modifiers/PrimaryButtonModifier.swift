//
//  PrimaryButtonModifier.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import SwiftUI

struct PrimaryButtonModifier: ViewModifier {
    private let minWidth: CGFloat = 360
    private let minHeight: CGFloat = 120
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 40)
            .padding(.vertical, 10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

extension View {
    func primaryButton() -> some View {
        self.modifier(PrimaryButtonModifier())
    }
}
