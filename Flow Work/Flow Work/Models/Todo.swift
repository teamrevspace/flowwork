//
//  Todo.swift
//  Flow Work
//
//  Created by Allen Lin on 10/19/23.
//

import Firebase

struct Todo: Identifiable {
    var id: String?
    var title: String = ""
    var completed: Bool = false
    var completedAt: Timestamp?
    var createdAt: Timestamp = Timestamp()
    var updatedAt: Timestamp?
    var userIds: [String]?
    var categoryIds: [String]?
}
