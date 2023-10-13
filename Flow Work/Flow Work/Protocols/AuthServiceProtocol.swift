//
//  AuthServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Foundation

protocol AuthServiceDelegate: AnyObject {
    func didSignIn()
    func didSignOut()
}

protocol AuthServiceProtocol {
    var isSignedIn: Bool { get set }
    var currentUser: User? { get set }
    
    func signInWithGoogle()
    func signOut()
}
