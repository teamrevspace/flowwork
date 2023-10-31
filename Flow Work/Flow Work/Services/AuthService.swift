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
import CryptoKit
import AuthenticationServices

fileprivate var currentNonce: String?

class AuthService: NSObject, AuthServiceProtocol, ObservableObject {
    weak var delegate: AuthServiceDelegate?
    
    @Published var networkService: NetworkServiceProtocol
    @Published var sessionService: SessionServiceProtocol
    @Published var storeService: StoreServiceProtocol
    
    @Published private var state = AuthState()
    
    fileprivate var currentNonce: String?
    
    private let resolver: Resolver
    private let authRef = Auth.auth()
    
    var statePublisher: AnyPublisher<AuthState, Never> {
        $state.eraseToAnyPublisher()
    }
    
    var handle: AuthStateDidChangeListenerHandle?
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.networkService = resolver.resolve(NetworkServiceProtocol.self)!
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        
        super.init()
        
        handle = authRef.addStateDidChangeListener({(auth, user) in
            DispatchQueue.main.async {
                if let user = user {
                    self.state.isSignedIn = true
                    self.delegate?.didSignIn()
                    guard let emailAddress = user.email, let name = user.displayName else { return }
                    self.state.currentUser = User(id: user.uid, name: name, emailAddress: emailAddress, avatarURL: user.photoURL)
                    user.getIDToken() { token, error in
                        if let error = error {
                            print("Error getting token: \(error.localizedDescription)")
                            return
                        }
                        
                        self.sessionService.updateAuthToken(token)
                    }
                    self.connectWebSocketIfSignedIn()
                } else {
                    self.state.isSignedIn = false
                    self.delegate?.didSignOut()
                    self.state.currentUser = nil
                    self.sessionService.updateAuthToken(nil)
                }
            }
        })
        
        networkService.delegate = self
    }
    
    deinit {
        if let handle = handle {
            authRef.removeStateDidChangeListener(handle)
        }
    }
    
    func getAuthMethods() -> [String] {
        return authRef.currentUser?.providerData.map({ $0.providerID }) ?? []
    }
    
    func updateProfilePicture(url: URL) {
        let changeRequest = authRef.currentUser?.createProfileChangeRequest()
        changeRequest?.photoURL = url
        changeRequest?.commitChanges { error in
            if let error = error {
                print("Error updating profile picture: \(error.localizedDescription)")
                return
            }
            self.state.currentUser?.avatarURL = url
        }
    }
    
    func updateDisplayName(name: String) {
        let changeRequest = authRef.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { error in
            if let error = error {
                print("Error updating display name: \(error.localizedDescription)")
                return
            }
            self.state.currentUser?.name = name
        }
    }
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let invisibleWindow = InvisibleWindow()
        
        GIDSignIn.sharedInstance.signIn(withPresenting: invisibleWindow) { result, error in
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
                
                let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                if (isNewUser) {
                    self.storeService.addUser(user: authResult.user)
                }
                
                self.delegate?.didRedirectToApp()
            }
        }
    }
    
    func signInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func signOut() {
        do {
            try authRef.signOut()
            if GIDSignIn.sharedInstance.currentUser != nil {
                self.signOutWithGoogle()
            }
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

extension AuthService: NetworkServiceDelegate {
    func didConnect() {
        self.connectWebSocketIfSignedIn()
    }
    
    func didDisconnect() {
        self.sessionService.disconnect()
    }
}

extension AuthService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let authWindow = CenteredWindow()
        authWindow.makeKey()
        authWindow.orderFrontRegardless()
        return authWindow
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            
            authRef.signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Firebase sign in error: \(error.localizedDescription)")
                    return
                }
                
                guard let authResult = authResult else {
                    print("No user data available")
                    return
                }
                
                let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                if (isNewUser) {
                    self.storeService.addUser(user: authResult.user)
                }
                
                self.delegate?.didRedirectToApp()
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
