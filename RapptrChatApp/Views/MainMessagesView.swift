//
//  MainMessagesView.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 04/01/2023.
//

import SwiftUI




struct MainMessagesView: View {
    @State var shouldShowLogoutOptions: Bool = false
    
    
    
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
            Image(systemName: "person.fill")
                .font(.system(size: 34, weight: .heavy))
            VStack(alignment: .leading, spacing: 4) {
                Text("Username")
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
                shouldShowLogoutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
            }
            
        }
        .padding()
        .confirmationDialog("Sign Out", isPresented: $shouldShowLogoutOptions) {
            Button("Sign Out", role: .destructive) {
                print("handle sign out")
            }
            
            Button("Cancel", role: .cancel) {
                
            }
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
        } //: Navigation View
    }
}

extension MainMessagesView {
    class ViewModel: ObservableObject {
        @Published var shouldShowLogoutOptions: Bool = false
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
            .preferredColorScheme(.dark)
        MainMessagesView()
    }
}
