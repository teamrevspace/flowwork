//
//  Category.swift
//  Flow Work
//
//  Created by Allen Lin on 10/26/23.
//

import Firebase

struct Category: Identifiable {
    var id: String?
    var title: String = ""
    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var userIds: [String]?
}
