//
//  AuthenticationViewModel.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 03/01/2023.
//

import SwiftUI
import Combine

class AppEnviromentObject: ObservableObject {
    @Published var isUserLoggedIn: Bool = false
}

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
        
        
        private func getImageData(_ compressionQuality: Double = 0.5) throws -> Data {
            guard let data = self.image?.jpegData(compressionQuality: compressionQuality) else {
                throw AppError.noUserImagePicked
            }
            return data
        }
        
        
        /// Handles the Login Action Button
        public func handleSignInAction() async {
            do {
                if isLoginMode {
                    try await authenticator.login(with: email, password: password)
                } else {
                    let imageData = try self.getImageData() 
                    let user = try await authenticator.signUp(with: email, password: password)
                    let url = try await storage.persist(image: imageData, for: user)
                    try await database.storUserInformation(withUrl: url, for: user)
                }
            } catch {
                self.error = error as? AppError
            }
        }
        
        public func handleImagePickerAction() {
            shouldShowImagePicker.toggle()
        }
    }
}
