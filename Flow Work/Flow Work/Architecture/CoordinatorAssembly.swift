//
//  CoordinatorAssembly.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Swinject

final class CoordinatorAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AppCoordinator.self) { r in
            AppCoordinator(resolver: r)
        }
        .inObjectScope(.container)
    }
}
