//
//  LargeIcon.swift
//  Flow Work
//
//  Created by Allen Lin on 10/27/23.
//

import SwiftUI

struct LargeIcon: View {
    var image: String
    
    var body: some View {
        Image(systemName: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundColor(Color.secondary)
    }
}
