//
//  StoreService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Foundation
import Firebase
import Swinject

class StoreService: StoreServiceProtocol, ObservableObject {
    @Published var errorService: ErrorServiceProtocol
    
    private let resolver: Resolver
    private let db = Firestore.firestore()
    private var lobbyListener: ListenerRegistration?
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.errorService = resolver.resolve(ErrorServiceProtocol.self)!
    }
    
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
    
    func findTodosByUserId(userId: String, completion: @escaping ([Todo]) -> Void) {
        db.collection("todos").whereField("userIds", arrayContains: userId)
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
                    let userIds = data["userIds"] as? [String]
                    return Todo(id: docId, title: title, completed: completed, userIds: userIds)
                })
                completion(todos)
            })
    }
    
    func addTodo(todo: Todo) -> Void {
        let data: [String: Any] = [
            "title": todo.title,
            "completed": todo.completed,
            "userIds": todo.userIds ?? []
        ]
        
        db.collection("todos").addDocument(data: data)
    }
    
    func updateTodoByTodoId(todoId: String, updatedTodo: Todo) -> Void {
        db.collection("todos").document(todoId).updateData([
            "title": updatedTodo.title,
            "completed": updatedTodo.completed,
            "userIds": updatedTodo.userIds ?? []
        ]) { err in
            if let err = err {
                print("Error updating todo: \(err)")
            } else {
                print("Todo updated successfully!")
            }
        }
    }
    
    func removeTodo(todoId: String) {
        db.collection("todos").document(todoId).delete()
    }
    
    func stopLobbyListener() {
        lobbyListener?.remove()
        lobbyListener = nil
    }
}
