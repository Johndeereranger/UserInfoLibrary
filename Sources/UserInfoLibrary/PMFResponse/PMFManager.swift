//
//  PMFManager.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/29/25.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import StoreKit

@MainActor
public class PMFManager {
    public static let instance = PMFManager()
    private let navigator: PMFSurveyNavigator
    private(set) var totalUsageCount: Int?
    private var surveyNavigationController: UINavigationController?
    private let sessionID = UUID().uuidString
    private var storedFeedback: String?
    private let hasAnsweredPMFKey = "hasAnsweredPMF"
    private let lastDeclinedAccessCountKey = "lastDeclinedAccessCount"
    private let lastPMFShownTimestamp = "lastPMFShownTimestamp"
    private let usageCountAtLastSurvey = "usageCountAtLastSurvey"
    private var pmfSessionTimestamp: Date?
    private var currentPMFDocumentID: String?

    private init() {
          self.navigator = PMFSurveyNavigator()
      }

    public func resetPMFDataForTesting() {
        UserDefaults.standard.removeObject(forKey: hasAnsweredPMFKey)
        UserDefaults.standard.removeObject(forKey: lastDeclinedAccessCountKey)
        UserDefaults.standard.synchronize()
    }

    public func presentSurvey(topImageName: String, from viewController: UIViewController, withDelay delay: TimeInterval = 3.0) {
        print(#function, "Show PMF")
        pmfSessionTimestamp = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let initialView = ProductMarketFitView(imageName: topImageName, onYesTapped: {
                self.navigator.presentMultipleChoiceQuestion(onNext: { selectedFeedback in
                    self.storedFeedback = selectedFeedback
                    self.navigator.presentFillInTheBlankQuestions(onSubmit: {
                        self.checkForRatingPrompt()
                        self.navigator.dismissSurvey()
                    })
                })
            }, onNoTapped: {
                PMFManager.instance.declinePMF()
                viewController.dismiss(animated: true, completion: nil)
            })
            self.navigator.startSurvey(from: viewController, initialView: initialView)
        }
    }
    
    private var isTestFlightOrAppStore: Bool {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else { return false }

        let path = appStoreReceiptURL.path
        return path.contains("sandboxReceipt") == false // `sandboxReceipt` is present for TestFlight
    }
    
    public func shouldShowPMF(force: Bool = false, shouldPrint: Bool = false, completion: @escaping (Bool,String) -> Void) {
        var showPMF: Bool = force
        
        if isTestFlightOrAppStore{
            showPMF = false
        }
        
        if showPMF {
            print("Force Show PMF")
            completion(true,"Force Show PMF")
        }
        guard let uid = PMFConfigurationProvider.userID else {
            print("PMF Manager - User ID not found")
            completion(false, "PMF Manager - User ID not found")
            return
        }

        let lastPMFShownTimestamp = UserDefaults.standard.double(forKey: lastPMFShownTimestamp)
        let usageCountAtLastSurvey = UserDefaults.standard.integer(forKey: usageCountAtLastSurvey)
        let hasAnsweredPMF = UserDefaults.standard.bool(forKey: hasAnsweredPMFKey)
        let lastDeclinedAccessCount = UserDefaults.standard.integer(forKey: lastDeclinedAccessCountKey)
        let ninetyDaysInSeconds: Double = 90 * 24 * 60 * 60

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("PMF Manager - Error retrieving user data: \(error.localizedDescription)")
                completion(false,"PMF Manager - Error retrieving user data: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data(),
                  let accessDates = data["accessDates"] as? [String] else {
                print("PMF Manager - Invalid access dates format or missing data")
                completion(false, "PMF Manager - Invalid access dates format or missing data")
                return
            }
            if shouldPrint{
                print(data)
            }
            let totalUsageCount = accessDates.count
            self.totalUsageCount = totalUsageCount
            let additionalUsageSinceLastSurvey = totalUsageCount - usageCountAtLastSurvey

          

            if usageCountAtLastSurvey == 0 && totalUsageCount >= 4 {
                print("Eligible for the first PMF survey.")
                self.recordSurveyShown(currentUsage: totalUsageCount)
                completion(true,"Eligible for the first PMF survey.")
                return
            }

            let timeSinceLastSurvey = Date().timeIntervalSince1970 - lastPMFShownTimestamp
            if timeSinceLastSurvey < ninetyDaysInSeconds {
                print("No PMF Show: Not enough time since last survey.")
                completion(false, "No PMF Show: Not enough time since last survey.")
                return
            }

            if additionalUsageSinceLastSurvey < 10 {
                print("No PMF Show: Not enough additional usage since last survey.")
                completion(false, "No PMF Show: Not enough additional usage since last survey.")
                return
            }

            if lastDeclinedAccessCount > 0 {
                let accessSinceLastDecline = totalUsageCount - lastDeclinedAccessCount
                if accessSinceLastDecline < 3 {
                    print("No PMF Show: Not enough access dates since last PMF decline.")
                    completion(false,"No PMF Show: Not enough access dates since last PMF decline.")
                    return
                }
            }

            print("User is eligible to be shown the PMF survey.")
            self.recordSurveyShown(currentUsage: totalUsageCount)
            completion(true, "User is eligible to be shown the PMF survey.")
        }
    }

