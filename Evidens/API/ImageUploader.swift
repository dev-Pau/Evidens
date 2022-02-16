//
//  ImageUploader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import FirebaseStorage
import Foundation

struct ImageUploader {
    
    static func uploadImage(image: UIImage, uid: String, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        //let filename = NSUUID().uuidString
        let filename = uid
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("DEBUG: Failed to upload image \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                guard let imageUrl = url?.absoluteString else { return }
                completion(imageUrl)
            }
        }
    }
    
    public enum StorageErrors: Error {
           case failedToUpload
           case failedToGetDownloadUrl
       }
    
    static func downloadImageURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = Storage.storage().reference().child(path)

            reference.downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }

                completion(.success(url))
            })
        }
}
