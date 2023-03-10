//
//  UserDataModel.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 15/01/2023.
//


struct UserData {
    let email, uid, profileIamageUrl: String
    public func data() -> [String: Any] {
        [FirebaseConstants.email: email,
         FirebaseConstants.uid: uid,
         FirebaseConstants.profileImageUrl: profileIamageUrl]
    }
}
