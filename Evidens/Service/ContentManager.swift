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
    
    /// Handles the change of liking status for a post and manages debouncing to prevent rapid consecutive interactions.
    ///
    /// - Parameters:
    ///   - postId: The ID of the post being interacted with.
    ///   - didLike: A Boolean value indicating whether the post is being liked (true) or unliked (false).
    func likePostChange(postId: String, didLike: Bool) {
        let postChange = PostLikeChange(postId: postId, didLike: didLike)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postLike), object: postChange)

        if let debounceTimer = likeDebounceTimers[postId] {
            debounceTimer.cancel()
        }

        if likeValues[postId] == nil {
            likeValues[postId] = !didLike

        }

        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let likeValue = strongSelf.likeValues[postId] else { return }

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

                    if let _ = error {
                        let postChange = PostLikeChange(postId: postId, didLike: likeValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postLike), object: postChange)
                    }
                    
                    strongSelf.likeValues[postId] = nil
                    strongSelf.likeValues[postId] = nil
                }
            }

            strongSelf.likeDebounceTimers[postId] = nil
        }

        likeDebounceTimers[postId] = debounceTimer

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
    
    /// Handles the change of bookmarking status for a post.
    ///
    /// - Parameters:
    ///   - postId: The ID of the post being interacted with.
    ///   - didBookmark: A Boolean value indicating whether the post is being bookmarked (true) or unbookmarked (false).
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
    
    /// Handles the change of comment action for a post.
    ///
    /// - Parameters:
    ///   - postId: The ID of the post being interacted with.
    ///   - comment: The comment associated with the action.
    ///   - action: The type of comment action (e.g., add, edit, delete).
    func commentPostChange(postId: String, path: [String], comment: Comment, action: CommentAction) {
        let postChange = PostCommentChange(postId: postId, path: path, comment: comment, action: action)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postComment), object: postChange)
    }
    
    /// Notifies observers about the edit of a post.
    ///
    /// - Parameter post: The edited post.
    func editPostChange(post: Post) {
        let postChange = PostEditChange(post: post)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postEdit), object: postChange)
    }
    
    func visiblePostChange(postId: String) {
        let postChange = PostVisibleChange(postId: postId)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postVisibility), object: postChange)

    }
}

extension ContentManager {
    
    /// Notifies observers about a like/unlike action on a comment of a post.
    ///
    /// - Parameters:
    ///   - postId: The ID of the post containing the comment.
    ///   - commentId: The ID of the comment.
    ///   - didLike: A boolean indicating whether the comment was liked (true) or unliked (false).
    func likeCommentPostChange(postId: String, path: [String], commentId: String, owner: String, didLike: Bool) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let commentChange = PostCommentLikeChange(postId: postId, commentId: commentId, didLike: didLike)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postCommentLike), object: commentChange)

        if let debounceTimer = likeDebounceTimers[commentId] {
            debounceTimer.cancel()
        }
        
        if likeValues[commentId] == nil {
            likeValues[commentId] = !didLike
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
                
                CommentService.likePostComment(forId: postId, forPath: path, forCommentId: commentId) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        let commentChange = PostCommentLikeChange(postId: postId, commentId: commentId, didLike: likeValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postCommentLike), object: commentChange)
                    } else {
                        if path.count >= 1 && uid != owner {
                            if uid != owner {
                                FunctionsManager.shared.addNotificationOnPostLikeReply(postId: postId, owner: owner, path: path, commentId: commentId)
                            }
                        }
                    }
                    
                    strongSelf.likeValues[commentId] = nil
                    strongSelf.likeValues[commentId] = nil
                }

            } else {
                
                CommentService.unlikePostComment(forId: postId, forPath: path, forCommentId: commentId) { [weak self] error in
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
    
}

extension ContentManager {
    
    /// Notifies observers about a change in the like status of a case.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the case.
    ///   - didLike: A boolean indicating whether the user liked or unliked the case.
    func likeCaseChange(caseId: String, didLike: Bool) {
        let caseChange = CaseLikeChange(caseId: caseId, didLike: didLike)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.caseLike), object: caseChange)

        if let debounceTimer = likeDebounceTimers[caseId] {
            debounceTimer.cancel()
        }

        if likeValues[caseId] == nil {
            likeValues[caseId] = !didLike
        }

        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let likeValue = strongSelf.likeValues[caseId] else { return }

            if didLike == likeValue {
                strongSelf.likeValues[caseId] = nil
                strongSelf.likeValues[caseId] = nil
                return
            }

            if didLike {
                CaseService.likeCase(withId: caseId) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        let caseChange = CaseLikeChange(caseId: caseId, didLike: didLike)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.caseLike), object: caseChange)
                    }
                    
                    strongSelf.likeValues[caseId] = nil
                    strongSelf.likeValues[caseId] = nil
                }

            } else {
                
                CaseService.unlikeCase(withId: caseId) { [weak self] error in
                    guard let strongSelf = self else { return }

                    if let _ = error {
                        let caseChange = CaseLikeChange(caseId: caseId, didLike: didLike)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.caseLike), object: caseChange)
                    }
                    
                    strongSelf.likeValues[caseId] = nil
                    strongSelf.likeValues[caseId] = nil
                }
            }

            strongSelf.likeDebounceTimers[caseId] = nil
        }

        likeDebounceTimers[caseId] = debounceTimer

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)

    }
    
    /// Notifies observers about a change in the bookmark status of a case.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the case.
    ///   - didBookmark: A boolean indicating whether the user bookmarked or unbookmarked the case.
    func bookmarkCaseChange(caseId: String, didBookmark: Bool) {
        let caseChange = CaseBookmarkChange(caseId: caseId, didBookmark: didBookmark)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.caseBookmark), object: caseChange)

        if let debounceTimer = bookmarkDebounceTimers[caseId] {
            debounceTimer.cancel()
        }

        if bookmarkValues[caseId] == nil {
            bookmarkValues[caseId] = !didBookmark
        }

        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let bookmarkValue = strongSelf.bookmarkValues[caseId] else { return }

            if didBookmark == bookmarkValue {

                strongSelf.bookmarkValues[caseId] = nil
                return
            }

            if didBookmark {

                CaseService.bookmarkCase(withId: caseId) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        let caseChange = CaseBookmarkChange(caseId: caseId, didBookmark: bookmarkValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.caseBookmark), object: caseChange)
                    }
                    
                    strongSelf.bookmarkValues[caseId] = nil

                }

            } else {
                CaseService.unbookmarkCase(withId: caseId) { [weak self] error in
                    guard let strongSelf = self else { return }

                    if let _ = error {
                        let caseChange = CaseBookmarkChange(caseId: caseId, didBookmark: bookmarkValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.caseBookmark), object: caseChange)
                    }
                    
                    strongSelf.bookmarkValues[caseId] = nil

                }
            }

            strongSelf.bookmarkDebounceTimers[caseId] = nil
        }

        bookmarkDebounceTimers[caseId] = debounceTimer

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
    
    /// Notifies observers about a change in the comments of a case.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the case.
    ///   - comment: The comment that was added, edited, or deleted.
    ///   - action: The type of action performed on the comment (added, edited, or deleted).
    func commentCaseChange(caseId: String, path: [String], comment: Comment, action: CommentAction) {
        let caseChange = CaseCommentChange(caseId: caseId, path: path, comment: comment, action: action)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.caseComment), object: caseChange)
    }
    
    /// Notifies observers about a revision in a case.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the case that has been revised.
    func revisionCaseChange(caseId: String) {
        let caseChange = CaseRevisionChange(caseId: caseId)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.caseRevision), object: caseChange)
    }
    
    func solveCaseChange(caseId: String, diagnosis: CaseRevisionKind?) {
        let caseSolve = CaseSolveChange(caseId: caseId, diagnosis: diagnosis)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.caseSolve), object: caseSolve)
    }
    
    func visibleCaseChange(caseId: String) {
        let caseChange = CaseVisibleChange(caseId: caseId)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.caseVisibility), object: caseChange)
    }
}

