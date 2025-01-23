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

//    public func fetchUserInfo(userId: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
//        db.collection("users").document(userId).getDocument { snapshot, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = snapshot?.data(),
//                  let name = data["documentID"] as? String,
//                  let email = data["userIDCreateDate"] as? String else {
//                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])))
//                return
//            }
//
//            let userInfo = UserInfo(id: userId, name: name, email: email)
//            completion(.success(userInfo))
//        }
//    }

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
    
    
}
