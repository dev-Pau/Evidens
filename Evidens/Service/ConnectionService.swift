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
        
        getConnectionPhase(uid: uid) { connection in
            guard connection.phase == .received else {
                completion(.unknown)
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
    }
    
    static func reject(forUid uid: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let currentUid = UserDefaults.getUid() else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        getConnectionPhase(uid: uid) { connection in
            guard connection.phase == .received else {
                completion(.unknown)
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            let date = Timestamp(date: Date())
            
            let currentConnection = ["phase": ConnectPhase.rejected.rawValue,
                                     "timestamp": date] as [String : Any]
            
            let targetConnection = ["phase": ConnectPhase.rejected.rawValue,
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
                completion(UserConnection(uid: uid))
            } else {
                guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
                    completion(UserConnection(uid: uid))
                    return
                }
                
                let connection = UserConnection(uid: uid, dictionary: data)
                completion(connection)
            }
        }
    }
    
    static func getConnectionPhase(forUsers users: [User], completion: @escaping([User]) -> Void) {
        let group = DispatchGroup()
        
        let uids = users.map { $0.uid! }
        
        var temp = users
        
        for (index, uid) in uids.enumerated() {
            group.enter()
            
            ConnectionService.getConnectionPhase(uid: uid) { connection in
                temp[index].set(connection: connection)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(temp)
        }
    }
}

//MARK: - Fetch Operations

extension ConnectionService {
    
    static func getConnections(forUid uid: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        if lastSnapshot == nil {
            let connections = COLLECTION_CONNECTIONS.document(uid).collection("user-connections").whereField("phase", isEqualTo: ConnectPhase.connected.rawValue).limit(to: 20)

            connections.getDocuments { snapshot, error in
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
            let connections = COLLECTION_CONNECTIONS.document(uid).collection("user-connections").whereField("phase", isEqualTo: ConnectPhase.connected.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
                            
            connections.getDocuments { snapshot, error in
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
}
