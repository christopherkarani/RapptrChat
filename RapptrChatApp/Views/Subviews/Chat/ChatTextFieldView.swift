//
//  ChatTextFIeldView.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 12/01/2023.
//

import SwiftUI

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct ChatTextFieldView: View {
    @ObservedObject var viewModel: ChatMessagesView.ViewModel
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $viewModel.currentChatMessage)
                    .opacity(viewModel.currentChatMessage.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
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
