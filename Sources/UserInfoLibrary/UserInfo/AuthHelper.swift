//
//  AuthHelper.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/29/25.
//

import Foundation

import Foundation
import FirebaseAuth

@MainActor
public class AuthHelper {
    
    /// Returns the current authenticated user ID, or `nil` if the user is not signed in.
    public static var currentUserID: String? {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("⚠️ AuthHelper: currentUserID is nil - User is not authenticated.")
            return nil
        }
        return userID
    }
    
    /// Checks if a user is currently authenticated.
    public static var isUserAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }
}
