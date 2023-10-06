//
//  Session.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation

struct Session: Identifiable {
    var id: String
    var name: String
    var password: String?
    var owner: User
    var users: [User]
    var isPrivate: Bool
}
