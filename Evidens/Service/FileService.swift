//
//  FileService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/5/23.
//

import Foundation
import UIKit

/// A singleton file gateway service used to interface with the documents directory.
struct FileGateway {
    
    static let shared = FileGateway()
    
    /// Saves an image to the document directory.
    ///
    /// - Parameters:
    ///   - url: The string of the image url to be saved.
    ///   - userId: The userID associated with the image.
    ///
    ///  - Returns:
    ///  The URL of the saved image, or nil if saving failed.
    func saveImage(url: String?, userId: String, completion: @escaping(URL?) -> Void) {
        guard let url = url, let validUrl = URL(string: url) else {
            completion(nil)
            return
        }
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        guard let imageUrl = documentDirectory?.appendingPathComponent("\(userId).jpg") else {
            completion(nil)
            return
        }
        
        DispatchQueue.global().async {
            do {
                let imageData = try Data(contentsOf: validUrl)
                fileManager.createFile(atPath: imageUrl.path, contents: imageData, attributes: nil)
                completion(imageUrl)
            } catch {
                completion(nil)
            }
        }
    }
    
    /// Saves an image to the document directory.
        ///
        /// - Parameters:
        ///   - image: The image to be saved.
        ///   - messageId: The messageID associated with the image.
        ///
        ///  - Returns:
        ///  The URL of the saved image, or nil if saving failed.
        func saveImage(image: UIImage?, messageId: String, completion: @escaping (URL?) -> Void) {
            guard let image = image else {
                completion(nil)
                return
            }
            
            let fileManager = FileManager.default
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            
            guard let imageUrl = documentDirectory?.appendingPathComponent("\(messageId).jpg") else {
                completion(nil)
                return
            }
            
            DispatchQueue.global().async {
                if let imageData = image.jpegData(compressionQuality: 0.5) {
                    do {
                        try imageData.write(to: imageUrl)
                        completion(imageUrl)
                    } catch {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        }
}
