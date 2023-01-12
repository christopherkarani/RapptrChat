//
//  RapptrChatAppApp.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 23/12/2022.
//

import SwiftUI
import Firebase

@main
struct RapptrChatAppApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            MainMessagesView()
        }
    }
}
