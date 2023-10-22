//
//  SessionItem.swift
//  Flow Work
//
//  Created by Allen Lin on 10/19/23.
//

import Foundation
import SwiftUI

struct SessionItem: View {
    var session: Session
    
    @State private var hover = false
    @State private var offset: CGFloat = 0
    
    private let spacing: CGFloat = 20.0
    
    var body: some View {
        HStack {
            GeometryReader { geometry in
                HStack(spacing: spacing) {
                    Text(session.name)
                        .font(.body)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    if session.name.width(usingFont: .body) + spacing > geometry.size.width {
                        Text(session.name)
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
                        withAnimation(Animation.linear(duration: Double(session.name.count) * 0.1)
                            .repeatForever(autoreverses: false)) {
                                hover = session.name.width(usingFont: .body) + spacing > geometry.size.width
                                offset = hover ? session.name.width(usingFont: .body) + spacing : 0
                            }
                    case .ended:
                        withAnimation() {
                            hover = false
                            offset = 0
                        }
                    }
                }
            }
            Spacer()
            Text("\(session.onlineUserCount ?? 0)/\(session.userIds?.count ?? 0)")
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
