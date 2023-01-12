//
//  ChatMessagesView.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 12/01/2023.
//

import SwiftUI

struct ChatMessagesView: View {
    var chatUser: ChatUser
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(0..<10) { num in
                    Text("Messages go here")
                }
            }
            .navigationTitle("Chat Messages View")
        }
    }
}

struct ChatMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        ChatMessagesView(chatUser: ChatUser(uid: "", email: "random@Gmail.com", profileImageUrl: ""))
    }
}
