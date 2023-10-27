//
//  Flow_Work_HelperApp.swift
//  Flow Work Helper
//
//  Created by Allen Lin on 10/21/23.
//

import SwiftUI

class HelperAppDelegate: NSObject, NSApplicationDelegate {
    
    struct Constants {
        static let mainAppBundleId = "school.rev.flowwork"
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains {
            $0.bundleIdentifier == Constants.mainAppBundleId
        }
        
        if !isRunning {
            let appPath: String = {
                let path = Bundle.main.bundlePath as NSString
                var components = path.pathComponents
                components.removeLast(4)
                return NSString.path(withComponents: components)
            }()
            let appURL = URL(fileURLWithPath: appPath)
            NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        }
    }
}
