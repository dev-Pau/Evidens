//
//  FunctionsManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/9/23.
//

import Foundation
import FirebaseFunctions

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
        
        print("add cloud function")
        addFunction.call(reply) { result, error in
            print(result)
            print(error)
        }
    }
    
    func addNotificationOnCaseReply(caseId: String, owner: String? = nil, path: [String], comment: Comment) {
        let addFunction = functions.httpsCallable("addNotificationOnPostReply")
        
        let reply: [String: Any] = [
            "caseId": caseId,
            "path": path,
            "timestamp": comment.timestamp.seconds,
            "uid": comment.uid,
            "id": comment.id,
            "owner": owner
        ]
        
        print("add cloud function")
        addFunction.call(reply) { result, error in
            print(result)
            print(error)
        }
    }
}

/*
 commentId: commentId,
       contentId: postId,
       kind: kind,
       timestamp: commentTimestamp,
       uid: userId,
 */
