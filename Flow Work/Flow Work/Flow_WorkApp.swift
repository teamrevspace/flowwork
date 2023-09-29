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
        FirebaseApp.configure()
    }
    
    func application(_ app: NSApplication, open urls: [URL]) {
        for url in urls {
            _ = GIDSignIn.sharedInstance.handle(url)
        }
    }
}

@main
struct Flow_WorkApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

