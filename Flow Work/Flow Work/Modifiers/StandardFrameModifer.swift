//
//  StandardFrameModifier.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import SwiftUI

struct StandardFrameModifier: ViewModifier {
    private let minWidth: CGFloat = 360
    private let minHeight: CGFloat = 60
    private let maxHeight: CGFloat = 360
    
    func body(content: Content) -> some View {
        content
            .frame(minWidth: minWidth, maxWidth: minWidth, minHeight: minHeight, maxHeight: maxHeight)
            .background(Color.clear)
            .background(.ultraThinMaterial, in: Rectangle())
    }
}

extension View {
    func standardFrame() -> some View {
        self.modifier(StandardFrameModifier())
    }
}
