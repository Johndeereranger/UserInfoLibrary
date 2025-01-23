//
//  File.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/23/25.
//

import Foundation
import FirebaseFirestore

public enum MetadataValue: Sendable, Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([String])
}

public struct UserInfo: Sendable {
    // Core required fields
    public let id: String
    public let documentID: String
    

    // General optional fields
    public let email: String?
    public var name: String?
    public var firstName: String?
    public var lastName: String?
    public var phoneNumber: String?
    public var signUpDate: String?
    public var accessDates: [String]?
    public var groups: [String]?
    public var fcmToken: String?
    public var receiptData: String?
    public var profilePictureURL: String?
    public var lastLoginDate: String?
    public var isActive: Bool?

    // Metadata fields
    public var metadata: [String: MetadataValue]?

    // Initializer for core fields
//    public init(id: String, documentID: String) {
//        self.id = id
//        self.documentID = documentID
//
//        
//    }

    // Full initializer for all fields
    public init(
        id: String,
        documentID: String,
        email: String,
        name: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        signUpDate: String? = nil,
        accessDates: [String]? = nil,
        groups: [String]? = nil,
        fcmToken: String? = nil,
        receiptData: String? = nil,
        profilePictureURL: String? = nil,
        lastLoginDate: String? = nil,
        isActive: Bool? = nil,
        metadata: [String: MetadataValue]? = nil
    ) {
        self.id = id
        self.documentID = documentID
        self.email = email
        self.name = name
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.signUpDate = signUpDate
        self.accessDates = accessDates
        self.groups = groups
        self.fcmToken = fcmToken
        self.receiptData = receiptData
        self.profilePictureURL = profilePictureURL
        self.lastLoginDate = lastLoginDate
        self.isActive = isActive
        self.metadata = metadata
    }
    
    
    // Initializer from Firestore DocumentSnapshot
    public init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }

       
        
        guard let extractedDocumentID = extractDocumentID(from: document) else {
                  print("Failed to extract documentID")
                  return nil
              }

              self.documentID = extractedDocumentID

        // Parse known fields
        self.id = extractedDocumentID
        
        self.email = data["email"] as? String
        self.name = data["name"] as? String
        self.firstName = data["firstName"] as? String
        self.lastName = data["lastName"] as? String
        self.phoneNumber = data["phoneNumber"] as? String
        self.signUpDate = data["signUpDate"] as? String
        self.accessDates = data["accessDates"] as? [String]
        self.groups = data["groups"] as? [String]
        self.fcmToken = data["fcmToken"] as? String
        self.receiptData = data["receiptData"] as? String
        self.profilePictureURL = data["profilePictureURL"] as? String
        self.lastLoginDate = data["lastLoginDate"] as? String
        self.isActive = data["isActive"] as? Bool

        // Parse metadata
        var metadata: [String: MetadataValue] = [:]
        for (key, value) in data {
            if !["uid", "email", "name", "firstName", "lastName", "phoneNumber", "signUpDate", "accessDates", "groups", "fcmToken", "receiptData", "profilePictureURL", "lastLoginDate", "isActive"].contains(key) {
                if let stringValue = value as? String {
                    metadata[key] = .string(stringValue)
                } else if let intValue = value as? Int {
                    metadata[key] = .int(intValue)
                } else if let doubleValue = value as? Double {
                    metadata[key] = .double(doubleValue)
                } else if let boolValue = value as? Bool {
                    metadata[key] = .bool(boolValue)
                } else if let arrayValue = value as? [String] {
                    metadata[key] = .array(arrayValue)
                } else {
                    print("Unexpected metadata field: \(key) with value: \(value)")
                }
            }
        }
        self.metadata = metadata.isEmpty ? nil : metadata
    }
}

public func extractDocumentID(from document: DocumentSnapshot) -> String? {
    // Attempt to fetch document ID from fields in the document's data
    if let data = document.data() {
        if let docID = data["docID"] as? String {
            return docID
        }
        if let documentID = data["documentID"] as? String {
            return documentID
        }
    }
    
    // Fallback to Firestore's document.documentID
    return document.documentID
}

