//
//  NetworkServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/21/23.
//

import Foundation
import Combine

protocol NetworkServiceDelegate: AnyObject {
    func didConnect()
    func didDisconnect()
}

protocol NetworkServiceProtocol {
    var delegate: NetworkServiceDelegate? { get set }
    
    var connected: Bool { get set }
    
    func checkConnection()
}
