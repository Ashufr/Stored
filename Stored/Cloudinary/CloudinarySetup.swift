//
//  CloudinarySetup.swift
//  Stored
//
//  Created by student on 08/05/24.
//

import Cloudinary
import Foundation
import UIKit

class CloudinarySetup {
    static let shared = CloudinarySetup() // Singleton instance
    
    static func getInstnce () -> CloudinarySetup {
        shared
    }
    
    private init() {
    }
    
    func uploadImageToCloudinary(image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil, NSError(domain: "ImageDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"]))
            return
        }
        
        let config = CLDConfiguration(cloudName: "davovyhul", apiKey: "946545891113388", apiSecret: "qfxaxq5_gZLU14StiSThKE3DTVM")
        let cloudinary = CLDCloudinary(configuration: config)
        let params = CLDUploadRequestParams()
        
        cloudinary.createUploader().signedUpload(data: imageData, params: params, progress: nil) { result, error in
            if let error = error {
                completion(nil, error)
            } else if let result = result, let secureURL = result.secureUrl {
                completion(secureURL, nil)
            } else {
                completion(nil, NSError(domain: "UploadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image"]))
            }
        }
    }



}
