//
//  ErrorPublisher.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import Combine
import SwiftUI

class ErrorPublisher: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let errorSubject = PassthroughSubject<String, Never>()
    
    var errorPublisher: AnyPublisher<String, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    func publish(error: LocalizedError) {
        errorSubject.send(error.localizedDescription)
    }
}
