//
//  PMFStatusViewModel.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/30/25.
//

import Foundation

import FirebaseFirestore

@MainActor
public class PMFStatusViewModel: ObservableObject {
    @Published var pmfResponses: [PMFResponse] = []
    @Published var pmfErrorMessage: String?
    @Published var userDefaultsData: [String: Any] = [:]
    @Published var userID: String?
    @Published var isLoading = false

    public init() {
        loadUserDefaultsData()
    }

    func fetchPMFResponses() async {
        guard let userID = UserDefaults.standard.string(forKey: "userDocID") else {
            pmfErrorMessage = "🚨 No userDocID found in UserDefaults. Cannot fetch PMF responses."
            return
        }

        self.userID = userID
        isLoading = true
        let db = Firestore.firestore().collection("users").document(userID)

        do {
            let document = try await db.getDocument()
            guard let data = document.data(), let pmfArray = data["pmfResponses"] as? [[String: Any]] else {
                pmfErrorMessage = "⚠️ No PMF responses found in Firestore."
                isLoading = false
                return
            }
            self.pmfResponses = pmfArray.compactMap { PMFResponse(from: $0) }
        } catch {
            self.pmfErrorMessage = "❌ Firestore error: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func loadUserDefaultsData() {
        self.userDefaultsData = UserDefaults.standard.dictionaryRepresentation()
    }
}
