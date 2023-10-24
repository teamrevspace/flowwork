//
//  WorkModeButton.swift
//  Flow Work
//
//  Created by Allen Lin on 10/23/23.
//

import Foundation
import SwiftUI

struct WorkModeButton: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var mode: WorkMode
    var iconName: String
    var title: String
    var description: String
    
    var isSelected: Bool {
        viewModel.sessionState.selectedMode == mode
    }
    
    var body: some View {
        Button(action: {
            viewModel.sessionService.updateWorkMode(mode)
        }) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                    Image(systemName: iconName)
                        .resizable()
                        .frame(width: 15, height: 15)
                    Text(title)
                        .font(.headline)
                }
                Text(description)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
            .background(isSelected ? mode.color.opacity(0.9) : Color.secondary.opacity(0.1))
            .foregroundColor(isSelected ? Color.white : Color("Primary").opacity(0.75))
            .cornerRadius(10)
            .gesture(TapGesture(count: 2).onEnded {
                viewModel.goToLobby()
            })
            .simultaneousGesture(TapGesture().onEnded {
                viewModel.sessionService.updateWorkMode(mode)
            })
        }
        .buttonStyle(PlainButtonStyle())
    }
}