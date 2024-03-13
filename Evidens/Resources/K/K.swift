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

let APP_NAME = "Evidens"

//MARK: - Colors

let primaryColor = UIColor.init(named: "primaryColor")!
let separatorColor = UIColor.init(named: "separatorColor")!
let primaryGray = UIColor.init(named: "primaryGray")!
let primaryRed = UIColor.init(named: "primaryColor")!
let caseColor = UIColor.init(named: "caseColor")!
let dimColor = UIColor.init(named: "dim")!
let baseColor = UIColor.init(named: "primaryColor")!
let dimPrimaryColor = UIColor.init(named: "dimPrimaryColor")!
let popupColor = UIColor.init(named: "popupColor")!
let darkColor = UIColor.init(named: "darkColor")!

//MARK: - Firebase collections

let COLLECTION_USERNAMES = Firestore.firestore().collection("usernames")
let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
let COLLECTION_HISTORY = Firestore.firestore().collection("history")
let COLLECTION_CONNECTIONS = Firestore.firestore().collection("connections")
let COLLECTION_BLOCKS = Firestore.firestore().collection("blocks")
let COLLECTION_POSTS = Firestore.firestore().collection("posts")
let COLLECTION_CASES = Firestore.firestore().collection("cases")
let COLLECTION_NOTIFICATIONS = Firestore.firestore().collection("notifications")

//MARK: - Ratio

let bannerAR = 3.62
