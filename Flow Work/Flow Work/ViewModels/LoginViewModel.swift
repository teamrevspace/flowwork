//
//  LoginViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Combine
import Swinject

class LoginViewModel: ObservableObject {
    @Published var authService: AuthServiceProtocol
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
    }
    
    func signInWithGoogle() {
        self.authService.signInWithGoogle()
    }
}
