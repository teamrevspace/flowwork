//
//  LobbyViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import Combine
import Swinject

private struct Constants {
    static let defaultSessionId = "8Bg42oZXM09n4FjcXV0v"
}

protocol LobbyViewModelDelegate: AnyObject {
    func showSessionView()
    func showHomeView()
}

class LobbyViewModel: ObservableObject {
    weak var delegate: LobbyViewModelDelegate?
    
    @Published var sessionService: SessionServiceProtocol
    @Published var authService: AuthServiceProtocol
    @Published var storeService: StoreServiceProtocol
    @Published var apiService: APIServiceProtocol
    @Published var audioService: AudioServiceProtocol
    
    @Published var authState = AuthState()
    @Published var sessionState = SessionState()
    @Published var joinSessionCode: String = ""
    
    @Published var newSessionName: String = ""
    @Published var newSessionPassword: String = ""
    @Published var showPassword: Bool = false
    @Published var isSessionListLoading: Bool = true
    
    private let resolver: Resolver
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.apiService = resolver.resolve(APIServiceProtocol.self)!
        self.audioService = resolver.resolve(AudioServiceProtocol.self)!
        
        authService.statePublisher
            .assign(to: \.authState, on: self)
            .store(in: &cancellables)
        sessionService.statePublisher
            .assign(to: \.sessionState, on: self)
            .store(in: &cancellables)
    }
    
    func fetchSessionList() {
        guard let currentUserId = self.authState.currentUser?.id else { return }
        self.isSessionListLoading = true
        self.storeService.findSessionsByUserId(userId: currentUserId) { sessions in
            var sessionList = sessions
            let sessionIds = sessions.map { $0.id }.joined(separator: ",")
            self.apiService.getUserCounts(sessionIds: sessionIds) { result in
                switch result {
                case .success(let userCountsResponse):
                    for (index, session) in sessionList.enumerated() {
                        let sessionId = session.id
                        if let userCount = userCountsResponse[sessionId] {
                            sessionList[index].onlineUserCount = userCount
                        }
                    }
                case .failure(_):
                    print(AppError.invalidURLFormat)
                }
                guard let currentUserId = self.authState.currentUser?.id else { return }
                self.storeService.findSessionBySessionId(sessionId: Constants.defaultSessionId) { defaultSession in
                    self.storeService.addUserToSession(userId: currentUserId, sessionId: Constants.defaultSessionId)
                    self.sessionService.initSessionList(sessions: sessionList, defaultSession: defaultSession)
                }
                self.isSessionListLoading = false
            }
        }
    }
    
    func createSession(userIds: [String]) {
        let newSession = Session(
            id: "_",
            name: self.newSessionName,
            password: self.newSessionPassword,
            userIds: userIds
        )
        self.sessionService.createSession(newSession)
        
        self.delegate?.showSessionView()
    }
    
    func joinSession(_ id: String? = nil) {
        var sessionId: String
        
        if let url = URL(string: joinSessionCode), let host = url.host, host == "flowwork.xyz" {
            let pathComponents = url.pathComponents
            if pathComponents.count > 2 && pathComponents[1] == "s" {
                // parsed URL is of the form flowwork.xyz/s/<sessionId>
                sessionId = pathComponents[2]
            } else {
                print(AppError.invalidURLFormat)
                return
            }
        } else {
            guard let id = id ?? (joinSessionCode.isEmpty ? nil : joinSessionCode) else {
                print(AppError.invalidURLFormat)
                return
            }
            sessionId = id
        }
        
        self.sessionService.joinSession(sessionId)
    }
    
    func returnToHome() {
        self.delegate?.showHomeView()
    }
}
