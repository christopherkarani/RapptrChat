//
//  ChatMessagesView.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 12/01/2023.
//

import SwiftUI
import FirebaseFirestore

struct ChatMessagesView: View {
    @ObservedObject var viewModel: ViewModel
    
    
    var chatUser: ChatUser
    
    init(chatUser: ChatUser) {
        self.chatUser = chatUser
        self.viewModel = .init(chatUser: chatUser)
    }
    
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
    
    var messagesView: some View {
        VStack {
            ScrollView {
                ForEach(0..<20) { num in
                    messageBubble
                }
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
            .safeAreaInset(edge: .bottom) {
                ChatTextFieldView(viewModel: viewModel)
                    .background(Color(.systemBackground)
                        .ignoresSafeArea()
                    )
            }
        }
    }
    

    var body: some View {
        ZStack {
            messagesView
        }
        .navigationTitle(chatUser.email)
        .navigationBarTitleDisplayMode(.inline)
        .errorAlert(error: $viewModel.error)
    }
}


extension ChatMessagesView {
    class ViewModel: ObservableObject {
        let chatUser: ChatUser
        @Published var errorMessage: String = ""
        @Published var error: AppError?
        private var database: DatabaseProtocol
        
        init(chatUser: ChatUser, database: DatabaseProtocol = FirebaseManager.shared) {
            self.chatUser = chatUser
            self.database = database
            
            fetchMessages()
        }
        
        @Published public var currentChatMessage = String()
        
        func fetchMessages() {
            guard let fromID = FirebaseManager.shared.currentUser?.uid else { return }
            
            FirebaseManager.shared.firestore
                .collection("messages")
                .document(fromID)
                .collection(chatUser.uid)
                .addSnapshotListener { querySnapShot, error in
                    if let err = error {
                        self.errorMessage = "failed to listen for messages: \(err.localizedDescription)"
                        print(err)
                        return
                    }
                    querySnapShot?.documents.forEach({ queryDocumentSnapShot in
                        queryDocumentSnapShot.data()
                    })
                }
        }
        
        public func handleSend() async {
            do {
                try await database.send(chatMessage: currentChatMessage, toID: chatUser.uid)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct ChatMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChatMessagesView(chatUser: makeMockChatUser())
        }
    }
}

func makeMockChatUser() -> ChatUser {
    ChatUser(
        uid: "OQSFIjuneVeKL4hFNiAQGA0HvE22",
        email: "test6@gmail.com",
        profileImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/rapttrchat.appspot.com/o/OQSFIjuneVeKL4hFNiAQGA0HvE22?alt=media&token=7fc5b9b9-a293-425c-862f-85065768e5c8")
}
