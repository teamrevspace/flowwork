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
        
        let contentRect = NSRect(x: -1000, y: -1000, width: 1, height: 1)
        super.init(contentRect: contentRect, styleMask: [], backing: .buffered, defer: false)
        self.alphaValue = 0.0
        self.hasShadow = false
        self.ignoresMouseEvents = true
    }
}

class CenteredWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        
        var contentRect = NSRect(x: -1000, y: -1000, width: 1, height: 1)
        
        if let screenFrame = NSScreen.main?.frame {
            let panelWidth: CGFloat = 600
            let panelHeight: CGFloat = 400
            let xPos = (screenFrame.width - panelWidth) / 2
            let yPos = (screenFrame.height - panelHeight) / 2
            contentRect = NSRect(x: xPos, y: yPos, width: panelWidth, height: panelHeight)
        }
        
        super.init(contentRect: contentRect, styleMask: [], backing: .buffered, defer: false)
        self.alphaValue = 0.0
        self.hasShadow = false
        self.ignoresMouseEvents = true
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var eventMonitor: EventMonitor?
    
    private var cancellables = Set<AnyCancellable>()
    
    private func runApp() {
        FirebaseApp.configure()
        
        let coordinator = appAssembler.resolver.resolve(AppCoordinator.self)!
        let appView = AppView(coordinator: coordinator).edgesIgnoringSafeArea(.top)
        
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 360)
        popover.behavior = .transient
        popover.contentViewController = BetterHostingController(rootView: appView)
        self.popover = popover
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            if let image = NSImage(named: NSImage.Name("FlowWorkLogo")) {
                image.size = NSSize(width: 22, height: 22)
                button.image = image
            }
            button.target = self
            button.action = #selector(didClickStatusBarButton(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        coordinator.$shouldShowPopover
            .sink { [weak self] shouldShow in
                if !(self?.popover.isShown ?? false) && shouldShow {
                    self?.openMenuPopover(nil)
                    coordinator.didHideApp()
                }
            }
            .store(in: &cancellables)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        runApp()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.openMenuPopover(nil)
        }
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        let sessionViewModel = appAssembler.resolver.resolve(SessionViewModel.self)!
        
        if let totalSessionsCount = sessionViewModel.totalSessionsCount, totalSessionsCount > 0 {
            sessionViewModel.restoreSessionGlobal()
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
    
    @objc private func didClickStatusBarButton(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .leftMouseUp {
            hideContextMenu()
            togglePopover(sender)
        }
        if event.type == .rightMouseUp {
            showContextMenu(sender)
        }
    }
    
    private func showContextMenu(_ sender: NSStatusBarButton) {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Rate on App Store", action: #selector(rateOnAppStore), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Send Feedback", action: #selector(sendFeedback), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Flow Work", action: #selector(NSApp.terminate(_:)), keyEquivalent: ""))
        statusBarItem.menu = menu
        statusBarItem.button?.performClick(nil)
        statusBarItem.menu = nil
    }
    
    private func hideContextMenu() {
        statusBarItem.menu = nil
    }
    
    @objc func rateOnAppStore() {
        if let url = URL(string: "itms-apps://apple.com/app/id6469406796?action=write-review") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func sendFeedback() {
        if let url = URL(string: "https://flowwork.xyz/feedback") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if self.popover.isShown {
            closeMenuPopover(sender)
        } else {
            openMenuPopover(sender)
        }
    }
    
    func openMenuPopover(_ sender: AnyObject?) {
        popover.animates = true
        if let button = self.statusBarItem.button {
            self.popover.performClose(sender)
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.maxY)
        }
        eventMonitor?.start()
    }
    
    func closeMenuPopover(_ sender: AnyObject?) {
        self.popover.performClose(sender)
        eventMonitor?.stop()
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
