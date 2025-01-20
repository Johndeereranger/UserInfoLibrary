//
//  Untitled.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/20/25.
//

import Foundation
import UIKit

public class LocalImageManager: @unchecked Sendable {
    
    public static let shared = LocalImageManager()
    
    private init() {} // Singleton instance

    /// Saves an image locally to the device.
    /// - Parameters:
    ///   - image: The `UIImage` to be saved.
    ///   - name: The filename for the image.
    /// - Returns: A `Result` indicating success or failure.
    public func saveImageLocally(_ image: UIImage, withName name: String) -> Result<Bool, Error> {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            return .failure(LocalStorageError.failedToConvertImage)
        }
        do {
            let filename = getDocumentsDirectory().appendingPathComponent(name)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            return .success(true)
        } catch {
            return .failure(error)
        }
    }

    /// Loads an image locally from the device.
    /// - Parameter name: The filename of the image.
    /// - Returns: A `Result` containing the `UIImage` on success or an error on failure.
    public func loadImageFromLocal(withName name: String) -> Result<UIImage, Error> {
        let fileURL = getDocumentsDirectory().appendingPathComponent(name)
        do {
            let imageData = try Data(contentsOf: fileURL)
            if let image = UIImage(data: imageData) {
                return .success(image)
            } else {
                return .failure(LocalStorageError.failedToConvertDataToImage)
            }
        } catch {
            return .failure(error)
        }
    }

    /// Deletes an image locally from the device.
    /// - Parameter name: The filename of the image.
    /// - Returns: A `Result` indicating success or failure.
    public func deleteImageLocally(withName name: String) -> Result<Bool, Error> {
        let fileURL = getDocumentsDirectory().appendingPathComponent(name)
        do {
            try FileManager.default.removeItem(at: fileURL)
            return .success(true)
        } catch {
            return .failure(error)
        }
    }
    
    public func saveImageLocally(_ image: UIImage, withName name: String) async throws -> Bool {
            guard let data = image.jpegData(compressionQuality: 1.0) else {
                throw LocalStorageError.failedToConvertImage
            }
            
            let filename = getDocumentsDirectory().appendingPathComponent(name)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            return true
        }

        /// Loads an image locally from the device.
        /// - Parameter name: The filename of the image.
        /// - Returns: A `UIImage` object or throws an error on failure.
        public func loadImageFromLocal(withName name: String) async throws -> UIImage {
            let fileURL = getDocumentsDirectory().appendingPathComponent(name)
            let imageData = try Data(contentsOf: fileURL)
            guard let image = UIImage(data: imageData) else {
                throw LocalStorageError.failedToConvertDataToImage
            }
            return image
        }

        /// Deletes an image locally from the device.
        /// - Parameter name: The filename of the image.
        /// - Returns: `true` on success or throws an error on failure.
        public func deleteImageLocally(withName name: String) async throws -> Bool {
            let fileURL = getDocumentsDirectory().appendingPathComponent(name)
            try FileManager.default.removeItem(at: fileURL)
            return true
        }
    
    /// Retrieves the documents directory path.
    /// - Returns: The URL of the documents directory.
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    /// Errors specific to local image storage operations.
    public enum LocalStorageError: Error {
        case failedToConvertImage
        case failedToConvertDataToImage
    }
}
