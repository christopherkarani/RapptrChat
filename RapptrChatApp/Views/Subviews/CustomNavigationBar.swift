//
//  CustomNavigationBar.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 12/01/2023.
//

import SwiftUI

struct CustomNavigationBar: View {
    @ObservedObject var viewModel: MainMessagesView.ViewModel
    var body: some View {
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
}

struct CustomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationBar(viewModel: MainMessagesView.ViewModel())
    }
}
