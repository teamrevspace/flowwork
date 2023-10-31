//
//  AuthServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Combine
import Foundation

protocol AuthServiceDelegate: AnyObject {
    func didSignIn()
    func didSignOut()
    func didRedirectToApp()
    func didHideApp()
}

protocol AuthServiceProtocol {
    var delegate: AuthServiceDelegate? { get set }
    
    var statePublisher: AnyPublisher<AuthState, Never> { get }
    
    func getAuthMethods() -> [String]
    func updateProfilePicture(url: URL)
    func updateDisplayName(name: String)
    func signInWithGoogle()
    func signInWithApple()
    func signOut()
}
