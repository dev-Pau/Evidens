//
//  UserFollow.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/10/22.
//

import UIKit
import Firebase
import FirebaseAuth

/// The model for a UserFollow
struct UserFollow {
    
    var uid: String
    var isFollow: Bool
  
    /// Initializes a new instance of a UserFollow using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the following status data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.isFollow = dictionary["isFollow"] as? Bool ?? false
    }
}
