//
//  Flow_WorkApp.swift
//  Flow Work
//
//  Created by Allen Lin on 9/29/23.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            let screenFrame = NSScreen.main?.frame ?? NSRect()
            
            let windowWidth: CGFloat = 360
            let windowHeight: CGFloat = 120
            
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
            
            let appView = AppView(webSocketManager: WebSocketManager(url: URL(string: "ws://localhost:4000/session/websocket")!))
            window.contentView = NSHostingView(rootView: appView)
            let controller = NSWindowController(window: window)
            controller.showWindow(self)
        }
    }
    
    //    private func setupWindow() {
    //        window = AlwaysOnTopWindow(
    //            contentRect: NSRect(x: 0, y: 0, width: 360, height: 120),
    //            styleMask: [.closable, .resizable, .fullSizeContentView],
    //            backing: .buffered, defer: false
    //        )
    //        window.titleVisibility = .hidden
    //        window.styleMask.remove(.titled)
    //        window.backgroundColor = .clear
    //        window.isMovableByWindowBackground = true
    //        window.level = .screenSaver
    //        window.orderFrontRegardless()
    //
    //        let contentView = NSHostingView(rootView: ContentView())
    //        window.visualEffectView.addSubview(contentView)
    //
    //        NSLayoutConstraint.activate([
    //            contentView.leadingAnchor.constraint(equalTo: window.visualEffectView.leadingAnchor),
    //            contentView.trailingAnchor.constraint(equalTo: window.visualEffectView.trailingAnchor),
    //            contentView.topAnchor.constraint(equalTo: window.visualEffectView.topAnchor),
    //            contentView.bottomAnchor.constraint(equalTo: window.visualEffectView.bottomAnchor)
    //        ])
    //    }
    
    func application(_ app: NSApplication, open urls: [URL]) {
        for url in urls {
            _ = GIDSignIn.sharedInstance.handle(url)
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
            AppView(webSocketManager: WebSocketManager(url: URL(string: "ws://localhost:4000/session/websocket")!))
        }
    }
}

