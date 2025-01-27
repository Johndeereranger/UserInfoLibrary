//
//  File.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/27/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
public class LoginViewModel: ObservableObject {
    public static let instance = LoginViewModel()
    
    @Published public var loginStatusMessage: String = ""
     @Published public var isLoading: Bool = false
    
    
    /// Handles login or account creation based on mode
    public func handleAction(
        isLoginMode: Bool,
        email: String,
        password: String,
        firstName: String? = nil,
        lastName: String? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        loginStatusMessage = ""
        isLoading = true

        // Perform login or registration
        if isLoginMode {
            loginUser(email: email, password: password, completion: completion)
        } else {
            guard let firstName = firstName?.trimmingCharacters(in: .whitespaces),
                  let lastName = lastName?.trimmingCharacters(in: .whitespaces),
                  LoginValidationUtils.isNameValid(firstName),
                  LoginValidationUtils.isNameValid(lastName) else {
                completion(.failure(LoginError.invalidName))
                isLoading = false
                return
            }

            createNewAccount(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName,
                completion: completion
            )
        }
    }

    /// Resets the password for the given email
    public func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            completion(LoginError.invalidEmail)
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.loginStatusMessage = "Password reset failed: \(error.localizedDescription)"
                } else {
                    self.loginStatusMessage = "Password reset email sent successfully."
                }
                completion(error)
            }
        }
    }

    // MARK: - Private Methods

    public func loginUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.loginStatusMessage = "Failed to log in: \(error.localizedDescription)"
                    completion(.failure(error))
                } else {
                    self.loginStatusMessage = "Successfully logged in."
                    completion(.success(()))
                }
            }
        }
    }

    public func createNewAccount(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.loginStatusMessage = "Failed to create account: \(error.localizedDescription)"
                    completion(.failure(error))
                } else {
                    UserInfoManager.shared.createUser(email: email, firstName: firstName, lastName: lastName, uid: result?.user.uid ?? "")
                    self.loginStatusMessage = "Account created successfully."
                    completion(.success(()))
                }
            }
        }
    }

    // MARK: - Error Types
    public enum LoginError: LocalizedError {
        case invalidName
        case invalidEmail
        
        public var errorDescription: String? {
            switch self {
            case .invalidName: return "Name must be between 2 and 20 characters."
            case .invalidEmail: return "Please provide a valid email address."
            }
        }
    }
}
