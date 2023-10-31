//
//  ProfileViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/22/23.
//

import Foundation
import Combine
import Swinject
import SwiftUI

protocol ProfileViewModelDelegate: AnyObject {
    func showHomeView()
    func didRedirectToApp()
}

class ProfileViewModel: ObservableObject {
    weak var delegate: ProfileViewModelDelegate?
    
    @Published var authService: AuthServiceProtocol
    @Published var storeService: StoreServiceProtocol
    @Published var storageService: StorageServiceProtocol
    
    @Published var authState = AuthState()
    
    private var cancellables = Set<AnyCancellable>()
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.storageService = resolver.resolve(StorageServiceProtocol.self)!
        
        authService.statePublisher
            .assign(to: \.authState, on: self)
            .store(in: &cancellables)
    }
    
    func getAuthImages() -> [String] {
        let authMethods = self.authService.getAuthMethods()
        return authMethods.compactMap { method in
            switch method {
            case "google.com":
                return "GoogleLogo"
            case "apple.com":
                return "AppleLogo"
            default:
                return nil
            }
        }
    }
    
    func selectPhoto(completion: @escaping (NSImage?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .heic]
        panel.allowsMultipleSelection = false
        panel.makeKey()
        panel.orderFrontRegardless()
        
        if let screenFrame = NSScreen.main?.frame {
            let panelWidth: CGFloat = 600
            let panelHeight: CGFloat = 400
            let xPos = (screenFrame.width - panelWidth) / 2
            let yPos = (screenFrame.height - panelHeight) / 2
            panel.setFrame(NSRect(x: xPos, y: yPos, width: panelWidth, height: panelHeight), display: true)
        }
        
        if panel.runModal() == .OK {
            if let url = panel.url, let nsImage = NSImage(contentsOf: url) {
                completion(nsImage)
            }
        } else {
            completion(nil)
        }
        self.delegate?.didRedirectToApp()
    }
    
    func updateProfilePicture(imageData: Data) {
        self.storageService.uploadProfilePicture(imageData: imageData) { url in
            self.authService.updateProfilePicture(url: url)
        }
    }
    
    func updateDisplayName(name: String) {
        self.authService.updateDisplayName(name: name)
    }
    
    func signOut() {
        self.authService.signOut()
    }
    
    func returnToHome() {
        self.delegate?.showHomeView()
    }
}
