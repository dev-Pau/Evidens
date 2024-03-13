//
//  CommentCaseRepliesViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/10/23.
//

import Foundation
import Firebase

/// The viewModel for a CommentCaseReplies.
class CommentCaseRepliesViewModel {

    var clinicalCase: Case
    var comment: Comment
    var user: User?
    
    var comments = [Comment]()
    var users = [User]()
    
    var firstLoad: Bool = false
    
    var currentNotification: Bool = false
    
    var networkFailure: Bool = false
    
    var path: [String]
    
    var commentLoaded: Bool
    var commentsLoaded: Bool = false
    
    var lastReplySnapshot: QueryDocumentSnapshot?
    
    let needsToFetch: Bool
    
    var caseId: String?
    var uid: String?

    var isFetchingMoreReplies: Bool = false
    
    
    init(path: [String], comment: Comment, user: User? = nil, clinicalCase: Case) {
        self.comment = comment
        self.user = user
        self.clinicalCase = clinicalCase
        self.path = path
        self.commentLoaded = true
        self.needsToFetch = false
    }
    
    init(caseId: String, uid: String, path: [String]) {
        self.caseId = caseId
        self.uid = uid
        self.path = path
        self.commentLoaded = false
        self.needsToFetch = true
        
        self.comment = Comment(dictionary: [:])
        self.clinicalCase = Case(caseId: "", dictionary: [:])
    }
    
    func getReplies(completion: @escaping () -> Void) {
        
        CommentService.fetchRepliesForCaseComment(forClinicalCase: clinicalCase, forPath: path, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.lastReplySnapshot = snapshot.documents.last
                let comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
                let uids = comments.filter { $0.visible == .regular }.map { $0.uid }
                
                let uniqueUids = Array(Set(uids))
                
                CommentService.getCaseCommentValuesFor(forCase: strongSelf.clinicalCase, forPath: strongSelf.path, forComments: comments) { [weak self] replies in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.comments = replies.sorted { $0.timestamp.seconds > $1.timestamp.seconds }
                    
                    
                    guard !uniqueUids.isEmpty else {
                        strongSelf.commentsLoaded = true
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users = users
                        strongSelf.commentsLoaded = true
                        completion()
                    }
                }
                
            case .failure(let error):
                strongSelf.networkFailure = error == .network
                strongSelf.commentsLoaded = true
                completion()
            }
        }
    }
    
    func getContent(completion: @escaping(FirestoreError?) -> Void) {
        guard let caseId = caseId else {
            completion(.unknown)
            return
        }
                       
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        CaseService.getPlainCase(withCaseId: caseId) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let clinicalCase):
                strongSelf.clinicalCase = clinicalCase
                let group = DispatchGroup()
                
                if let uid = strongSelf.uid, uid != "" {
                    group.enter()
                    UserService.fetchUser(withUid: uid) { [weak self] result in
                        guard let strongSelf = self else { return }
                        switch result {
                        case .success(let user):
                            
                            strongSelf.user = user
                            group.leave()
                            
                        case .failure(_):
                            completion(.unknown)
                        }
                    }
                }
                
                group.enter()
                
                CommentService.fetchReply(forCase: clinicalCase, forPath: strongSelf.path) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let comment):
                        strongSelf.comment = comment
                        group.leave()
                        
                    case .failure(_):
                        completion(.unknown)
                    }
                }
                
                group.notify(queue: .main) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.commentLoaded = true
                    completion(nil)
                }
                
            case .failure(_):
                break
            }
        }
    }
    
    func getMoreReplies(completion: @escaping () -> Void) {
        
        guard lastReplySnapshot != nil, !comments.isEmpty, !isFetchingMoreReplies, comment.numberOfComments > comments.count, commentsLoaded else {
            return
        }

        showBottomSpinner()

        CommentService.fetchRepliesForCaseComment(forClinicalCase: clinicalCase, forPath: path, lastSnapshot: lastReplySnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.lastReplySnapshot = snapshot.documents.last
                var comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
                
                let visibleUids = comments.filter { $0.visible == .regular }.map { $0.uid }
                let uniqueUids = Array(Set(visibleUids))

                let currentUserUids = strongSelf.users.map { $0.uid }
                
                let usersToFetch = uniqueUids.filter { !currentUserUids.contains($0) }
                
                CommentService.getCaseCommentValuesFor(forCase: strongSelf.clinicalCase, forPath: strongSelf.path, forComments: comments) { [weak self] newComments in
                    
                    guard let strongSelf = self else { return }
                    comments = newComments
                    comments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    
                    strongSelf.comments.append(contentsOf: comments)
                    
                    
                    guard !usersToFetch.isEmpty else {
                        strongSelf.hideBottomSpinner()
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: usersToFetch) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users.append(contentsOf: users)
                        strongSelf.hideBottomSpinner()
                        completion()
                    }
                }
            case .failure(_):
                strongSelf.hideBottomSpinner()
            }
        }
    }
    
    func addReply(_ comment: String, withCurrentUser currentUser: User, completion: @escaping(Result<Comment, FirestoreError>) -> Void) {
        
        var uidTarget = ""
        
        if let user, let uid = user.uid, uid != "" {
            uidTarget = uid
        }
        
        CommentService.addReply(on: uidTarget, comment, path: path, clinicalCase: clinicalCase, fromUser: currentUser) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                strongSelf.comment.numberOfComments += 1
                
                if comment.visible == .regular {
                    strongSelf.users.append(currentUser)
                }
                
                // If the reply is not from the comment owner, we send a notification to the comment owner
                if strongSelf.comment.uid != comment.uid {
                    
                    var replyPath = strongSelf.path
                    replyPath.append(comment.id)
                    
                    let anonymous = (comment.uid == strongSelf.clinicalCase.uid && strongSelf.clinicalCase.privacy == .anonymous) ? true : false

                    FunctionsManager.shared.addNotificationOnCaseReply(caseId: strongSelf.clinicalCase.caseId, owner: strongSelf.comment.uid, path: replyPath, comment: comment, anonymous: anonymous)
                }
                
                completion(.success(comment))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func editReply(_ comment: String, withId id: String, withCurrentUser currentUser: User, completion: @escaping(FirestoreError?) -> Void) {
        
        if let lastId = path.last {
            
            if lastId == id && lastId == self.comment.id {
                // Editing the top comment. This can either be a comment to the post, or a comment to another reply
                if path.count == 1 {
                    // Comment to a post
                    CommentService.editComment(comment, forId: id, for: clinicalCase) { [weak self] error in
                        guard let _ = self else { return }
                        if let error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    }
                } else {
                    // Comment to another reply
                    CommentService.editReply(comment, forId: id, path: path.dropLast(), clinicalCase: clinicalCase) { [weak self] error in
                        guard let _ = self else { return }
                        if let error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    }
                }
            } else {
                CommentService.editReply(comment, forId: id, path: path, clinicalCase: clinicalCase) { [weak self] error in
                    guard let _ = self else { return }
                    if let error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }
            }
        } else {
            completion(.unknown)
        }
    }
    
    func deleteComment(forId id: String, forPath path: [String], completion: @escaping(FirestoreError?) -> Void) {
        CommentService.deleteComment(forCase: clinicalCase, forPath: path, forCommentId: id) { [weak self] error in
            guard let _ = self else { return }
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}

//MARK: - Miscellaneous

extension CommentCaseRepliesViewModel {
    
    private func showBottomSpinner() {
        isFetchingMoreReplies = true
    }
    
    private func hideBottomSpinner() {
        isFetchingMoreReplies = false
    }
}
