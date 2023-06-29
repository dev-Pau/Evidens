//
//  NotificationService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/11/21.
//

import UIKit
import Firebase
import FirebaseAuth

struct NotificationService {
    
    static func syncPreferences(_ status: UNAuthorizationStatus) {
        switch status {
        case .notDetermined, .denied, .provisional, .ephemeral:
            set("enabled", false)
        case .authorized:
            set("enabled", true)
        @unknown default:
            set("enabled", false)
        }
    }
    
    static func fetchPreferences(completion: @escaping(Result<NotificationPreference?, Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let preferenceRef = COLLECTION_NOTIFICATIONS.document(uid)
        preferenceRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
                    completion(.success(nil))
                    return
                }

                let preferences = NotificationPreference(dictionary: data)
                print(preferences)
                completion(.success(preferences))
            }
        }
    }
    
    static func set(_ key: String, _ value: Bool) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let preferenceRef = COLLECTION_NOTIFICATIONS.document(uid)
        preferenceRef.setData([key: value], merge: true) { error in
            if let error = error {
                print("ERROR BELOW")
                print(error)
            } else {
                print("Update successful")
            }
        }
    }
    
    static func set(_ parentKey: String, _ nestedKey: String, _ value: Any) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let preferenceRef = COLLECTION_NOTIFICATIONS.document(uid)
        
        let updateData: [String: Any] = [
            parentKey: [
                nestedKey: value
            ]
        ]
        
        preferenceRef.setData(updateData, merge: true) { error in
            if let error = error {
                print("ERROR BELOW")
                print(error)
            } else {
                print("Update Nested successful")
            }
        }
    }
    
    
    //Upload a notification to a specific user

    #warning("ADD GROUP ID TO NOTIFICATION IN CASE IT IS FROM GROUP, ADD THE CASE GROUP POST AND GROPU CASE AND BECAUSE RIGHT NOW FOR JULIA ROBERT IS NOT FETCHING GOOD")

    static func uploadNotification(toUid uid: String, fromUser: User, type: Notification.NotificationType, post: Post? = nil, clinicalCase: Case? = nil, withCommentId: String? = nil, job: Job? = nil) {
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        guard type != .likePost else {
            print("we are not sending notification")
            return
            
        }
        print("we are sending notification")
        //To avoid receiving user own notifications
        guard uid != currentUid else { return }
        if let post = post {
            
            let id = post.postId
            let notificationExists = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").whereField("contentId", isEqualTo: id).whereField("kind", isEqualTo: type.rawValue)
            notificationExists.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty, let notificationSnapshot = snapshot.documents.first else {
                    let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
                    
                    var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                               "uid": fromUser.uid as Any,
                                               "contentId": post.postId,
                                               "kind": type.rawValue,
                                               "id": docRef.documentID]
                    
                    if let comment = withCommentId {
                        data["commentId"] = comment
                    }
                    
                    // Notification related to a group
                    if let groupId = post.groupId {
                        data["groupId"] = groupId
                    }
                    
                    docRef.setData(data)
                    return
                }
                
                // We have a notification type associated with this post registered already
                let notification = Notification(dictionary: notificationSnapshot.data() )
                var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                           "uid": fromUser.uid as Any]
                if let comment = withCommentId {
                    data["commentId"] = comment
                }
                
                COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document(notification.id).setData(data, merge: true)
            }
        } else if let clinicalCase = clinicalCase {
            
            let id = clinicalCase.caseId
            let notificationExists = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").whereField("contentId", isEqualTo: id).whereField("kind", isEqualTo: type.rawValue)
            notificationExists.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty, let notificationSnapshot = snapshot.documents.first else {
                    let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
                    
                    var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                               "uid": fromUser.uid as Any,
                                               "contentId": clinicalCase.caseId,
                                               "kind": type.rawValue,
                                               "id": docRef.documentID]
                    
                    if let comment = withCommentId {
                        data["commentId"] = comment
                    }
                    
                    // Notification related to a group
                    if let groupId = clinicalCase.groupId {
                        data["groupId"] = groupId
                    }
                    
                    docRef.setData(data)
                    return
                }
                
                // We have a notification type associated with this post registered already
                let notification = Notification(dictionary: notificationSnapshot.data() )
                var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                           "uid": fromUser.uid as Any]
                if let comment = withCommentId {
                    data["commentId"] = comment
                }
                
                COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document(notification.id).setData(data, merge: true)
            }
        } else {

                let notificationExists = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").whereField("kind", isEqualTo: type.rawValue)
                notificationExists.getDocuments { snapshot, error in
                    guard let snapshot = snapshot, !snapshot.isEmpty, let notificationSnapshot = snapshot.documents.first else {
                        let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
                        
                        let data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                                   "uid": fromUser.uid as Any,
                                                   "kind": type.rawValue,
                                                   "id": docRef.documentID]
                        docRef.setData(data)
                        return
                    }
                    
                    // We have a notification type associated with this post registered already
                    let notification = Notification(dictionary: notificationSnapshot.data() )
                    let data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                               "uid": fromUser.uid as Any]
                    COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document(notification.id).setData(data, merge: true)
                
            }
            // Follow
            
        }
        
        /*
         let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
         
         var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
         "uid": fromUser.uid as Any,
         "type": type.rawValue,
         "id": docRef.documentID]
         
         //Notifications could not have a post associated
         if let post = post {
         data["postId"] = post.postId
         //Put all the post information to navigate
         //data["postText"] = post.postText
         }
         
         if let clinicalCase = clinicalCase {
         data["caseId"] = clinicalCase.caseId
         //data["caseTitle"] = clinicalCase.caseTitle
         }
         
         //If notification is a reply
         if let comment = withComment {
         data["comment"] = comment
         }
         
         docRef.setData(data)
         */
    }
    
    static func deleteNotification(withUid notificationUid: String, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document(notificationUid)
        query.delete() { error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            completion(true)
            
        }
    }
    
    /*
     static func fetchNotifications(completion: @escaping([Notification]) -> Void) {
     guard let uid = Auth.auth().currentUser?.uid else { return }
     
     let query = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true)
     
     query.getDocuments { (snapshot, _) in
     guard let documents = snapshot?.documents else { return }
     let notifications = documents.map({ Notification(dictionary: $0.data()) })
     completion(notifications)
     }
     }
     */
    
    static func fetchNotifications(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true).limit(to: 15)
            firstGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty  else {
                    completion(snapshot!)
                    return
                }
                guard snapshot.documents.last != nil else {
                    completion(snapshot)
                    return
                }
                completion(snapshot)
            }
        } else {
            let nextGroupToFetch = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15)
            nextGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }
    
    static func getNewNotifications(lastSnapshot: QueryDocumentSnapshot, completion: @escaping(QuerySnapshot?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let newNotificationsQuery = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: false).start(afterDocument: lastSnapshot).count
        newNotificationsQuery.getAggregation(source: .server) { snapshot, _ in
            guard let snapshot = snapshot, snapshot.count.intValue > 0 else {
                print("no new notis")
                completion(nil)
                return
            }
            
            // Number new notifications counting since last notification received
            let numberOfNewNotifications = min(snapshot.count.intValue, 15)
            if numberOfNewNotifications == 15 {
                // Fetch most recent notifications
                fetchNotifications(lastSnapshot: nil) { snapshot in
                    completion(snapshot)
                }
            } else {
                // Fetch the new notifications
                fetchCustomAmountOfNewNotificationsWithValue(numberOfNewNotifications) { snapshot in
                    completion(snapshot)
                }
                
            }
        }
    }
    
    static func fetchCustomAmountOfNewNotificationsWithValue(_ count: Int, completion: @escaping(QuerySnapshot) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let newNotificationsQuery = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true).limit(to: count)
        newNotificationsQuery.getDocuments { snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty  else {
                completion(snapshot!)
                return
            }
            guard snapshot.documents.last != nil else {
                completion(snapshot)
                return
            }
            completion(snapshot)
        }
    }
    
    static func getSnapshotForLastNotification(_ notification: Notification, completion: @escaping(QuerySnapshot) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let query = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").whereField("id", isEqualTo: notification.id).limit(to: 1)
        query.getDocuments { snapshot, _ in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion(snapshot!)
                return
            }
            
            completion(snapshot)
        }
    }
}
    
