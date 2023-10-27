//
//  SessionViewModel.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import Combine
import Swinject
import AppKit

private struct Constants {
    static let pomodoroTime = 25 * 60 // 25 minutes in seconds
    static let shortBreakTime = 5 * 60 // 5 minutes in seconds
}

enum TimerType {
    case pomodoro, shortBreak
}

protocol SessionViewModelDelegate: AnyObject {
    func showHomeView()
    func showLobbyView()
    func didRedirectToApp()
}

class SessionViewModel: ObservableObject {
    weak var delegate: SessionViewModelDelegate?
    
    @Published var authService: AuthServiceProtocol
    @Published var sessionService: SessionServiceProtocol
    @Published var roomService: RoomServiceProtocol
    @Published var storeService: StoreServiceProtocol
    @Published var todoService: TodoServiceProtocol
    @Published var networkService: NetworkServiceProtocol
    @Published var audioService: AudioServiceProtocol
    
    @Published var authState = AuthState()
    @Published var sessionState = SessionState()
    @Published var todoState = TodoState()
    @Published var categoryState = CategoryState()
    
    @Published var totalSessionsCount: Int? = nil
    @Published var isUpdating: Bool = false
    private var sessionPassword: String? = nil
    
    // MARK: pomodoro mode
    @Published var timerType: TimerType = .pomodoro
    @Published var timeRemaining: Int = Constants.pomodoroTime
    @Published var isTimerRunning: Bool = false
    private var pomodoroTimer: Timer?
    
    // MARK: focus mode
    private let defaults = UserDefaults.standard
    private let ignoreSystemWindows: Bool = false
    private let terminateApps: Bool = false
    private let keepRunningAppOpen: Bool = false
    
    // MARK: todo sync
    private var updateQueue: Int = 0
    
    @Published var savePublisher = PassthroughSubject<(() -> Void)?, Never>()
    
    private let resolver: Resolver
    private var cancellables = Set<AnyCancellable>()
    private var checkTodoWorkItems: [String: DispatchWorkItem] = [:]
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
        self.sessionService = resolver.resolve(SessionServiceProtocol.self)!
        self.roomService = resolver.resolve(RoomServiceProtocol.self)!
        self.todoService = resolver.resolve(TodoServiceProtocol.self)!
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.networkService = resolver.resolve(NetworkServiceProtocol.self)!
        self.audioService = resolver.resolve(AudioServiceProtocol.self)!
        
        authService.statePublisher
            .assign(to: \.authState, on: self)
            .store(in: &cancellables)
        sessionService.statePublisher
            .assign(to: \.sessionState, on: self)
            .store(in: &cancellables)
        todoService.todoStatePublisher
            .assign(to: \.todoState, on: self)
            .store(in: &cancellables)
        todoService.categoryStatePublisher
            .assign(to: \.categoryState, on: self)
            .store(in: &cancellables)
        
