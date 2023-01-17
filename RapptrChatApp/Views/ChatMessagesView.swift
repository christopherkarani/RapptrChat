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
        .errorAlert(error: $viewModel.error)
    }
}


extension ChatMessagesView {
<<<<<<< HEAD
    class ViewModel: ObservableObject {
        let chatUser: ChatUser
        @Published var error: AppError?
=======
    @MainActor class ViewModel: ObservableObject {
        @Published var errorMessage: String = ""
        @Published public var currentChatMessage = String()
        @Published public var chatMessages = [ChatMessageModel]()
        @Published public var appError: AppError?
        @Published public var count = 0
        let chatUser: ChatUser
>>>>>>> d1e34b38f3813e2ba01f922ffba8d64192d20f22
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
        
<<<<<<< HEAD
        func fetchMessages() {
            guard let fromID = FirebaseManager.shared.currentUser?.uid else { return }
            
            FirebaseManager.shared.firestore
                .collection("messages")
                .document(fromID)
                .collection(chatUser.uid)
                .addSnapshotListener { querySnapShot, error in
                    if let err = error {
                        self.error = AppError.errorFetchingMessages(description: err.localizedDescription)
                        return
                    }
                    querySnapShot?.documents.forEach({ queryDocumentSnapShot in
                        queryDocumentSnapShot.data()
                    })
=======
        public func fetchMessages() {
            database.fetchMessages(for: chatUser) { [weak self] result in
                switch result {
                case .success(let messages):
                    self?.chatMessages = messages
                    self?.count += 1 // scroll to bottom
                case .failure(let error):
                    self?.appError = error
>>>>>>> d1e34b38f3813e2ba01f922ffba8d64192d20f22
                }
            }
        }
        
        public func handleSend() async {
            do {
                guard !currentChatMessage.isEmpty else { return }
                try await database.send(chatMessage: currentChatMessage, toID: chatUser.uid)
                currentChatMessage = String()
                count += 1
            } catch {
<<<<<<< HEAD
                self.error = AppError.errorSendingMessage(description: error.localizedDescription)
=======
                appError = AppError.failedToSendMessage(description: error.localizedDescription)
>>>>>>> d1e34b38f3813e2ba01f922ffba8d64192d20f22
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
