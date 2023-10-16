//
//  FText.swift
//  Flow Work
//
//  Created by Allen Lin on 10/16/23.
//

import SwiftUI

struct FText: View {
    var content: String
    
    init(_ content: String) {
        self.content = content
    }
    
    var body: some View {
        Text(content)
            .foregroundColor(Color("Primary"))
    }
}

