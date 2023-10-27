//
//  SmallIcon.swift
//  Flow Work
//
//  Created by Allen Lin on 10/27/23.
//

import SwiftUI

struct SmallIcon: View {
    var image: String
    var foregroundColor: Color? = Color.secondary
    
    var body: some View {
        Image(systemName: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 15, height: 15)
            .foregroundColor(foregroundColor)
    }
}
