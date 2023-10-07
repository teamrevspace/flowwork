// ViewModels/AppViewModel.swift

import Combine
import SwiftUI
import Firebase

class LoginViewModel: ObservableObject {
    @Published var authManager: AuthManager
    @Published var isSignedIn: Bool = Auth.auth().currentUser != nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        
        self.authManager.$isSignedIn
            .assign(to: \.isSignedIn, on: self)
            .store(in: &cancellables)
    }
    
    func signInWithGoogle() {
        self.authManager.signInWithGoogle()
    }
}
