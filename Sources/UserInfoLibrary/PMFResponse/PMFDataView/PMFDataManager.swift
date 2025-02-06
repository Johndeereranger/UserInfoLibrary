//
//  PMFDataManager.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/29/25.
//
import Foundation
import FirebaseFirestore

//public actor PMFDataManager {
//    public static let shared = PMFDataManager() // Thread-safe singleton
//
//    private let firestore = Firestore.firestore()
//    private let pmfResponsesKey = "pmfResponses"
//    private let usersCollection = "users"
//
//    private init() {} // Prevent direct initialization
//
//    public func fetchAllPMFData() async -> [PMFResponse] {
//        let usersCollectionRef = firestore.collection(usersCollection)
//
//        do {
//            let snapshot = try await usersCollectionRef.getDocuments()
//            print("Fetched \(snapshot.documents.count) user documents.")
//            var allResponses: [PMFResponse] = []
//
//            for document in snapshot.documents {
//                let userDocRef = usersCollectionRef.document(document.documentID)
//                let userSnapshot = try await userDocRef.getDocument()
//
//                if let data = userSnapshot.data(),
//                   let pmfResponses = data[pmfResponsesKey] as? [[String: Any]] {
//                    let responses = pmfResponses.compactMap { PMFResponse(from: $0) }
//                    allResponses.append(contentsOf: responses)
//                }
//            }
//            return allResponses
//        } catch {
//            print("Error fetching PMF data: \(error)")
//            return []
//        }
//    }
//}
//
//public actor PMFDataManagerOld {
//    public static let shared = PMFDataManager() // Thread-safe singleton
//
//    private let firestore = Firestore.firestore()
//    private let pmfResponsesKey = "pmfResponses"
//    private let usersCollection = "users"
//
//    private init() {} // Prevent direct initialization
//
//    public func fetchAllPMFData() async -> [PMFResponse] {
//        let usersCollectionRef = firestore.collection(usersCollection)
//
//        do {
//            print("Fetching PMF Data...") // Debug Log
//            let snapshot = try await usersCollectionRef.getDocuments()
//            print("Fetched \(snapshot.documents.count) user documents.") // Debug Log
//
//            var allResponses: [PMFResponse] = []
//
//            for document in snapshot.documents {
//                let userDocRef = usersCollectionRef.document(document.documentID)
//                let userSnapshot = try await userDocRef.getDocument()
//
//                if let data = userSnapshot.data(),
//                   let pmfResponses = data[pmfResponsesKey] as? [[String: Any]] {
//                    print("User \(document.documentID) has \(pmfResponses.count) PMF responses.") // Debug Log
//
//                    let responses = pmfResponses.compactMap { PMFResponse(from: $0) }
//                    allResponses.append(contentsOf: responses)
//                } else {
//                    print("No PMF responses for user \(document.documentID).") // Debug Log
//                }
//            }
//
//            print("Returning \(allResponses.count) PMF responses.") // Debug Log
//            return allResponses
//        } catch {
//            print("Error fetching PMF data: \(error)") // Debug Log
//            return []
//        }
//    }
//}


import Foundation
import FirebaseFirestore

public actor PMFDataManager {
    public static let shared = PMFDataManager() // Thread-safe singleton

    private let firestore = Firestore.firestore()
    private let pmfResponsesKey = "pmfResponses"
    private let usersCollection = "users"

    private init() {} // Prevent direct initialization

    public func fetchAllPMFData() async -> [PMFResponse] {
        let usersCollectionRef = firestore.collection(usersCollection)

        do {
            print("Fetching PMF Data...") // Debug Log
            
            // 🔥 Optimize: Query only users who have PMF responses
            let snapshot = try await usersCollectionRef
                .whereField(pmfResponsesKey, isGreaterThan: []) // Ensures we only fetch users with responses
                .getDocuments()

            print("Fetched \(snapshot.documents.count) user documents with PMF responses.") // Debug Log

            var allResponses: [PMFResponse] = []

            for document in snapshot.documents {
                
                 let data = document.data()
                if let pmfResponses = data[pmfResponsesKey] as? [[String: Any]] {
                    print("User \(document.documentID) has \(pmfResponses.count) PMF responses.") // Debug Log
                    
                    let responses = pmfResponses.compactMap { PMFResponse(from: $0) }
                    allResponses.append(contentsOf: responses)
                }
            }

            print("Returning \(allResponses.count) PMF responses.") // Debug Log
            return allResponses
        } catch {
            print("Error fetching PMF data: \(error)") // Debug Log
            return []
        }
    }
    
    public func deletePMFResponse(sessionID: String) async {
        let usersCollectionRef = firestore.collection(usersCollection)

        do {
            // 🔥 Step 1: Find the user document that contains this session ID
            let snapshot = try await usersCollectionRef.getDocuments(source: .server)
            
            var userIDToUpdate: String?
            var responsesToUpdate: [[String: Any]] = []

            print("🔍 Searching for sessionID: \(sessionID) across all users...")

            for document in snapshot.documents {
                let userID = document.documentID
                guard let responses = document.data()[pmfResponsesKey] as? [[String: Any]] else { continue }

                // Check if any response in this user doc matches the session ID
                if responses.contains(where: { ($0["sessionID"] as? String) == sessionID }) {
                    userIDToUpdate = userID
                    responsesToUpdate = responses
                    break
                }
            }

            guard let userID = userIDToUpdate else {
                print("❌ No matching session ID found across users.")
                return
            }

            print("✅ Found sessionID: \(sessionID) in user document: \(userID)")

            // 🔥 Step 2: Remove the session from the found user's PMF responses
            let userDocRef = usersCollectionRef.document(userID)
            let originalCount = responsesToUpdate.count

            responsesToUpdate.removeAll { ($0["sessionID"] as? String) == sessionID }

            print("📌 After deletion, remaining PMF responses: \(responsesToUpdate.count)")

            // 🛑 If nothing was removed, log an error
            if responsesToUpdate.count == originalCount {
                print("⚠️ No response was removed! Possible data inconsistency.")
                return
            }

            // 🔥 Step 3: Update Firestore with the modified responses
            try await userDocRef.setData([pmfResponsesKey: responsesToUpdate], merge: true)

            print("✅ Successfully deleted PMF response for session: \(sessionID) from user: \(userID)")

        } catch {
            print("❌ Error deleting PMF response: \(error.localizedDescription)")
        }
    }
}

