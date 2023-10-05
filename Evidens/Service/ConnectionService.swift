//
//  ConnectionService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/23.
//

import Foundation
import Firebase

struct ConnectionService {
    
    static func connect(withUid uid: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let currentUid = UserDefaults.getUid() else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        let date = Timestamp(date: Date())
        
        let currentConnection = ["phase": ConnectPhase.pending.rawValue,
                              "timestamp": date] as [String : Any]
        
        let targetConnection = ["phase": ConnectPhase.received.rawValue,
                                "timestamp": date] as [String : Any]
        
        var errorFlag = false
        
        dispatchGroup.enter()
        COLLECTION_CONNECTIONS.document(currentUid).collection("user-connections").document(uid).setData(currentConnection) { error in
            if let _ = error {
                errorFlag = true
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        COLLECTION_CONNECTIONS.document(uid).collection("user-connections").document(currentUid).setData(targetConnection) { error in
            if let _ = error {
                errorFlag = true
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if errorFlag {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    static func unconnect(withUid uid: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let currentUid = UserDefaults.getUid() else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        let date = Timestamp(date: Date())
        
        let currentConnection = ["phase": ConnectPhase.unconnect.rawValue,
                              "timestamp": date] as [String : Any]
        
        let rejectedConnection = ["phase": ConnectPhase.rejected.rawValue,
                              "timestamp": date] as [String : Any]
        
        var errorFlag = false
        
        dispatchGroup.enter()
        COLLECTION_CONNECTIONS.document(currentUid).collection("user-connections").document(uid).setData(currentConnection) { error in
            if let _ = error {
                errorFlag = true
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        COLLECTION_CONNECTIONS.document(uid).collection("user-connections").document(currentUid).setData(rejectedConnection) { error in
            if let _ = error {
                errorFlag = true
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if errorFlag {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    static func accept(forUid uid: String, user: User, completion: @escaping(FirestoreError?) -> Void) {

        guard let currentUid = UserDefaults.getUid() else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        let date = Timestamp(date: Date())
        
        let connection = ["phase": ConnectPhase.connected.rawValue,
                          "timestamp": date] as [String : Any]
        
        var errorFlag = false
        
        dispatchGroup.enter()
        COLLECTION_CONNECTIONS.document(currentUid).collection("user-connections").document(uid).setData(connection) { error in
            if let _ = error {
                errorFlag = true
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        COLLECTION_CONNECTIONS.document(uid).collection("user-connections").document(currentUid).setData(connection) { error in
            if let _ = error {
                errorFlag = true
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if errorFlag {
                completion(.unknown)
            } else {
                FunctionsManager.shared.addNotificationOnAcceptConnection(user: user, userId: uid)
                completion(nil)
            }
        }
    }
    
    static func reject(forUid uid: String, completion: @escaping(FirestoreError?) -> Void) {
        
    }
    
    static func withdraw(forUid uid: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let currentUid = UserDefaults.getUid() else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        let date = Timestamp(date: Date())
        
        let currentConnection = ["phase": ConnectPhase.withdraw.rawValue,
                              "timestamp": date] as [String : Any]
        
        let targetConnection = ["phase": ConnectPhase.none.rawValue,
                                "timestamp": date] as [String : Any]
        
        var errorFlag = false
        
        dispatchGroup.enter()
        COLLECTION_CONNECTIONS.document(currentUid).collection("user-connections").document(uid).setData(currentConnection) { error in
            if let _ = error {
                errorFlag = true
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        COLLECTION_CONNECTIONS.document(uid).collection("user-connections").document(currentUid).setData(targetConnection) { error in
            if let _ = error {
                errorFlag = true
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if errorFlag {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
}

//MARK: - Miscellaneous

extension ConnectionService {
    
    static func getConnectionPhase(uid: String, completion: @escaping(UserConnection) -> Void) {
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        COLLECTION_CONNECTIONS.document(currentUid).collection("user-connections").document(uid).getDocument { snapshot, error in
            if let _ = error {
                completion(UserConnection())
            } else {
                guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
                    completion(UserConnection())
                    return
                }
                
                let connection = UserConnection(dictionary: data)
                completion(connection)
            }
        }
    }
}
