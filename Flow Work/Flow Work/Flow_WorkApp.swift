//
//  Flow_WorkApp.swift
//  Flow Work
//
//  Created by Allen Lin on 9/29/23.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import Combine

private let appAssembler = AppAssembler()

class BetterHostingController<Content: View>: NSHostingController<Content> {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let popover = self.view.window?.windowController as? NSPopover {
            popover.contentViewController?.view.window?.minSize = NSSize(width: 360, height: 60)
            popover.contentViewController?.view.window?.maxSize = NSSize(width: 360, height: 480)
        }
    }
}

class InvisibleWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        let offscreenRect = NSRect(x: -1000, y: -1000, width: 1, height: 1)
        super.init(contentRect: offscreenRect, styleMask: [], backing: .buffered, defer: false)
        self.alphaValue = 0.0
        self.hasShadow = false
        self.ignoresMouseEvents = true
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseApp.configure()
        
        let appView = AppView(coordinator: appAssembler.resolver.resolve(AppCoordinator.self)!).edgesIgnoringSafeArea(.top)
        
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 360)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = BetterHostingController(rootView: appView)
        self.popover = popover
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            if let image = NSImage(named: NSImage.Name("FlowWorkLogo")) {
                image.size = NSSize(width: 22, height: 22)
                button.image = image
            }
            button.action = #selector(togglePopover(_:))
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.performClose(sender)
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.maxY)
            }
        }
    }
    
    func openMenuPopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            self.popover.performClose(sender)
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.maxY)
        }
    }
    
    func closeMenuPopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            self.popover.performClose(sender)
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
    
    func application(_ app: NSApplication, open urls: [URL]) {
        for url in urls {
            // MARK: Universal Links
            if (url.absoluteString.starts(with: "flowwork://")) {
                let pathComponents = url.host()?.components(separatedBy: "/")
                let queryItems = url.query()?.components(separatedBy: "&")
                let sessionId = queryItems?.first?.components(separatedBy: "=").last
                let lobbyViewModel = appAssembler.resolver.resolve(LobbyViewModel.self)
                if let navAction = pathComponents?.first, String(navAction) == "join", sessionId != nil {
                    lobbyViewModel?.joinSession(String(sessionId!))
                    self.openMenuPopover(nil)
                }
            }
        }
    }
}

@main
struct Flow_WorkApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        Settings {
        }
    }
}
