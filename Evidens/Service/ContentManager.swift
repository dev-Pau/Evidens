//
//  ContentChangesManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/8/23.
//

import Foundation

class ContentManager {
    
    static let shared = ContentManager()
    
    private var likeDebounceTimers: [String: DispatchWorkItem] = [:]
    private var likeValues: [String: Bool] = [:]
    
    private var bookmarkDebounceTimers: [String: DispatchWorkItem] = [:]
    private var bookmarkValues: [String: Bool] = [:]
    
}

extension ContentManager {
    
    func likePostChange(postId: String, didLike: Bool) {
        let postChange = PostLikeChange(postId: postId, didLike: didLike)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postLike), object: postChange)
    
        // Cancel the previous debounce timer for this post, if any
        if let debounceTimer = likeDebounceTimers[postId] {
            debounceTimer.cancel()
        }
        
        // Store the initial like state and count
        if likeValues[postId] == nil {
            likeValues[postId] = !didLike
            //likePostCount[postId] = post.likes
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let likeValue = strongSelf.likeValues[postId] else { return }//, let countValue = strongSelf.likePostCount[indexPath] else {

            // Prevent any database action if the value remains unchanged
            if didLike == likeValue {
                strongSelf.likeValues[postId] = nil
                strongSelf.likeValues[postId] = nil
                return
            }

            if didLike {
                PostService.likePost(withId: postId) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        let postChange = PostLikeChange(postId: postId, didLike: likeValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postLike), object: postChange)
                    }
                    
                    strongSelf.likeValues[postId] = nil
                    strongSelf.likeValues[postId] = nil
                }

            } else {
                
                PostService.unlikePost(withId: postId) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    // Revert to the previous like state and count if there's an error
                    if let _ = error {
                        let postChange = PostLikeChange(postId: postId, didLike: likeValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postLike), object: postChange)
                    }
                    
                    strongSelf.likeValues[postId] = nil
                    strongSelf.likeValues[postId] = nil
                }
            }
            
            // Clean up the debounce timer
            strongSelf.likeDebounceTimers[postId] = nil
        }
        
        // Save the debounce timer
        likeDebounceTimers[postId] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)

    }
    
    func bookmarkPostChange(postId: String, didBookmark: Bool) {
        let postChange = PostBookmarkChange(postId: postId, didBookmark: didBookmark)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postBookmark), object: postChange)
        
        // Cancel the previous debounce timer for this post, if any
        if let debounceTimer = bookmarkDebounceTimers[postId] {
            debounceTimer.cancel()
        }
        
        // Store the initial like state and count
        if bookmarkValues[postId] == nil {
            bookmarkValues[postId] = !didBookmark
            //likePostCount[postId] = post.likes
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let bookmarkValue = strongSelf.bookmarkValues[postId] else { return }//, let countValue = strongSelf.likePostCount[indexPath] else {

            // Prevent any database action if the value remains unchanged
            if didBookmark == bookmarkValue {

                strongSelf.bookmarkValues[postId] = nil
                return
            }

            if didBookmark {

                PostService.bookmarkPost(withId: postId) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        let postChange = PostLikeChange(postId: postId, didLike: bookmarkValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postBookmark), object: postChange)
                    }
                    
                    strongSelf.bookmarkValues[postId] = nil

                }

            } else {
                PostService.unbookmarkPost(withId: postId) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    // Revert to the previous like state and count if there's an error
                    if let _ = error {
                        let postChange = PostLikeChange(postId: postId, didLike: bookmarkValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postBookmark), object: postChange)
                    }
                    
                    strongSelf.bookmarkValues[postId] = nil

                }
            }
            
            // Clean up the debounce timer
            strongSelf.bookmarkDebounceTimers[postId] = nil
        }
        
        // Save the debounce timer
        bookmarkDebounceTimers[postId] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
    
    func commentPostChange(postId: String, comment: Comment, action: CommentAction) {
        let postChange = PostCommentChange(postId: postId, comment: comment, action: action)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postComment), object: postChange)
    }
    
    func editPostChange(post: Post) {
        let postChange = PostEditChange(post: post)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postEdit), object: postChange)
    }
}

