//
//  ChatUser.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 11/01/2023.
//

import Foundation

struct ChatUser: Identifiable {
    var id: String {
        return uid
    }
    
    let uid, email, profileImageUrl: String
}

extension ChatUser {
    init(data: [String: Any]) {
        uid = data[FirebaseConstants.uid] as? String ?? ""
        email = data[FirebaseConstants.email] as? String ?? ""
        profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
    }
    
    var username: String {
        return email.replacingOccurrences(of: "@gmail.com", with: "")
    }
}
