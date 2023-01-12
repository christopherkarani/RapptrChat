//
//  NewMessagesButton.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 12/01/2023.
//

import SwiftUI

struct NewMessagesButton: View {
    @ObservedObject var viewModel: MainMessagesView.ViewModel = .init()
    var body: some View {
        Button {
            viewModel.shouldShowMessageScreen.toggle()
        } label: {
            Spacer()
            Text("+ New Message")
                .font(.system(size: 16, weight: .bold))
            Spacer()
        }
        .foregroundColor(.white)
        .padding(.vertical)
        .background(Color.blue)
        .cornerRadius(32)
        .padding(.horizontal)
        .shadow(radius: 15)
        .fullScreenCover(isPresented: $viewModel.shouldShowMessageScreen) {
            CreateNewMessageView { user in
                viewModel.shouldNavigateToChatView.toggle()
                viewModel.selectedChatUser = user
            }
        }
    }
}

struct NewMessagesButton_Previews: PreviewProvider {
    static var previews: some View {
        NewMessagesButton()
    }
}
