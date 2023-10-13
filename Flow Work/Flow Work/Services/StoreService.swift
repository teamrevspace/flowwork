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
    @Published var sessionService: SessionServiceProtocol
    @Published var errorService: ErrorServiceProtocol
    
    private let db = Firestore.firestore()
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.errorService = resolver.resolve(ErrorServiceProtocol.self)!
    }
    
    func addUser(_ user: Firebase.User) -> Void {
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
    
    func findUsersByUserIds(_ userIds: [String], completion: @escaping ([User]?) -> Void) {
        db.collection("users").whereField("id", in: userIds).getDocuments {
            (snapshot, error) in
            guard let documents = snapshot?.documents else {
                completion(nil)
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
    
    func findSessionBySessionId(_ sessionId: String, completion: @escaping (Session?) -> Void) {
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
            let joinCode = data?["joinCode"] as? String
            let session = Session(id: docId, name: name, description: description, joinCode: joinCode, userIds: userIds)
            completion(session)
            
        }
    }
    
    func findSessionsByUserId(_ userId: String, completion: @escaping ([Session]?) -> Void) {
        db.collection("sessions").whereField("users", arrayContains: userId)
            .addSnapshotListener({(snapshot, error) in
                guard let documents = snapshot?.documents else {
                    completion(nil)
                    return
                }
                
                let sessions = documents.map({docSnapshot -> Session in
                    let data = docSnapshot.data()
                    let docId = docSnapshot.documentID
                    let name = data["name"] as? String ?? ""
                    let description = data["description"] as? String
                    let users = data["users"] as? [String]
                    let joinCode = data["joinCode"] as? String
                    return Session(id: docId, name: name, description: description, joinCode: joinCode, userIds: users)
                })
                completion(sessions)
            })
    }
}
