//
//  ServiceAssembly.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Swinject

final class ServiceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AuthServiceProtocol.self) { r in
            AuthService(resolver: r)
        }
        .inObjectScope(.container)
        
        container.register(SessionServiceProtocol.self) { r in
            SessionService(resolver: r)
        }
        .inObjectScope(.container)
        
        container.register(RoomServiceProtocol.self) { r in
            RoomService(resolver: r)
        }
        .inObjectScope(.container)
        
        container.register(TodoServiceProtocol.self) { r in
            TodoService(resolver: r)
        }
        .inObjectScope(.container)
        
        container.register(StoreServiceProtocol.self) { r in
            StoreService(resolver: r)
        }
        .inObjectScope(.container)
        
        container.register(NetworkServiceProtocol.self) { r in
            NetworkService(resolver: r)
        }
        .inObjectScope(.container)
        
        container.register(APIServiceProtocol.self) { r in
            APIService(resolver: r)
        }
        .inObjectScope(.container)
        
        container.register(AudioServiceProtocol.self) { r in
            AudioService(resolver: r)
        }
        .inObjectScope(.container)
        
        container.register(StorageServiceProtocol.self) { r in
            StorageService(resolver: r)
        }
        .inObjectScope(.container)
    }
}
