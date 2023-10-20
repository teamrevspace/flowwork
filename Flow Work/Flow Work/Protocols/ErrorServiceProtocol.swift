//
//  ErrorServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Combine

protocol ErrorServiceProtocol {
    var hasError: Bool { get set }
    var errorMessage: String? { get set }
    var errorPublisher: AnyPublisher<String, Never> { get }
    
    
    
    func clearError()
    func publish(_ error: LocalizedError)
}
