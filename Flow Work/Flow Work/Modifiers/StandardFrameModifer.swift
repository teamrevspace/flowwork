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
    private let minHeight: CGFloat = 120
    private let maxHeight: CGFloat = 480
    
    func body(content: Content) -> some View {
        content
            .frame(minWidth: minWidth, minHeight: minHeight, maxHeight: maxHeight)
            .fixedSize()
            .background(Color(NSColor.windowBackgroundColor))
    }
}

extension View {
    func standardFrame() -> some View {
        self.modifier(StandardFrameModifier())
    }
}
