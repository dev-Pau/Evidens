//
//  K.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import UIKit
import Firebase
import FirebaseFirestore

// Colors
let primaryColor = UIColor(rgb: 0x00C6B7)
let lightColor = UIColor(rgb: 0xF1F4F7)
let blackColor = UIColor(rgb: 0x2B2D42)
let grayColor = UIColor(rgb: 0x677987)
let lightGrayColor = UIColor(rgb: 0xDCE4EA)
let pinkColor = UIColor(rgb: 0xEC7480)

// Firebase collections
let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
let COLLECTION_POSTS = Firestore.firestore().collection("posts")
let COLLECTION_NOTIFICATIONS = Firestore.firestore().collection("notifications")

