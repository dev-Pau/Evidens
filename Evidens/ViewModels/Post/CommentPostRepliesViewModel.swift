//
//  CommentPostRepliesViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/10/23.
//

import Foundation
import Firebase

/// The viewModel for a CommentPostReplies.
class CommentPostRepliesViewModel {
    var post: Post
    var comment: Comment
    var user: User
    
    var postId: String?
    var uid: String?
    
    var path: [String]
    let needsToFetch: Bool
    
    var firstLoad: Bool = false
    
    var comments = [Comment]()
    var users = [User]()
    
    var currentNotification: Bool = false

    var commentLoaded: Bool
    var commentsLoaded: Bool = false
    
    var networkFailure: Bool = false
    
    var lastReplySnapshot: QueryDocumentSnapshot?

    var isFetchingMoreReplies: Bool = false
    
    init(path: [String], comment: Comment, user: User, post: Post) {
        self.comment = comment
        self.user = user
        self.post = post
        self.path = path
        self.commentLoaded = true
        self.needsToFetch = false
    }
    
    init(postId: String, uid: String, path: [String]) {
        self.postId = postId
        self.uid = uid
        self.path = path
        self.commentLoaded = false
        self.needsToFetch = true
        
        self.user = User(dictionary: [:])
        self.comment = Comment(dictionary: [:])
        self.post = Post(postId: "", dictionary: [:])
    }
    
    
    func getReplies(completion: @escaping() -> Void) {
        
        CommentService.fetchRepliesForPostComment(forPost: post, forPath: path, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
                
            case .success(let snapshot):
                strongSelf.lastReplySnapshot = snapshot.documents.last
                let comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
                let replyUids = Array(Set(comments.map { $0.uid } ))
                
                CommentService.getPostCommentsValuesFor(forPost: strongSelf.post, forPath: strongSelf.path, forComments: comments) { [weak self] comments in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.comments = comments.sorted { $0.timestamp.seconds > $1.timestamp.seconds }
                    
                    UserService.fetchUsers(withUids: replyUids) { [weak self] users in
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
        
        guard let postId = postId, let uid = uid else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        PostService.getPlainPost(withPostId: postId) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let post):
                strongSelf.post = post
                let group = DispatchGroup()
                
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
                
                group.enter()

                CommentService.fetchReply(forPost: post, forPath: strongSelf.path) { [weak self] result in
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
                    guard let _ = self else { return }
                    strongSelf.commentLoaded = true
                    completion(nil)
                }
            case .failure(_):
                break
            }
        }
    }
    
    func getMoreComments(completion: @escaping () -> Void) {
        
        guard lastReplySnapshot != nil, !comments.isEmpty, !isFetchingMoreReplies, comment.numberOfComments > comments.count, commentsLoaded else {
            return
        }
        
        showBottomSpinner()
        
        CommentService.fetchRepliesForPostComment(forPost: post, forPath: path, lastSnapshot: lastReplySnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.lastReplySnapshot = snapshot.documents.last
                var comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
                
                let replyUids = Array(Set(comments.map { $0.uid } ))

                let currentUserUids = strongSelf.users.map { $0.uid }
                
                let usersToFetch = replyUids.filter { !currentUserUids.contains($0) }
                
                CommentService.getPostCommentsValuesFor(forPost: strongSelf.post, forPath: strongSelf.path, forComments: comments) { [weak self] newComments in
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

        CommentService.addReply(on: user.uid ?? "", comment, path: path, post: post) { [weak self] result in
    
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let comment):
                strongSelf.comment.numberOfComments += 1
                strongSelf.users.append(currentUser)
                
                // If the reply is not from the comment owner, we send a notification to the comment owner
                if strongSelf.comment.uid != comment.uid {
                    
                    var replyPath = strongSelf.path
                    replyPath.append(comment.id)
                    
                    FunctionsManager.shared.addNotificationOnPostReply(postId: strongSelf.post.postId, owner: strongSelf.comment.uid, path: replyPath, comment: comment)
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
                    CommentService.editComment(comment, forId: id, for: post) { [weak self] error in
                        guard let _ = self else { return }
                        if let error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    }
                } else {
                    // Comment to another reply
                    CommentService.editReply(comment, forId: id, path: path.dropLast(), post: post) { [weak self] error in
                        guard let _ = self else { return }
                        if let error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    }
                }
            } else {
                CommentService.editReply(comment, forId: id, path: path, post: post) { [weak self] error in
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
        CommentService.deleteComment(forPost: post, forPath: path, forCommentId: id) { [weak self] error in
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
extension CommentPostRepliesViewModel {
    
    private func showBottomSpinner() {
        isFetchingMoreReplies = true
    }
    
    private func hideBottomSpinner() {
        isFetchingMoreReplies = false
    }
}
