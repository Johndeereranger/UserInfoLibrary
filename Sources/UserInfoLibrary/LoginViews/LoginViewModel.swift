//
//  File.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/27/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Foundation
import FirebaseFirestore
import FirebaseAuth

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
        lastName: String? = nil
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
                    lastName: lastName
                )
            }
        } catch {
            loginStatusMessage = "Error: \(error.localizedDescription)"
            throw error
        } finally {
            isLoading = false
        }
    }

    /// Logs in a user (Async)
    public func loginUser(email: String, password: String) async throws {
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            loginStatusMessage = "Successfully logged in."
        } catch {
            loginStatusMessage = "Failed to log in: \(error.localizedDescription)"
            throw error
        }
    }

    /// Creates a new account (Async)
    public func createNewAccount(
        email: String,
        password: String,
        firstName: String,
        lastName: String
    ) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            guard let uid = result.user.uid else {
                throw LoginError.invalidEmail
            }

            await UserInfoManager.shared.createUser(email: email, firstName: firstName, lastName: lastName, uid: uid)
            loginStatusMessage = "Account created successfully."
        } catch {
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
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await handleAction(isLoginMode: isLoginMode, email: email, password: password, firstName: firstName, lastName: lastName)
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
}
