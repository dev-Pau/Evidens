//
//  K.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import UIKit
import Firebase
import FirebaseFirestore

//MARK: - App
let APP_NAME = "MyEvidens"

//MARK: - Colors
let primaryColor =  UIColor.systemBlue
let pinkColor = UIColor.systemRed
let separatorColor = UIColor.init(named: "separatorColor")

//MARK: - Firebase collections
let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
let COLLECTION_HISTORY = Firestore.firestore().collection("history")
let COLLECTION_CONNECTIONS = Firestore.firestore().collection("connections")
let COLLECTION_POSTS = Firestore.firestore().collection("posts")
let COLLECTION_CASES = Firestore.firestore().collection("cases")
let COLLECTION_NOTIFICATIONS = Firestore.firestore().collection("notifications")


