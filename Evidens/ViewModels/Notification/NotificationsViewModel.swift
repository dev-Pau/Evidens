//
//  NotificationsViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/9/23.
//

import Foundation

class NotificationsViewModel {
    
    var notifications = [Notification]()
    var newNotifications = [Notification]()
    var users = [User]()
    
    var comments = [Comment]()
    var followers: Int = 0
    
    var loaded: Bool = false
    var fetchLimit: Bool = false
    
    var currentNotification: Bool = false

    var lastRefreshTime: Date?
    var isFetchingMoreNotifications: Bool = false
    
    
    
    func getNotifications() {
        notifications = DataService.shared.getNotifications()
    }
    
    func getNewNotifications(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        let date = DataService.shared.getLastNotificationDate()

        NotificationService.fetchNotifications(since: date) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let notifications):
                strongSelf.newNotifications = notifications
                strongSelf.fetchAdditionalData(for: notifications, group: group)
                group.notify(queue: .main) { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    for notification in strongSelf.newNotifications {
                        DataService.shared.save(notification: notification)
                    }
                
                    strongSelf.loaded = true
                    strongSelf.newNotifications.sort(by: { $0.timestamp > $1.timestamp })
                    strongSelf.notifications.insert(contentsOf: strongSelf.newNotifications, at: 0)
                    strongSelf.newNotifications.removeAll()
                    completion()
                    //strongSelf.activityIndicator.stop()
                    //strongSelf.collectionView.reloadData()
                    //strongSelf.collectionView.isHidden = false
                    //strongSelf.collectionView.refreshControl?.endRefreshing()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadNotifications), object: nil, userInfo: ["notifications": 0])

                }
            case .failure(_):
                if strongSelf.loaded == false {
                    strongSelf.loaded = true
                    completion()
                    //strongSelf.activityIndicator.stop()
                    //strongSelf.collectionView.reloadData()
                    //strongSelf.collectionView.isHidden = false
                    //strongSelf.collectionView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    func getMoreNotifications(completion: @escaping () -> Void) {
        
        guard !isFetchingMoreNotifications, !notifications.isEmpty, !fetchLimit, loaded else {
            return
        }
        guard let date = notifications.last?.timestamp else { return }
        
        showBottomSpinner()
        
        let newNotifications = DataService.shared.getNotifications(before: date, limit: 10)

        if newNotifications.count < 10 {
            fetchLimit = true
        }
        
        notifications.append(contentsOf: newNotifications)
        hideBottomSpinner()
        completion()
    }
    
    private func fetchAdditionalData(for notifications: [Notification], group: DispatchGroup) {
        fetchUsers(for: notifications, group: group)
        checkIfUsersAreFollowed(for: notifications, group: group)
        fetchLikePosts(for: notifications, group: group)
        fetchLikeCases(for: notifications, group: group)
        fetchCommentPost(for: notifications, group: group)
        fetchCommentCase(for: notifications, group: group)
        fetchRepliesCommentPost(for: notifications, group: group)
        fetchRepliesCommentCase(for: notifications, group: group)
        fetchLikeRepliesPosts(for: notifications, group: group)
        fetchLikeRepliesCases(for: notifications, group: group)
    }
    
