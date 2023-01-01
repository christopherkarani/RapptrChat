//
//  View+SignInError.swift
//  RapptrChatApp
//
//  Created by Chris Karani on 01/01/2023.
//

import SwiftUI


extension View {
    func errorAlert(error: Binding<FirebaseAuthenticator.SignInError?>, buttonTitle: String = "OK") -> some View {
        let signInErr = FirebaseAuthenticator.SignInError(error: error.wrappedValue)
        return alert(isPresented: .constant(signInErr != nil), error: signInErr) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
    }
}
