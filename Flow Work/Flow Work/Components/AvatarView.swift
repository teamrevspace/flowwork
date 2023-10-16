//
//  AvatarView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Foundation
import SwiftUI
import URLImage

struct AvatarView: View {
    let avatarURL: URL?
    
    var body: some View {
        if let url = avatarURL {
            URLImage(url) { image in
                image
                    .resizable()
                    .frame(width: 30, height: 30)
                    .background(Color.secondary.opacity(0.5))
                    .cornerRadius(.infinity)
                    .aspectRatio(contentMode: .fit)
            }
        } else {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 30, height: 30)
                .background(Color.secondary.opacity(0.5))
                .cornerRadius(.infinity)
                .aspectRatio(contentMode: .fit)
        }
    }
}
