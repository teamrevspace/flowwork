//
//  PomodoroTimer.swift
//  Flow Work
//
//  Created by Allen Lin on 10/23/23.
//

import SwiftUI

struct PomodoroTimer: View {
    @ObservedObject var viewModel: SessionViewModel
    
    var body: some View {
        HStack {
            Text(viewModel.timeString(from: viewModel.timeRemaining))
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            if viewModel.isTimerRunning {
                Button("Pause") {
                    viewModel.pauseTimer()
                }
            } else {
                Button("Start") {
                    viewModel.startTimer()
                }
            }
            Button("Reset") {
                viewModel.resetTimer()
            }
        }
        .padding(0)
        .frame(height: 40)
    }
}
