//
//  ContentView.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 23/12/2022.
//

import SwiftUI
import Firebase

struct AuthenticationView: View {
    
    @StateObject private var viewModel = ViewModel()
    
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
                            viewModel.handleImagePickerAction()
                        } label: {
                            VStack {
                                if let image = self.viewModel.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 128, height: 128)
                                        .scaledToFill()
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(.black)
                                }
                            } //: VStack
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth: 3)
                            )
                        } //: Button
                    }
                    Group {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        SecureField("Password", text: $viewModel.password)
                    } //: Group
                    .padding(12)
                    .background(.white)
                    
                    Button {
                        Task {
                            await viewModel.handleSignInAction()
                        }
                        
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
        .fullScreenCover(isPresented: $viewModel.shouldShowImagePicker) {
            ImagePicker(image: $viewModel.image)
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}


