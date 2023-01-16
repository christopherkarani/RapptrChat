//
//  CreateNewMessageView.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 11/01/2023.
//

import SwiftUI

struct CreateNewMessageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = ViewModel()
    let didSelectNewUser: (ChatUser) -> ()
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(viewModel.users) { user in
                    Button {
                        didSelectNewUser(user)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            AsyncImage(url: URL(string: user.profileImageUrl)) { image in
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
                            Text(user.email)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }.padding(.horizontal)
                        Divider()
                            .padding(.vertical)
                    }
                }
            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .errorAlert(error: $viewModel.error)
        }
        .navigationViewStyle(.stack)
    }
}

extension CreateNewMessageView {
    @MainActor class ViewModel: ObservableObject {
        var database: DatabaseProtocol
        var error: AppError?
        @Published var users = [ChatUser]()
        
        init(database: DatabaseProtocol = FirebaseManager.shared) {
            self.database = database
            Task {
                await fetchAllUsers()
            }
        }
        
        private func fetchAllUsers() async {
            do {
                users = try await database.fetchAllUsers()
            } catch {
                self.error = AppError.errorFetchingAllUsers(description: error.localizedDescription)
            }
        }
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewMessageView { user in
            print("user", user.uid)
        }
    }
}
