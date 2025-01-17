//
//  File.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/17/25.
//

//test
import Foundation

public struct UserInfo: Sendable {
    public let id: String
    public let name: String
    public let email: String

    public init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

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

    public func fetchUserInfo(userId: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data(),
                  let name = data["name"] as? String,
                  let email = data["email"] as? String else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])))
                return
            }

            let userInfo = UserInfo(id: userId, name: name, email: email)
            completion(.success(userInfo))
        }
    }
}