    public func recordSurveyShown(currentUsage: Int) {
        let now = Date().timeIntervalSince1970
        UserDefaults.standard.set(now, forKey: lastPMFShownTimestamp)
        UserDefaults.standard.set(currentUsage, forKey: usageCountAtLastSurvey)
        print("PMF survey recorded: Timestamp = \(now), Usage Count = \(currentUsage)")
    }

    public func declinePMF() {
        guard let uid = PMFConfigurationProvider.userID else {
            print("PMF Decline - User ID not found")
            return
        }

        let userDocRef = Firestore.firestore().collection("users").document(uid)
        userDocRef.getDocument { snapshot, error in
            if let error = error {
                print("Error retrieving user data: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data(),
                  let accessDates = data["accessDates"] as? [String] else {
                print("Error retrieving access dates or invalid data format")
                return
            }

            UserDefaults.standard.set(accessDates.count, forKey: self.lastDeclinedAccessCountKey)
        }
    }

    public func markPMFAsAnswered() {
        UserDefaults.standard.set(true, forKey: hasAnsweredPMFKey)
    }

    private func promptAppRating() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    public func storePMFResponse(feedback: String? = nil, mainBenefit: String? = nil, improvementSuggestions: String? = nil) {
      
        let totalUsageCount = self.totalUsageCount ?? 99999999999

        guard let uid = PMFConfigurationProvider.userID else {
            print("PMF Manager - storePMFResponse User ID not found.")
            return
        }
        
        


        let userDocRef = Firestore.firestore().collection("users").document(uid)
        let timestamp = Date()

        userDocRef.getDocument { document, error in
            if let error = error {
                print("Error fetching PMF responses: \(error.localizedDescription)")
                return
            }

            var existingResponses = document?.data()?["pmfResponses"] as? [[String: Any]] ?? []

            if let index = existingResponses.firstIndex(where: { $0["sessionID"] as? String == self.sessionID }) {
                var existingResponse = existingResponses[index]

                if let feedback = feedback { existingResponse["feedback"] = feedback }
                if let mainBenefit = mainBenefit { existingResponse["mainBenefit"] = mainBenefit }
                if let improvementSuggestions = improvementSuggestions { existingResponse["improvementSuggestions"] = improvementSuggestions }
                existingResponse["usageCountAtSurvey"] = totalUsageCount
                existingResponse["answeredAt"] = Timestamp(date: timestamp)

                existingResponses[index] = existingResponse
            } else {
                let newResponse: [String: Any] = [
                    "sessionID": self.sessionID,
                    "feedback": feedback ?? "",
                    "mainBenefit": mainBenefit ?? "",
                    "improvementSuggestions": improvementSuggestions ?? "",
                    "usageCountAtSurvey": totalUsageCount,
                    "answeredAt": Timestamp(date: timestamp)
                ]
                existingResponses.append(newResponse)
            }

            userDocRef.updateData(["pmfResponses": existingResponses]) { error in
                if let error = error {
                    print("Error storing PMF response: \(error.localizedDescription)")
                } else {
                    print("Successfully stored PMF response.")
                }
            }
        }
    }

    private func checkForRatingPrompt() {
        if let feedback = storedFeedback, feedback.lowercased() == "very disappointed" {
            self.promptAppRating()
        }
    }
}
