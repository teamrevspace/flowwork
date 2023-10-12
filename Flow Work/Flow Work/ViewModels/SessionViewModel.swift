//
//  SessionViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import Combine
import SwiftUI
import Firebase

class SessionViewModel: ObservableObject {
    @Published var authManager: AuthManager
    @Published var webSocketManager: WebSocketManager
    @Published var currentSession: Session?
    @Published var isLoading: Bool = false
    @Published var sessionUserIds: [String]? {
        didSet {
            fetchData()
        }
    }
    @Published var sessionUsers: [User] = []
    
    var appCoordinator: AppCoordinator
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManager, webSocketManager: WebSocketManager, appCoordinator: AppCoordinator) {
        self.authManager = authManager
        self.webSocketManager = webSocketManager
        self.appCoordinator = appCoordinator
        
        if (user != nil) {
            self.webSocketManager.updateSessionUserIds([user?.uid ?? ""])
        }
        
        self.webSocketManager.$sessionUserIds
            .assign(to: \.sessionUserIds, on: self)
            .store(in: &cancellables)
        
        self.webSocketManager.$currentSession
            .assign(to: \.currentSession, on: self)
            .store(in: &cancellables)
        
        self.webSocketManager.$sessionUsers
            .assign(to: \.sessionUsers, on: self)
            .store(in: &cancellables)
        
        self.webSocketManager.$currentSession
            .sink { session in
                if session == nil {
                    self.isLoading = true
                } else {
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
        
        fetchData()
    }
    
    func fetchData() {
        if (user != nil) {
            db.collection("users").whereField("id", in: sessionUserIds!)
                .addSnapshotListener({(snapshot, error) in
                    guard let documents = snapshot?.documents else {
                        print("No documents found")
                        return
                    }
                    
                    let users = documents.map({docSnapshot -> User in
                        let data = docSnapshot.data()
                        let docId = docSnapshot.documentID
                        let name = data["name"] as? String ?? ""
                        let emailAddress = data["emailAddress"] as? String ?? ""
                        let avatarURL = URL(string: data["avatarURL"] as! String)
                        return User(id: docId, name: name, emailAddress: emailAddress, avatarURL: avatarURL)
                    })
                    self.webSocketManager.updateSessionUsers(users)
                })
            
        }
    }
    
    func getCurrentUser() -> User? {
        return self.authManager.currentUser
    }
    
    func copyToClipboard(textToCopy: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(textToCopy, forType: .string)
    }
    
    func leaveSession() {
        self.webSocketManager.leaveSessionLobby()
        self.appCoordinator.showHomeView()
        self.webSocketManager.leaveSession()
    }
}
