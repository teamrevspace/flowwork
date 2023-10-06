// Views/AppView.swift

import SwiftUI
import Firebase

struct AppView: View {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some View {
        appCoordinator.currentView
    }
}
