//
//  FirebaseAuthenticator.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 01/01/2023.
//

import FirebaseCore
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import Combine

public class FirebaseManager: NSObject, ObservableObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    @Published public var currentUser : AuthenticatedUser?
    private var cancellable: AnyCancellable?
    
    public var isUserLoggedIn = PassthroughSubject<Bool, Never>()
    
    static let shared = FirebaseManager()
    override init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        super.init()
        
        auth.addStateDidChangeListener { _, user in
            if let currentUser = user {
                self.currentUser = currentUser
                self.isUserLoggedIn.send(true)
            } else {
                self.currentUser = nil
                self.isUserLoggedIn.send(false)
            }
        }
    }
}


extension FirebaseManager: AuthProtocol {
    public func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            throw AppError.signOutError(description: error.localizedDescription)
        }
    }
    
    public func signUp(with email: String, password: String) async throws -> AuthenticatedUser {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return result.user
        } catch {
            throw AppError.failedRegistration(description: error.localizedDescription)
        }
    }
    
    public func login(with email: String, password: String) async throws -> AuthenticatedUser {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return result.user
        } catch {
            throw AppError.failedRegistration(description: error.localizedDescription)
        }
    }
    
    @available(*, deprecated, renamed: "signUp")
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
    @available(*, deprecated, renamed:  "login")
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
    public func persist(image data: Data, for user: AuthenticatedUser) async throws -> URL {
        let ref = storage.reference(withPath: user.uid)
        do {
            let _ = try await ref.putDataAsync(data)
            let url = try await ref.downloadURL()
            return url
        } catch {
            throw AppError.failedToRetrieveDownloadUrl(description: error.localizedDescription)
        }
    }
    
    
    
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
    func fetchMessages(for chatUser: ChatUser, completion: @escaping (Result<[ChatMessageModel], AppError>) -> ()) {
        guard let fromID = currentUser?.uid else { return }
        firestore
            .collection(FirebaseConstants.DatabaseCollections.messages)
            .document(fromID)
            .collection(chatUser.uid)
            .order(by: FirebaseConstants.DatabaseCollections.timestamp)
            .addSnapshotListener { querySnapShot, error in
                if let err = error {
                    print(err)
                    completion(.failure(AppError.fetchMessages(description: err.localizedDescription)))
                    return
                }
                let result = querySnapShot?.documentChanges
                    .filter { $0.type == .added }
                    .compactMap { ChatMessageModel(documentID:  $0.document.documentID, data: $0.document.data()) }
                completion(.success(result ?? []))
            }
    }
    
    func fetchAllUsers() async throws -> [ChatUser] {
        let documentSnapShot = try await FirebaseManager.shared.firestore.collection("users")
            .getDocuments()
        return documentSnapShot.documents
            .map { ChatUser(data: $0.data()) }
            .filter { $0.uid != currentUser?.uid}
    }
    
    func fetchCurrentUserInfo() async throws -> [String : Any] {
        guard let user = currentUser else {
            throw AppError.unableToRetrieveCurrentUser
        }
        do {
            let documentSnapshot = try await FirebaseManager.shared.firestore.collection("users")
                .document(user.uid).getDocument()
            guard let data = documentSnapshot.data() else {
                throw AppError.unableToRetrieveCollectionData
            }
            return data
        } catch {
            throw AppError.collectionDataError(description: error.localizedDescription)
        }
    }
    
    
    func storUserInformation(withUrl imageProfileurl: URL, for user: AuthenticatedUser) async throws {
        guard let email = user.email else { throw AppError.errorFormingUserDatat(type: "email")}
        let userData = UserData(email: email, uid: user.uid, profileIamageUrl: imageProfileurl.absoluteString)
        do {
            try await firestore
                .collection(FirebaseConstants.DatabaseCollections.users)
                .document(user.uid)
                .setData(userData.data())
        } catch {
            throw AppError.failedToStoreUserInfo(description: error.localizedDescription)
        }
    }
    
    func storUserInformation(withUrl imageProfileurl: URL, for user: AuthenticatedUser, completion: @escaping (Result<(), AppError>) -> () ) {
        guard let email = user.email else { return }
        let userData = UserData(email: email, uid: user.uid, profileIamageUrl: imageProfileurl.absoluteString)
        firestore
            .collection("users")
            .document(user.uid)
            .setData(userData.data()) { error in
                if let error = error {
                    completion(.failure(.failedToStoreUserInfo(description: error.localizedDescription)))
                    return
                }
                completion(.success(()))
            }
    }
    
    func send(chatMessage: String, toID: String) async throws {
        guard let fromID = currentUser?.uid else { throw AppError.unableToRetrieveCurrentUser }
        let messageData = ChatMessageModel.sendMessageData(chatMessage: chatMessage, toID: toID, fromID: fromID)
        let document = firestore
            .collection(FirebaseConstants.DatabaseCollections.messages)
            .document(fromID)
            .collection(toID)
            .document()
        try await document.setData(messageData)
        let reciepientDocument = firestore
            .collection(FirebaseConstants.DatabaseCollections.messages)
            .document(toID)
            .collection(fromID)
            .document()
        try await reciepientDocument.setData(messageData)
    }
}







