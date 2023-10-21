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
    var statusItem: NSStatusItem?
    var windowController: NSWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let menuButton = statusItem?.button else { return }
        menuButton.image = NSImage(systemSymbolName: "water.waves", accessibilityDescription: nil)
        menuButton.action = #selector(showWindow)
        
        if let window = NSApplication.shared.windows.first, let screenFrame = NSScreen.main?.frame {
            let windowWidth: CGFloat = 360
            let windowHeight: CGFloat = 60
            let x = screenFrame.width - windowWidth - 48
            let y = screenFrame.height - windowHeight - 64
            window.setFrame(NSRect(x: x, y: y, width: windowWidth, height: windowHeight), display: true)
            
            window.styleMask = [.closable, .resizable, .fullSizeContentView]
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.styleMask.remove(.titled)
            window.backgroundColor = .clear
            window.isMovableByWindowBackground = true
            window.level = .floating
            
            let appView = AppView(coordinator: appAssembler.resolver.resolve(AppCoordinator.self)!)
            window.contentView = NSHostingView(rootView: appView)
            let controller = NSWindowController(window: window)
            windowController = controller
            controller.showWindow(self)
        }
    }
    
    @objc func showWindow() {
        windowController?.window?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
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
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(coordinator: appAssembler.resolver.resolve(AppCoordinator.self)!)
        }
    }
}

