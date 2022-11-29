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
    
    static func uploadBannerImage(image: UIImage, uid: String, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let filename = uid
        let ref = Storage.storage().reference(withPath: "/banners/\(filename)")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("DEBUG: Failed to upload image \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                guard let bannerUrl = url?.absoluteString else { return }
                completion(bannerUrl)
            }
        }
    }
    
    /// Uploads an image for a specific user to firebase storage to verify eligibility
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
    
    /// Uploads a profile image for a specific user to firebase storage with url string to download
    static func uploadPostImage(images: [UIImage], uid: String, completion: @escaping([String]) -> Void) {

        var postImagesUrl: [String] = []
        var index = 0
        var order = 0
        
        images.forEach { image in
            
            guard let imageData = image.jpegData(compressionQuality: 0.1) else { return } //0.75
            
            
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
    
    static func uploadCaseImage(images: [UIImage], uid: String, completion: @escaping([String]) -> Void) {

        var postImagesUrl: [String] = []
        var index = 0
        var order = 0
        
        images.forEach { image in
            
            guard let imageData = image.jpegData(compressionQuality: 0.1) else { return } //0.75
            
            
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
    
    /// Uploads a profile image for a specific user to firebase storage with url string to download
    static func uploadGroupImages(images: [UIImage], completion: @escaping([String]) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        var groupImagesUrl: [String] = []
        var index = 0
        var order = 0
        
        images.forEach { image in
            
            guard let imageData = image.jpegData(compressionQuality: 0.1) else { return } //0.75
            
            
            let filename = "\(order) \(uid) \(NSUUID().uuidString)"
            let ref = Storage.storage().reference(withPath: "/group_images/\(filename)")
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
                        
                        var appended: [Int] = []
                        
                        groupImagesUrl.forEach { url in
                            
                            let currentURL = url.replacingOccurrences(of: "https://firebasestorage.googleapis.com:443/v0/b/evidens-ec6bd.appspot.com/o/group_images%2F", with: "")
                            appended.append(Int(currentURL[0..<1])!)
                            
                            if appended.count == groupImagesUrl.count {
                                var orderedGroupImagesUrl = [groupImagesUrl[appended.firstIndex(of: 0)!], groupImagesUrl[appended.firstIndex(of: 1)!]]
                                completion(orderedGroupImagesUrl)
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func uploadGroupImage(image: UIImage, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75), let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let filename = uid
        let ref = Storage.storage().reference(withPath: "/group_images/\(filename)")
        
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
