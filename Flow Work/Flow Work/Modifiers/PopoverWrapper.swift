//
//  PopoverWrapper.swift
//  Flow Work
//
//  Created by Allen Lin on 10/21/23.
//

import Foundation
import SwiftUI

struct PopoverWrapper: NSViewRepresentable {
    class Coordinator: NSObject, NSPopoverDelegate {
        var parent: PopoverWrapper
        
        init(parent: PopoverWrapper) {
            self.parent = parent
        }
        
        func popoverWillClose(_ notification: Notification) {
            parent.isPresented = false
        }
    }
    
    @Binding var isPresented: Bool
    var content: () -> AnyView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeNSView(context: Context) -> NSPopover {
        let popover = NSPopover()
        popover.delegate = context.coordinator
        return popover
    }
    
    func updateNSView(_ nsView: NSPopover, context: Context) {
        nsView.contentViewController = NSHostingController(rootView: content())
        nsView.contentSize = nsView.contentViewController!.view.intrinsicContentSize
        if isPresented {
            nsView.show(relativeTo: .zero, of: context.coordinator.parent.window, preferredEdge: .minY)
        } else {
            nsView.performClose(nil)
        }
    }
}
