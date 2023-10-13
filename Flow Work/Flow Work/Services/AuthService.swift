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
import Combine

struct AuthState {
    var isSignedIn: Bool = false
    var currentUser: User? = nil
}

class AuthService: AuthServiceProtocol, ObservableObject {
    weak var delegate: AuthServiceDelegate?
    
    @Published var sessionService: SessionServiceProtocol
    @Published var storeService: StoreServiceProtocol
    
    @Published private var state = AuthState()
    
    private let resolver: Resolver
    private let authRef = Auth.auth()
    
    var statePublisher: AnyPublisher<AuthState, Never> {
        $state.eraseToAnyPublisher()
    }
    
    var handle: AuthStateDidChangeListenerHandle?
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        
        sessionService.delegate = self
        
        handle = authRef.addStateDidChangeListener({(auth, user) in
            DispatchQueue.main.async {
                if let user = user {
                    self.state.isSignedIn = true
                    self.delegate?.didSignIn()
                    self.state.currentUser = User(id: user.uid, name: user.displayName!, emailAddress: user.email!, avatarURL: user.photoURL!)
                    self.connectWebSocketIfSignedIn()
                } else {
                    self.state.isSignedIn = false
                    self.delegate?.didSignOut()
                    self.state.currentUser = nil
                }
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
                
                let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                if (isNewUser) {
                    self.storeService.addUser(user: authResult.user)
                }
            }
        }
    }
    
    func signOut() {
        do {
            try authRef.signOut()
            self.signOutWithGoogle()
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

extension AuthService: SessionServiceDelegate {
    func didJoinSession(_ sessionId: String) {
        guard let userId = self.state.currentUser?.id else { return }
        self.storeService.addUserToSession(userId: userId, sessionId: sessionId)
    }
    func sessionNotFound() {}
}
