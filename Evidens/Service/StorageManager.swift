//
//  ImageUploader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import FirebaseStorage
import UIKit

/// A storage manager used to interface with Firebase Storage
struct StorageManager {
    
    /// Uploads a profile image to Firebase Storage.
    ///
    /// - Parameters:
    ///   - image: The UIImage object representing the image to be uploaded.
    ///   - uid: The user ID associated with the profile image.
    ///   - completion: A closure to be called upon completion of the upload process. It takes a single parameter:
    ///                 - imageUrl: The download URL of the uploaded image, or `nil` if the upload was unsuccessful.
    ///                 - error: An `Error` object indicating any error that occurred during the upload process, or `nil` if there was no error.
    static func uploadProfileImage(image: UIImage, uid: String, completion: @escaping(String?, Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        
        let filename = uid
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(nil, error)
            } else {
                ref.downloadURL { url, error in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    if let imageUrl = url?.absoluteString {
                        completion(imageUrl, nil)
                        return
                    }
                    
                    completion(nil, nil)
                }
            }
        }
    }
    
    /// Uploads a banner image to the storage service.
    ///
    /// - Parameters:
    ///   - image: The UIImage object representing the image to be uploaded.
    ///   - uid: The user ID associated with the banner image.
    ///   - completion: A closure to be called upon completion of the upload process. It takes two optional parameters:
    ///                 - bannerUrl: The download URL of the uploaded banner image, or `nil` if the upload was unsuccessful.
    ///                 - error: An `Error` object indicating any error that occurred during the upload process, or `nil` if there was no error.
    static func uploadBannerImage(image: UIImage, uid: String, completion: @escaping(String?, Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        let filename = uid
        let ref = Storage.storage().reference(withPath: "/banners/\(filename)")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(nil, error)
            } else {
                ref.downloadURL { url, error in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    if let bannerUrl = url?.absoluteString {
                        completion(bannerUrl, nil)
                        return
                    }
                    
                    completion(nil, nil)
                }
            }
        }
    }
    
    /// Uploads both profile and banner images to the storage service.
    ///
    /// - Parameters:
    ///   - images: An array of UIImage objects representing the images to be uploaded.
    ///   - userUid: The user ID associated with the profile images.
    ///   - completion: A closure to be called upon completion of the upload process. It takes a single parameter:
    ///                 - imageUrls: An array of strings representing the download URLs of the uploaded images.
    ///                               The order of the URLs corresponds to the order of the input images.
    static func uploadProfileImages(images: [UIImage], userUid: String, completion: @escaping([String]) -> Void) {
        var groupImagesUrl: [String] = []
        var index = 0
        var order = 0
        let filename = userUid
        
        images.forEach { image in
            guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }

            let fileRef = (order == 0) ? "/banners/" : "/profile_images/"
            let ref = Storage.storage().reference(withPath: "\(fileRef)\(filename)")
            order += 1
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                ref.downloadURL { url, error in
                    index += 1
                    guard let imageUrl = url?.absoluteString else { return }
                    groupImagesUrl.append(imageUrl)

                    
                    if images.count == index {
                        completion(groupImagesUrl)
                    }
                }
            }
        }
    }
    
    /// Uploads an array of documentation images to the storage service.
    ///
    /// - Parameters:
    ///   - images: An array of UIImage objects representing the images to be uploaded.
    ///   - type: The type of documentation associated with the images.
    ///   - uid: The user ID associated with the documentation images.
    ///   - completion: A closure to be called upon completion of the upload process. It takes a single parameter:
    ///                 - success: A boolean value indicating whether the upload process was successful (true) or not (false).
    static func uploadDocumentationImage(images: [UIImage], type: String, uid: String, completion: @escaping(Bool) -> Void) {
        var index = 0
        
        images.forEach { image in
            guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
            let filename = "\(index)_\(type)_\(uid)"
            
            let ref = Storage.storage().reference(withPath: "/verification_images/\(uid)/\(filename)")
            index += 1
            
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("DEBUG: Failed to upload post image \(error.localizedDescription)")
                    return
                }
                if images.count == index {
                    completion(true)
                }
            }
        }
    }
    
    /// Uploads an array of post images to the storage service.
    ///
    /// - Parameters:
    ///   - images: An array of UIImage objects representing the images to be uploaded.
    ///   - uid: The user ID associated with the post images.
    ///   - completion: A closure to be called upon completion of the upload process. It takes a single parameter:
    ///                 - imageUrls: An array of strings representing the download URLs of the uploaded images.
    ///                               The order of the URLs corresponds to the order of the input images.
    static func uploadPostImage(images: [UIImage], uid: String, completion: @escaping([String]) -> Void) {
        var postImagesUrl: [String] = []
        var index = 0
        var order = 0
        
        images.forEach { image in
            guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
            let filename = "\(order) \(uid) \(NSUUID().uuidString)"
            let ref = Storage.storage().reference(withPath: "/post_images/\(filename)")
            order += 1
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
    
    /// Uploads an array of case images to the storage service.
    ///
    /// - Parameters:
    ///   - images: An array of UIImage objects representing the images to be uploaded.
    ///   - uid: The user ID associated with the case images.
    ///   - completion: A closure to be called upon completion of the upload process. It takes a single parameter:
    ///                 - imageUrls: An array of strings representing the download URLs of the uploaded images.
    ///                               The order of the URLs corresponds to the order of the input images.
    static func uploadCaseImage(images: [UIImage], uid: String, completion: @escaping([String]) -> Void) {
        var postImagesUrl: [String] = []
        var index = 0
        var order = 0
        
        images.forEach { image in
            guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
            let filename = "\(order) \(uid) \(NSUUID().uuidString)"
            print(filename)
            let ref = Storage.storage().reference(withPath: "/case_images/\(filename)")
            order += 1
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
    
    /// Uploads an array of group images to the storage service.
    ///
    /// - Parameters:
    ///   - images: An array of UIImage objects representing the images to be uploaded.
    ///   - groupId: The group ID associated with the group images.
    ///   - completion: A closure to be called upon completion of the upload process. It takes a single parameter:
    ///                 - imageUrls: An array of strings representing the download URLs of the uploaded images.
    ///                               The order of the URLs corresponds to the order of the input images.
    static func uploadGroupImages(images: [UIImage], groupId: String, completion: @escaping([String]) -> Void) {
        var groupImagesUrl: [String] = []
        var index = 0
        var order = 0
        let filename = groupId
        
        images.forEach { image in
            guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }

            let fileRef = (order == 0) ? "/banners/" : "/profiles/"
            let ref = Storage.storage().reference(withPath: "/group_images/\(fileRef)\(filename)")
            order += 1
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("DEBUG: Failed to upload post image \(error.localizedDescription)")
                    return
                }
                
                ref.downloadURL { url, error in
                    index += 1
                    guard let imageUrl = url?.absoluteString else { return }
                    groupImagesUrl.append(imageUrl)

                    
                    if images.count == index {
                        completion(groupImagesUrl)
                    }
                }
            }
        }
    }
    
    /// Uploads a group image to the storage service.
    ///
    /// - Parameters:
    ///   - image: The UIImage object representing the image to be uploaded.
    ///   - isProfile: A boolean value indicating whether the image is a profile image (true) or a banner image (false).
    ///   - groupId: The group ID associated with the image.
    ///   - completion: A closure to be called upon completion of the upload process. It takes a single parameter:
    ///                 - imageUrl: A string representing the download URL of the uploaded image.
    static func uploadGroupImage(image: UIImage, isProfile: Bool, groupId: String, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        let filename = groupId
        let fileRef = isProfile ? "/profiles/" : "/banners/"
        let ref = Storage.storage().reference(withPath: "/group_images/\(fileRef)\(filename)")
        
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
    
    /// Uploads a company image to the storage service.
    ///
    /// - Parameters:
    ///   - image: The UIImage object representing the image to be uploaded.
    ///   - companyID: The company ID associated with the image.
    ///   - completion: A closure to be called upon completion of the upload process. It takes a single parameter:
    ///                 - imageUrl: A string representing the download URL of the uploaded image.
    static func uploadCompanyImage(image: UIImage, companyId: String, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        let filename = companyId
        let fileRef = "/profiles/"
        let ref = Storage.storage().reference(withPath: "/company_images/\(fileRef)\(filename)")
        
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
    
    /// Uploads multiple images to the specified group case.
    ///
    /// - Parameters:
    ///   - images: An array of images to upload.
    ///   - uid: The unique identifier of the user.
    ///   - groupId: The unique identifier of the group.
    ///   - completion: A closure to be called when the upload is complete. It receives an array of strings representing the URLs of the uploaded images.
    static func uploadGroupCaseImage(images: [UIImage], uid: String, groupId: String, completion: @escaping([String]) -> Void) {
        var caseImagesUrl: [String] = []
        var index = 0
        var order = 0
        
        images.forEach { image in
            
            guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
            
            
            let filename = "\(order) \(uid) \(NSUUID().uuidString)"
            let ref = Storage.storage().reference(withPath: "/group/case/case_images/\(filename)")
            order += 1
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("DEBUG: Failed to upload case image \(error.localizedDescription)")
                    return
                }
                
                ref.downloadURL { url, error in
                    index += 1
                    guard let imageUrl = url?.absoluteString else { return }
                    caseImagesUrl.append(imageUrl)
                    if images.count == index {
                        completion(caseImagesUrl)
                    }
                }
            }
        }
    }
    
    
    static func uploadJobDocument(jobId: String, fileName: String, url: URL, completion: @escaping(String) -> Void) {
        let jobRef = Storage.storage().reference(withPath: "/jobs/\(jobId)/applicants/\(fileName)")
        jobRef.putFile(from: url, metadata: nil) { metadata, error in
            if let error = error {
                print("DEBUG: Failed to upload job document \(error.localizedDescription)")
                return
            }
            jobRef.downloadURL { url, error in
                guard let downloadUrl = url else { return }
                completion(downloadUrl.absoluteString)
            }
        }
    }
    
    
    
    static func uploadGroupPostImage(images: [UIImage], uid: String, groupId: String, completion: @escaping([String]) -> Void) {
        let ordered = ["IMAGE_ORDER_0", "IMAGE_ORDER_1", "IMAGE_ORDER_2", "IMAGE_ORDER_3"]

        var caseImagesUrl: [String] = []
        var index = 0
        var order = 0
        
        images.forEach { image in
            
            guard let imageData = image.jpegData(compressionQuality: 0.1) else { return } //0.75
            
            let filename = "IMAGE_ORDER_\(order) \(uid) \(NSUUID().uuidString)"
            let ref = Storage.storage().reference(withPath: "/group/post/post_images/\(filename)")
            order += 1
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("DEBUG: Failed to upload case image \(error.localizedDescription)")
                    return
                }
                
                ref.downloadURL { url, error in
                    index += 1
                    guard let imageUrl = url?.absoluteString else { return }
                    caseImagesUrl.append(imageUrl)
                    if images.count == index {
                        var orderedUrls = [String]()

                        orderedUrls.append(caseImagesUrl.first(where: { url in
                            url.contains(ordered[0])
                        })!)
                        
                        if caseImagesUrl.count > 1 {
                            orderedUrls.append(caseImagesUrl.first(where: { url in
                                url.contains(ordered[1])
                            }) ?? "")
                        }
                        
                        if caseImagesUrl.count > 2 {
                            
                            orderedUrls.append(caseImagesUrl.first(where: { url in
                                url.contains(ordered[2])
                            }) ?? "")
                        }
                        
                        if caseImagesUrl.count > 3 {
                            
                            orderedUrls.append(caseImagesUrl.first(where: { url in
                                url.contains(ordered[3])
                            }) ?? "")
                        }

                        completion(orderedUrls.compactMap{ $0 })
                    }
                }
            }
        }
    }

    static func uploadPostVideo(with fileUrl: URL, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let fileName = "\(uid) \(NSUUID().uuidString)"
        
        //let data = Data(contentsOf: fileUrl)
        
        let ref = Storage.storage().reference(withPath: "/post_videos/\(fileName)")
        
        ref.putFile(from: fileUrl, metadata: nil) { result, error in
            if let error = error {
                print("Failed to upload message video file \(error.localizedDescription)")
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                guard let url = url else { return }
                let urlString = url.absoluteString
                print(urlString)
                completion(.success(urlString))
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
    
    static func uploadMessagePhoto(_ image: UIImage, conversationId: String, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        let ref = Storage.storage().reference(withPath: "/messages/\(conversationId)/images/\(fileName)")
        ref.putData(imageData, metadata: nil) { result, error in
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
    
    /*
     guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
     
     let filename = uid
     let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
     
     ref.putData(imageData, metadata: nil) { metadata, error in
         if let error = error {
             completion(nil, error)
         } else {
             ref.downloadURL { url, error in
                 if let error = error {
                     completion(nil, error)
                     return
                 }
                 if let imageUrl = url?.absoluteString {
                     completion(imageUrl, nil)
                     return
                 }
                 
                 completion(nil, nil)
             }
         }
     }
     */
    
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

public func copyBundleResourceToTemporaryDirectory(resourceName: String, fileExtension: String) -> URL?
    {
        // Get the file path in the bundle
        if let bundleURL = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) {

            let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

            // Create a destination URL.
            let targetURL = tempDirectoryURL.appendingPathComponent(resourceName).appendingPathExtension(fileExtension)

            // Copy the file.
            do {
                try FileManager.default.copyItem(at: bundleURL, to: targetURL)
                return targetURL
            } catch let error {
                print("Unable to copy file: \(error)")
            }
        }

        return nil
    }
