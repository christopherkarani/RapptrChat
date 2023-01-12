//
//  MainMessagesView.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 04/01/2023.
//

import SwiftUI
import Combine


struct MainMessagesView: View {
    @ObservedObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                CustomNavigationBar(viewModel: viewModel)
                MessagesView()
            }//: Vstack
            .navigationDestination(isPresented: $viewModel.shouldNavigateToChatView) {
            }
            .overlay(
                NewMessagesButton(viewModel: viewModel),
                alignment: .bottom)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                Task {
                    guard (await viewModel.fetchCurrentUserInfo()) != nil else { return }
                }
            }
        } //: Navigation View
    }
}

extension MainMessagesView {
    @MainActor public class ViewModel: ObservableObject {
        
        
        private var rubish = Set<AnyCancellable>()
        private var database: DatabaseProtocol
        private var authenticator: AuthProtocol
        var error: AppError?

        
        @Published public var chatUser: ChatUser?
        @Published public var shouldShowMessageScreen: Bool = false
        @Published public var selectedChatUser: ChatUser?
        @Published public var shouldNavigateToChatView: Bool = false
        @Published public var shouldShowLogoutOptions: Bool = false
        @Published public var isUserLoggedOut: Bool = false
        
        public init(database: DatabaseProtocol = FirebaseManager.shared,
             authenticator: AuthProtocol = FirebaseManager.shared
        ) {
            self.database = database
            self.authenticator = authenticator
            
            FirebaseManager.shared.isUserLoggedIn
                .sink { [weak self] isUserLoggedIn in
                    self?.isUserLoggedOut = !isUserLoggedIn
                }.store(in: &rubish)
        }
        
        public func handleSignOut() {
            isUserLoggedOut = true
            do {
                try authenticator.signOut()
            } catch {
                self.error = error as? AppError
            }
        }
        
        public func toggleSettingsAlert() {
            shouldShowLogoutOptions.toggle()
        }
        
        public func fetchCurrentUserInfo() async -> [String: Any]? {
            do {
                let userData = try await database.fetchCurrentUserInfo()
                self.chatUser = ChatUser(data: userData)
                return userData
            } catch {
                self.error = error as? AppError
            }
            
            return nil
        }
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
            .preferredColorScheme(.dark)
        MainMessagesView()
    }
}
