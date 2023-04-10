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
    
    //Upload a notification to a specific user
    static func uploadNotification(toUid uid: String, fromUser: User, type: Notification.NotificationType, post: Post? = nil, clinicalCase: Case? = nil, withCommentId: String? = nil) {
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //To avoid receiving user own notifications
        guard uid != currentUid else { return }
        
        if let post = post {
            
            let id = post.postId
            let notificationExists = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").whereField("postId", isEqualTo: id).whereField("type", isEqualTo: type.rawValue)
            notificationExists.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty, let notificationSnapshot = snapshot.documents.first else {
                    let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
                    
                    var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                               "uid": fromUser.uid as Any,
                                               "postId": post.postId,
                                               "type": type.rawValue,
                                               "id": docRef.documentID]
                    
                    if let comment = withCommentId {
                        data["commentId"] = comment
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
            let notificationExists = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").whereField("caseId", isEqualTo: id).whereField("type", isEqualTo: type.rawValue)
            notificationExists.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty, let notificationSnapshot = snapshot.documents.first else {
                    let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
                    
                    var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                               "uid": fromUser.uid as Any,
                                               "caseId": clinicalCase.caseId,
                                               "type": type.rawValue,
                                               "id": docRef.documentID]
                    
                    if let comment = withCommentId {
                        data["commentId"] = comment
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
            // Follow
            let notificationExists = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").whereField("type", isEqualTo: type.rawValue)
            notificationExists.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty, let notificationSnapshot = snapshot.documents.first else {
                    let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
                    
                    let data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                               "uid": fromUser.uid as Any,
                                               "type": type.rawValue,
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
}

