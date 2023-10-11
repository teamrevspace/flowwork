//
//  JoinSessionViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import Combine
import SwiftUI
import Firebase

class JoinSessionViewModel: ObservableObject {
    @Published var webSocketManager: WebSocketManager
    @Published var inputText: String = ""
    @Published var errorPublisher: ErrorPublisher
    var appCoordinator: AppCoordinator
    
    @Published var currentSession: Session?
    @Published var sessions = [Session]()
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    private var cancellables = Set<AnyCancellable>()
    
    init(webSocketManager: WebSocketManager, errorPublisher: ErrorPublisher, appCoordinator: AppCoordinator) {
        self.webSocketManager = webSocketManager
        self.errorPublisher = errorPublisher
        self.appCoordinator = appCoordinator
        
        self.fetchData()
    }
    
    func fetchData() {
        if (user != nil) {
            db.collection("sessions").whereField("users", arrayContains: user!.uid)
                .addSnapshotListener({(snapshot, error) in
                    guard let documents = snapshot?.documents else {
                        print("No documents found")
                        return
                    }
                    
                    self.sessions = documents.map({docSnapshot -> Session in
                        let data = docSnapshot.data()
                        let docId = docSnapshot.documentID
                        let name = data["name"] as? String ?? ""
                        let description = data["description"] as? String
                        let users = data["users"] as? [String]
                        let joinCode = data["joinCode"] as? String
                        return Session(id: docId, name: name, description: description, joinCode: joinCode, users: users)
                    })
                })
        }
    }
    
    func joinSession(_ id: String? = nil) {
        var sessionId: String
        
        if let url = URL(string: inputText), let host = url.host, host == "flowwork.xyz" {
            let pathComponents = url.pathComponents
            if pathComponents.count > 2 && pathComponents[1] == "s" {
                // parsed URL is of the form flowwork.xyz/s/<sessionId>
                sessionId = pathComponents[2]
            } else {
                self.errorPublisher.publish(error: AppError.invalidURLFormat)
                return
            }
        } else {
            guard let id = id ?? (inputText.isEmpty ? nil : inputText) else {
                self.errorPublisher.publish(error: AppError.invalidURLFormat)
                return
            }
            sessionId = id
        }
        
        
        if !self.webSocketManager.hasJoinedSession {
            self.webSocketManager.joinSessionLobby()
        }
        
        let payload = ["id": sessionId]
        let message = Message(
            topic: "coworking_session:lobby",
            event: "join_session",
            payload: payload,
            ref: "1")
        self.webSocketManager.sendMessage(message: message)
        print("Joined session: \(sessionId)")
        self.appCoordinator.showSessionView()
    }
    
    func returnToHome() {
        self.webSocketManager.leaveSessionLobby()
        self.appCoordinator.showHomeView()
    }
}
