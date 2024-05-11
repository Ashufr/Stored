//
//  StorageManager.swift
//  Stored
//
//  Created by student on 10/05/24.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

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
    
    public enum StorageErrors: Error {
            case failedToUpload
            case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
            let reference = storage.child(path)
            reference.downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    print(error)
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }

                completion(.success(url))
            })
        }
}

