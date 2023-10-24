//
//  SessionState.swift
//  Flow Work
//
//  Created by Allen Lin on 10/21/23.
//

struct SessionState {
    var isConnected: Bool = false
    var hasJoinedSession: Bool = false
    var currentSession: Session? = nil
    var currentSessionUsers: [User]? = nil
    var availableSessions: [Session] = []
    var selectedMode: WorkMode = .lounge
    var maxRetriesReached: Bool = false
}
