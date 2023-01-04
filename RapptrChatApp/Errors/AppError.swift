//
//  SignInError.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 02/01/2023.
//

import Foundation

public enum AppError: LocalizedError {
    case failedLogin(description: String)
    case failedRegistration(description: String)
    case failedImageUpload(description: String)
    case failedToRetrieveDownloadUrl(description: String)
    case failedToStoreUserInfo(description: String)
    case error(description: String)
    
    init?(error: AppError?) {
        guard let err = error else { return nil}
        self = err
    }
    
    public var errorDescription: String? {
        switch self {
        case .failedLogin(description: let description):
            return "Failed Login: \(description)"
        case .failedRegistration(description: let description):
            return "Failed Registration: \(description)"
        case .failedImageUpload(description: let description):
            return "Failed Image upload: \(description)"
        case .failedToRetrieveDownloadUrl(description: let description):
            return "Failed to retrieve download Url: \(description)"
        case .error(description: let description):
            return "Error: \(description)"
        case .failedToStoreUserInfo(description: let description):
            return "Failed to store user Info in Firestore: \(description)"
        }
    }
}
