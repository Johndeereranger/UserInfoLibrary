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
    @Published var userID: String?
    @Published var isLoading = false
    @Published var shouldShowPMFResult: Bool?
    @Published var shouldShowPMFResultString: String?

    // Specific UserDefaults Values from PMFManager
    @Published var hasAnsweredPMF: Bool = false
    @Published var lastDeclinedAccessCount: Int = 0
    @Published var lastPMFShownTimestamp: Double = 0
    @Published var usageCountAtLastSurvey: Int = 0

    public init() {
        loadPMFUserDefaults()
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

    private func loadPMFUserDefaults() {
        let defaults = UserDefaults.standard
        self.hasAnsweredPMF = defaults.bool(forKey: "hasAnsweredPMF")
        self.lastDeclinedAccessCount = defaults.integer(forKey: "lastDeclinedAccessCount")
        self.lastPMFShownTimestamp = defaults.double(forKey: "lastPMFShownTimestamp")
        self.usageCountAtLastSurvey = defaults.integer(forKey: "usageCountAtLastSurvey")
    }
    
    func checkShouldShowPMF() {
           PMFManager.instance.shouldShowPMF { shouldShow, message in
            
               DispatchQueue.main.async {
                   self.shouldShowPMFResult = shouldShow
                   self.shouldShowPMFResultString = message
               }
           }
       }
}

