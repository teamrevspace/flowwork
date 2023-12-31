//
//  SessionServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Combine

protocol SessionServiceDelegate: AnyObject {
    func didJoinSession(_ sessionId: String)
    func sessionNotFound()
    func didUpdateLobby(_ userIds: [String], completion: @escaping ([User]) -> Void)
}

protocol SessionServiceProtocol {
    var delegate: SessionServiceDelegate? { get set }
    
    var statePublisher: AnyPublisher<SessionState, Never> { get }
    
    func initSessionList(sessions: [Session], defaultSession: Session?)
    func updateAuthToken(_ token: String?)
    func connect(_ userId: String?)
    func disconnect()
    func createSession(_ session: Session)
    func joinSession(_ sessionId: String)
    func leaveSession(_ sessionId: String)
    func sendMessage(message: Message)
    func resetMaxRetries()
    
    func updateWorkMode(_ mode: WorkMode)
}
