//
//  AuthService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/5/23.
//

import Foundation
import Firebase
import GoogleSignIn
import Swinject

class AuthService: AuthServiceProtocol, ObservableObject {
    weak var delegate: AuthServiceDelegate?
    
    @Published var sessionService: SessionServiceProtocol
    @Published var storeService: StoreServiceProtocol
    
    @Published var isSignedIn: Bool = false
    @Published var currentUser: User? = nil
    
    private let authRef = Auth.auth()
    private let resolver: Resolver
    
    var handle: AuthStateDidChangeListenerHandle?
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        
        handle = authRef.addStateDidChangeListener({(auth, user) in
            if let user = user {
                self.isSignedIn = true
                self.currentUser = User(id: user.uid, name: user.displayName!, emailAddress: user.email!, avatarURL: user.photoURL!)
                self.connectWebSocketIfSignedIn()
            } else {
                self.isSignedIn = false
                self.currentUser = nil
            }
        })
    }
    
    deinit {
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
            
            
            self.authRef.signIn(with: credential) { authResult, error in
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
                self.delegate?.didSignIn()
                
                let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                if (isNewUser) {
                    self.storeService.addUser(authResult.user)
                }
            }
        }
    }
    
    func signOut() {
        do {
            try authRef.signOut()
            self.signOutWithGoogle()
            self.currentUser = nil
            self.isSignedIn = false
            self.delegate?.didSignOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    private func signOutWithGoogle() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    private func connectWebSocketIfSignedIn() {
        guard let user = authRef.currentUser else { return }
        
        user.getIDToken { token, error in
            if token != nil {
                self.sessionService.connect(user.uid)
            } else if let error = error {
                print("Error getting ID token: \(error.localizedDescription)")
            }
        }
    }
}
