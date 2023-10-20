//
//  RTCService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/20/23.
//

import Foundation
import Swinject

class RTCService: RTCServiceProtocol, ObservableObject {
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
}
