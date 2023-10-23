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
            Text(timeString(from: viewModel.timeRemaining))
                .font(.largeTitle)
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
        .padding()
        .frame(height: 40)
    }
    
    func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
