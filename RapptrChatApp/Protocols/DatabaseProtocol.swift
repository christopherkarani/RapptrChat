//
//  DatabaseProtocol.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 03/01/2023.
//

import Foundation


protocol DatabaseProtocol {
    func storUserInformation(withUrl imageProfileurl: URL, for user: AuthenticatedUser, completion: @escaping (Result<(), AppError>) -> ())
    
    func storUserInformation(withUrl imageProfileurl: URL, for user: AuthenticatedUser) async throws
    
    func fetchCurrentUserInfo() async throws -> [String: Any]
    
    func fetchAllUsers() async throws -> [ChatUser]
    
    func send(chatMessage: String, toID: String) async throws
}
