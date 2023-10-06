//
//  ContentView.swift
//  Flow Work
//
//  Created by Allen Lin on 9/29/23.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct AppView: View {
    @ObservedObject var webSocketManager: WebSocketManager
    @ObservedObject var authManager = AuthManager()
    
    var body: some View {
        VStack {
            if authManager.isSignedIn && Auth.auth().currentUser != nil {
                VStack {
                    Text("Hi \(Auth.auth().currentUser?.displayName ?? "there")!")
                    Button("Create a session") {
                        let jsonObject: [String: Any] = [
                            "topic": "coworking_session:lobby",
                            "event": "create_session",
                            "payload": ["name": "rev"],
                            "ref": "1"
                        ]
                        webSocketManager.sendJSON(jsonObject)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    Button("Join a session") {
                        
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    Button("Log out") {
                        authManager.signOut()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }.padding()
            } else {
                Button("Sign in with Google") {
                    authManager.signInWithGoogle()
                }
            }
        }.frame(minWidth:360, minHeight: 120)
            .fixedSize().background(Color(NSColor.windowBackgroundColor)).onAppear {
                webSocketManager.connectCoworkingSession()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(webSocketManager: WebSocketManager(url: URL(string: "ws://localhost:4000/session/websocket")!))
    }
}