        setupCloudSync()
    }
    
    func reconnectToSession(_ userId: String) {
        self.sessionService.resetMaxRetries()
        self.sessionService.connect(userId)
        self.rejoinSession()
    }
    
    func fetchTodoList(categoryId: String?) {
        guard let currentUserId = self.authState.currentUser?.id else { return }
        if (!self.todoState.isTodoListInitialized) {
            if let categoryId = categoryId, categoryId != currentUserId {
                self.storeService.findTodosByCategoryId(categoryId: categoryId) { todos in
                    self.todoService.initTodoList(todos: todos)
                }
            } else {
                self.storeService.findTodosByUserId(userId: currentUserId) { todos in
                    self.todoService.initTodoList(todos: todos)
                }
            }
        }
    }
    
    func fetchCategoryList() {
        guard let currentUserId = self.authState.currentUser?.id else { return }
        self.storeService.findCategoriesByUserId(userId: currentUserId) { categories in
            self.todoService.initCategoryList(categories: categories)
            self.todoService.selectCategory(category: nil)
        }
    }
    
    func setupCloudSync() {
        savePublisher
            .debounce(for: 1.0, scheduler: DispatchQueue.main)
            .sink { onCloudSync in
                onCloudSync?()
                self.setUpdateStatus(false)
            }
            .store(in: &cancellables)
    }
    
    func syncToCloud(_ onCloudSync: (() -> Void)?) {
        self.setUpdateStatus(true)
        self.savePublisher.send(onCloudSync)
    }
    
    func copyToClipboard(textToCopy: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(textToCopy, forType: .string)
    }
    
    func checkTodoCompleted(todo: Todo, completed: Bool) {
        guard let todoId = todo.id else { return }
        
        checkTodoWorkItems[todoId]?.cancel()
        
        if completed {
            let workItem = DispatchWorkItem {
                var updatedTodo = todo
                updatedTodo.completed = completed
                self.updateTodo(todo: updatedTodo)
            }
            
            checkTodoWorkItems[todoId] = workItem
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
        }
    }
    
    func updateTodo(todo: Todo) {
        self.setUpdateStatus(true)
        self.storeService.updateTodo(todo: todo) {
            self.setUpdateStatus(false)
        }
    }
    
    func removeTodo(todoId: String?) {
        guard let todoId = todoId else { return }
        self.setUpdateStatus(true)
        self.storeService.removeTodo(todoId: todoId) {
            self.setUpdateStatus(false)
        }
    }
    
    func addDraftTodo() {
        if (!self.todoState.draftTodo.title.isEmpty) {
            self.setUpdateStatus(true)
            guard let currentUserId = self.authState.currentUser?.id else { return }
            var newTodo = self.todoState.draftTodo
            newTodo.userIds = [currentUserId]
            let currentCategoryId = self.categoryState.selectedCategory?.id ?? currentUserId
            newTodo.categoryIds = [currentCategoryId]
            self.todoService.updateDraftTodo(todo: Todo())
            self.todoState.isHoveringActionButtons.append(false)
            self.storeService.addTodo(todo: newTodo) {
                self.setUpdateStatus(false)
            }
        }
    }
    
    func addDraftCategory() {
        if (!self.categoryState.draftCategory.title.isEmpty) {
            self.setUpdateStatus(true)
            guard let currentUserId = self.authState.currentUser?.id else { return }
            var newCategory = self.categoryState.draftCategory
            newCategory.userIds = [currentUserId]
            self.todoService.updateDraftCategory(category: Category())
            self.storeService.addCategory(category: newCategory) {
                self.setUpdateStatus(false)
            }
        }
    }
    
    func getSession(sessionId: String) {
        storeService.findSessionBySessionId(sessionId: sessionId) { session in
            self.sessionPassword = session?.password
        }
    }
    
    func verifyPassword(enteredPassword: String, forSession session: Session) -> Bool {
        return enteredPassword == session.password
    }
    
    func leaveSession() {
        if let currentSessionId = self.sessionState.currentSession?.id {
            self.sessionService.leaveSession(currentSessionId)
        }
        self.delegate?.showHomeView()
    }
    
    func rejoinSession() {
        if let currentSessionId = self.sessionState.currentSession?.id {
            self.sessionService.joinSession(currentSessionId)
        }
    }
    
    func setUpdateStatus(_ isUpdating: Bool) -> Void {
        self.isUpdating = isUpdating
    }
    
    func createAudioRoom() {
        guard let roomId = self.sessionState.currentSession?.id else {
            print("No room Id available.")
            return
        }
        
        roomService.createRoom(roomId: roomId)
    }
    
    func joinAudioRoom() {
        guard let roomId = self.sessionState.currentSession?.id else {
            print("No room Id available.")
            return
        }
        
        roomService.joinRoom(roomId: roomId)
    }
}

// MARK: lounge mode implementation
extension SessionViewModel {
    // TODO: add webrtc feature
}

