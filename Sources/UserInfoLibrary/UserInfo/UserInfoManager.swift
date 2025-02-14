//
//  File.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/17/25.
//

//test
import Foundation

//public struct UserInfo: Sendable {
//    public let id: String
//    public let name: String
//    public let email: String
//
//    public init(id: String, name: String, email: String) {
//        self.id = id
//        self.name = name
//        self.email = email
//    }
//}

import FirebaseCore
import FirebaseAuth
//import FirebaseFirestore

public class FirebaseManager: @unchecked Sendable {
    public static let shared = FirebaseManager()

    private init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
}

import FirebaseFirestore

public final class UserInfoManager: @unchecked Sendable {
    public static let shared = UserInfoManager()

    private let db = Firestore.firestore()

    private init() {
        // Ensure Firebase is initialized
        _ = FirebaseManager.shared
    }

    public func fetchUserInfo(userId: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists, let userInfo = UserInfo(document: snapshot) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid or missing user data."])))
                return
            }
            
            completion(.success(userInfo))
        }
    }
    public func fetchUserInfo(userId: String) async throws -> UserInfo {
        let db = Firestore.firestore()

        do {
            // Fetch the document snapshot asynchronously
            let snapshot = try await db.collection("users").document(userId).getDocument()

            // Validate and parse the snapshot into a UserInfo object
            guard snapshot.exists, let userInfo = UserInfo(document: snapshot) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid or missing user data."])
            }

            return userInfo
        } catch {
            // Propagate the error to the caller
            throw error
        }
    }



    public func fetchAllUsers(completion: @escaping (Result<[UserInfo], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").getDocuments(source: .default) { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }

            // Use the UserInfo initializer with DocumentSnapshot
            let users = documents.compactMap { UserInfo(document: $0) }
            completion(.success(users))
        }
    }
    
    public func fetchAllUsers() async throws -> [UserInfo] {
        let db = Firestore.firestore()

        do {
            // Fetch the snapshot asynchronously
            let snapshot = try await db.collection("users").getDocuments(source: .default)

            // Use the UserInfo initializer to parse documents
            let users = snapshot.documents.compactMap { UserInfo(document: $0) }
            return users
        } catch {
            // Propagate the error to the caller
            throw error
        }
    }
    
    private func getTodayDateString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: Date())
    }
    
    public func appAccessedToday(userID: String) {
        let db = Firestore.firestore().collection("users").document(userID)
        let todayString = getTodayDateString()
        db.updateData(["accessDates" : FieldValue.arrayUnion([todayString])])
    }
    
    public func createUser(email: String, firstName: String, lastName: String, uid: String, companyName: String?) {
        let todayString = getTodayDateString()
        var userData: [String: Any] = [
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "uid": uid,
            "signUpDate": todayString,
            "accessDates": [todayString]
        ]
        
        if let companyName = companyName, !companyName.isEmpty {
            userData["companyName"] = companyName
            print(#function, "Adding company Name: \(companyName)")
        } else {
            print(#function, "Failed company Name: \(companyName)")
        }
        
        Firestore.firestore().collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Failed to save user data: \(error)")
            }
        }
        
    }
    
    public func deleteUserAccount(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])))
            return
        }

        // Delete Firestore user document
        db.collection("users").document(userId).delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Delete Firebase Auth account
            user.delete { authError in
                if let authError = authError {
                    completion(.failure(authError))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    public func deleteUserAccount(userId: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
        }

        try await db.collection("users").document(userId).delete()
        try await user.delete()
    }
    
}
