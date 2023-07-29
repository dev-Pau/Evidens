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
    
    static func fetchPreferences(completion: @escaping(Result<NotificationPreference, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let preferenceRef = COLLECTION_NOTIFICATIONS.document(uid)
        preferenceRef.getDocument { snapshot, error in
            if let error = error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {

                case .notFound:
                    completion(.failure(.notFound))
                default:
                    completion(.failure(.unknown))
                }
            } else {
                guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
                    completion(.failure(.unknown))
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
    
