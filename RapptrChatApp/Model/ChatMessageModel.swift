//
//  ChatMessageModel.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 15/01/2023.
//

import Foundation
import FirebaseFirestore

struct ChatMessageModel {
    let fromID: String
    let toID: String
    let text: String
    //let timeStamp: TimeStamp
}

extension ChatMessageModel {
    init(data: [String: Any]) {
        self.fromID = data[FirebaseConstants.fromID] as? String ?? ""
        self.toID = data[FirebaseConstants.toID] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}

extension ChatMessageModel {
    public func data() -> [String: Any] {
        let messageData = ["fromId": fromID, "toId": toID, "text": text, "timestamp": Timestamp()] as [String: Any]
        return messageData
    }
}
