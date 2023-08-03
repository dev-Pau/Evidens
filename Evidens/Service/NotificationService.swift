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
    
}

//MARK: - Preferences

extension NotificationService {
    
    //MARK: - Sync
    
    /// Synchronizes the notification preferences based on the provided `UNAuthorizationStatus`.
    /// It sets the "enabled" key to `true` if the status is `.authorized`, otherwise, sets it to `false`.
    ///
    /// - Parameter status: The `UNAuthorizationStatus` representing the authorization status for notifications.
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
    
    /// Sets a boolean value for the provided key in the user's notification preferences.
    ///
    /// - Parameters:
    ///   - key: The key to set in the preferences.
    ///   - value: The boolean value to set for the key.
    ///   - completion: An optional closure to be called when the operation is completed.
    ///                 It takes a single parameter of type `FirestoreError`, which will be either `nil`
    ///                 if the operation was successful, or an error of type `FirestoreError` indicating
    ///                 the reason for failure.
    static func set(_ key: String, _ value: Bool, completion: ((FirestoreError?) -> Void)? = nil) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion?(.network)
            return
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion?(.unknown)
            return
        }
        
        let preferenceRef = COLLECTION_NOTIFICATIONS.document(uid)
        preferenceRef.setData([key: value], merge: true) { error in
            if let _ = error {
                completion?(.unknown)
            } else {
                completion?(nil)
            }
        }
    }
    
    /// Sets a nested value for the provided parent and nested keys in the user's notification preferences.
    ///
    /// - Parameters:
    ///   - parentKey: The parent key in the preferences.
    ///   - nestedKey: The nested key within the parent key.
    ///   - value: The value to set for the nested key.
    ///   - completion: An optional closure to be called when the operation is completed.
    ///                 It takes a single parameter of type `FirestoreError`, which will be either `nil`
    ///                 if the operation was successful, or an error of type `FirestoreError` indicating
    ///                 the reason for failure.
    static func set(_ parentKey: String, _ nestedKey: String, _ value: Any, completion: ((FirestoreError?) -> Void)? = nil) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion?(.network)
            return
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion?(.unknown)
            return
        }
        
        let preferenceRef = COLLECTION_NOTIFICATIONS.document(uid)
        
        let preferenceToUpdate: [String: Any] = [
            parentKey: [
                nestedKey: value
            ]
        ]
        
        preferenceRef.setData(preferenceToUpdate, merge: true) { error in
            if let _ = error {
                completion?(.unknown)
            } else {
                completion?(nil)
            }
        }
    }
}

//MARK: - Delete Operations

extension NotificationService {
    
    /// Deletes a notification with the provided notification UID.
    ///
    /// - Parameters:
    ///   - notificationUid: The UID of the notification to delete.
    ///   - completion: A closure to be called when the deletion process is completed.
    ///                 It takes an optional parameter of type `FirestoreError`.
    ///                 If the deletion is successful, the completion will be called with `nil`.
    ///                 If there's an error during the deletion, the completion will be called with the appropriate `FirestoreError`.
    static func deleteNotification(withId notificationId: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        let query = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document(notificationId)
        query.delete() { error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {

                case .notFound:
                    completion(.notFound)
                default:
                    completion(.unknown)
                }
                
            } else {
                completion(nil)
            }
        }
    }
    
    /*
     static func deleteComment(forCase clinicalCase: Case, forCommentId commentId: String, completion: @escaping(FirestoreError?) -> Void) {
         
         /// Deletes a comment from a clinical case.
         ///
         /// - Parameters:
         ///   - clinicalCase: The clinical case from which the comment will be deleted.
         ///   - commentId: The ID of the comment to be deleted.
         ///   - completion: A closure to be called when the operation is completed.
         ///                 It takes a `FirestoreError` parameter, which is nil if the deletion is successful, or an error if it fails.
         guard NetworkMonitor.shared.isConnected else {
             completion(.network)
             return
         }
         
         COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).updateData(["visible": Visible.deleted.rawValue]) { error in
             if let error {
                 let nsError = error as NSError
                 let errCode = FirestoreErrorCode(_nsError: nsError)
                 
                 switch errCode.code {

                 case .notFound:
                     completion(.notFound)
                 default:
                     completion(.unknown)
                 }
                 
             } else {
                 completion(nil)
             }
         }
     }
     
     */
}

