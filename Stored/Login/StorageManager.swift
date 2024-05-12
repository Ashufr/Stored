//
//  StorageManager.swift
//  Stored
//
//  Created by student on 10/05/24.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import UIKit

class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    static func safeEmail(email : String) -> String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    public typealias UploadPictureCompletion = (Result<String, Error>)
    
    public func uploadProfilePicture(with data : Data, fileName : String, completion : @escaping (UploadPictureCompletion) -> Void){
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                print("Failed to upload Image")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Image Url not found")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("Url String return : \(urlString)")
                completion(.success(urlString))
            })
            
            
        })
    }
    
    func uploadItemImage(with image: UIImage, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.pngData() else {
            print("Failed to convert UIImage to Data")
            completion(.failure(StorageErrors.invalidImageData))
            return
        }
        
        let storageRef = Storage.storage().reference().child("items/\(fileName)")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload item image: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to retrieve download URL for item image: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url?.absoluteString else {
                    print("Download URL not found for item image")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                print("Item image uploaded successfully. Download URL: \(downloadURL)")
                completion(.success(downloadURL))
            }
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
        case invalidImageData
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        })
    }
    
    func getImageFromURL(_ url: String, completion: @escaping (UIImage?) -> Void) {
        // Create a reference to the Firebase Storage URL
        let storageRef = Storage.storage().reference(forURL: url)

        // Download the data from Firebase Storage
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image from Firebase Storage: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Check if data exists and create UIImage
            if let imageData = data, let image = UIImage(data: imageData) {
                completion(image)
            } else {
                print("Failed to create UIImage from downloaded data")
                completion(nil)
            }
        }
    }
}

