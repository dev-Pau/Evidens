//
//  BlockService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/3/24.
//

import Firebase

struct BlockService { }

extension BlockService {
    
    static func block(user: User, completion: @escaping(FirestoreError?) -> Void) {
        guard let currentUid = UserDefaults.getUid(), let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let batch = Firestore.firestore().batch()
        
        let timestamp = Timestamp(date: Date())
        
        let currentBlockData: [String: Any] = [
            "phase": BlockPhase.block.rawValue,
            "timestamp": timestamp
        ]
        
        let targetBlockData: [String: Any] = [
            "phase": BlockPhase.blocked.rawValue,
            "timestamp": timestamp
        ]
        
        let connectionData: [String: Any] = [
            "phase": ConnectPhase.unconnect.rawValue,
            "timestamp": timestamp
        ]
        
        let currentUserBlockRef = COLLECTION_BLOCKS.document(currentUid).collection("user-blocks").document(uid)
        let targetBlockRef = COLLECTION_BLOCKS.document(uid).collection("user-blocks").document(currentUid)
        
        let currentConnectionRef = COLLECTION_CONNECTIONS.document(currentUid).collection("user-connections").document(uid)
        let targetConnectionRef = COLLECTION_CONNECTIONS.document(uid).collection("user-connections").document(currentUid)

        let currentFollowerRef = COLLECTION_FOLLOWERS.document(currentUid).collection("user-followers").document(uid)
        let currentFollowingRef = COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid)
        
        let targetFollowerRef = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid)
        let targetFollowingRef = COLLECTION_FOLLOWING.document(uid).collection("user-following").document(currentUid)
        
        batch.setData(currentBlockData, forDocument: currentUserBlockRef)
        batch.setData(targetBlockData, forDocument: targetBlockRef)
        
        batch.setData(connectionData, forDocument: currentConnectionRef)
        batch.setData(connectionData, forDocument: targetConnectionRef)
        
        batch.deleteDocument(currentFollowerRef)
        batch.deleteDocument(currentFollowingRef)
        
        batch.deleteDocument(targetFollowerRef)
        batch.deleteDocument(targetFollowingRef)
        
        batch.commit { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    static func unblock(user: User, completion: @escaping(FirestoreError?) -> Void) {
        guard let currentUid = UserDefaults.getUid(), let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        
        let batch = Firestore.firestore().batch()

        let currentUserBlockRef = COLLECTION_BLOCKS.document(currentUid).collection("user-blocks").document(uid)
        let targetBlockRef = COLLECTION_BLOCKS.document(uid).collection("user-blocks").document(currentUid)
        
        batch.deleteDocument(currentUserBlockRef)
        batch.deleteDocument(targetBlockRef)
        
        batch.commit { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    static func getBlockPhase(forUserId uid: String, completion: @escaping(Result<BlockPhase?, FirestoreError>) -> Void) {
        
        guard let currentUid = UserDefaults.getUid() else {
            completion(.failure(.unknown))
            return
        }
        
        let ref = COLLECTION_BLOCKS.document(currentUid).collection("user-blocks").document(uid)
        ref.getDocument { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
                return
            } else {
                if let snapshot, let data = snapshot.data(), !data.isEmpty {
                    if let phase = data["phase"] as? Int {
                        let blockPhase = BlockPhase(rawValue: phase)
                        completion(.success(blockPhase))
                    } else {
                        completion(.failure(.unknown))
                    }
                    
                } else {
                    completion(.success(nil))
                }
            }
        }
    }
    
    static func getBlockUsers(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }

        guard let uid = UserDefaults.getUid() else { return }
        
        if lastSnapshot == nil {
            let ref = COLLECTION_BLOCKS.document(uid).collection("user-blocks").whereField("phase", isEqualTo: BlockPhase.block.rawValue).order(by: "timestamp", descending: true).limit(to: 15)
            ref.getDocuments { snapshot, error in
                
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                    return
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
            let ref = COLLECTION_BLOCKS.document(uid).collection("user-blocks").whereField("phase", isEqualTo: BlockPhase.block.rawValue).order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15)
              
            ref.getDocuments { snapshot, error in
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                    return
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
