//
//  File.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/20/25.
//

import Foundation
import FirebaseStorage
import UIKit

public class FirebaseImageManager {
    
    public static let shared = FirebaseImageManager()
    private let storage = Storage.storage().reference()
    
    private init() {} // Private initializer to enforce singleton
    
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

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    public enum LocalStorageError: Error {
        case failedToConvertImage
        case failedToConvertDataToImage
    }
}

public enum StorageError: Error {
    case failedToConvertImage
    case failedToConvertDataToImage
    case downloadError
    case unknown
}

