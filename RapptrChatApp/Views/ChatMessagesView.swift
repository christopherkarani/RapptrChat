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
    
    
    func messageBubble(text: String) -> some View {
        HStack {
            Spacer()
            HStack {
                Text(text)
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
                ForEach(viewModel.chatMessages) { message in
                    messageBubble(text: message.text)
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
            Text(viewModel.errorMessage)
        }
        
        .navigationTitle(chatUser.email)
        .navigationBarTitleDisplayMode(.inline)
    }
}


extension ChatMessagesView {
    @MainActor class ViewModel: ObservableObject {
        let chatUser: ChatUser
        @Published var errorMessage: String = ""
        private var database: DatabaseProtocol
        
        init(chatUser: ChatUser, database: DatabaseProtocol = FirebaseManager.shared) {
            self.chatUser = chatUser
            self.database = database
            
            fetchMessages()
        }
        
        @Published public var currentChatMessage = String()
        @Published public var chatMessages = [ChatMessageModel]()
        
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
                    querySnapShot?.documentChanges.forEach { [weak self] change in
                        if change.type == .added {
                            let data = change.document.data()
                            let documentID = change.document.documentID
                            self?.chatMessages.append(.init(documentID: documentID,data: data))
                        }
                    }
//                    querySnapShot?.documents.forEach({ [weak self] queryDocumentSnapShot in
//                        let data = queryDocumentSnapShot.data()
//                        let documentID = queryDocumentSnapShot.documentID
//                        self?.chatMessages.append(.init(documentID: documentID,data: data))
//                    })
                }
        }
        
        public func handleSend() async {
            do {
                guard !currentChatMessage.isEmpty else { return }
                try await database.send(chatMessage: currentChatMessage, toID: chatUser.uid)
                currentChatMessage = String()
                
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
