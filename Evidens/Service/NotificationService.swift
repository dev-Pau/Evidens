//
//  NotificationService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/11/21.
//

import UIKit
import Firebase
import FirebaseAuth

/// A service used to interface with FirebaseFirestore for user notifications.
struct NotificationService { }

//MARK: - Preferences

extension NotificationService {
    
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
            
            if let preferredLanguage = Locale.preferredLanguages.first {
                let currentLanguage = Locale(identifier: preferredLanguage).languageCode
                set(code: currentLanguage ?? "en")
            }
            
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
        
        guard let uid = UserDefaults.getUid() else {
            completion?(.unknown)
            return
        }
        
        let preferenceRef = K.FirestoreCollections.COLLECTION_NOTIFICATIONS.document(uid)
        preferenceRef.setData([key: value], merge: true) { error in
            if let _ = error {
                completion?(.unknown)
            } else {
                completion?(nil)
            }
        }
    }
    
    /// Set the notification code preference for the user.
    ///
    /// - Parameter code: The notification code to be set.
    static func set(code: String) {
        guard let uid = UserDefaults.getUid() else { return }
        let preferenceRef = K.FirestoreCollections.COLLECTION_NOTIFICATIONS.document(uid)
        preferenceRef.setData(["code": code], merge: true)
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
        
        guard let uid = UserDefaults.getUid() else {
            completion?(.unknown)
            return
        }
        
        let preferenceRef = K.FirestoreCollections.COLLECTION_NOTIFICATIONS.document(uid)
        
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

        guard let uid = UserDefaults.getUid() else {
            completion(.unknown)
            return
        }
        
        let query = K.FirestoreCollections.COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document(notificationId)
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
}

//MARK: - Fetch Operations

extension NotificationService {
    
    /// Fetches the count of new notifications since a specified date for a user.
    /// - Parameters:
    ///   - date: The date to compare against for fetching new notifications.
    ///   - completion: A closure to be called when the fetching is completed.
    ///                 It provides a `Result` enum with either the count of new notifications or an error.
    static func fetchNewNotificationCount(since date: Date?, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        guard let uid = UserDefaults.getUid() else {
            completion(.failure(.unknown))
            return
        }
      
        if let date {
            let timestamp = Timestamp(date: date)
            let newTimestamp = Timestamp(seconds: timestamp.seconds + 1, nanoseconds: timestamp.nanoseconds)
            let query = K.FirestoreCollections.COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true).whereField("timestamp", isGreaterThan: newTimestamp).count
            query.getAggregation(source: .server) { snapshot, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    if let notifications = snapshot?.count {
                        completion(.success(notifications.intValue))

                    } else {
                        completion(.success(0))
                    }
                }
            }
        } else {
            // Used to be order: false; if there's error switch it
            let query = K.FirestoreCollections.COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true).limit(to: 20).count
            query.getAggregation(source: .server) { snapshot, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    if let notifications = snapshot?.count {
                        completion(.success(notifications.intValue))

                    } else {
                        completion(.success(0))
                    }
                }
            }
        }
    }
    
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
        
        guard let uid = UserDefaults.getUid() else {
            completion(.failure(.unknown))
            return
            
        }

        if lastSnapshot == nil {
            let firstGroupToFetch = K.FirestoreCollections.COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true).limit(to: 15)
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
            let nextGroupToFetch = K.FirestoreCollections.COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15)
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
    
    /// Fetches user notifications since the specified date.
    ///
    /// - Parameters:
    ///   - date: An optional parameter representing the date since which notifications are to be fetched.
    ///   - completion: A completion block that is called with the result of the query.
    static func fetchNotifications(since date: Date?, completion: @escaping(Result<[Notification], FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        guard let uid = UserDefaults.getUid() else {
            completion(.failure(.unknown))
            return
            
        }

        if let date {
            let timestamp = Timestamp(date: date)
            let newTimestamp = Timestamp(seconds: timestamp.seconds + 1, nanoseconds: timestamp.nanoseconds)
            let query = K.FirestoreCollections.COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true).whereField("timestamp", isGreaterThan: newTimestamp).limit(to: 20)
            
            query.getDocuments { snapshot, error in
                
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                let notifications = snapshot.documents.map { Notification(dictionary: $0.data() )}
                completion(.success(notifications))
            }
        } else {
            let query = K.FirestoreCollections.COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true).limit(to: 20)
            query.getDocuments { snapshot, error in
                
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                let notifications = snapshot.documents.map { Notification(dictionary: $0.data() )}
                completion(.success(notifications))
            }
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
        guard let uid = UserDefaults.getUid() else { return }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let preferenceRef = K.FirestoreCollections.COLLECTION_NOTIFICATIONS.document(uid)
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
                completion(.success(preferences))
            }
        }
    }
}
