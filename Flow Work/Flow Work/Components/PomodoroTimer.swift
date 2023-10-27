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
        HStack(alignment: .center) {
            Text(viewModel.timeString(from: viewModel.timeRemaining))
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            HStack(spacing: 10) {
                Group {
                    if viewModel.isTimerRunning {
                        Button(action: {
                            viewModel.pauseTimer()
                            viewModel.playClickSound()
                        }) {
                            Image(systemName: "pause.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color("Primary").opacity(0.75))
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Button(action: {
                            viewModel.startTimer()
                            viewModel.playClickSound()
                        }) {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color("Primary").opacity(0.75))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                if viewModel.timerType == .pomodoro {
                    Button(action: {
                        viewModel.resetTimer()
                        viewModel.startTimer()
                        viewModel.playWindUpSound()
                    }) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color("Primary").opacity(0.75))
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Button(action: {
                        viewModel.skipTimer()
                        viewModel.playTickSound()
                    }) {
                        Image(systemName: "arrow.right.to.line.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color("Primary").opacity(0.75))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(0)
        .frame(height: 30)
    }
}
