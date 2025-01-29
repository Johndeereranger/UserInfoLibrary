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
            let snapshot = try await usersCollectionRef.getDocuments()
            print("Fetched \(snapshot.documents.count) user documents.") // Debug Log

            var allResponses: [PMFResponse] = []

            for document in snapshot.documents {
                let userDocRef = usersCollectionRef.document(document.documentID)
                let userSnapshot = try await userDocRef.getDocument()

                if let data = userSnapshot.data(),
                   let pmfResponses = data[pmfResponsesKey] as? [[String: Any]] {
                    print("User \(document.documentID) has \(pmfResponses.count) PMF responses.") // Debug Log

                    let responses = pmfResponses.compactMap { PMFResponse(from: $0) }
                    allResponses.append(contentsOf: responses)
                } else {
                    print("No PMF responses for user \(document.documentID).") // Debug Log
                }
            }

            print("Returning \(allResponses.count) PMF responses.") // Debug Log
            return allResponses
        } catch {
            print("Error fetching PMF data: \(error)") // Debug Log
            return []
        }
    }
}
