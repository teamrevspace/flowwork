//
//  Audio.swift
//  Flow Work
//
//  Created by Allen Lin on 10/24/23.
//

enum SoundFx: String, CaseIterable {
    case door = "Door"
    case tick = "Tick"
    case click = "Click"
    case conga = "Conga"
    case ticking = "Ticking"
    case ding = "Ding"
    
    var fileName: String {
        return self.rawValue
    }
}
