//
//  SessionState.swift
//  Flow Work
//
//  Created by Allen Lin on 10/21/23.
//

enum MessageType {
    case socketResponse(SocketResponse)
    case sessionResponse(SessionResponse)
    case lobbyResponse(LobbyResponse)
    case errorResponse(ErrorResponse)
    case unknown(Any)
}

struct SessionState {
    var isConnected: Bool = false
    var hasJoinedSession: Bool = false
    var currentSession: Session? = nil
    var currentSessionUsers: [User]? = nil
    var availableSessions: [Session] = []
}
