//
//  AudioService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/24/23.
//

import AppKit
import Swinject

class AudioService: AudioServiceProtocol {
    @Published var isMuted: Bool = false
    
    private var sounds: [SoundFx: NSSound] = [:]
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        
        loadSounds()
        loadMuteSoundFxSetting()
    }
    
    func playSound(_ name: SoundFx) {
        guard !isMuted, let sound = sounds[name] else { return }
        sound.play()
    }
    
    func muteSoundFx(_ mute: Bool) {
        isMuted = mute
        UserDefaults.standard.set(mute, forKey: "muteSoundFx")
    }
    
    private func loadSounds() {
        for name in SoundFx.allCases {
            if let sound = NSSound(named: name.fileName) {
                sounds[name] = sound
            }
        }
    }
    
    private func loadMuteSoundFxSetting() {
        isMuted = UserDefaults.standard.bool(forKey: "muteSoundFx")
    }
}
