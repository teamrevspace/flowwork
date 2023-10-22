//
//  SettingsViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/21/23.
//

import Foundation
import Swinject
import Combine
import ServiceManagement

protocol SettingsViewModelDelegate: AnyObject {
    func showHomeView()
}

private struct Constants {
    static let helperBundleId = "school.rev.flowwork-helper"
}

class SettingsViewModel: ObservableObject {
    weak var delegate: SettingsViewModelDelegate?
    
    @Published var authService: AuthServiceProtocol
    @Published var storeService: StoreServiceProtocol
    
    @Published var authState = AuthState()
    
    private let appService = SMAppService.mainApp
    @Published var launchAtLogin: Bool = false
    @Published var appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "x"
    
    @Published var appBuildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "xx"
    
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
    
    func returnToHome() {
        self.delegate?.showHomeView()
    }
    
    func initLaunchAtLogin() {
        self.launchAtLogin = SMAppService.mainApp.status == .enabled
    }
    
    func handleLaunchAtLoginToggle() {
        DispatchQueue.main.async {
            do {
                if self.launchAtLogin {
                    try SMAppService.mainApp.register()
                    self.launchAtLogin = true
                } else {
                    try SMAppService.mainApp.unregister()
                    self.launchAtLogin = false
                }
            } catch {
                print("Failed to \(self.launchAtLogin ? "enable" : "disable") launch at login: \(error.localizedDescription)")
            }
        }
    }
    
    func signOut() {
        self.authService.signOut()
    }
}
