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

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var windowController: NSWindowController?
    
    let windowWidth: CGFloat = 360
    let windowHeight: CGFloat = 480
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let appView = AppView(coordinator: appAssembler.resolver.resolve(AppCoordinator.self)!).edgesIgnoringSafeArea(.top)
        
        popover = NSPopover()
        guard let popover = popover else { return }
        popover.contentSize = NSSize(width: windowWidth, height: windowHeight)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: appView)

        statusItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let menuButton = self.statusItem?.button {
            menuButton.image = NSImage(systemSymbolName: "water.waves", accessibilityDescription: nil)
            menuButton.action = #selector(showPopover(_:))
        }
        
        if let window = NSApp.windows.first, let screenFrame = NSScreen.main?.frame {
            window.delegate = self
            
            let x = screenFrame.width - windowWidth - 48
            let y = screenFrame.height - windowHeight - 64
            window.setFrame(NSRect(x: x, y: y, width: windowWidth, height: windowHeight), display: true)
            
            window.titleVisibility = .hidden
            window.styleMask = [.borderless]
            window.titlebarAppearsTransparent = true
//            window.backgroundColor = .clear
            window.isMovableByWindowBackground = true
            window.level = .floating
            
            window.contentView = NSHostingView(rootView: appView)
            let controller = NSWindowController(window: window)
            windowController = controller
            controller.showWindow(self)
        }
    }
    
    @objc func showPopover(_ sender: AnyObject?) {
        if let menuButton = self.statusItem?.button {
            guard let popover = self.popover else { return }
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: NSRectEdge.minY)
                windowController?.window?.orderOut(nil)
            }
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        let mainWindow = NSApp.windows.first
        if flag {
            mainWindow?.orderFront(nil)
        } else {
            mainWindow?.makeKeyAndOrderFront(nil)
        }
        return true
    }
    
    //    @objc func showWindow() {
    //        windowController?.window?.makeKeyAndOrderFront(self)
    //        NSApp.activate(ignoringOtherApps: true)
    //    }
    
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

