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

public class UserInfoManager: @unchecked Sendable {
    public static let shared = UserInfoManager()

    private init() {}

    public func getDummyUser() -> UserInfo {
        return UserInfo(id: "1", name: "John Doe", email: "john.doe@example.com")
    }
}
