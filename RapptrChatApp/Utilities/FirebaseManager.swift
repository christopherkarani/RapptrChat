//
//  FirebaseAuthenticator.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 01/01/2023.
//

import Firebase

public class FirebaseManager: NSObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    override init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        super.init()
    }
    
    public var currentUser : AuthenticatedUser? {
        return auth.currentUser
    }
}


extension FirebaseManager: AuthProtocol {
    public func signUp(with email: String,
                password: String,
                completion: @escaping (Result<AuthenticatedUser, AppError>) -> ()) {
        auth.createUser(withEmail: email, password: password) { result
            , error in
            if let error = error {
                completion(.failure(.failedRegistration(description: error.localizedDescription)))
                return
            }
            guard let user = result?.user else { return }
            completion(.success(user))
            return
        }
    }
    
    

    public func login(with email: String,
                password: String,
                completion: @escaping (Result<AuthenticatedUser, AppError>) -> ()) {
        
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(.failedLogin(description: error.localizedDescription)))
                return
            }
            guard let user = result?.user else { return }
            completion(.success(user))
            return
        }
    }
}


extension FirebaseManager: StorageProtocol {
    public func persist(image data: Data, for user: AuthenticatedUser, completion: @escaping (Result<URL, AppError>) -> ()) {
        let ref = storage.reference(withPath: user.uid)
        
        ref.putData(data, metadata: nil) { metadata, error in
            if let err = error {
                completion(.failure(.failedImageUpload(description: err.localizedDescription)))
                return
            }
            ref.downloadURL { url, err in
                if let err = error {
                    completion(.failure(.failedToRetrieveDownloadUrl(description: err.localizedDescription)))
                    return
                }
                guard let url = url else { return }
                completion(.success(url))
            }
            
        }
    }
}

extension FirebaseManager: DatabaseProtocol {
    func storUserInformation(withUrl imageProfileurl: URL, for user: AuthenticatedUser, completion: @escaping (Result<(), AppError>) -> () ) {
        let userData = ["email": user.email ?? "", "uid": user.uid, "profileImageUrl": imageProfileurl.absoluteString]
        firestore
            .collection("users")
            .document(user.uid)
            .setData(userData) { error in
                if let error = error {
                    completion(.failure(.failedToStoreUserInfo(description: error.localizedDescription)))
                    return
                }
                print("Success bitttttch")
                completion(.success(()))
            }
    }
}







