//
//  File.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/20/25.
//

import Foundation
import FirebaseStorage
import UIKit

public class FirebaseImageManager: @unchecked Sendable  {
    
    public static let shared = FirebaseImageManager()
    private let storage = Storage.storage().reference()
    
    private init() {} // Private initializer to enforce singleton
    /// Stores an image in Firebase Storage.
    /// - Parameters:
    ///   - image: The `UIImage` to be stored.
    ///   - path: The path within Firebase Storage where the image will be stored.
    /// - Returns: The download URL as a string.
//    public func storeImage(_ image: UIImage, atPath path: String) async throws -> String {
//        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
//            throw StorageError.failedToConvertImage
//        }
//        
//        let imageRef = storage.child(path)
//        
//        // Upload data to Firebase Storage
//        _ = try await imageRef.putDataAsync(imageData, metadata: nil)
//        
//        // Get the download URL
//        let url = try await imageRef.downloadURL()
//        return url.absoluteString
//    }
    public func storeImage(_ image: UIImage, atPath path: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            throw StorageError.failedToConvertImage
        }

        let imageRef = storage.child(path)

        return try await withCheckedThrowingContinuation { continuation in
            imageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                // Retrieve the download URL after the upload succeeds
                imageRef.downloadURL { url, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let url = url {
                        continuation.resume(returning: url.absoluteString)
                    } else {
                        continuation.resume(throwing: StorageError.unknown)
                    }
                }
            }
        }
    }

    
    /// Retrieves an image from Firebase Storage.
    /// - Parameters:
    ///   - path: The path within Firebase Storage where the image is stored.
    /// - Returns: A `UIImage` object.
    public func getImage(atPath path: String) async throws -> UIImage {
        let imageRef = storage.child(path)
        let maxDownloadSize: Int64 = 5 * 1024 * 1024
        
        let data = try await imageRef.getData(maxSize: maxDownloadSize)
        guard let image = UIImage(data: data) else {
            throw StorageError.failedToConvertDataToImage
        }
        return image
    }
    
    public func storeImage(_ image: UIImage, atPath path: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(.failure(StorageError.failedToConvertImage))
            return
        }
        
        let imageRef = storage.child(path)
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                completion(.failure(error ?? StorageError.unknown))
                return
            }
            
            imageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(.failure(error ?? StorageError.unknown))
                    return
                }
                completion(.success(downloadURL.absoluteString))
            }
        }
    }
    
    public func getImage(atPath path: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let imageRef = storage.child(path)
        let maxDownloadSize: Int64 = 5 * 1024 * 1024
        
        imageRef.getData(maxSize: maxDownloadSize) { data, error in
            guard let imageData = data, error == nil else {
                completion(.failure(error ?? StorageError.downloadError))
                return
            }
            
            if let image = UIImage(data: imageData) {
                completion(.success(image))
            } else {
                completion(.failure(StorageError.failedToConvertDataToImage))
            }
        }
    }
    
}

public enum StorageError: Error {
    case failedToConvertImage
    case failedToConvertDataToImage
    case downloadError
    case unknown
}


extension StorageReference {
    /// Async wrapper for `putData`.
//    func putDataAsync(_ data: Data, metadata: StorageMetadata?) async throws -> StorageMetadata {
//        try await withCheckedThrowingContinuation { continuation in
//            putData(data, metadata: metadata) { metadata, error in
//                if let error = error {
//                    continuation.resume(throwing: error)
//                } else if let metadata = metadata {
//                    continuation.resume(returning: metadata)
//                } else {
//                    continuation.resume(throwing: StorageError.unknown)
//                }
//            }
//        }
//    }
  
        /// Async wrapper for `putData`.
    func putDataAsync(_ data: Data, metadata: StorageMetadata?) async throws -> StorageMetadata {
        try await withCheckedThrowingContinuation { continuation in
            putData(data, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let metadata = metadata {
                    // Create a new instance by extracting only the necessary data
                    let safeMetadata = StorageMetadata()
                    safeMetadata.contentType = metadata.contentType
                    safeMetadata.cacheControl = metadata.cacheControl
                    safeMetadata.customMetadata = metadata.customMetadata
                    
                    
                    continuation.resume(returning: safeMetadata)
                } else {
                    continuation.resume(throwing: StorageError.unknown)
                }
            }
        }
    }
    

    
    /// Async wrapper for `getData`.
    func getData(maxSize: Int64) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            getData(maxSize: maxSize) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: StorageError.unknown)
                }
            }
        }
    }
    
    /// Async wrapper for `downloadURL`.
    func downloadURL() async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: StorageError.unknown)
                }
            }
        }
    }
}