    private func fetchUsers(for notifications: [Notification], group: DispatchGroup) {
        group.enter()
        let uids = notifications.map { $0.uid }.filter { !$0.isEmpty }
        let uniqueUids = Array(Set(uids))
        
        guard !uniqueUids.isEmpty else {
            group.leave()
            return
        }
        
        var completedTasks = 0
        
        UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
            guard let strongSelf = self else { return }
            
            strongSelf.users = users
            
            for user in users {
                FileGateway.shared.saveImage(url: user.profileUrl, userId: user.uid!) { [weak self] url in
                    guard let strongSelf = self else { return }
                    
                    for (index, notification) in strongSelf.newNotifications.enumerated() {
                        if notification.uid == user.uid! {
                            strongSelf.newNotifications[index].set(image: url?.absoluteString ?? nil)
                            strongSelf.newNotifications[index].set(name: user.name())
                        }
                    }
                    
                    completedTasks += 1
                    
                    if completedTasks == users.count {
                        group.leave()
                    }
                }
            }
        }
    }
    
    private func checkIfUsersAreFollowed(for notifications: [Notification], group: DispatchGroup) {
        group.enter()
        
        let followNotification = notifications.filter({ $0.kind == .follow })
        
        guard !followNotification.isEmpty else {
            group.leave()
            return
        }

        let uids = followNotification.map { $0.uid }
        
        var completedTasks = 0
        
        for uid in uids {
            
            UserService.checkIfUserIsFollowed(withUid: uid) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let isFollowed):
                    if let index = strongSelf.newNotifications.firstIndex(where: { $0.uid == uid && $0.kind == .follow }) {
                        strongSelf.newNotifications[index].set(isFollowed: isFollowed)
                    }
                case .failure(_):
                    break
                }
                
                completedTasks += 1
                
                if completedTasks == uids.count {
                    group.leave()
                }
            }
        }
    }

    private func fetchLikePosts(for notifications: [Notification], group: DispatchGroup) {
        group.enter()
        
        let notificationLikePosts = notifications.filter({ $0.kind == .likePost })
        
        guard !notificationLikePosts.isEmpty else {
            group.leave()
            return
        }
        
        let postIds = notificationLikePosts.map { $0.contentId! }

        
        PostService.getRawPosts(withPostIds: postIds) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let posts):
                for post in posts {
                    if let index = strongSelf.newNotifications.firstIndex(where: { $0.contentId == post.postId && $0.kind == .likePost }) {
                        strongSelf.newNotifications[index].set(content: post.postText)
                        strongSelf.newNotifications[index].set(likes: post.likes)
                        strongSelf.newNotifications[index].set(contentId: post.postId)
                    }
                }
            case .failure(_):
                break
            }
            
            group.leave()
        }
    }
    
    private func fetchLikeCases(for notifications: [Notification], group: DispatchGroup) {
        
        group.enter()
        
        let notificationLikeCases = notifications.filter({ $0.kind == .likeCase })
        
        guard !notificationLikeCases.isEmpty else {
            group.leave()
            return
        }
        
        let caseIds = notificationLikeCases.map { $0.contentId! }

        CaseService.getRawCases(withCaseIds: caseIds) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let cases):
                for clinicalCase in cases {
                    if let index = strongSelf.newNotifications.firstIndex(where: { $0.contentId == clinicalCase.caseId && $0.kind == .likeCase }) {
                        strongSelf.newNotifications[index].set(content: clinicalCase.title)
                        strongSelf.newNotifications[index].set(likes: clinicalCase.likes)
                    }
                }
            case .failure(_):
                break
            }
            
            group.leave()
        }
    }
    
    func fetchCommentPost(for notifications: [Notification], group: DispatchGroup) {
        group.enter()
        
        let notificationPostComments = notifications.filter({ $0.kind == .replyPost })
        
        
        guard !notificationPostComments.isEmpty else {
            group.leave()
            return
        }
        
        CommentService.getRawPostComments(forNotifications: notificationPostComments, withLikes: false) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let comments):
                for comment in comments {
                    if let index = strongSelf.newNotifications.firstIndex(where: { $0.path?.last == comment.id && $0.kind == .replyPost }) {
                        strongSelf.newNotifications[index].set(content: comment.comment)
                    }
                }
            case .failure(_):
                break
            }
            
            group.leave()
        }
    }
    
    private func fetchCommentCase(for notifications: [Notification], group: DispatchGroup) {
        
        group.enter()
        
        let notificationCaseComments = notifications.filter({ $0.kind == .replyCase })
        
        guard !notificationCaseComments.isEmpty else {
            group.leave()
            return
        }
        
        CommentService.getRawCaseComments(forNotifications: notificationCaseComments, withLikes: false) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let comments):

                strongSelf.comments.append(contentsOf: comments)
                
                for comment in comments {
                    if let index = strongSelf.newNotifications.firstIndex(where: { $0.path?.last == comment.id && $0.kind == .replyCase }) {
                        strongSelf.newNotifications[index].set(content: comment.comment)
                    }
                }
            case .failure(_):
                break
            }

            group.leave()
        }
    }
    
    private func fetchRepliesCommentPost(for notifications: [Notification], group: DispatchGroup) {
        group.enter()
        
        let notificationPostComments = notifications.filter({ $0.kind == .replyPostComment })
        
        guard !notificationPostComments.isEmpty else {
            group.leave()
            return
        }
        
        CommentService.getRawPostComments(forNotifications: notificationPostComments, withLikes: false) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let comments):
                for comment in comments {
                    if let index = strongSelf.newNotifications.firstIndex(where: { $0.path?.last == comment.id && $0.kind == .replyPostComment }) {
                        strongSelf.newNotifications[index].set(content: comment.comment)
                    }
                }
            case .failure(_):
                break
            }
            
            group.leave()
        }
    }
    
    private func fetchRepliesCommentCase(for notifications: [Notification], group: DispatchGroup) {
        group.enter()
        
        let notificationCaseComments = notifications.filter({ $0.kind == .replyCaseComment })
        
        guard !notificationCaseComments.isEmpty else {
            group.leave()
            return
        }
        
        CommentService.getRawCaseComments(forNotifications: notificationCaseComments, withLikes: false) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let comments):
                for comment in comments {
                    if let index = strongSelf.newNotifications.firstIndex(where: { $0.path?.last == comment.id && $0.kind == .replyCaseComment }) {
                        strongSelf.newNotifications[index].set(content: comment.comment)
                    }
                }
            case .failure(_):
                break
            }
            
            group.leave()
        }
    }
    
    private func fetchLikeRepliesPosts(for notifications: [Notification], group: DispatchGroup) {
        group.enter()
        
        let notificationLikePostComments = notifications.filter({ $0.kind == .likePostReply })
        
        guard !notificationLikePostComments.isEmpty else {
            group.leave()
            return
        }
        
        CommentService.getRawPostComments(forNotifications: notificationLikePostComments, withLikes: true) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let comments):
                for comment in comments {
                    if let index = strongSelf.newNotifications.firstIndex(where: { $0.commentId == comment.id && $0.kind == .likePostReply }) {
                        strongSelf.newNotifications[index].set(content: comment.comment)
                        strongSelf.newNotifications[index].set(likes: comment.likes)
                    }
                }
            case .failure(_):
                break
            }
            
            group.leave()
        }
    }
    
    private func fetchLikeRepliesCases(for notifications: [Notification], group: DispatchGroup) {
        group.enter()
        
        let notificationLikeCaseComments = notifications.filter({ $0.kind == .likeCaseReply })
        
        guard !notificationLikeCaseComments.isEmpty else {
            group.leave()
            return
        }

        CommentService.getRawCaseComments(forNotifications: notificationLikeCaseComments, withLikes: true) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let comments):
                for comment in comments {
                    if let index = strongSelf.newNotifications.firstIndex(where: { $0.commentId == comment.id && $0.kind == .likeCaseReply }) {
                        strongSelf.newNotifications[index].set(content: comment.comment)
                        strongSelf.newNotifications[index].set(likes: comment.likes)
                    }
                }
            case .failure(_):
                break
            }
            
            group.leave()
        }
    }
}

//MARK: - Miscellaneous

extension NotificationsViewModel {
    
    private func showBottomSpinner() {
        isFetchingMoreNotifications = true
    }
    
    private func hideBottomSpinner() {
        isFetchingMoreNotifications = false
    }
}
