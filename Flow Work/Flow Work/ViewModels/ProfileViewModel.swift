//
//  ProfileViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/22/23.
//

import Foundation
import Combine
import Swinject

protocol ProfileViewModelDelegate: AnyObject {
    func showHomeView()
}

class ProfileViewModel: ObservableObject {
    weak var delegate: ProfileViewModelDelegate?
    
    @Published var authService: AuthServiceProtocol
    @Published var storeService: StoreServiceProtocol
    
    @Published var authState = AuthState()
    
    private var cancellables = Set<AnyCancellable>()
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        
        authService.statePublisher
            .assign(to: \.authState, on: self)
            .store(in: &cancellables)
    }
    
    func signOut() {
        self.authService.signOut()
    }
    
    func returnToHome() {
        self.delegate?.showHomeView()
    }
}
