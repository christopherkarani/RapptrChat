//
//  MainMessagesView.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 04/01/2023.
//

import SwiftUI
import Combine


struct ChatUser {
    let uid, email, profileImageUrl: String
}

extension ChatUser {
    init(data: [String: Any]) {
        uid = data["uid"] as? String ?? ""
        email = data["email"] as? String ?? ""
        profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
    
    var username: String {
        return email.replacingOccurrences(of: "@gmail.com", with: "")
    }
}


struct MainMessagesView: View {
    @ObservedObject private var viewModel = ViewModel()
    


    private var newMessageButton: some View {
        Button {
            
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
    }
    
    private var customNavigationBar: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: viewModel.chatUser?.profileImageUrl ?? "")) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .cornerRadius(50)
            .overlay(RoundedRectangle(cornerRadius: 32)
                .stroke(Color(.label), lineWidth: 1)
            )
            .shadow(radius: 5)
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.chatUser?.username ?? "")
                    .font(.system(size: 24, weight: .bold))
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            Button {
                viewModel.toggleSettingsAlert()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
            }
            
        }
        .padding()
        .confirmationDialog("Sign Out", isPresented: $viewModel.shouldShowLogoutOptions) {
            Button("Sign Out", role: .destructive) {
                viewModel.handleSignOut()
            }
            
            Button("Cancel", role: .cancel) {
        
            }
        }
        .fullScreenCover(isPresented: $viewModel.isUserLoggedOut) {
            AuthenticationView()
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 32)
                                .stroke(Color(.label), lineWidth: 1)
                            )
                        VStack(alignment: .leading) {
                            Text("Username")
                                .font(.system(size: 16, weight: .bold))
                            Text("Message sent to user")
                                .font(.system(size: 14))
                                .foregroundColor(Color(.lightGray))
                        }
                        Spacer()
                        Text("22d")
                            .font(.system(size: 14, weight: .semibold))
                    }//HStack
                    Divider()
                        .padding(.vertical, 8)
                }//: VStack
                .padding(.horizontal)
            }//: ForEach
            .padding(.bottom, 50)
        }//: ScrollView
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                customNavigationBar
                messagesView
            }//: Vstack
            .overlay(
                newMessageButton,
                alignment: .bottom)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                Task {
                    //viewModel.checkLoginStatus()
                    guard let data = await viewModel.fetchCurrentUserInfo() else {
                        print("unable to obtain data")
                        return
                    }
                    print("Current User Data \(data)")
                }
            }
        } //: Navigation View

    }
}

extension MainMessagesView {
    @MainActor class ViewModel: ObservableObject {
        
        var cancellable: AnyCancellable?
        
        var rubish = Set<AnyCancellable>()
        var error: AppError?
        var database: DatabaseProtocol
        
        // needed for sign out
        var authenticator: AuthProtocol
        
        @Published public var chatUser: ChatUser?
        
        
        init(database: DatabaseProtocol = FirebaseManager.shared,
             authenticator: AuthProtocol = FirebaseManager.shared
        ) {
            self.database = database
            self.authenticator = authenticator

            FirebaseManager.shared.isUserLoggedIn
                .sink { [weak self] isUserLoggedIn in
                    self?.isUserLoggedOut = !isUserLoggedIn
                }.store(in: &rubish)
        }
        @Published var shouldShowLogoutOptions: Bool = false
        
        @Published var isUserLoggedOut: Bool = false
        
        
      
            
        

        
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
