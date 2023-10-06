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
    @Published var webSocketManager: WebSocketManager?
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.isSignedIn = user != nil
        }
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
                authResult?.user.getIDToken(completion: { token, error in
                    if let token = token {
                        self.webSocketManager = WebSocketManager(url: URL(string: "ws://localhost:4000/session/websocket")!, authToken: token)
                        self.webSocketManager?.connectCoworkingSession()
                    }
                })
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
}
