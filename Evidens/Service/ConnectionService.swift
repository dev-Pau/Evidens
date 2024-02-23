//
//  ConnectionService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/23.
//

import Foundation
import Firebase

/// A service used to interface with FirebaseFirestore for user connection operations.
struct ConnectionService { }

//MARK: - Write Operations

extension ConnectionService {
    
    /// Establishes a connection between the current user and the specified user with the given UID.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user to establish a connection with.
    ///   - completion: A completion block that is called once the connection is established or an error occurs.
    ///                If successful, the completion is called with a nil parameter. If there's an error, a FirestoreError is provided.
    static func connect(withUid uid: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let currentUid = UserDefaults.getUid() else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let date = Timestamp(date: Date())
        
        let currentConnection = ["phase": ConnectPhase.pending.rawValue,
                              "timestamp": date] as [String : Any]
        
        let targetConnection = ["phase": ConnectPhase.received.rawValue,
                                "timestamp": date] as [String : Any]
        
        let batch = Firestore.firestore().batch()
        
        let currentConnectionsRef = COLLECTION_CONNECTIONS.document(currentUid).collection("user-connections").document(uid)
        let targetConnectionsRef = COLLECTION_CONNECTIONS.document(uid).collection("user-connections").document(currentUid)
        
        batch.setData(currentConnection, forDocument: currentConnectionsRef)
        batch.setData(targetConnection, forDocument: targetConnectionsRef)
        
        batch.commit { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Ends the connection with the specified user, transitioning to the 'unconnected' phase.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user to disconnect from.
    ///   - completion: A completion block that is called once the disconnection is completed or an error occurs.
    ///                If successful, the completion is called with a nil parameter. If there's an error, a FirestoreError is provided.
    static func unconnect(withUid uid: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let currentUid = UserDefaults.getUid() else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let date = Timestamp(date: Date())
        
        let currentConnection = ["phase": ConnectPhase.unconnect.rawValue,
                              "timestamp": date] as [String : Any]
        
        let rejectedConnection = ["phase": ConnectPhase.rejected.rawValue,
                              "timestamp": date] as [String : Any]
        
        let batch = Firestore.firestore().batch()
        
        let currentConnectionRef = COLLECTION_CONNECTIONS.document(currentUid).collection("user-connections").document(uid)
        let rejectedConnectionRef = COLLECTION_CONNECTIONS.document(uid).collection("user-connections").document(currentUid)
        
        batch.setData(currentConnection, forDocument: currentConnectionRef)
        batch.setData(rejectedConnection, forDocument: rejectedConnectionRef)
        
        batch.commit { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Accepts a connection request from the specified user, transitioning to the 'connected' phase.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user whose connection request is being accepted.
    ///   - user: The User object representing the connected user.
    ///   - completion: A completion block that is called once the connection is accepted or an error occurs.
    ///                If successful, the completion is called with a nil parameter. If there's an error, a FirestoreError is provided.
    static func accept(forUid uid: String, user: User, completion: @escaping(FirestoreError?) -> Void) {

        guard let currentUid = UserDefaults.getUid() else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        var errorFlag: Bool = false
        
        var group = DispatchGroup()
        
        
        group.enter()
        UserService.fetchUser(withUid: uid) { result in
            switch result {
                
            case .success(let user):
                if user.phase != .verified {
                    errorFlag = true
                }
            case .failure(_):
                errorFlag = true
            }
            
            group.leave()
        }
        
        group.enter()
        getConnectionPhase(uid: uid) { connection in
            if connection.phase != .received {
                errorFlag = true
            }
            
            group.leave()
        }
        
        group.notify(queue: .main) {
            guard errorFlag == false else {
                completion(.unknown)
                return
            }
            
            let date = Timestamp(date: Date())
            
            let connection = ["phase": ConnectPhase.connected.rawValue,
                              "timestamp": date] as [String : Any]
            
            let batch = Firestore.firestore().batch()
            
            let currentConnectionRef = COLLECTION_CONNECTIONS.document(currentUid).collection("user-connections").document(uid)
            let targetConnectionRef = COLLECTION_CONNECTIONS.document(uid).collection("user-connections").document(currentUid)
            
            batch.setData(connection, forDocument: currentConnectionRef)
            batch.setData(connection, forDocument: targetConnectionRef)
            
            batch.commit { error in
                if let _ = error {
                    completion(.unknown)
                } else {
                    FunctionsManager.shared.addNotificationOnAcceptConnection(user: user, userId: uid)
                    completion(nil)
                }
            }
        }
    }
    
    /// Rejects a connection request from the specified user, transitioning to the 'rejected' phase.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user whose connection request is being rejected.
    ///   - completion: A completion block that is called once the rejection is completed or an error occurs.
    ///                If successful, the completion is called with a nil parameter. If there's an error, a FirestoreError is provided.
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
            
            let date = Timestamp(date: Date())
            
            let currentConnection = ["phase": ConnectPhase.rejected.rawValue,
                                     "timestamp": date] as [String : Any]
            
            let targetConnection = ["phase": ConnectPhase.rejected.rawValue,
                                    "timestamp": date] as [String : Any]
            
            let batch = Firestore.firestore().batch()
            
            let currentConnectionRef = COLLECTION_CONNECTIONS.document(currentUid).collection("user-connections").document(uid)
            let targetConnectionRef = COLLECTION_CONNECTIONS.document(uid).collection("user-connections").document(currentUid)
            
            batch.setData(currentConnection, forDocument: currentConnectionRef)
            batch.setData(targetConnection, forDocument: targetConnectionRef)
            
            batch.commit { error in
                if let _ = error {
                    completion(.unknown)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    /// Withdraws a connection request with the specified user, transitioning to the 'withdrawn' phase.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user from whom the connection request is being withdrawn.
    ///   - completion: A completion block that is called once the withdrawal is completed or an error occurs.
    ///                If successful, the completion is called with a nil parameter. If there's an error, a FirestoreError is provided.
    static func withdraw(forUid uid: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let currentUid = UserDefaults.getUid() else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let date = Timestamp(date: Date())
        
        let currentConnection = ["phase": ConnectPhase.withdraw.rawValue,
                              "timestamp": date] as [String : Any]
        
        let targetConnection = ["phase": ConnectPhase.none.rawValue,
                                "timestamp": date] as [String : Any]
        
        let batch = Firestore.firestore().batch()
        
        let currentConnectionRef = COLLECTION_CONNECTIONS.document(currentUid).collection("user-connections").document(uid)
        let targetConnectionRef = COLLECTION_CONNECTIONS.document(uid).collection("user-connections").document(currentUid)
        
        batch.setData(currentConnection, forDocument: currentConnectionRef)
        batch.setData(targetConnection, forDocument: targetConnectionRef)
        
        batch.commit { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
}

//MARK: - Miscellaneous

extension ConnectionService {
    
    /// Retrieves the connection phase with the specified user.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user for whom the connection phase is queried.
    ///   - completion: A completion block that is called with the UserConnection object containing the connection phase information.
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
    
    /// Retrieves the connection phase for a list of users.
    ///
    /// - Parameters:
    ///   - users: An array of User objects for whom the connection phases are queried.
    ///   - completion: A completion block that is called with the updated array of User objects containing the connection phase information.
    ///
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
    
    /// Retrieves the connected users for the specified user.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user for whom connected users are queried.
    ///   - lastSnapshot: An optional parameter representing the last document snapshot in case of paginated results.
    ///   - completion: A completion block that is called with the result of the query.
    static func getConnections(forUid uid: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        if lastSnapshot == nil {
            let connections = COLLECTION_CONNECTIONS.document(uid).collection("user-connections").whereField("phase", isEqualTo: ConnectPhase.connected.rawValue).limit(to: 15)

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
