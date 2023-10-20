//
//  MarqueeText.swift
//  Flow Work
//
//  Created by Allen Lin on 10/19/23.
//

import Foundation
import SwiftUI

struct MarqueeText: View {
    @State private var hover = false
    @State private var offset: CGFloat = 0
    var text: String
    private let spacing: CGFloat = 20.0
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: spacing) {
                Text(text)
                    .font(.body)
                    .fixedSize(horizontal: true, vertical: false)
                
                if text.width(usingFont: .body) + spacing > geometry.size.width {
                    Text(text)
                        .font(.body)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: -offset)
            .lineLimit(hover ? nil : 1)
            .truncationMode(.tail)
            .onContinuousHover { hoverState in
                switch hoverState {
                case .active:
                    withAnimation(Animation.linear(duration: Double(text.count) * 0.1)
                        .repeatForever(autoreverses: false)) {
                            hover = text.width(usingFont: .body) + spacing > geometry.size.width
                            offset = hover ? text.width(usingFont: .body) + spacing : 0
                        }
                case .ended:
                    withAnimation() {
                        hover = false
                        offset = 0
                    }
                }
            }
        }
    }
}

extension String {
    func width(usingFont font: Font) -> CGFloat {
        let nsFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        let fontAttributes = [NSAttributedString.Key.font: nsFont]
        let size = (self as NSString).size(withAttributes: fontAttributes)
        return size.width
    }
}
