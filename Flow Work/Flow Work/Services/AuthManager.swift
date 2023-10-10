//
//  AuthManager.swift
//  Flow Work
//
//  Created by Allen Lin on 10/5/23.
//

import Foundation
import Firebase
import GoogleSignIn

class AuthManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var webSocketManager: WebSocketManager
    @Published var session: User?
    
    var handle: AuthStateDidChangeListenerHandle?
    let authRef = Auth.auth()
    
    init(webSocketManager: WebSocketManager) {
        self.webSocketManager = webSocketManager
        self.listen()
    }
    
    deinit {
        unbind()
    }
    
    func listen() {
        handle = authRef.addStateDidChangeListener({(auth, user) in
            if let user = user {
                self.isSignedIn = true
                self.session = User(id: user.uid, name: user.displayName!, emailAddress: user.email!, avatarURL: user.photoURL)
                self.connectWebSocketIfSignedIn()
            } else {
                self.isSignedIn = false
                self.session = nil
            }
        })
    }
    
    func unbind() {
        if let handle = handle {
            authRef.removeStateDidChangeListener(handle)
        }
    }
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: NSApplication.shared.mainWindow!) { result, error in
            guard error == nil else {
                print("Error signing in: \(error!.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                print("Error getting tokens")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign in error: \(error.localizedDescription)")
                    return
                }
                
                guard let authResult = authResult else {
                    print("No user data available")
                    return
                }
                
                print("Signed in to Firebase as: \(authResult.user.email!)")
                self.isSignedIn = true
                User.current = User(id: authResult.user.uid, name: authResult.user.displayName!, emailAddress: authResult.user.email!, avatarURL: authResult.user.photoURL)
            }
        }
    }
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            self.session = nil
            self.isSignedIn = false
            return true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            return false
        }
    }
    
    private func connectWebSocketIfSignedIn() {
        guard let user = authRef.currentUser else { return }
        
        user.getIDToken { token, error in
            if let token = token {
                self.webSocketManager.authToken = token
                self.webSocketManager.connect()
                if !self.webSocketManager.hasJoinedSession {
                    self.webSocketManager.joinSessionLobby()
                }
            } else if let error = error {
                print("Error getting ID token: \(error.localizedDescription)")
            }
        }
    }
}
