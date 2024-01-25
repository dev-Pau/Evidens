//
//  NotificationsViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/9/23.
//

import Foundation

/// The viewModel for Notifications.
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
                print("new notifications \(strongSelf.newNotifications.count)")
                
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
                    
                    NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadNotifications), object: nil, userInfo: ["notifications": 0])
                    
                }
            case .failure(_):
                if strongSelf.loaded == false {
                    strongSelf.loaded = true
                    completion()
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
            
            if newNotifications.count == 0 {
                hideBottomSpinner()
                return
            }
        }
        
        notifications.append(contentsOf: newNotifications)
        hideBottomSpinner()
        completion()
    }
    
    private func fetchAdditionalData(for notifications: [Notification], group: DispatchGroup) {
        fetchUsers(for: notifications, group: group)
        checkIfUsersAreConnected(for: notifications, group: group)
        
        fetchPosts(for: notifications, group: group)
        fetchCases(for: notifications, group: group)
        
        fetchApproveCase(for: notifications, group: group)
        fetchLikePosts(for: notifications, group: group)
        fetchLikeCases(for: notifications, group: group)
        
        fetchCommentPost(for: notifications, group: group)
        fetchCommentCase(for: notifications, group: group)
    }
    
    private func fetchUsers(for notifications: [Notification], group: DispatchGroup) {
      
        group.enter()
        
        // Some notifications may not have a uid, indicating the user is anonymous
        let uids = notifications.filter { !$0.uid.isEmpty }.map { $0.uid }

        let uniqueUids = Array(Set(uids))

        guard !uniqueUids.isEmpty else {
            group.leave()
            return
        }
        
        let currentGroup = DispatchGroup()

        UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
            guard let strongSelf = self else { return }
            
            strongSelf.users = users
            
            for (index, notification) in strongSelf.newNotifications.enumerated() {

                currentGroup.enter()
                
                switch notification.kind {
                    
                case .caseApprove:
                    currentGroup.leave()
                    
                case .connectionAccept, .connectionRequest:
                    if let userIndex = users.firstIndex(where: { $0.uid == notification.uid }) {
                        let user = users[userIndex]
                        
                        FileGateway.shared.saveImage(url: user.profileUrl, userId: user.uid ?? "") { [weak self] url in
                            guard let strongSelf = self else { return }
                            strongSelf.newNotifications[index].set(image: url?.absoluteString ?? nil)
                            strongSelf.newNotifications[index].set(name: user.name())
                            currentGroup.leave()
                        }
                    }
                    
                default:
                    // Notification may not have uid. Notifications w/o uid are anonymous notifications comming from cases
                    if let userIndex = users.firstIndex(where: { $0.uid == notification.uid }) {
                        let user = users[userIndex]
                        
                        strongSelf.newNotifications[index].set(name: user.name())
                    }
                    
                    currentGroup.leave()
                }
            }
            
            currentGroup.notify(queue: .main) { [weak self] in
                guard let _ = self else { return }
                group.leave()
            }
        }
    }
    
    private func checkIfUsersAreConnected(for notifications: [Notification], group: DispatchGroup) {
        group.enter()
        
        let connectRequestNotification = notifications.filter({ $0.kind == .connectionRequest })
        
        guard !connectRequestNotification.isEmpty else {
            group.leave()
            return
        }
        
        let uids = connectRequestNotification.map { $0.uid }
        
        let currentGroup = DispatchGroup()
        
        for uid in uids {
            
            currentGroup.enter()
            
            ConnectionService.getConnectionPhase(uid: uid) { [weak self] connection in
                guard let strongSelf = self else { return }
                
                if connection.phase != .received {
                    if let index = strongSelf.newNotifications.firstIndex(where: { $0.uid == uid && $0.kind == .connectionRequest }) {
                        NotificationService.deleteNotification(withId: strongSelf.newNotifications[index].id) { _ in }
                        strongSelf.newNotifications.remove(at: index)
                    }
                }
                
                currentGroup.leave()
            }
        }
        
        currentGroup.notify(queue: .main) {
            group.leave()
        }
    }
    
    private func fetchPosts(for notifications: [Notification], group: DispatchGroup) {
        group.enter()
        
        let notificationPosts = notifications.filter( { $0.kind == .likePost || $0.kind == .replyPost || $0.kind == .likePostReply || $0.kind == .replyPostComment })
        
        guard !notificationPosts.isEmpty else {
            group.leave()
            return
        }
        
        let postIds = notificationPosts.compactMap { $0.contentId }
        
        let uniquePostIds = Array(Set(postIds))
        
        PostService.getPlainPosts(withPostIds: uniquePostIds) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let posts):
                for notification in notificationPosts {
                    if let postIndex = posts.firstIndex(where: { $0.postId == notification.contentId }) {
                        
                        let post = posts[postIndex]
                        if let notificationIndex = strongSelf.newNotifications.firstIndex(where: { $0.id == notification.id }) {
                            strongSelf.newNotifications[notificationIndex].set(image: post.imageUrl?.first)
                            strongSelf.newNotifications[notificationIndex].set(contentId: post.postId)
                            
                            if strongSelf.newNotifications[notificationIndex].kind == .likePost {
                                strongSelf.newNotifications[notificationIndex].set(content: post.postText)
                            }
                        }
                    }
                }
            case .failure(_):
                break
            }

            group.leave()
        }
    }

    private func fetchCases(for notifications: [Notification], group: DispatchGroup) {
        group.enter()
        
        let notificationCases = notifications.filter( { $0.kind == .likeCase || $0.kind == .replyCase || $0.kind == .likeCaseReply || $0.kind == .replyCaseComment })
        
        guard !notificationCases.isEmpty else {
            group.leave()
            return
        }
        
        let caseIds = notificationCases.compactMap { $0.contentId }
        
        let uniqueCaseIds = Array(Set(caseIds))
        
        CaseService.getPlainCases(withCaseIds: uniqueCaseIds) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let cases):
                
                for notification in notificationCases {
                    if let caseIndex = cases.firstIndex(where: { $0.caseId == notification.contentId }) {
                        
                        let clinicalCase = cases[caseIndex]
                        if let notificationIndex = strongSelf.newNotifications.firstIndex(where: { $0.id == notification.id }) {
                            strongSelf.newNotifications[notificationIndex].set(image: clinicalCase.imageUrl.first)
                            strongSelf.newNotifications[notificationIndex].set(contentId: clinicalCase.caseId)
                            
                            if strongSelf.newNotifications[notificationIndex].kind == .likeCase {
                                strongSelf.newNotifications[notificationIndex].set(content: clinicalCase.title)
                            }
                        }
                    }
                }
            case .failure(_):
                break
            }
            
            group.leave()
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
        
        let currentGroup = DispatchGroup()
        
        for postId in postIds {
            currentGroup.enter()
            
            PostService.getLikesForNotificationPost(withId: postId) { [weak self] likes in
                guard let strongSelf = self else { return }
                if let index = strongSelf.newNotifications.firstIndex(where: { $0.contentId == postId && $0.kind == .likePost }) {
                    strongSelf.newNotifications[index].set(likes: likes)
                }
                currentGroup.leave()
            }
        }
        
        currentGroup.notify(queue: .main) {
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
        
        let currentGroup = DispatchGroup()
        
        for caseId in caseIds {
            currentGroup.enter()
            
            CaseService.getLikesForNotificationCase(withId: caseId) { [weak self] likes in
                guard let strongSelf = self else { return }
                
                if let index = strongSelf.newNotifications.firstIndex(where: { $0.contentId == caseId && $0.kind == .likeCase }) {
                    strongSelf.newNotifications[index].set(likes: likes)
                }
                currentGroup.leave()
            }
        }
        
        currentGroup.notify(queue: .main) {
            group.leave()
        }
    }
    
    func fetchCommentPost(for notifications: [Notification], group: DispatchGroup) {
        group.enter()
        
        let notificationPostComments = notifications.filter({ $0.kind == .replyPost || $0.kind == .replyPostComment || $0.kind == .likePostReply })
        
        
        guard !notificationPostComments.isEmpty else {
            group.leave()
            return
        }
        
        CommentService.getNotificationPostComments(forNotifications: notificationPostComments) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let comments):
                for comment in comments {
                    if let index = strongSelf.newNotifications.firstIndex(where: { $0.path?.last == comment.id && ($0.kind == .replyPost || $0.kind == .replyPostComment || $0.kind == .likePostReply) }) {
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
        
        let notificationCaseComments = notifications.filter({ $0.kind == .replyCase || $0.kind == .replyCaseComment || $0.kind == .likeCaseReply })
        
        guard !notificationCaseComments.isEmpty else {
            group.leave()
            return
        }
        
        CommentService.getNotificationCaseComments(forNotifications: notificationCaseComments) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let comments):
                
                strongSelf.comments.append(contentsOf: comments)
                
                for comment in comments {
                    if let index = strongSelf.newNotifications.firstIndex(where: { $0.path?.last == comment.id && ($0.kind == .replyCase || $0.kind == .replyCaseComment || $0.kind == .likeCaseReply) }) {
                        strongSelf.newNotifications[index].set(content: comment.comment)
                    }
                }
            case .failure(_):
                break
            }
            
            group.leave()
        }
    }
    
    private func fetchApproveCase(for notifications: [Notification], group: DispatchGroup) {
        group.enter()
        
        let notificationApproveCase = notifications.filter({ $0.kind == .caseApprove })
        
        guard !notificationApproveCase.isEmpty else {
            group.leave()
            return
        }
        
        let caseIds = notifications.compactMap { $0.contentId }
        
        guard !caseIds.isEmpty else {
            group.leave()
            return
        }
        
        CaseService.getPlainCases(withCaseIds: caseIds) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let cases):
                for clinicalCase in cases {
                    if let index = strongSelf.newNotifications.firstIndex(where: { $0.contentId == clinicalCase.caseId && $0.kind == .caseApprove }) {
                        strongSelf.newNotifications[index].set(content: clinicalCase.title)
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

//MARK: - Network

extension NotificationsViewModel {
    
    func connect(withUid uid: String, currentUser: User, completion: @escaping(FirestoreError?) -> Void) {
        
        ConnectionService.accept(forUid: uid, user: currentUser) { [weak self] error in
            guard let _ = self else { return }
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func ignore(withUid uid: String, completion: @escaping(FirestoreError?) -> Void) {

        ConnectionService.reject(forUid: uid) { [weak self] error in
            guard let _ = self else { return }
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}
