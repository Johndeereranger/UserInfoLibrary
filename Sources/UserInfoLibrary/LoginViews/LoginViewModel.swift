//
//  File.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/27/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

@MainActor
public class LoginViewModel: ObservableObject {
    public static let instance = LoginViewModel()
    
    @Published public var loginStatusMessage: String = ""
    @Published public var isLoading: Bool = false

    // MARK: - Async/Await Methods

    /// Handles login or account creation based on mode (Async)
    public func handleAction(
        isLoginMode: Bool,
        email: String,
        password: String,
        firstName: String? = nil,
        lastName: String? = nil,
        companyName: String? = nil
    ) async throws {
        loginStatusMessage = ""
        isLoading = true

        do {
            if isLoginMode {
                try await loginUser(email: email, password: password)
            } else {
                guard let firstName = firstName?.trimmingCharacters(in: .whitespaces),
                      let lastName = lastName?.trimmingCharacters(in: .whitespaces),
                      LoginValidationUtils.isNameValid(firstName),
                      LoginValidationUtils.isNameValid(lastName) else {
                    throw LoginError.invalidName
                }
                try await createNewAccount(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    companyName: companyName
                )
            }
            isLoading = false // Success path
        } catch {
            isLoading = false // Error path
            loginStatusMessage = "Error: \(error.localizedDescription)"
            throw error
        }
    }


    /// Logs in a user (Async)
    public func loginUser(email: String, password: String) async throws {
        do {
            // Perform the sign-in operation in a detached task
            let uid = try await Task.detached {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                return result.user.uid // Extract UID
            }.value
            
            // Return to the main actor for UI updates
            loginStatusMessage = "Successfully logged in with UID: \(uid)"
            print("Logged in user ID: \(uid)")
        } catch {
            // Handle errors
            loginStatusMessage = "Failed to log in: \(error.localizedDescription)"
            throw error
        }
    }




    /// Creates a new account (Async)
    public func createNewAccount(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        companyName: String?
    ) async throws {
        do {
            // Perform the account creation operation in a detached task
            let uid = try await Task.detached {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                return result.user.uid // Extract UID
            }.value

            // Execute further operations on the main actor
            await UserInfoManager.shared.createUser(email: email, firstName: firstName, lastName: lastName, uid: uid, companyName: companyName)
            loginStatusMessage = "Account created successfully."
            print("Account created for user ID: \(uid)")
        } catch {
            // Handle errors
            loginStatusMessage = "Failed to create account: \(error.localizedDescription)"
            throw error
        }
    }


    /// Resets the user's password (Async)
    public func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            loginStatusMessage = "Password reset email sent successfully."
        } catch {
            loginStatusMessage = "Failed to send password reset: \(error.localizedDescription)"
            throw error
        }
    }

    // MARK: - Completion-Based Convenience Wrappers (Optional)

    /// Handles login or account creation using completion blocks
    public func handleAction(
        isLoginMode: Bool,
        email: String,
        password: String,
        firstName: String? = nil,
        lastName: String? = nil,
        companyName: String? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await handleAction(isLoginMode: isLoginMode, email: email, password: password, firstName: firstName, lastName: lastName, companyName: companyName)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Resets the password using a completion block
    public func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                try await resetPassword(email: email)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    @MainActor
    public func signOut() async throws {
        do {
            try Auth.auth().signOut()
            // Reset ViewModel state after sign-out
            loginStatusMessage = ""
            isLoading = false
            print("Successfully signed out from Firebase Auth.")
        } catch {
            print("Error signing out from Firebase Auth:", error.localizedDescription)
            throw error
        }
    }


}

public enum LoginError: LocalizedError {
    case invalidName
    case invalidEmail
    case missingUID

    public var errorDescription: String? {
        switch self {
        case .invalidName: return "Name must be between 2 and 20 characters."
        case .invalidEmail: return "Please provide a valid email address."
        case .missingUID: return "User ID is missing after login."
        }
    }
}