//MARK: - Fetch Operations

extension NotificationService {
    
    /// Fetches notifications from Firestore for the current user starting from the provided `lastSnapshot`.
    ///
    /// - Parameters:
    ///   - lastSnapshot: The `QueryDocumentSnapshot` to start fetching notifications from. If `nil`,
    ///                   the function will fetch the most recent notifications.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<QuerySnapshot, FirestoreError>`.
    ///                 The result will be either `.success` with a `QuerySnapshot` containing the fetched notifications,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchNotifications(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
            
        }

        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true).limit(to: 15)
            firstGroupToFetch.getDocuments { snapshot, error in
                
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
            }
        } else {
            let nextGroupToFetch = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15)
            nextGroupToFetch.getDocuments { snapshot, error in
                
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
            }
        }
    }
    
    /// Retrieves new notifications for the current user starting from the specified `lastSnapshot`.
    ///
    /// - Parameters:
    ///   - lastSnapshot: The `QueryDocumentSnapshot` to start retrieving new notifications from. If `nil`,
    ///                   the function will retrieve the most recent notifications.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<QuerySnapshot, FirestoreError>`.
    ///                 The result will be either `.success` with a `QuerySnapshot` containing the new notifications,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func getNewNotifications(lastSnapshot: QueryDocumentSnapshot, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let newNotificationsQuery = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: false).start(afterDocument: lastSnapshot).count
        newNotificationsQuery.getAggregation(source: .server) { snapshot, error in
            
            if let error {
                let nsError = error as NSError
                let _ = FirestoreErrorCode(_nsError: nsError)
                completion(.failure(.unknown))
            }
            
            guard let snapshot = snapshot, snapshot.count.intValue > 0 else {
                completion(.failure(.notFound))
                return
            }
            
            // Number new notifications counting since last notification received
            let newNotificationsCount = min(snapshot.count.intValue, 15)
            if newNotificationsCount == 15 {
                // Fetch most recent notifications
                fetchNotifications(lastSnapshot: nil) { result in
                    switch result {
                    case .success(let snapshot):
                        completion(.success(snapshot))
                    case .failure(let error):
                        let nsError = error as NSError
                        let _ = FirestoreErrorCode(_nsError: nsError)
                        completion(.failure(.unknown))
                        
                    }
                }
            } else {
                // Fetch the new notifications
                fetchCustomAmountOfNewNotificationsWithValue(newNotificationsCount) { result in
                    switch result {
                        
                    case .success(let snapshot):
                        completion(.success(snapshot))
                    case .failure(let error):
                        let nsError = error as NSError
                        let _ = FirestoreErrorCode(_nsError: nsError)
                        completion(.failure(.unknown))
                    }
                }
            }
        }
    }
    
    /// Fetches a custom amount of new notifications for the user with a given count.
    ///
    /// - Parameters:
    ///   - count: The number of new notifications to fetch.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<QuerySnapshot, FirestoreError>`.
    ///                 The result will be either `.success` with the query snapshot containing the new notifications,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchCustomAmountOfNewNotificationsWithValue(_ count: Int, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let newNotificationsQuery = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true).limit(to: count)
        
        newNotificationsQuery.getDocuments { snapshot, error in
            
            if let error {
                let nsError = error as NSError
                let _ = FirestoreErrorCode(_nsError: nsError)
                completion(.failure(.unknown))
            }
            
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion(.failure(.notFound))
                return
            }
            
            guard snapshot.documents.last != nil else {
                completion(.success(snapshot))
                return
            }
            
            completion(.success(snapshot))
        }
    }

    /// Fetches the notification preferences for the current user.
    ///
    /// - Parameters:
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<NotificationPreference, FirestoreError>`.
    ///                 The result will be either `.success` with a `NotificationPreference` object containing
    ///                 the user's notification preferences, or `.failure` with a `FirestoreError` indicating
    ///                 the reason for failure.
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
}

//MARK: - Miscellaneous

extension NotificationService {
    
    /// Retrieves the query snapshot for the last notification matching the provided notification object.
    ///
    /// - Parameters:
    ///   - notification: The notification object to search for.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `QuerySnapshot?`, which will contain the query snapshot
    ///                 for the last notification if found, or `nil` if not found.
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