extension ContentManager {
    
    /// Notifies observers about a change in the like status of a comment on a case.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the case.
    ///   - commentId: The ID of the comment.
    ///   - didLike: A boolean indicating whether the comment was liked or unliked.
    func likeCommentCaseChange(caseId: String, path: [String], commentId: String, owner: String, didLike: Bool, anonymous: Bool) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let commentChange = CaseCommentLikeChange(caseId: caseId, commentId: commentId, didLike: didLike)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.caseCommentLike), object: commentChange)

        if let debounceTimer = likeDebounceTimers[commentId] {
            debounceTimer.cancel()
        }
        
        if likeValues[commentId] == nil {
            likeValues[commentId] = !didLike
        }

        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let likeValue = strongSelf.likeValues[commentId] else { return }

            if didLike == likeValue {
                strongSelf.likeValues[commentId] = nil
                strongSelf.likeValues[commentId] = nil
                return
            }

            if didLike {
                
                CommentService.likeCaseComment(forId: caseId, forPath: path, forCommentId: commentId) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        let commentChange = CaseCommentLikeChange(caseId: caseId, commentId: commentId, didLike: likeValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.caseCommentLike), object: commentChange)
                    } else {
                        if path.count >= 1 && uid != owner {
                            FunctionsManager.shared.addNotificationOnCaseLikeReply(caseId: caseId, owner: owner, path: path, commentId: commentId, anonymous: anonymous)
                        }
                    }
                    
                    strongSelf.likeValues[commentId] = nil
                    strongSelf.likeValues[commentId] = nil
                }

            } else {
                
                CommentService.unlikeCaseComment(forId: caseId, forPath: path, forCommentId: commentId) { [weak self] error in
                    guard let strongSelf = self else { return }

                    if let _ = error {
                        let commentChange = CaseCommentLikeChange(caseId: caseId, commentId: commentId, didLike: likeValue)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.caseCommentLike), object: commentChange)
                    }
                    
                    strongSelf.likeValues[commentId] = nil
                    strongSelf.likeValues[commentId] = nil
                }
            }

            strongSelf.likeDebounceTimers[commentId] = nil
        }

        likeDebounceTimers[commentId] = debounceTimer

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
}

// User Changes

extension ContentManager {
    func userFollowChange(uid: String, isFollowed: Bool) {
        let userChange = UserFollowChange(uid: uid, isFollowed: isFollowed)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.followUser), object: userChange)
    }
    
    func userConnectionChange(uid: String, phase: ConnectPhase) {
        let connectionChange = UserConnectionChange(uid: uid, phase: phase)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.connectUser), object: connectionChange)
    }
}

