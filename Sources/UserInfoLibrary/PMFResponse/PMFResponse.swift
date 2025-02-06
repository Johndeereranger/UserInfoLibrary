//
//  File.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/29/25.
//

import Foundation
import Firebase

public struct PMFResponse: Codable, Sendable {
    public let sessionID: String
    public let userID: String
    public let feedback: String?
    public let mainBenefit: String?
    public let improvementSuggestions: String?
    public let usageCountAtSurvey: Int?
    public let answeredAt: Date
    public let accessDateCount: Int? // Field to store the accessDates count at the time of request

    public init(
        sessionID: String,
        userID: String,
        feedback: String? = nil,
        mainBenefit: String? = nil,
        improvementSuggestions: String? = nil,
        answeredAt: Date,
        accessDateCount: Int? = nil,
        usageCountAtSurvey: Int? = nil
    ) {
        self.sessionID = sessionID
        self.userID = userID
        self.feedback = feedback
        self.mainBenefit = mainBenefit
        self.improvementSuggestions = improvementSuggestions
        self.answeredAt = answeredAt
        self.accessDateCount = accessDateCount
        self.usageCountAtSurvey = usageCountAtSurvey
    }

    public init?(from dictionary: [String: Any]) {
        guard let sessionID = dictionary["sessionID"] as? String else { return nil }

        // Handle both Firestore's Timestamp & standard Date storage
        if let timestamp = dictionary["answeredAt"] as? Double {
            self.answeredAt = Date(timeIntervalSince1970: timestamp)
        } else if let firestoreTimestamp = dictionary["answeredAt"] as? Timestamp {
            self.answeredAt = firestoreTimestamp.dateValue()
        } else {
            return nil // Invalid date format
        }

        self.sessionID = sessionID
        self.userID = dictionary["userID"] as? String ?? "NO ID" // ✅ Fallback if missing
        self.feedback = dictionary["feedback"] as? String
        self.mainBenefit = dictionary["mainBenefit"] as? String
        self.improvementSuggestions = dictionary["improvementSuggestions"] as? String
        self.accessDateCount = dictionary["accessDateCount"] as? Int
        self.usageCountAtSurvey = dictionary["usageCountAtSurvey"] as? Int
    }

    public func dictionaryRepresentation() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["sessionID"] = sessionID
        dict["userID"] = userID
        dict["feedback"] = feedback
        dict["mainBenefit"] = mainBenefit
        dict["improvementSuggestions"] = improvementSuggestions

        // Store date as UNIX timestamp to avoid Firestore dependency
        dict["answeredAt"] = answeredAt.timeIntervalSince1970

        dict["accessDateCount"] = accessDateCount
        dict["usageCountAtSurvey"] = usageCountAtSurvey

        return dict
    }
}
