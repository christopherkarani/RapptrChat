//
//  StorageProtocol.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 02/01/2023.
//

import Foundation


public protocol StorageProtocol {
    /// A method used to persist images to storage for an Authenticated User
    /// - parameter image: The Data for the image to be uploaded
    /// - parameter path: The path used for storage location
    /// - parameter user: The User that this image belongs to
    func persist(image data: Data, toStorage path: String, for user: AuthenticatedUser, completion: @escaping (Result<URL, AppError>) -> ())
}

