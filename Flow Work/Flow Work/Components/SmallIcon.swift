//
//  SmallIcon.swift
//  Flow Work
//
//  Created by Allen Lin on 10/27/23.
//

import SwiftUI

struct SmallIcon: View {
    var icon: String?
    var image: String?
    var foregroundColor: Color? = Color.secondary
    
    var body: some View {
        if let imageName = image {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15)
                .foregroundColor(foregroundColor)
        } else if let iconName = icon {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15)
                .foregroundColor(foregroundColor)
        }
    }
}
