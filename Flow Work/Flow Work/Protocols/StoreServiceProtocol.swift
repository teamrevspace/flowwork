//
//  StoreServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Firebase
import WebRTC

protocol StoreServiceProtocol {
    func addUser(user: Firebase.User) -> Void
    func updateUser(user: User) -> Void
    func findUsersByUserIds(userIds: [String], completion: @escaping ([User]) -> Void)
    
    func findSessionBySessionId(sessionId: String, completion: @escaping (Session?) -> Void)
    func findSessionsByUserId(userId: String, completion: @escaping ([Session]) -> Void)
    func addUserToSession(userId: String, sessionId: String) -> Void
    func removeUserFromSession(userId: String, sessionId: String) -> Void
    func stopLobbyListener()
    
    func findTodosByUserId(userId: String, completion: @escaping ([Todo]) -> Void)
    func findTodosByCategoryId(categoryId: String, completion: @escaping ([Todo]) -> Void)
    func addTodo(todo: Todo, completion: @escaping (() -> Void))
    func removeTodo(todoId: String, completion: @escaping (() -> Void))
    func updateTodo(todo: Todo, completion: @escaping (() -> Void))
    func addUserToTodo(userId: String, todoId: String, completion: @escaping (() -> Void))
    func removeUserFromTodo(userId: String, todoId: String, completion: @escaping (() -> Void))
    func stopTodoListListener()
    
    func findCategoriesByUserId(userId: String, completion: @escaping ([Category]) -> Void)
    func addCategory(category: Category, completion: @escaping (() -> Void))
    func removeCategory(categoryId: String, completion: @escaping (() -> Void))
    func updateCategory(category: Category, completion: @escaping (() -> Void))
    func removeUserFromCategory(userId: String, categoryId: String) -> Void
    func stopCategoryListListener()
    
    func addRTCOfferToRoom(rtcOffer: RTCOffer, roomId: String)
    func addRTCAnswerToRoom(rtcAnswer: RTCAnswer, roomId: String)
    func findRTCAnswerByRoomId(roomId: String, completion: @escaping (RTCSessionDescription?) -> Void)
    func findRTCIceCandidateByRoomId(roomId: String, completion: @escaping (RTCIceCandidate?) -> Void)
    func findRTCOfferByRoomId(roomId: String, completion: @escaping (RTCSessionDescription?) -> Void)
}
