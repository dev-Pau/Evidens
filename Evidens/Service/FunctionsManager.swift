//
//  FunctionsManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/9/23.
//

import Foundation
import FirebaseFunctions
import Firebase

/// A class that interfaces with Firebase Cloud Functions.
class FunctionsManager {
    
    static let shared = FunctionsManager()
    
    private lazy var functions = Functions.functions()

    /// Sends a notification to the server when a user receives a reply on their post.
    ///
    /// - Parameters:
    ///   - postId: The ID of the post that received the reply.
    ///   - owner: The UID of the owner of the post.
    ///   - path: The path to the comment in the post's comment thread.
    ///   - comment: The comment object representing the reply.
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
    
    /// Sends a notification to the server when a user receives a like on their post reply.
    ///
    /// - Parameters:
    ///   - postId: The ID of the post that received the like.
    ///   - owner: The UID of the owner of the post.
    ///   - path: The path to the comment in the post's comment thread.
    ///   - commentId: The ID of the comment that received the like.
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
    
    /// Sends a notification to the server when a user receives a reply on their clinical case.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the clinical case that received the reply.
    ///   - owner: The UID of the owner of the clinical case.
    ///   - path: The path to the comment in the clinical case's comment thread.
    ///   - comment: The comment that was posted as a reply.
    ///   - anonymous: A boolean indicating whether the reply is anonymous or not.
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
    
    /// Sends a notification to the server when a user receives a like on a comment in their clinical case.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the clinical case.
    ///   - owner: The UID of the owner of the clinical case.
    ///   - path: The path to the comment in the clinical case's comment thread.
    ///   - commentId: The ID of the comment that received the like.
    ///   - anonymous: A boolean indicating whether the like is anonymous or not.
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
    
    /// Sends a notification to the server when a connection request is accepted by a user.
    ///
    /// - Parameters:
    ///   - user: The user object representing the user who accepted the connection request.
    ///   - userId: The UID of the user whose connection request was accepted.
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
