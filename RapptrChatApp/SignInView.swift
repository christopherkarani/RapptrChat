//
//  ContentView.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 23/12/2022.
//

import SwiftUI

struct SignInView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    } label: {
                        Text("Login")
                    } //: Picker
                    .pickerStyle(SegmentedPickerStyle())
                    
                    
                    if !isLoginMode {
                        Button {
                            handleAction()
                        } label: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .padding()
                        } //: Button
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.none )
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(.white)
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }
                        .background(.blue)
                    } //: Button
                } //: VStack
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(white: 0, opacity: 0.05)
                .ignoresSafeArea())
        }
    }
    
    private func handleAction() {
        if isLoginMode {
            print("Login to firebase with existing credentials")
        } else {
            print("Register a new account inside of firebase Auth and then store image in Storage somehow")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
