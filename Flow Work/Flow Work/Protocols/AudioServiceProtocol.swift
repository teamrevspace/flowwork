//
//  AudioServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/24/23.
//

protocol AudioServiceProtocol {
    var isMuted: Bool { get set }
    
    func playSound(_ name: SoundFx)
    func muteSoundFx(_ mute: Bool)
}
