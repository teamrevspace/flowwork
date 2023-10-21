//
//  AppView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import SwiftUI

struct AppView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    var body: some View {
        GeometryReader { geometry in
            coordinator.currentView
                .backgroundStyle(.clear)
                .frame( width: geometry.size.width, height: geometry.size.height, alignment: .top)
                .padding(0)
        }
    }
}
