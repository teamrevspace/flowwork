//
//  StoreServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Foundation
import Firebase

protocol StoreServiceProtocol {
    func addUser(user: Firebase.User) -> Void
    func findUsersByUserIds(userIds: [String], completion: @escaping ([User]) -> Void)
    func findSessionBySessionId(sessionId: String, completion: @escaping (Session?) -> Void)
    func findSessionsByUserId(userId: String, completion: @escaping ([Session]) -> Void)
    func addUserToSession(userId: String, sessionId: String) -> Void
    func stopLobbyListener()
}
