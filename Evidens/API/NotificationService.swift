//
//  NotificationService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/11/21.
//

import UIKit
import Firebase

struct NotificationService {
    
    //Upload a notification to a specific user
    static func uploadNotification(toUid uid: String, fromUser: User, type: Notification.NotificationType, post: Post? = nil, withComment: String? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        //To avoid receiving user own notifications
        guard uid != currentUid else { return }
        
        let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
        
        var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                   "uid": fromUser.uid as Any,
                                   "type": type.rawValue,
                                   "id": docRef.documentID,
                                   "userProfileImageUrl": fromUser.profileImageUrl as Any,
                                   "firstName": fromUser.firstName as Any,
                                   "lastName": fromUser.lastName as Any]
        
        //Notifications could not have a post associated
        if let post = post {
            data["postId"] = post.postId
            //Put all the post information to navigate
            data["postUrl"] = post.postText
        }
        
        //If notification is a reply
        if let comment = withComment {
            data["postComment"] = comment
        }
        
        docRef.setData(data)
    }
    
    static func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true)
        
        query.getDocuments { (snapshot, _) in
            guard let documents = snapshot?.documents else { return }
            let notifications = documents.map({ Notification(dictionary: $0.data()) })
            completion(notifications)
        }
    }
}

