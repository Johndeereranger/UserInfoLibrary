//
//  ImageStoreManager.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 5/20/25.
//


import Foundation
import UIKit

public class ImageStoreManager: @unchecked Sendable {
    
    public static let shared = ImageStoreManager()
    
    private init() {}
    
    /// Retrieves an image, prioritizing local cache before fetching from Firebase.
    /// - Parameters:
    ///   - name: The local filename (typically the docID).
    ///   - remotePath: Firebase storage path (typically imageURL).
    /// - Returns: The resolved `UIImage`.
    public func retrieveImage(name: String, remotePath: String) async throws -> UIImage {
        // 1. Try to load locally
        if let localImage = try? await LocalImageManager.shared.loadImageFromLocal(withName: name) {
            return localImage
        }
        
        // 2. If not local, fetch from Firebase and cache it
        let firebaseImage = try await FirebaseImageManager.shared.getImage(atPath: remotePath)
        
        // Save locally
        do {
            try await LocalImageManager.shared.saveImageLocally(firebaseImage, withName: name)
        } catch {
            print("Warning: Failed to cache image \(name) locally – \(error.localizedDescription)")
        }
        
        return firebaseImage
    }
    
    /// Stores an image to both Firebase and local storage.
    /// - Parameters:
    ///   - image: The `UIImage` to save.
    ///   - name: Local filename.
    ///   - remotePath: Path in Firebase Storage.
    /// - Returns: Firebase download URL.
    public func storeImage(_ image: UIImage, name: String, remotePath: String) async throws -> String {
        // Save to local
        _ = try await LocalImageManager.shared.saveImageLocally(image, withName: name)
        
        // Save to Firebase
        return try await FirebaseImageManager.shared.storeImage(image, atPath: remotePath)
    }
    
    public func deleteImage(name: String, remoteURL: String) async throws {
        // Try local delete first
        do {
            _ = try await LocalImageManager.shared.deleteImageLocally(withName: name)
        } catch {
            print("⚠️ Failed to delete local image \(name): \(error.localizedDescription)")
        }

        // Delete from Firebase using download URL
        try await FirebaseImageManager.shared.deleteImage(from: remoteURL)
    }
}
