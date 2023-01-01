//
//  FirebaseAuthenticator.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 01/01/2023.
//

import FirebaseAuth


protocol SignInProtocol {
    func login(with email: String, password: String, completion: @escaping ((Result<(), FirebaseAuthenticator.SignInError>)) -> ())
    func signUp(with email: String, password: String, completion: @escaping ((Result<(), FirebaseAuthenticator.SignInError>)) -> ())
}

class FirebaseAuthenticator: SignInProtocol {
    func signUp(with email: String,
                password: String,
                completion: @escaping (Result<(), SignInError>) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { result
            , error in
            if let error = error {
                completion(.failure(.failedRegistration(description: error.localizedDescription)))
                return
            }
            return
        }
    }
    
    func login(with email: String,
                password: String,
                completion: @escaping (Result<(), SignInError>) -> ()) {
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(.failedLogin(description: error.localizedDescription)))
                return
            }
            return
        }
    }
}


extension FirebaseAuthenticator {
    public enum SignInError: LocalizedError {
        case failedLogin(description: String)
        case failedRegistration(description: String)
        case error(description: String)
        
        init?(error: SignInError?) {
            guard let err = error else { return nil}
            self = err
        }
        
        public var errorDescription: String? {
            switch self {
            case .failedLogin(description: let description):
                return "Failed Login: \(description)"
            case .failedRegistration(description: let description):
                return "Failed Registration: \(description)"
            case .error(description: let description):
                return "Error: \(description)"
            }
        }
    }
}
