//
//  ImageUploader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import FirebaseStorage
import UIKit

/// Allows to get get, fetch and upload files to firebase storage
struct StorageManager {
    
    /// Uploads a profile image for a specific user to firebase storage with url string to download
    static func uploadProfileImage(image: UIImage, uid: String, completion: @escaping(String) -> Void) {
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
    
    /// Uploads a profile image for a specific user to firebase storage with url string to download
    static func uploadPostImage(images: [UIImage], uid: String, completion: @escaping([String]) -> Void) {
        
        //var imageData: [Data] = []
        var postImagesUrl: [String] = []
        var index = 0
        
        images.forEach { image in
            
            guard let imageData = image.jpegData(compressionQuality: 0.1) else { return } //0.75
            
            
            let filename = "\(uid) \(NSUUID().uuidString)"
            let ref = Storage.storage().reference(withPath: "/post_images/\(filename)")
            
            
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("DEBUG: Failed to upload post image \(error.localizedDescription)")
                    return
                }
                
                ref.downloadURL { url, error in
                    index += 1
                    guard let imageUrl = url?.absoluteString else { return }
                    postImagesUrl.append(imageUrl)
                    if images.count == index {
                        completion(postImagesUrl)
                    }
                }
            }
        }
    }
    
    
    /// Uploads a PDF file to storage with url string to download
    static func uploadPostFile(fileName: String, url: URL, completion: @escaping(Result<URL, Error>) -> Void) {
        let ref = Storage.storage().reference().child("/post_files/\(fileName)")
        
        ref.putFile(from: url, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                print(error?.localizedDescription)
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            let size = metadata.size
            let name = metadata.name
            
            
            print("Size of file is: \(size) and name is \(name)")
            
            ref.downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                completion(.success(url))
            }
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    /// Downloads image url for a specific path
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
    
    ///Upload image that will be sent in a conversation message
    static func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = Storage.storage().reference(withPath: "/message_images/\(fileName)")
        ref.putData(data, metadata: nil) { result, error in
            if let error = error {
                print("Failed to upload message image \(error.localizedDescription)")
                return
            }
            ref.downloadURL { url, error in
                guard let url = url else { return }
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }
    
    ///Upload video that will be sent in a conversation message
    static func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = Storage.storage().reference(withPath: "/message_videos/\(fileName)")
        ref.putFile(from: fileUrl, metadata: nil) { result, error in
            if let error = error {
                print("Failed to upload message video file \(error.localizedDescription)")
                return
            }
            ref.downloadURL { url, error in
                guard let url = url else { return }
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }
    
    ///Upload audio that will be sent in a conversation message
    static func uploadMessageAudio(fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let fileName = fileName + ".m4a"
        let ref = Storage.storage().reference(withPath: "/message_audios/\(fileName)")
        
        if fileExistsAtPath(path: fileName) {
            
            if let audioData = NSData(contentsOfFile: fileInDocumentsDirectory(fileName: fileName)) {
                ref.putData(audioData as Data, metadata: nil) { result, error in
                    if let error = error {
                        print("Failed to upload message audio file \(error.localizedDescription)")
                        return
                    }
                    ref.downloadURL { url, error in
                        guard let url = url else { return }
                        let urlString = url.absoluteString
                        completion(.success(urlString))
                    }
                }
            }
        }
    }
    
    
}

func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentsURL().appendingPathComponent(fileName).path
}

func getDocumentsURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistsAtPath(path: String) -> Bool {
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}
