//
//  K.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import UIKit
import Firebase
import FirebaseFirestore


struct K {
    
    struct App {
        static let APP_NAME = "Evidens"
    }
    
    struct Colors {
        static let primaryColor = UIColor.init(named: "primaryColor")!
        static let separatorColor = UIColor.init(named: "separatorColor")!
        static let primaryGray = UIColor.init(named: "primaryGray")!
        static let caseColor = UIColor.init(named: "caseColor")!
        static let baseColor = UIColor.init(named: "primaryColor")!
        static let dimPrimaryColor = UIColor.init(named: "dimPrimaryColor")!
        static let popupColor = UIColor.init(named: "popupColor")!
        static let darkColor = UIColor.init(named: "darkColor")!
    }
    
    struct FirestoreCollections {
        static let COLLECTION_USERNAMES = Firestore.firestore().collection("usernames")
        static let COLLECTION_USERS = Firestore.firestore().collection("users")
        static let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
        static let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
        static let COLLECTION_HISTORY = Firestore.firestore().collection("history")
        static let COLLECTION_CONNECTIONS = Firestore.firestore().collection("connections")
        static let COLLECTION_BLOCKS = Firestore.firestore().collection("blocks")
        static let COLLECTION_POSTS = Firestore.firestore().collection("posts")
        static let COLLECTION_CASES = Firestore.firestore().collection("cases")
        static let COLLECTION_NOTIFICATIONS = Firestore.firestore().collection("notifications")
    }
    
    struct Ratio {
        static let bannerAR = 3.62
    }
    
    struct Paddings {
        
        struct Content {
            static let horizontalPadding: CGFloat = UIDevice.isPad ? 20 : 10
            static let verticalPadding: CGFloat = UIDevice.isPad ? 15 : 10
            
            static let userImageSize: CGFloat = UIDevice.isPad ? 55 : 35
            static let ownerImageSize: CGFloat = UIDevice.isPad ? 31 : 27
        }
    }
}
