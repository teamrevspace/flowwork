//
//  EventMonitorService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/24/23.
//

import Foundation
import SwiftUI

class EventMonitorManager: ObservableObject {
    
    private var eventMonitor: EventMonitor?
    
    @Published var somePropertyToUpdate: Bool = false
    
    init() {
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            // Update SwiftUI properties or do other work in response to the event
            self?.somePropertyToUpdate.toggle()
        }
    }
    
    func startMonitoring() {
        eventMonitor?.start()
    }
    
    func stopMonitoring() {
        eventMonitor?.stop()
    }
}
