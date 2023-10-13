//
//  ErrorService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import Combine

class ErrorService: ErrorServiceProtocol, ObservableObject {
    @Published var hasError: Bool = false
    @Published var errorMessage: String? = nil
    
    private let errorSubject = PassthroughSubject<String, Never>()
    
    var errorPublisher: AnyPublisher<String, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    func clearError() {
        DispatchQueue.main.async {
            self.hasError = false
            self.errorMessage = nil
        }
    }
    
    func publish(_ error: LocalizedError) {
        DispatchQueue.main.async {
            let errorMessage = error.localizedDescription
            self.hasError = true
            self.errorMessage = errorMessage
            self.errorSubject.send(errorMessage)
        }
    }
}
