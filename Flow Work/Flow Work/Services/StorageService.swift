//
//  StorageService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/30/23.
//

import Foundation
import FirebaseStorage
import Swinject
import Combine

class StorageService: StorageServiceProtocol, ObservableObject {
    private let storage = Storage.storage().reference()
    
    @Published var authState = AuthState()
    @Published var authService: AuthServiceProtocol
    
    private let resolver: Resolver
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.resolver = resolver
        
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        
        authService.statePublisher
            .assign(to: \.authState, on: self)
            .store(in: &cancellables)
    }
    
    func uploadProfilePicture(imageData: Data, completion: @escaping (URL) -> Void) {
        guard let user = self.authState.currentUser else { return }
        
        let storageRef = storage.child("profile_images/\(user.id)/profile.jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("Failed to upload image: \(error)")
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error)")
                    return
                }
                
                guard let url = url else { return }
                completion(url)
            }
        }
    }
    
}
