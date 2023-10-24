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
    func findUsersByUserIds(userIds: [String], completion: @escaping ([User]) -> Void)
    func findSessionBySessionId(sessionId: String, completion: @escaping (Session?) -> Void)
    func findSessionsByUserId(userId: String, completion: @escaping ([Session]) -> Void)
    func addUserToSession(userId: String, sessionId: String) -> Void
    func removeUserFromSession(userId: String, sessionId: String) -> Void
    func findTodosByUserId(userId: String, completion: @escaping ([Todo]) -> Void)
    func addTodo(todo: Todo) -> Void
    func removeTodo(todoId: String, completion: @escaping () -> Void) -> Void
    func updateTodo(todo: Todo) -> Void
    func stopLobbyListener()
    func addRTCOfferToRoom(rtcOffer: RTCOffer, roomId: String)
    func addRTCAnswerToRoom(rtcAnswer: RTCAnswer, roomId: String)
    func findRTCAnswerByRoomId(roomId: String, completion: @escaping (RTCSessionDescription?) -> Void)
    func findRTCIceCandidateByRoomId(roomId: String, completion: @escaping (RTCIceCandidate?) -> Void)
    func findRTCOfferByRoomId(roomId: String, completion: @escaping (RTCSessionDescription?) -> Void)
}
