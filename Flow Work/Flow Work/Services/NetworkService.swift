//
//  NetworkService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/21/23.
//

import Foundation
import Network
import Swinject
import Combine

class NetworkService: NetworkServiceProtocol, ObservableObject {
    weak var delegate: NetworkServiceDelegate?
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    @Published var connected: Bool = false
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        
        checkConnection()
    }
    
    deinit {
        monitor.cancel()
    }
    
    func checkConnection() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.connected = true
                } else {
                    self.connected = false
                }
            }
        }
        monitor.start(queue: queue)
    }
}
