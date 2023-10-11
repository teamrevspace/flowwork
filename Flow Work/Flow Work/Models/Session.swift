//
//  Session.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation

struct Session: Codable, Identifiable {
    static var current: Session? = nil
    
    var id: String
    var name: String
    var description: String?
    var joinCode: String?
    var users: [String]?
}
