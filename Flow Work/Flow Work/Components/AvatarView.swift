//
//  AvatarView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import SwiftUI

struct AvatarView: View {
    let avatarURL: URL?
    @State private var isHovering: Bool = false
    
    var body: some View {
        if let url = avatarURL {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.secondary.opacity(0.5))
                    .cornerRadius(.infinity)
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.secondary.opacity(0.5))
                    .cornerRadius(.infinity)
            }
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(Color.secondary.opacity(0.5))
                .cornerRadius(.infinity)
                .aspectRatio(contentMode: .fit)
        }
    }
}
