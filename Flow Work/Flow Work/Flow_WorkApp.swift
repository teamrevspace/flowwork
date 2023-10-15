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
            window.level = .screenSaver
            
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
                let pathComponents = url.host()?.split(separator: "/")
                let queryItems = url.query()?.split(separator: "&")
                let sessionId = queryItems?.first?.split(separator: "=").last
                let coordinator = appAssembler.resolver.resolve(AppCoordinator.self)
                let lobbyViewModel = appAssembler.resolver.resolve(LobbyViewModel.self)
                if let navAction = pathComponents?.first, String(navAction) == "join", sessionId != nil {
                    lobbyViewModel?.joinSession(String(sessionId!))
                    coordinator?.navigate(to: .Session)
                }
            }
        }
    }
    
//    func application(_ application: NSApplication,
//                     continue userActivity: NSUserActivity,
//                     restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool
//    {
//        print(userActivity.activityType)
//        return true
//    }
//        print(userActivity.activityType)
//        // Get URL components from the incoming user activity.
//        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
//              let incomingURL = userActivity.webpageURL,
//              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
//            return false
//        }
//
//        // Check for specific URL components that you need.
//        guard let path = components.path,
//              let queryItems = components.queryItems else {
//            return false
//        }
//        print("path = \(path)")
//
//        guard let navAction = path.split(separator: "/").first,
//              let sessionId = queryItems.first(where: { $0.name == "sessionId" })?.value,
//              navAction == "join" else {
//            return false
//        }
//        print(sessionId)
//        return true
//    }
        
}

@main
struct Flow_WorkApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        Window("Flow Work", id: "main") {
            AppView(coordinator: appAssembler.resolver.resolve(AppCoordinator.self)!)
        }
    }
}

