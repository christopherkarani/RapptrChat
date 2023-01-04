//
//  AuthenticationViewModel.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 03/01/2023.
//

import SwiftUI

extension AuthenticationView {
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
        private var authenticator: AuthProtocol
        
        private var storage: StorageProtocol
        
        private var database: DatabaseProtocol
        
        
        /// A flag to dictate when we show the ImagePickerController
        @Published public var shouldShowImagePicker: Bool = false
        
        /// The image of the User
        @Published public var image: UIImage?
        
        
        init(authenticator: AuthProtocol = FirebaseManager.shared,
             storage: StorageProtocol = FirebaseManager.shared,
             database: DatabaseProtocol = FirebaseManager.shared
        ) {
            self.authenticator = authenticator
            self.storage = storage
            self.database = database
        }
        
        private func getImageData(_ compressionQuality: Double = 0.5) -> Data? {
            guard let data = self.image?.jpegData(compressionQuality: compressionQuality) else {
                return nil
            }
            return data
        }
        
        private func saveUserInfo(_ url: URL, _ user: AuthenticatedUser) {
            database.storUserInformation(withUrl: url, for: user) { result in
                if let _ = try? result.get() {
                    print("Success")
                }
            }
        }
        
        /// Handles the Login Action Button
        public func handleSignInAction() {
            if isLoginMode {
                singIn { user in
                    
                }
            } else {
                signUp { [weak self] user in
                    guard let self = self, let imageData = self.getImageData() else { return }
                    self.persistImageToStorage(for: user, imageData) { url in
                        self.saveUserInfo(url, user)
                    }
                }
            }
        }
        
        /// #Sign up
        /// A function used to register users into to Rapttr chat database
        public func signUp(completion: @escaping (AuthenticatedUser) -> () ) {
            authenticator.signUp(with: email, password: password) { result in
                switch result {
                case .failure(let err):
                    self.error = err
                case .success(let user):
                    completion(user)
                }
            }
        }
        
        /// #Sign in
        /// A function used to log users into to Rapttr chat app
        /// parameter: email
        public func singIn(completion: @escaping (AuthenticatedUser) -> () ) {
            authenticator.login(with: email, password: password) { result in
                switch result {
                case .failure(let err):
                    self.error = err
                case .success(let user):
                    completion(user)
                }
            }
        }
        
        public func handleImagePickerAction() {
            shouldShowImagePicker.toggle()
        }
        
        
        public func persistImageToStorage(for user: AuthenticatedUser, _ imageData: Data, completion: @escaping (URL) -> ()) {
            storage.persist(image: imageData, for: user) { result in
                switch result {
                case .success(let url):
                    completion(url)
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
}
