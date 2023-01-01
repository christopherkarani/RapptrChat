//
//  ContentView.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 23/12/2022.
//

import SwiftUI
import Firebase

struct SignInView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker(selection: $viewModel.isLoginMode) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    } label: {
                        Text("Login")
                    } //: Picker
                    .pickerStyle(SegmentedPickerStyle())
                    
                    
                    if !viewModel.isLoginMode {
                        Button {
                            
                        } label: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .padding()
                        } //: Button
                    }
                    Group {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        SecureField("Password", text: $viewModel.password)
                    } //: Group
                    .padding(12)
                    .background(.white)
                    
                    Button {
                        viewModel.handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(viewModel.isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }
                        .background(.blue)
                    } //: Button
                } //: VStack
                .padding()
                .errorAlert(error: $viewModel.error)
            } //: ScrollView
            .navigationTitle(viewModel.isLoginMode ? "Log In" : "Create Account")
            .background(Color(white: 0, opacity: 0.05)
                .ignoresSafeArea())
        } //: NavigationView
        .navigationViewStyle(.stack)
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}


extension SignInView {
    @MainActor class ViewModel: ObservableObject {
        @Published public var error: FirebaseAuthenticator.SignInError?
        @Published public var isLoginMode = false
        @Published public var email = ""
        @Published public var password = ""
        @Published public var authenticator = FirebaseAuthenticator()
        
        /// Handles the Login Action Button
        public func handleAction() {
            if isLoginMode {
                print("Login to firebase with existing credentials")
            } else {
                print("Register a new account inside of firebase Auth and then store image in Storage somehow")
                signUp()
            }
        }
        
        public func signUp() {
            authenticator.signUp(with: email, password: password) { result in
                switch result {
                case .failure(let err):
                    self.error = err
                case .success(()):
                    print("Success")
                }
            }
        }
        
        public func singIn() {
            authenticator.login(with: email, password: password) { result in
                switch result {
                case .failure(let err):
                    self.error = err
                case .success(()):
                    print("Success")
                }
            }
        }
    }
}