// MARK: pomodoro mode implementation
extension SessionViewModel {
    func startTimer() {
        guard !self.isTimerRunning else { return }
        self.isTimerRunning = true
        pomodoroTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard self.isTimerRunning else { return }
            if self.timeRemaining > 1 {
                self.timeRemaining -= 1
                
                if self.timeRemaining <= 5 {
                    self.playTickingSound()
                }
            } else {
                self.playDingSound()
                self.switchTimerType()
            }
        }
    }
    
    private func switchTimerType() {
        pomodoroTimer?.invalidate()
        pomodoroTimer = nil
        
        switch timerType {
        case .pomodoro:
            self.timerType = .shortBreak
            self.timeRemaining = Constants.shortBreakTime
        case .shortBreak:
            self.timerType = .pomodoro
            self.timeRemaining = Constants.pomodoroTime
        }
        self.delegate?.didRedirectToApp()
        self.isTimerRunning = false
        self.startTimer()
    }
    
    func pauseTimer() {
        pomodoroTimer?.invalidate()
        self.isTimerRunning = false
    }
    
    func resetTimer() {
        pomodoroTimer?.invalidate()
        pomodoroTimer = nil
        
        switch timerType {
        case .pomodoro:
            timerType = .pomodoro
            timeRemaining = Constants.pomodoroTime
        case .shortBreak:
            timerType = .shortBreak
            timeRemaining = Constants.shortBreakTime
        }
        self.isTimerRunning = false
    }
    
    func playDoorSound() {
        self.audioService.playSound(.door)
    }
    
    func playTickSound() {
        self.audioService.playSound(.tick)
    }
    
    func playClickSound() {
        self.audioService.playSound(.click)
    }
    
    private func playTickingSound() {
        self.audioService.playSound(.ticking)
    }
    
    private func playDingSound() {
        self.audioService.playSound(.ding)
    }
    
    func timeString(from seconds: Int) -> String {
        //        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: focus mode implementation
extension SessionViewModel {
    func saveSessionGlobal() {
        var array = [String]()
        var arrayNames = [String]()
        var sessionName = ""
        var sessionFull = ""
        var sessionsAdded = 1
        var sessionsRemaining = 0
        var totalSessions = 0
        var lastState = false;
        
        let runningApp = NSWorkspace.shared.frontmostApplication!
        
        NSApp.setActivationPolicy(.regular)
        
        for runningApplication in NSWorkspace.shared.runningApplications {
            
            // Check if the application is in the exception list
            if ((ignoreSystemWindows && (runningApplication.localizedName != "Finder" && runningApplication.localizedName != "Activity Monitor" && runningApplication.localizedName != "System Preferences" && runningApplication.localizedName != "App Store")) || !ignoreSystemWindows) {
                
                // Ignore itself + only affect regular applications
                if (runningApplication.activationPolicy == .regular && runningApplication.localizedName != "Flow Work" && runningApplication != runningApp) {
                    array.append(runningApplication.executableURL!.absoluteString)
                    arrayNames.append(runningApplication.localizedName!)
                    
                    // Only close applications if "keep windows open" is disabled
                    if (!terminateApps) {
                        runningApplication.hide()
                    } else {
                        if (runningApplication.localizedName != "Finder") {
                            runningApplication.terminate()
                        }
                        lastState = true;
                    }
                    
                    // Get application names for session label
                    if (sessionName == "") {
                        sessionName = runningApplication.localizedName!
                        sessionFull = runningApplication.localizedName!
                    } else if (sessionsAdded <= 3) {
                        sessionName += ", "+runningApplication.localizedName!
                    } else {
                        sessionsRemaining += 1
                    }
                    sessionFull += ", "+runningApplication.localizedName!
                    sessionsAdded += 1
                    totalSessions += 1
                }
            }
        }
        
        if (!keepRunningAppOpen && ((ignoreSystemWindows && (runningApp.localizedName != "Finder" && runningApp.localizedName != "Activity Monitor" && runningApp.localizedName != "System Preferences" && runningApp.localizedName != "App Store")) || !ignoreSystemWindows)) {
            if (runningApp.activationPolicy == .regular && runningApp.localizedName != "Flow Work") {
                array.append(runningApp.executableURL!.absoluteString)
                arrayNames.append(runningApp.localizedName!)
                
                // Only close applications if "keep windows open" is disabled
                if (!terminateApps) {
                    runningApp.hide()
                } else {
                    if (runningApp.localizedName != "Finder") {
                        runningApp.terminate()
                    }
                    lastState = true;
                }
                // Get application names for session label
                if (sessionName == "") {
                    sessionName = runningApp.localizedName!
                    sessionFull = runningApp.localizedName!
                } else if (sessionsAdded <= 3) {
                    sessionName += ", "+runningApp.localizedName!
                } else {
                    sessionsRemaining += 1
                }
                sessionFull += ", "+runningApp.localizedName!
                sessionsAdded += 1
                totalSessions += 1
            }
        }
        
        if (sessionsRemaining > 0) {
            sessionName += ", +"+String(sessionsRemaining)+" more"
        }
        
        NSApp.setActivationPolicy(.accessory)
        
        // Save session data
        defaults.set(lastState, forKey:"lastState")
        defaults.set(array, forKey: "apps")
        defaults.set(arrayNames, forKey: "appNames")
        defaults.set(sessionName, forKey: "sessionName")
        defaults.set(sessionFull, forKey: "sessionFullName")
        defaults.set(String(totalSessions), forKey: "totalSessions")
        updateSession()
        
        self.delegate?.didRedirectToApp()
    }
    
    func restoreSessionGlobal() {
        // Check if apps are to be terminated as opposed to hiding them
        if (terminateApps) {
            for runningApplication in NSWorkspace.shared.runningApplications {
                if ((ignoreSystemWindows && (runningApplication.localizedName != "Finder" && runningApplication.localizedName != "Activity Monitor" && runningApplication.localizedName != "System Preferences" && runningApplication.localizedName != "App Store")) || !ignoreSystemWindows) {
                    if (runningApplication.activationPolicy == .regular && runningApplication.localizedName != "Terminal") {
                        runningApplication.terminate()
                    }
                }
            }
        }
        
        // Restore apps
        if let apps = defaults.object(forKey: "appNames") as? [String] {
            if let executables = defaults.object(forKey: "apps") as? [String] {
                for (index, app) in apps.enumerated() {
                    activate(name:app, url:executables[index])
                }
                noSessions()
            }
        }
        
        self.delegate?.didRedirectToApp()
    }
    
    func playCongaSound() {
        self.audioService.playSound(.conga)
    }
    
    private func checkAnyWindows() {
        var totalSessions = 0
        for runningApplication in NSWorkspace.shared.runningApplications {
            if ((ignoreSystemWindows && (runningApplication.localizedName != "Finder" && runningApplication.localizedName != "Activity Monitor" && runningApplication.localizedName != "System Preferences" && runningApplication.localizedName != "App Store")) || !ignoreSystemWindows) {
                if (runningApplication.activationPolicy == .regular) {
                    totalSessions += 1
                }
            }
        }
        
        self.totalSessionsCount = totalSessions
    }
    
    private func activate(name: String, url: String) {
        guard let app = NSWorkspace.shared.runningApplications.filter ({
            return $0.localizedName == name
        }).first else {
            do {
                let task = Process()
                task.executableURL = URL.init(string:url)
                try task.run()
            } catch {
                print("Error activating windows")
            }
            return
        }
        
        app.unhide()
    }
    
    private func updateSession() {
        defaults.set(true, forKey:"session")
        checkAnyWindows()
    }
    
    private func noSessions() {
        defaults.set(false, forKey:"session")
        checkAnyWindows()
    }
}
