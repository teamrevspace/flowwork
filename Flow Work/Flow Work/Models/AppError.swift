//
//  AppError.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation

enum AppError: LocalizedError {
    case invalidURLFormat
    case networkError(String)
    case sessionNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURLFormat:
            return "Invalid URL format."
        case .networkError(let message):
            return message
        case .sessionNotFound:
            return "Session not found."
        }
    }
}
