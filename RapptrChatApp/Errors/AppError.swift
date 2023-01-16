//
//  SignInError.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 02/01/2023.
//

import Foundation

public enum AppError: LocalizedError {
    case errorFormingUserDatat(type: String)
    case failedLogin(description: String)
    case failedRegistration(description: String)
    case failedImageUpload(description: String)
    case failedToRetrieveDownloadUrl(description: String)
    case failedToStoreUserInfo(description: String)
    case unableToRetrieveCollectionData
    case collectionDataError(description: String)
    case unableToRetrieveCurrentUser
    case signOutError(description: String)
    case noUserImagePicked
    case errorFetchingAllUsers(description: String)
    case errorFetchingMessages(description: String)
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
        case .unableToRetrieveCollectionData:
            return "Firestore was unable to retrieve the collection Data"
        case .unableToRetrieveCurrentUser:
            return "Failed to retrieve current user"
        case .collectionDataError(description: let description):
            return "Collection Data Error: \(description)"
        case .signOutError(description: let description):
            return "Error signing user out: \(description)"
        case .noUserImagePicked:
            return "User has not picked a profile Image, Tap on the Person.Fill image to present Image Picker"
        case .errorFetchingAllUsers(description: let description):
            return "There was an error fetching all the users: \(description)"
        case .errorFormingUserDatat(let type):
            return "There was error forming User data: \(type)"
        case .errorFetchingMessages(description: let description):
            return "There was an error fetching messages: \(description)"
        }
    }
}
