//
//  FirebaseConstants.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 15/01/2023.
//

import Foundation


enum FirebaseConstants {
    static let fromID = "fromId"
    static let toID = "toId"
    static let text = "text"
    static let uid = "uid"
    static let email = "email"
    static let profileImageUrl = "profileImageUrl"
    
    
    struct DatabaseCollections {
        static let users = "users"
        static let messages = "messages"
        static let timestamp = "timestamp"
        static let recentMessages = "recent_messages"
    }
}
