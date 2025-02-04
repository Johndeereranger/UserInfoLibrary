//
//  UserUpdateManager.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 2/3/25.
//

import Foundation
import FirebaseFirestore


public final class UserUpdateManager: @unchecked Sendable {
    public static let shared = UserUpdateManager()
    
    private let db = Firestore.firestore()
    
    private init() {}

    
    //MARK: - General Updates
    private func getTodayDateString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: Date())
    }

    public func storeUserIDFA(idfa: String, userId: String) {
        db.collection("users").document(userId)
            .setData(["idfa": idfa], merge: true)
    }
    
    public func returningUser(userId: String) {
        let todayString = getTodayDateString()
        db.collection("users").document(userId)
            .updateData(["accessDates": FieldValue.arrayUnion([todayString])])
    }
    
    //MARK: - South Magnolia
    
    @MainActor public func updateCompanyName(companyName: String) {
        guard let userId = AuthHelper.currentUserID else { return }
        db.collection("users").document(userId).updateData(["companyName": companyName])
    }
    
    @MainActor public func updateFCMToken(_ fcmToken: String) {
        guard let userId = AuthHelper.currentUserID else { return }
        let userDoc = db.collection("users").document(userId)
        userDoc.updateData(["fcmToken": fcmToken]) { error in
               if let error = error {
                   print(#function,"Error updating token: \(error.localizedDescription)")
               }
           }
    }

    
    
    //MARK: - NC Waterfalls updates
    public func purchasedWaterfaller(userId: String) {
        let todayString = getTodayDateString()
        let docRef = db.collection("users").document(userId)
        docRef.setData(["purchased": true, "purchasedDate": todayString], merge: true)
    }

    public func approvedRisk(userId: String) {
        let todayString = getTodayDateString()
        db.collection("users").document(userId)
            .updateData(["approvedRisk": FieldValue.arrayUnion([todayString])])
    }
    
    public func declinedRisk(userId: String) {
        let todayString = getTodayDateString()
        db.collection("users").document(userId)
            .updateData(["declinedRisk": FieldValue.arrayUnion([todayString])])
    }
    
    public func waterfallVisited(userId: String, fallDocID: String, status: Bool) {
        let docRef = db.collection("users").document(userId)
        if status {
            docRef.updateData(["WaterfallsVisited": FieldValue.arrayUnion([fallDocID])])
        } else {
            docRef.updateData(["WaterfallsVisited": FieldValue.arrayRemove([fallDocID])])
        }
    }
    
}
