//
//  Flow_WorkApp.swift
//  Flow Work
//
//  Created by Allen Lin on 9/29/23.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

private let appAssembler = AppAssembler()

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            let screenFrame = NSScreen.main?.frame ?? NSRect()
            
            let windowWidth: CGFloat = 360
            let windowHeight: CGFloat = 60
            
            let x = screenFrame.width - windowWidth - 48
            let y = screenFrame.height - windowHeight - 64
            
            window.setFrame(NSRect(x: x, y: y, width: windowWidth, height: windowHeight), display: true)
            window.styleMask = [.closable, .resizable, .fullSizeContentView]
            
            let visualEffectView = NSVisualEffectView()
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            visualEffectView.material = .underWindowBackground
            visualEffectView.state = .active
            visualEffectView.wantsLayer = true
            visualEffectView.layer?.cornerRadius = 16.0
            
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.styleMask.remove(.titled)
            window.backgroundColor = .clear
            window.isMovableByWindowBackground = true
            window.level = .floating
            
            window.contentView = visualEffectView
            
            guard let constraints = window.contentView else {
                return
            }
            
            visualEffectView.leadingAnchor.constraint(equalTo: constraints.leadingAnchor).isActive = true
            visualEffectView.trailingAnchor.constraint(equalTo: constraints.trailingAnchor).isActive = true
            visualEffectView.topAnchor.constraint(equalTo: constraints.topAnchor).isActive = true
            visualEffectView.bottomAnchor.constraint(equalTo: constraints.bottomAnchor).isActive = true
            
            window.orderFrontRegardless()
            
            let appView = AppView(coordinator: appAssembler.resolver.resolve(AppCoordinator.self)!)
            window.contentView = NSHostingView(rootView: appView)
            let controller = NSWindowController(window: window)
            controller.showWindow(self)
        }
    }
    
    func application(_ app: NSApplication, open urls: [URL]) {
        for url in urls {
            if (url.absoluteString.starts(with: "flowwork://")) {
                let pathComponents = url.host()?.components(separatedBy: "/")
                let queryItems = url.query()?.components(separatedBy: "&")
                let sessionId = queryItems?.first?.components(separatedBy: "=").last
                let coordinator = appAssembler.resolver.resolve(AppCoordinator.self)
                let lobbyViewModel = appAssembler.resolver.resolve(LobbyViewModel.self)
                if let navAction = pathComponents?.first, String(navAction) == "join", sessionId != nil {
                    lobbyViewModel?.joinSession(String(sessionId!))
                    coordinator?.navigate(to: .Session)
                }
            }
        }
    }
}

@main
struct Flow_WorkApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var currentNumber: String = "1"
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        Window("Flow Work", id: "main") {
            AppView(coordinator: appAssembler.resolver.resolve(AppCoordinator.self)!)
        }
        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            // 3
            Button("One") {
                currentNumber = "1"
            }
            Button("Two") {
                currentNumber = "2"
            }
            Button("Three") {
                currentNumber = "3"
            }
        }
    }
}

