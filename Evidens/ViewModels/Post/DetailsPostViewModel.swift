//
//  DetailsPostViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/10/23.
//

import UIKit
import Firebase

/// The viewModel for a DetailsPost.
class DetailsPostViewModel {
    
    private(set) var postLoaded: Bool
    var selectedImage: UIImageView!

    var commentsLastSnapshot: QueryDocumentSnapshot?
    var commentsLoaded: Bool = false
    
    
    var previewingController: Bool = false
    
    var post: Post
    var user: User
    var postId: String?
    
    var networkFailure: Bool = false
    
    var currentNotification: Bool = false
    
    var isFetchingMoreComments: Bool = false
    
    var comments = [Comment]()
    var users = [User]()
    
    init(post: Post, user: User) {
        self.post = post
        self.user = user
        self.postLoaded = true
    }
    
    init(postId: String) {
        self.post = Post(postId: "", dictionary: [:])
        self.user = User(dictionary: [:])
        self.postId = postId
        self.postLoaded = false
    }
    
    func fetchPost(completion: @escaping(FirestoreError?) -> Void) {
        guard let postId = postId else {
            completion(.unknown)
            return
        }

        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        PostService.fetchPost(withPostId: postId) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let post):
                strongSelf.post = post
                let uid = post.uid
                
                UserService.fetchUser(withUid: uid) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                        
                    case .success(let user):
                        strongSelf.user = user
                        strongSelf.postLoaded = true
                        completion(nil)
                    case .failure(_):
                        break
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    func getComments(completion: @escaping () -> Void) {
        CommentService.fetchPostComments(forPost: post, forPath: [], lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.commentsLastSnapshot = snapshot.documents.last
                strongSelf.comments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
                
                CommentService.getPostCommentsValuesFor(forPost: strongSelf.post, forPath: [], forComments: strongSelf.comments) { [weak self] fetchedComments in
                    guard let strongSelf = self else { return }
                    strongSelf.comments = fetchedComments
                    
                    let uids = strongSelf.comments.map { $0.uid }
                    
                    strongSelf.comments.enumerated().forEach { [weak self] index, comment in
                        guard let strongSelf = self else { return }
                        strongSelf.comments[index].isAuthor = comment.uid == strongSelf.post.uid
                    }
                    
                    strongSelf.comments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    
                    UserService.fetchUsers(withUids: uids) { [weak self] users in
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
    
    func getMoreComments(completion: @escaping () -> Void) {
        
        guard commentsLastSnapshot != nil, !comments.isEmpty, !isFetchingMoreComments, commentsLoaded else { return }

        isFetchingMoreComments = true
        
        CommentService.fetchPostComments(forPost: post, forPath: [], lastSnapshot: commentsLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):
                strongSelf.commentsLastSnapshot = snapshot.documents.last
                
                var newComments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
                
                CommentService.getPostCommentsValuesFor(forPost: strongSelf.post, forPath: [], forComments: newComments) { [weak self] fetchedComments in
                    guard let strongSelf = self else { return }
                    
                    newComments = fetchedComments
                    newComments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    strongSelf.comments.append(contentsOf: newComments)
                    let newUserUids = newComments.map { $0.uid }
                    let currentUserUids = strongSelf.users.map { $0.uid }
                    let usersToFetch = newUserUids.filter { !currentUserUids.contains($0) }
                    
                    guard !usersToFetch.isEmpty else {
                        strongSelf.isFetchingMoreComments = false
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: usersToFetch) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users.append(contentsOf: users)
                        strongSelf.isFetchingMoreComments = false
                        completion()
                    }
                }
                
            case.failure(_):
                strongSelf.isFetchingMoreComments = false
                break
            }
        }
    }
    
    func deletePost(forId id: String, completion: @escaping(FirestoreError?) -> Void) {
        PostService.deletePost(withId: id) { [weak self] error in

            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                strongSelf.post.visible = .deleted
                completion(nil)
            }
        }
    }
    
    func deleteComment(forPath path: [String], forCommentId id: String, completion: @escaping(FirestoreError?) -> Void) {
        CommentService.deleteComment(forPost: post, forPath: path, forCommentId: id) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
               
                if let index = strongSelf.comments.firstIndex(where: { $0.id == id }) {
                    strongSelf.comments[index].visible = .deleted
                    strongSelf.post.numberOfComments -= 1
                    completion(nil)
                } else {
                    completion(.unknown)
                }
            }
        }
    }
    
    func addComment(_ comment: String, from currentUser: User, completion: @escaping(Result<Comment, FirestoreError>) -> Void) {
        CommentService.addComment(comment, for: post) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                
                strongSelf.post.numberOfComments += 1
                
                strongSelf.users.append(currentUser)
                completion(.success(comment))
            
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
