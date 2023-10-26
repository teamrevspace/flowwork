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
            AsyncImage(url: url) { phase in
                if let image = phase.image  {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.secondary.opacity(0.5))
                        .cornerRadius(.infinity)
                        .aspectRatio(contentMode: .fit)
                } else if phase.error != nil {
                    PlaceholderAvatar()
                } else {
                    ProgressView()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.secondary.opacity(0.5))
                        .cornerRadius(.infinity)
                }
            }
        } else {
            PlaceholderAvatar()
        }
    }
}

struct PlaceholderAvatar: View {
    var body: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundColor(Color.secondary.opacity(0.5))
            .cornerRadius(.infinity)
            .aspectRatio(contentMode: .fit)
    }
}
