//
//  ChatTextFIeldView.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 12/01/2023.
//

import SwiftUI

struct ChatTextFieldView: View {
    @ObservedObject var viewModel: ChatMessagesView.ViewModel
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            TextField("description", text: $viewModel.currentChatMessage)
            Button {
                Task{
                    await viewModel.handleSend()
                }
                
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.blue)
            .cornerRadius(5)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct ChatTextFIeldView_Previews: PreviewProvider {
    static var previews: some View {
        ChatTextFieldView(viewModel: ChatMessagesView.ViewModel.init(chatUser: makeMockChatUser()))
    }
}
