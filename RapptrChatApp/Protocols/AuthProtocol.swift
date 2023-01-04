//
//  SignInProtocol.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 01/01/2023.
//



public protocol AuthProtocol {
    /// Authenticate users and register them into database
    /// - parameter email: users unique email used to register them into the database
    /// - parameter password: The users 6 character password
    /// - parameter completion: Function called upon completion of this network activity
    func login(with email: String, password: String, completion: @escaping ((Result<AuthenticatedUser, AppError>)) -> ())
    
    /// Authenticate and log users into the app
    /// - parameter email: users unique email used to log them into the app
    /// - parameter password: The users 6 character password
    /// - parameter completion: Function called upon completion of this network activity
    func signUp(with email: String, password: String, completion: @escaping ((Result<AuthenticatedUser, AppError>)) -> ())
    
    /// The Current user of the app
    var currentUser: AuthenticatedUser? { get }
}
