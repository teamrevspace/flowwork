//
//  ContentView.swift
//  Flow Work
//
//  Created by Allen Lin on 9/29/23.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct ContentView: View {
    @State private var isSignedIn = false
    
    var body: some View {
        VStack {
            if isSignedIn {
                Text("You're signed in as: \(Auth.auth().currentUser?.email ?? "Unknown")")
            } else {
                Button("Sign in with Google") {
                    self.signInWithGoogle()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(40)
            }
        }
    }
    
    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: NSApplication.shared.mainWindow!) { [self] result, error in
            guard error == nil else {
                print("Error signing in: \(error!.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                print("Error getting tokens")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            // Sign in to Firebase with the Google Auth credentials
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign in error: \(error.localizedDescription)")
                } else {
                    print("Signed in to Firebase as: \(authResult?.user.email ?? "Unknown")")
                    self.isSignedIn = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
