//
//  RecentMessageModel.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 17/01/2023.
//

import FirebaseFirestore

struct RecentMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let text, email: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Timestamp
}

extension RecentMessage {
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.text = data[FirebaseConstants.text] as? String ?? ""
        self.fromId = data[FirebaseConstants.fromID] as? String ?? ""
        self.toId = data[FirebaseConstants.toID] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.timestamp = data[FirebaseConstants.DatabaseCollections.timestamp] as? Timestamp ?? Timestamp(date: Date())
    }
}
