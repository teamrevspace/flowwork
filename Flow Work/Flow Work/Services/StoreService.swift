//
//  StoreService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Foundation
import Firebase
import Swinject
import WebRTC

class StoreService: StoreServiceProtocol, ObservableObject {
    private let db = Firestore.firestore()
    private let settings = FirestoreSettings()
    
    private var lobbyListener: ListenerRegistration?
    private var todoListListener: ListenerRegistration?
    private var categoryListListener: ListenerRegistration?
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    // MARK: users collection
    
    func addUser(user: Firebase.User) -> Void {
        db.collection("users").document(user.uid).setData([
            "id": user.uid,
            "name": user.displayName ?? "",
            "emailAddress": user.email ?? "",
            "avatarURL": user.photoURL?.absoluteString ?? ""
        ]) { error in
            if let error = error {
                print("Error adding user: \(error.localizedDescription)")
            } else {
                print("User added")
            }
        }
    }
    
    func findUsersByUserIds(userIds: [String], completion: @escaping ([User]) -> Void) {
        db.collection("users").whereField("id", in: userIds).getDocuments {
            (snapshot, error) in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            
            let users = documents.map { docSnapshot -> User in
                let data = docSnapshot.data()
                let docId = docSnapshot.documentID
                let name = data["name"] as! String
                let emailAddress = data["emailAddress"] as! String
                let avatarURL = URL(string: data["avatarURL"] as! String)!
                
                return User(id: docId, name: name, emailAddress: emailAddress, avatarURL: avatarURL)
            }
            completion(users)
        }
    }
    
    // MARK: sessions collection
    
    func findSessionBySessionId(sessionId: String, completion: @escaping (Session?) -> Void) {
        db.collection("sessions").document(sessionId).getDocument { (document, error) in
            guard let document = document, document.exists else {
                completion(nil)
                return
            }
            
            let data = document.data()
            let docId = document.documentID
            let name = data?["name"] as! String
            let userIds = data?["userIds"] as? [String]
            let description = data?["description"] as? String
            let password = data?["password"] as? String
            let session = Session(id: docId, name: name, description: description, password: password, userIds: userIds)
            completion(session)
        }
    }
    
    func findSessionsByUserId(userId: String, completion: @escaping ([Session]) -> Void) {
        lobbyListener?.remove()
        
        lobbyListener = db.collection("sessions").whereField("userIds", arrayContains: userId)
            .addSnapshotListener({(snapshot, error) in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let sessions = documents.map({docSnapshot -> Session in
                    let data = docSnapshot.data()
                    let docId = docSnapshot.documentID
                    let name = data["name"] as? String ?? ""
                    let description = data["description"] as? String
                    let userIds = data["userIds"] as? [String]
                    let password = data["password"] as? String
                    return Session(id: docId, name: name, description: description, password: password, userIds: userIds)
                })
                completion(sessions)
            })
    }
    
    func addUserToSession(userId: String, sessionId: String) -> Void {
        db.collection("sessions").document(sessionId).updateData([
            "userIds": FieldValue.arrayUnion([userId])
        ])
    }
    
    func removeUserFromSession(userId: String, sessionId: String) -> Void {
        db.collection("sessions").document(sessionId).updateData([
            "userIds": FieldValue.arrayRemove([userId])
        ])
    }
    
    func stopLobbyListener() {
        lobbyListener?.remove()
        lobbyListener = nil
    }
    
    // MARK: todos collection
    
    func findTodosByUserId(userId: String, completion: @escaping ([Todo]) -> Void) {
        todoListListener?.remove()
        
        todoListListener = db.collection("todos").whereField("userIds", arrayContains: userId)
            .addSnapshotListener({(snapshot, error) in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let todos = documents.map({docSnapshot -> Todo in
                    let data = docSnapshot.data()
                    let docId = docSnapshot.documentID
                    let title = data["title"] as? String ?? ""
                    let completed = data["completed"] as? Bool ?? false
                    let createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
                    let updatedAt = data["updatedAt"] as? Timestamp
                    let userIds = data["userIds"] as? [String]
                    let categoryIds = data["categoryIds"] as? [String]
                    return Todo(id: docId, title: title, completed: completed, createdAt: createdAt, updatedAt: updatedAt, userIds: userIds, categoryIds: categoryIds)
                })
                completion(todos)
            })
    }
    
    func findTodosByCategoryId(categoryId: String, completion: @escaping ([Todo]) -> Void) {
        todoListListener?.remove()
        
        todoListListener = db.collection("todos").whereField("categoryIds", arrayContains: categoryId)
            .addSnapshotListener({(snapshot, error) in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let todos = documents.map({docSnapshot -> Todo in
                    let data = docSnapshot.data()
                    let docId = docSnapshot.documentID
                    let title = data["title"] as? String ?? ""
                    let completed = data["completed"] as? Bool ?? false
                    let createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
                    let updatedAt = data["updatedAt"] as? Timestamp
                    let userIds = data["userIds"] as? [String]
                    let categoryIds = data["categoryIds"] as? [String]
                    return Todo(id: docId, title: title, completed: completed, createdAt: createdAt, updatedAt: updatedAt, userIds: userIds, categoryIds: categoryIds)
                })
                completion(todos)
            })
    }
    
    func addTodo(todo: Todo, completion: @escaping (() -> Void)) {
        var data: [String: Any] = [
            "title": todo.title,
            "completed": todo.completed,
            "createdAt": FieldValue.serverTimestamp(),
        ]
        if (todo.completed) {
            data.updateValue(FieldValue.serverTimestamp(), forKey: "completedAt")
        }
        if let userIds = todo.userIds {
            data.updateValue(userIds, forKey: "userIds")
        }
        if let categoryIds = todo.categoryIds {
            data.updateValue(categoryIds, forKey: "categoryIds")
        }
        db.collection("todos").addDocument(data: data)
        completion()
    }
    
