//
//  ChatMessagesView.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 12/01/2023.
//

import SwiftUI

struct ChatMessagesView: View {
    @ObservedObject var viewModel: ViewModel
    var chatUser: ChatUser
    
    var messageBubble: some View {
        HStack {
            Spacer()
            HStack {
                Text("Messages go here")
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    

    var body: some View {
        ZStack {
            ScrollView {
                ForEach(0..<20) { num in
                    messageBubble
                }
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
            .padding(.bottom, 65)
            VStack {
                Spacer()
                ChatTextFieldView(viewModel: viewModel)
                    .background(.white)
            }
            
        }
        .navigationTitle(chatUser.email)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension ChatMessagesView {
    class ViewModel: ObservableObject {
        @Published public var currentChatMessage = String()
    }
}

struct ChatMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChatMessagesView(viewModel: .init(), chatUser: ChatUser(
                uid: "OQSFIjuneVeKL4hFNiAQGA0HvE22",
                email: "test6@gmail.com",
                profileImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/rapttrchat.appspot.com/o/OQSFIjuneVeKL4hFNiAQGA0HvE22?alt=media&token=7fc5b9b9-a293-425c-862f-85065768e5c8")
            )
        }
    }
}
