//
//  ImageUploader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import FirebaseStorage
import UIKit

/// A storage manager used to interface with FirebaseStorage.
struct StorageManager { }

//MARK: - User Operations

extension StorageManager {
    
    /// Uploads an image to the storage and returns the URL of the uploaded image.
    ///
    /// - Parameters:
    ///   - image: The image to be uploaded.
    ///   - uid: The user's unique identifier.
    ///   - kind: The kind of image (profile or banner).
    ///   - completion: A closure to be called when the upload is completed or encounters an error.
    ///                 This closure receives a `Result` type, either containing the image URL on success
    ///                 or a `StorageError` on failure.
    static func addImage(image: UIImage, uid: String, kind: ImageKind, completion: @escaping(Result<String, StorageError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let filename = uid
        var path = String()
        
        switch kind {
        case .profile:
            path = "users/\(uid)/images/profile/\(filename)"
        case .banner:
            path = "users/\(uid)/images/banner/\(filename)"
        }
        
        let ref = Storage.storage().reference(withPath: path)
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                ref.downloadURL { url, error in
                    if let _ = error {
                        completion(.failure(.unknown))
                    } else {
                        if let imageUrl = url?.absoluteString {
                            completion(.success(imageUrl))
                        } else {
                            completion(.failure(.unknown))
                        }
                    }
                }
            }
        }
    }
    
    /// Uploads document images (e.g., identification documents) to the storage for a user's verification process.
    ///
    /// - Parameters:
    ///   - viewModel: The view model containing document images and user information.
    ///   - completion: A closure to be called when the upload is completed or encounters an error.
    ///                 This closure receives a `StorageError` on failure and is called on the main queue.
    static func addDocImages(viewModel: VerificationViewModel, completion: @escaping(StorageError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        guard let docImage = viewModel.docImage?.jpegData(compressionQuality: 0.5), let idImage = viewModel.idImage?.jpegData(compressionQuality: 0.5), let uid = viewModel.uid else {
            completion(.unknown)
            return
        }
        
        let images = [docImage, idImage]
        let fileNames = ["doc", "id"]
        let path = "users/\(uid)/id/"
        let paths = ["\(path)\(fileNames[0])", "\(path)\(fileNames[1])"]
        
        let group = DispatchGroup()
        
        images.enumerated().forEach { index, image in
            let ref = Storage.storage().reference(withPath: paths[index])
            group.enter()
            ref.putData(image, metadata: nil) { metadata, error in
                if let _ = error {
                    completion(.unknown)
                } else {
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(nil)
            }
        }
    }
}


//MARK: - Posts Operations

extension StorageManager {
    
    /// Uploads an array of images to the storage for a specific post and returns their download URLs.
    ///
    /// - Parameters:
    ///   - id: The ID of the post associated with the images.
    ///   - images: An array of images to be uploaded.
    ///   - completion: A closure to be called when the upload is completed or encounters an error.
    ///                 This closure receives a `Result<[String], StorageError>` indicating success or failure and is called on the main queue.
    static func addImages(toPostId id: String, _ images: [UIImage], completion: @escaping(Result<[String], StorageError>) -> Void) {

        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        var imagesUrl: [(index: Int, url: String)] = []
        let group = DispatchGroup()
        
        images.enumerated().forEach { index, image in
            guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                completion(.failure(.unknown))
                return
            }
            
            group.enter()
            
            let filename = UUID().uuidString
            let ref = Storage.storage().reference(withPath: "/posts/\(id)/images/\(filename)")
            
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    ref.downloadURL { url, error in
                        if let _ = error {
                            completion(.failure(.unknown))
                        } else {
                            guard let imageUrl = url?.absoluteString else {
                                completion(.failure(.unknown))
                                return
                            }
                            
                            imagesUrl.append((index: index, url: imageUrl))
                            group.leave()
                        }
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            let sortedUrls = imagesUrl.sorted { $0.index < $1.index }
            let urls = sortedUrls.map { $0.url }
            completion(.success(urls))
        }
    }
}

//MARK: - Case Operations

extension StorageManager {
    
    /// Uploads an array of case images to the storage service.
    ///
    /// - Parameters:
    ///   - images: An array of UIImage objects representing the images to be uploaded.
    ///   - uid: The user ID associated with the case images.
    ///   - completion: A closure to be called upon completion of the upload process. It takes a single parameter:
    ///                 - imageUrls: An array of strings representing the download URLs of the uploaded images.
    ///                               The order of the URLs corresponds to the order of the input images.
    static func addImages(toCaseId id: String, _ images: [UIImage], completion: @escaping(Result<[String], StorageError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        var imagesUrl: [(index: Int, url: String)] = []
        let group = DispatchGroup()
        images.enumerated().forEach { index, image in
            guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                completion(.failure(.unknown))
                return
            }
            
            group.enter()
            
            let filename = UUID().uuidString
            let ref = Storage.storage().reference(withPath: "/cases/\(id)/images/\(filename)")
            
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    ref.downloadURL { url, error in
                        if let _ = error {
                            completion(.failure(.unknown))
                        } else {
                            guard let imageUrl = url?.absoluteString else {
                                completion(.failure(.unknown))
                                return
                            }
                            
                            imagesUrl.append((index: index, url: imageUrl))
                            group.leave()
                        }
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            let sortedUrls = imagesUrl.sorted { $0.index < $1.index }
            let urls = sortedUrls.map { $0.url }
            completion(.success(urls))
        }
    }
}
    
//MARK: - Profile Operations

extension StorageManager {
    
    /// Uploads an array of images to the user's storage in Firebase and retrieves their download URLs.
    ///
    /// - Parameters:
    ///   - images: An array of `UIImage` objects to be uploaded.
    ///   - completion: A closure to be called when the upload process is completed.
    ///                 It takes a single parameter of type `Result<[String], StorageError>`.
    ///                 The result will be either `.success` with an array of download URLs for the uploaded images,
    ///                 or `.failure` with a `StorageError` indicating the reason for failure.
    static func addUserImages(images: [UIImage], completion: @escaping(Result<[String], StorageError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        var imageUrls: [String] = []
        let filename = uid
        let dispatchGroup = DispatchGroup()
        
        for (index, image) in images.enumerated() {
            dispatchGroup.enter()
            
            guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                completion(.failure(.unknown))
                return
            }
            
            let path = index == 0 ? "users/\(uid)/images/banner/\(filename)" : "users/\(uid)/images/profile/\(filename)"
            let ref = Storage.storage().reference(withPath: path)
            
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    ref.downloadURL { url, error in
                        if let _ = error {
                            completion(.failure(.unknown))
                        } else {
                            guard let imageUrl = url?.absoluteString else {
                                completion(.failure(.unknown))
                                return
                            }
                            
                            imageUrls.append(imageUrl)
                            dispatchGroup.leave()
                        }
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(.success(imageUrls))
            
            
        }
    }
    
    static func deleteImage(kind: ImageKind) {
        guard let uid = UserDefaults.getUid() else { return }
        
        var path = ""
        
        switch kind {
            
        case .profile:
            path = "users/\(uid)/images/profile/\(uid)"
        case .banner:
            path = "users/\(uid)/images/banner/\(uid)"
        }

        let ref = Storage.storage().reference(withPath: path)
        ref.delete(completion: nil)
    }
}
