//
//  FButton.swift
//  Flow Work
//
//  Created by Allen Lin on 10/25/23.
//

import SwiftUI

struct FButton: View {
    var image: String?
    var text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 5) {
                if let imageName = image {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                }
                Text(text)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
        }
        .background(Color.secondary.opacity(0.25))
        .cornerRadius(5)
        .buttonStyle(PlainButtonStyle())
    }
}
