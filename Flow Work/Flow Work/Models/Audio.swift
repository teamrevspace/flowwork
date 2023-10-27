//
//  Audio.swift
//  Flow Work
//
//  Created by Allen Lin on 10/24/23.
//

enum SoundFx: String, CaseIterable {
    case door = "Door"
    case click = "Click"
    case tick = "Tick"
    case windup = "WindUp"
    case ticking = "Ticking"
    case ding = "Ding"
    case conga = "Conga"
    
    var fileName: String {
        return self.rawValue
    }
}
