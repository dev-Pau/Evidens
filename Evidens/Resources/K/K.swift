//
//  K.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import UIKit
import Firebase
import FirebaseFirestore

// App
let APP_NAME = "MyEvidens"

// Colors
let primaryColor =  UIColor.systemBlue //UIColor(rgb: 0x00C6B7)
let lightColor = UIColor(rgb: 0xF1F4F7)
let blackColor = UIColor(rgb: 0x2B2D42)
let grayColor = UIColor(rgb: 0x677987)
let lightGrayColor = UIColor(rgb: 0xDCE4EA)
let pinkColor = UIColor.systemRed //UIColor(rgb: 0xEC7480)
let leafGreenColor = UIColor(rgb: 0x55B684)
let interactiveColor = UIColor(rgb: 0x2176FF)
let separatorColor = UIColor.init(named: "separatorColor")


// Firebase collections
let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
let COLLECTION_CONNECTIONS = Firestore.firestore().collection("connections")
let COLLECTION_POSTS = Firestore.firestore().collection("posts")
let COLLECTION_CASES = Firestore.firestore().collection("cases")
let COLLECTION_NOTIFICATIONS = Firestore.firestore().collection("notifications")
let COLLECTION_GROUPS = Firestore.firestore().collection("groups")
let COLLECTION_COMPANIES = Firestore.firestore().collection("companies")
let COLLECTION_JOBS = Firestore.firestore().collection("jobs")
let COLLECTION_NEWS = Firestore.firestore().collection("news")

