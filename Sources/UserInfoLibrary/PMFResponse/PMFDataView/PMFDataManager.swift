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
    
    public func deletePMFResponse(userID: String, sessionID: String) async {
        let userDocRef = firestore.collection(usersCollection).document(userID)

        do {
            // 🔥 Force Firestore to fetch fresh data
            let document = try await userDocRef.getDocument(source: .server)

            // 🔍 Validate if pmfResponses exists
            guard var responses = document.data()?[pmfResponsesKey] as? [[String: Any]] else {
                print("❌ No PMF responses found for user: \(userID)")
                return
            }

            print("📋 Existing PMF responses before deletion: \(responses.count)")

            // 🔍 Print all session IDs before filtering
            for response in responses {
                print("✅ Found Session ID: \(response["sessionID"] ?? "Unknown")")
            }

            // 🔥 Ensure correct session ID removal
            let originalCount = responses.count
            responses.removeAll { response in
                let existingSessionID = response["sessionID"] as? String
                let shouldRemove = existingSessionID == sessionID
                print("🔍 Checking: \(existingSessionID ?? "nil") against \(sessionID) -> \(shouldRemove)")
                return shouldRemove
            }

            print("📌 Remaining PMF responses after deletion: \(responses.count)")

            // 🛑 Validate if deletion actually removed an item
            if responses.count == originalCount {
                print("⚠️ No response was removed! Session ID might not be matching.")
                return
            }

            // 🔥 Use setData() with merge to ensure update is applied
            try await userDocRef.setData([pmfResponsesKey: responses], merge: true)

            print("✅ Successfully deleted PMF response for session: \(sessionID)")

        } catch {
            print("❌ Error deleting PMF response: \(error.localizedDescription)")
        }
    }
}

