//
//  StoreServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Foundation
import Firebase

protocol StoreServiceProtocol {
    func addUser(_ user: Firebase.User) -> Void
    func findUsersByUserIds(_ userIds: [String], completion: @escaping ([User]?) -> Void)
    func findSessionBySessionId(_ sessionId: String, completion: @escaping (Session?) -> Void)
    func findSessionsByUserId(_ userId: String, completion: @escaping ([Session]?) -> Void)
}