    func updateTodo(todo: Todo, completion: @escaping (() -> Void)) {
        guard let todoId = todo.id else { return }
        var newData: [String: Any] = [
            "title": todo.title,
            "completed": todo.completed,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if (todo.completed) {
            newData.updateValue(FieldValue.serverTimestamp(), forKey: "completedAt")
        }
        if let userIds = todo.userIds {
            newData.updateValue(userIds, forKey: "userIds")
        }
        if let categoryIds = todo.categoryIds {
            newData.updateValue(categoryIds, forKey: "categoryIds")
        }
        db.collection("todos").document(todoId).updateData(newData)
        completion()
    }
    
    func removeTodo(todoId: String, completion: @escaping (() -> Void)) {
        db.collection("todos").document(todoId).delete()
        completion()
    }
    
    func stopTodoListListener() {
        todoListListener?.remove()
        todoListListener = nil
    }
    
    // MARK: categories collection
    
    func findCategoriesByUserId(userId: String, completion: @escaping ([Category]) -> Void) {
        categoryListListener?.remove()
        
        categoryListListener = db.collection("categories").whereField("userIds", arrayContains: userId)
            .addSnapshotListener({(snapshot, error) in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let categories = documents.map({docSnapshot -> Category in
                    let data = docSnapshot.data()
                    let docId = docSnapshot.documentID
                    let title = data["title"] as? String ?? ""
                    let createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
                    let updatedAt = data["updatedAt"] as? Timestamp
                    let userIds = data["userIds"] as? [String]
                    return Category(id: docId, title: title, createdAt: createdAt, updatedAt: updatedAt, userIds: userIds)
                })
                completion(categories)
            })
    }
    
    func addCategory(category: Category, completion: @escaping (() -> Void)) {
        var newData: [String: Any] = [
            "title": category.title,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let userIds = category.userIds {
            newData.updateValue(userIds, forKey: "userIds")
        }
        db.collection("categories").addDocument(data: newData)
        completion()
    }
    
    func removeCategory(categoryId: String, completion: @escaping (() -> Void)) {
        db.collection("categories").document(categoryId).delete()
        completion()
    }
    
    func updateCategory(category: Category, completion: @escaping (() -> Void)) {
        guard let categoryId = category.id else { return }
        var newData: [String: Any] = [
            "title": category.title,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let userIds = category.userIds {
            newData.updateValue(userIds, forKey: "userIds")
        }
        db.collection("categories").document(categoryId).updateData(newData)
        completion()
    }
    
    func removeUserFromCategory(userId: String, categoryId: String) {
        db.collection("categories").document(categoryId).updateData([
            "userIds": FieldValue.arrayRemove([userId])
        ])
    }
    
    func stopCategoryListListener() {
        categoryListListener?.remove()
        categoryListListener = nil
    }
    
    // MARK: rooms collection
    
    func addRTCOfferToRoom(rtcOffer: RTCOffer, roomId: String) {
        let data: [String: Any] = [
            "sdp": rtcOffer.sdp,
            "type": rtcOffer.type
        ]
        
        db.collection("rooms").document(roomId).collection("offers").addDocument(data: data)
    }
    
    func addRTCAnswerToRoom(rtcAnswer: RTCAnswer, roomId: String) {
        let data: [String: Any] = [
            "sdp": rtcAnswer.sdp,
            "type": rtcAnswer.type
        ]
        
        db.collection("rooms").document(roomId).collection("answers").document("answer").setData(data)
    }
    
    private func sdpType(from string: String) -> RTCSdpType? {
        switch string {
        case "offer":
            return .offer
        case "pranswer":
            return .prAnswer
        case "answer":
            return .answer
        default:
            return nil
        }
    }
    
    func findRTCOfferByRoomId(roomId: String, completion: @escaping (RTCSessionDescription?) -> Void) {
        db.collection("rooms").document(roomId).collection("offers")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No offers")
                    completion(nil)
                    return
                }
                for document in documents {
                    let data = document.data()
                    guard let sdp = data["sdp"] as? String,
                          let typeRawValue = data["type"] as? String,
                          let type = self.sdpType(from: typeRawValue) else {
                        continue
                    }
                    let offer = RTCSessionDescription(type: type, sdp: sdp)
                    completion(offer)
                }
            }
    }
    
    func findRTCAnswerByRoomId(roomId: String, completion: @escaping (RTCSessionDescription?) -> Void) {
        self.db.collection("rooms").document(roomId).collection("answers")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No answers")
                    completion(nil)
                    return
                }
                for document in documents {
                    let data = document.data()
                    guard let sdp = data["sdp"] as? String,
                          let typeRawValue = data["type"] as? String,
                          let type = self.sdpType(from: typeRawValue) else {
                        continue
                    }
                    let answer = RTCSessionDescription(type: type, sdp: sdp)
                    completion(answer)
                }
            }
    }
    
    func findRTCIceCandidateByRoomId(roomId: String, completion: @escaping (RTCIceCandidate?) -> Void) {
        db.collection("rooms").document(roomId).collection("iceCandidates")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No ICE candidates")
                    completion(nil)
                    return
                }
                for document in documents {
                    let candidateData = document.data()
                    guard let sdp = candidateData["candidate"] as? String,
                          let sdpMid = candidateData["sdpMid"] as? String,
                          let sdpMLineIndex = candidateData["sdpMLineIndex"] as? Int32 else {
                        continue
                    }
                    let candidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
                    completion(candidate)
                }
            }
    }
}
