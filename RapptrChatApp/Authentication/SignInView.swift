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
                        viewModel.handleSignInAction()
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
        SignInView()
    }
}


extension SignInView {
    @MainActor class ViewModel: ObservableObject {
        /// Used to propogate signIn Errors
        @Published public var error: AppError?
        
        /// A Flag to keep track of the segmented control
        @Published public var isLoginMode = false
        
        /// The email of the user entered in the email textfield
        @Published public var email = ""
        
        /// The password of the user entered into the password textfield
        @Published public var password = ""
        
        /// The Object used to authenticate users
        @Published public var authenticator: AuthProtocol
        
        
        /// A flag to dictate when we show the ImagePickerController
        @Published public var shouldShowImagePicker: Bool = false
        
        /// The image of the User
        @Published public var image: UIImage?
        
        
        init(authenticator: AuthProtocol = FirebaseManager()) {
            self.authenticator = authenticator
        }
        
        /// Handles the Login Action Button
        public func handleSignInAction() {
            if isLoginMode {
                singIn()
            } else {
                signUp()
            }
        }
        
        /// #Sign up
        /// A function used to register users into to Rapttr chat database
        public func signUp() {
            authenticator.signUp(with: email, password: password) { result in
                switch result {
                case .failure(let err):
                    self.error = err as? AppError
                case .success(let user):
                    print("Sign up success for \(user.uid)")
                    self.persistImageToStorage()
                }
            }
        }
        
        /// #Sign in
        /// A function used to log users into to Rapttr chat app
        /// parameter: email
        public func singIn() {
            authenticator.login(with: email, password: password) { result in
                switch result {
                case .failure(let err):
                    self.error = err as? AppError
                case .success(let user):
                    print("Sign In success for \(user.uid)")
                }
            }
        }
        
        public func handleImagePickerAction() {
            shouldShowImagePicker.toggle()
        }
        
        public func persistImageToStorage() {
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
                return
            }
            let ref = FirebaseManager.shared.storage.reference(withPath: uid)
            guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {
                return
            }
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let err = error {

                    return
                }
                
                ref.downloadURL { url, err in
                    if let err = error {
                        
                        return
                    }
                    
                    print("Successfully uploaded Image")
                }
            }
        }
    }
}
