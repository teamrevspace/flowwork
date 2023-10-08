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
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    init(webSocketManager: WebSocketManager) {
        self.webSocketManager = webSocketManager
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.isSignedIn = Auth.auth().currentUser != nil
            self.connectWebSocketIfSignedIn()
        }
        connectWebSocketIfSignedIn()
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
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
                } else {
                    print("Signed in to Firebase as: \(authResult?.user.email ?? "Unknown")")
                    self.isSignedIn = true
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    private func connectWebSocketIfSignedIn() {
        guard let user = Auth.auth().currentUser else { return }
        
        user.getIDToken { token, error in
            if let token = token {
                self.webSocketManager.authToken = token
                self.webSocketManager.connect()
            } else if let error = error {
                print("Error getting ID token: \(error.localizedDescription)")
            }
        }
    }
}
