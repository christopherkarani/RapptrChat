//
//  AuthenticatedUser.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 01/01/2023.
//

import FirebaseAuth



public protocol AuthenticatedUser {
    var uid: String { get }
    var email: String? { get }
    var refreshToken: String? { get }
    var photoURL: URL? { get }
}

extension User: AuthenticatedUser {}