extension ContentManager {
    
    func likeCommentPostChange(postId: String, commentId: String, didLike: Bool) {
        let commentChange = PostCommentLikeChange(postId: postId, commentId: commentId, didLike: didLike)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postCommentLike), object: commentChange)
     
        if let debounceTimer = likeDebounceTimers[commentId] {
            debounceTimer.cancel()
        }
        
        if likeValues[commentId] == nil {
            likeValues[commentId] = !didLike
            //likePostCount[postId] = post.likes
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let likeValue = strongSelf.likeValues[commentId] else { return }

            // Prevent any database action if the value remains unchanged
            if didLike == likeValue {
                strongSelf.likeValues[commentId] = nil
                strongSelf.likeValues[commentId] = nil
                return
            }

            if didLike {
                
                CommentService.likePostComment(forId: postId, forCommentId: commentId) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        let commentChange = PostCommentLikeChange(postId: postId, commentId: commentId, didLike: likeValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postCommentLike), object: commentChange)
                    }
                    
                    strongSelf.likeValues[commentId] = nil
                    strongSelf.likeValues[commentId] = nil
                }

            } else {
                
                CommentService.unlikePostComment(forId: postId, forCommentId: commentId) { [weak self] error in
                    guard let strongSelf = self else { return }

                    if let _ = error {
                        let commentChange = PostCommentLikeChange(postId: postId, commentId: commentId, didLike: likeValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postCommentLike), object: commentChange)
                    }
                    
                    strongSelf.likeValues[commentId] = nil
                    strongSelf.likeValues[commentId] = nil
                }
            }
            
            // Clean up the debounce timer
            strongSelf.likeDebounceTimers[commentId] = nil
        }
        
        // Save the debounce timer
        likeDebounceTimers[commentId] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
    
    func likeReplyPostChange(postId: String, commentId: String, replyId: String, didLike: Bool) {
        let replyChange = PostReplyLikeChange(postId: postId, commentId: commentId, replyId: replyId, didLike: didLike)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postReplyLike), object: replyChange)
     
        if let debounceTimer = likeDebounceTimers[commentId] {
            debounceTimer.cancel()
        }
        
        if likeValues[replyId] == nil {
            likeValues[replyId] = !didLike
            //likePostCount[postId] = post.likes
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let likeValue = strongSelf.likeValues[replyId] else { return }

            // Prevent any database action if the value remains unchanged
            if didLike == likeValue {
                strongSelf.likeValues[replyId] = nil
                strongSelf.likeValues[replyId] = nil
                return
            }

            if didLike {
                
                CommentService.likePostReply(forId: postId, forCommentId: commentId, forReplyId: replyId) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        let replyChange = PostReplyLikeChange(postId: postId, commentId: commentId, replyId: replyId, didLike: likeValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postReplyLike), object: replyChange)
                    }
                    
                    strongSelf.likeValues[replyId] = nil
                    strongSelf.likeValues[replyId] = nil
                }

            } else {
                
                CommentService.unlikePostReply(forId: postId, forCommentId: commentId, forReplyId: replyId) { [weak self] error in
                    guard let strongSelf = self else { return }

                    if let _ = error {
                        
                        let replyChange = PostReplyLikeChange(postId: postId, commentId: commentId, replyId: replyId, didLike: likeValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postReplyLike), object: replyChange)
                    }
                    
                    strongSelf.likeValues[replyId] = nil
                    strongSelf.likeValues[replyId] = nil
                }
            }
            
            // Clean up the debounce timer
            strongSelf.likeDebounceTimers[replyId] = nil
        }
        
        // Save the debounce timer
        likeDebounceTimers[replyId] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
    
    func replyPostChange(postId: String, commentId: String, reply: Comment, action: CommentAction) {
        let replyChange = PostReplyChange(postId: postId, commentId: commentId, reply: reply, action: action)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postReply), object: replyChange)
    }
}

extension ContentManager {
    
}

