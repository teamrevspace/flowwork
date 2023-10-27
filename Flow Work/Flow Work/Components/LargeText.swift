//
//  LargeText.swift
//  Flow Work
//
//  Created by Allen Lin on 10/27/23.
//

import SwiftUI

struct LargeText: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(Color.secondary)
    }
}
