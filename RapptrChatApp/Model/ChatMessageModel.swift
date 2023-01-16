//
//  ChatMessageModel.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 15/01/2023.
//

import Foundation
import FirebaseFirestore

struct ChatMessageModel: Identifiable {
    var id: String { documentID }
    
    let fromID: String
    let toID: String
    let text: String
    let documentID: String
    //let timeStamp: TimeStamp
}

extension ChatMessageModel {
    init(documentID: String, data: [String: Any]) {
        self.documentID = documentID
        self.fromID = data[FirebaseConstants.fromID] as? String ?? ""
        self.toID = data[FirebaseConstants.toID] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}

extension ChatMessageModel {
    public func data() -> [String: Any] {
        let messageData = [FirebaseConstants.fromID: fromID,
                           FirebaseConstants.toID: toID,
                           FirebaseConstants.text: text,
                           FirebaseConstants.DatabaseCollections.timestamp: Timestamp()] as [String: Any]
        return messageData
    }
    
    static func sendMessageData(chatMessage: String, toID: String, fromID: String) -> [String: Any] {
        let messageData = [FirebaseConstants.fromID: fromID,
                           FirebaseConstants.toID: toID,
                           FirebaseConstants.text: chatMessage,
                           FirebaseConstants.DatabaseCollections.timestamp: Timestamp()] as [String: Any]
        return messageData
    }
}
