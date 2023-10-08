//
//  SessionView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/6/23.
//

import Foundation
import SwiftUI

struct SessionView: View {
    @ObservedObject var viewModel: SessionViewModel
    @ObservedObject var errorPublisher: ErrorPublisher
    private var testUser: User;
    private var session: Session;
    
    init(viewModel: SessionViewModel, errorPublisher: ErrorPublisher) {
        self.viewModel = viewModel
        self.errorPublisher = errorPublisher
        let user1 = User(id: "test-user", name: "test-name", emailAddress: "test@example.com", isOnline: true)
        self.testUser = user1
        self.session = Session(id: "test", name: "test", owner: testUser, users: [testUser], isPrivate: false)
    }
    
    var body: some View {
        VStack{
            Text("https://flowwork.xyz/s/\(session.id)")
            Text("\(session.name)")
            Button(action: {
                viewModel.leaveSession()
            }) {
                Text("Leave")
            }
        }.standardFrame()
            .errorOverlay(errorPublisher: errorPublisher)
    }
}
