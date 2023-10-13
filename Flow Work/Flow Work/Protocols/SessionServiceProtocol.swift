//
//  SessionServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Foundation

protocol SessionServiceProtocol {
    var isConnected: Bool { get set }
    var hasJoinedSession: Bool { get set }
    var currentSession: Session? { get set }
    
    func connect(_ userId: String)
    func disconnect()
    func createSession(_ session: Session)
    func joinSession(_ sessionId: String)
    func leaveSession(_ sessionId: String)
    func sendMessage(message: Message)
}
