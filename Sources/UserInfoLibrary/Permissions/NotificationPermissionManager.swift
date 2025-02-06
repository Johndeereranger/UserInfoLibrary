//
//  NotificationPermissionManager.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 2/6/25.
//

import UserNotifications
import UIKit

@MainActor
public class NotificationPermissionManager {
    public static let shared = NotificationPermissionManager()

    private init() {}

    /// Requests push notification permissions from the user.
    public func requestPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Permission granted: \(granted)")
            guard granted else { return }
            
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    UserUpdateManager.shared.setIsPushNoticationEnabled(isEnabled: true)
                }
            }
        }
    }
}

