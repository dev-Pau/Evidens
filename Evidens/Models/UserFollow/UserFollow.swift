//
//  UserFollow.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/10/22.
//

import UIKit
import Firebase
import FirebaseAuth

struct UserFollow {
    
    var uid: String
    var isFollow: Bool
  
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.isFollow = dictionary["isFollow"] as? Bool ?? false
        
    }
}
