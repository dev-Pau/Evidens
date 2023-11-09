//
//  FunctionsManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/9/23.
//

import Foundation
import FirebaseFunctions
import Firebase

class FunctionsManager {
    static let shared = FunctionsManager()
    
    private lazy var functions = Functions.functions()

    func addNotificationOnPostReply(postId: String, owner: String, path: [String], comment: Comment) {
        let addFunction = functions.httpsCallable("addNotificationOnPostReply")
        
        let reply: [String: Any] = [
            "postId": postId,
            "path": path,
            "timestamp": comment.timestamp.seconds,
            "uid": comment.uid,
            "id": comment.id,
            "owner": owner
        ]
        
        addFunction.call(reply) { result, error in

        }
    }
    
    func addNotificationOnPostLikeReply(postId: String, owner: String, path: [String], commentId: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeFunction = functions.httpsCallable("addNotificationOnPostLikeReply")
        
        let like: [String: Any] = [
            "postId": postId,
            "path": path,
            "timestamp": Timestamp(date: .now).seconds,
            "uid": uid,
            "id": commentId,
            "owner": owner
        ]

        likeFunction.call(like) { result, error in

        }
    }

    func addNotificationOnCaseReply(caseId: String, owner: String, path: [String], comment: Comment, anonymous: Bool) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let addFunction = functions.httpsCallable("addNotificationOnCaseReply")
        
        var reply: [String: Any] = [
            "caseId": caseId,
            "path": path,
            "timestamp": comment.timestamp.seconds,
            "id": comment.id,
            "owner": owner,
        ]
        
        if !anonymous {
            reply["uid"] = uid
        }
        
        addFunction.call(reply) { result, error in

        }
    }
    
    func addNotificationOnCaseLikeReply(caseId: String, owner: String, path: [String], commentId: String, anonymous: Bool) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeFunction = functions.httpsCallable("addNotificationOnCaseLikeReply")
        
        var like: [String: Any] = [
            "caseId": caseId,
            "path": path,
            "timestamp": Timestamp(date: .now).seconds,
            "id": commentId,
            "owner": owner
        ]
        
        if !anonymous {
            like["uid"] = uid
        }

        likeFunction.call(like) { result, error in

        }
    }
    
    func addNotificationOnAcceptConnection(user: User, userId: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let connectionFunction = functions.httpsCallable("addNotificationOnAcceptConnection")
        
        let connection: [String: Any] = [
            "uid": uid,
            "userId": userId,
            "name": user.name()
        ]
        
        connectionFunction.call(connection) { result, error in
            
        }
    }
}
