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
    static func uploadNotification(toUid uid: String, fromUser: User, type: Notification.NotificationType, post: Post? = nil, clinicalCase: Case? = nil, withComment: String? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        //To avoid receiving user own notifications
        guard uid != currentUid else { return }
        
        let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
        
        var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                   "uid": fromUser.uid as Any,
                                   "type": type.rawValue,
                                   "id": docRef.documentID]
        
        //Notifications could not have a post associated
        if let post = post {
            data["postId"] = post.postId
            //Put all the post information to navigate
            data["postText"] = post.postText
        }
        
        if let clinicalCase = clinicalCase {
            data["caseId"] = clinicalCase.caseId
            data["caseTitle"] = clinicalCase.caseTitle
        }
        
        //If notification is a reply
        if let comment = withComment {
            data["comment"] = comment
        }
        
        docRef.setData(data)
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
    
    static func fetchNotifications(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true).limit(to: 15)
            firstGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else {
                    completion(nil)
                    return
                }
                guard snapshot.documents.last != nil else {
                    completion(nil)
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

