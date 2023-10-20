//
//  ViewModelAssembly.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Swinject

final class ViewModelAssembly: Assembly {
    func assemble(container: Container) {
        container.register(HomeViewModel.self) { r in
            HomeViewModel(resolver: r)
        }
        .inObjectScope(.transient)
        
        container.register(SessionViewModel.self) { r in
            SessionViewModel(resolver: r)
        }
        .inObjectScope(.transient)
        
        container.register(LobbyViewModel.self) { r in
            LobbyViewModel(resolver: r)
        }
        .inObjectScope(.transient)
    }
}
