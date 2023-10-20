//
//  Todo.swift
//  Flow Work
//
//  Created by Allen Lin on 10/19/23.
//

import Foundation

struct Todo: Identifiable {
    var id: String?
    var title: String = ""
    var completed: Bool = false
    var userIds: [String]?
    var updatedAt: Date = Date()
}
