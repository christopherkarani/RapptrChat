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
    
    func messageBubble(for message: ChatMessageModel) -> some View {
        VStack {
            if viewModel.isCurrentUser(message: message) {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    
                    HStack {
                        Text(message.text)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    var messagesView: some View {
        VStack {
            ScrollView {
                ScrollViewReader { proxy in
                    VStack {
                        ForEach(viewModel.chatMessages) { message in
                            messageBubble(for: message)
                        }
                        HStack { Spacer() }
                            .id(ViewModel.emptyScrollToString)
                    }
                    .onReceive(viewModel.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            proxy.scrollTo(ViewModel.emptyScrollToString, anchor: .bottom)
                        }
                    }
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
        .errorAlert(error: $viewModel.appError)
        .navigationTitle(chatUser.email)
        .navigationBarTitleDisplayMode(.inline)
    }
}


extension ChatMessagesView {
    @MainActor class ViewModel: ObservableObject {
        @Published var errorMessage: String = ""
        @Published public var currentChatMessage = String()
        @Published public var chatMessages = [ChatMessageModel]()
        @Published public var appError: AppError?
        @Published public var count = 0
        let chatUser: ChatUser
        private var database: DatabaseProtocol
        static let emptyScrollToString = "Empty"
        
        init(chatUser: ChatUser, database: DatabaseProtocol = FirebaseManager.shared) {
            self.chatUser = chatUser
            self.database = database
            fetchMessages()
        }
        
        public func isCurrentUser(message: ChatMessageModel) -> Bool {
            message.fromID == FirebaseManager.shared.currentUser?.uid
        }
        

        public func fetchMessages() {
            database.fetchMessages(for: chatUser) { [weak self] result in
                switch result {
                case .success(let messages):
                    self?.chatMessages = messages
                    self?.count += 1 // scroll to bottom
                case .failure(let error):
                    self?.appError = error

                }
            }
        }
        
        public func handleSend() async {
            do {
                guard !currentChatMessage.isEmpty else { return }
                try await database.send(chatMessage: currentChatMessage, toID: chatUser.uid)
                persistRecentMessage()
                currentChatMessage = String()
                count += 1
            } catch {
                appError = AppError.failedToSendMessage(description: error.localizedDescription)
            }
        }
        
        public func persistRecentMessage() {
            guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
            let document = FirebaseManager.shared.firestore
                .collection(FirebaseConstants.DatabaseCollections.recentMessages)
                .document(uid)
                .collection(FirebaseConstants.DatabaseCollections.messages)
                .document(self.chatUser.uid)
            
            let data = [
                FirebaseConstants.DatabaseCollections.timestamp: Timestamp(),
                FirebaseConstants.text: self.currentChatMessage,
                FirebaseConstants.fromID: uid,
                FirebaseConstants.toID: chatUser.uid,
                FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
                FirebaseConstants.email: chatUser.email
            ] as [String: Any]
            
            document.setData(data) { error in
                if let err = error {
                    self.appError = AppError.failedToSaveRecentMessage(description: err.localizedDescription)
                    return
                }
            }
            
            guard let currentUser = FirebaseManager.shared.currentUser else { return }
            let recipientRecentMessageDictionary = [
                FirebaseConstants.DatabaseCollections.timestamp: Timestamp(),
                FirebaseConstants.text: self.currentChatMessage,
                FirebaseConstants.fromID: uid,
                FirebaseConstants.toID: chatUser.uid,
                FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
                FirebaseConstants.email: chatUser.email
            ] as [String : Any]
            
            FirebaseManager.shared.firestore
                .collection(FirebaseConstants.DatabaseCollections.recentMessages)
                .document(chatUser.uid)
                .collection(FirebaseConstants.DatabaseCollections.messages)
                .document(currentUser.uid)
                .setData(recipientRecentMessageDictionary) { error in
                    if let error = error {
                        print("Failed to save recipient recent message: \(error)")
                        return
                    }
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
