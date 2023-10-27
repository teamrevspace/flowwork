//
//  CategoryItem.swift
//  Flow Work
//
//  Created by Allen Lin on 10/26/23.
//

import Foundation
import SwiftUI

struct CategoryItem: View {
    var category: Category
    @Binding var selectedCategory: Category?
    @Binding var isSidebarVisible: Bool
    var onSelect: () -> Void
    
    var body: some View {
            HStack(alignment: .top) {
                Text(category.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(5)
            .background(selectedCategory?.id == category.id ? Color.secondary.opacity(0.25) : Color.clear)
            .contentShape(Rectangle())
            .cornerRadius(5)
            .onTapGesture {
                onSelect()
                withAnimation {
                    isSidebarVisible = false
                }
            }
        }
}
