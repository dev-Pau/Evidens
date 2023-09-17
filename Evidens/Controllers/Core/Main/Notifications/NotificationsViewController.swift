//
//  NotificationsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/8/22.
//

import UIKit
import Firebase

private let followCellReuseIdentifier = "FollowCellReuseIdentifier"
private let likeCellReuseIdentifier = "LikeCellReuseIdentifier"
private let emptyCellReuseIdentifier = "EmptyCellReuseIdentifier"

class NotificationsViewController: NavigationBarViewController {
    
    //MARK: - Properties
    
    private var notifications = [Notification]()
    
    private var newNotifications = [Notification]()
    private var users = [User]()

    private var comments = [Comment]()
    private var followers: Int = 0
    
    private var loaded: Bool = false
    private var fetchLimit: Bool = false
    
    private var currentNotification: Bool = false

    private var lastRefreshTime: Date?
    private var isFetchingMoreNotifications: Bool = false

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.isHidden = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let activityIndicator = PrimaryLoadingView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNotificationObservers()
        loadNotifications()
        fetchNotifications()
    }
    
    private func configureCollectionView() {
        title = AppStrings.Settings.notificationsTitle

        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubviews(activityIndicator, collectionView)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
        
        collectionView.register(NotificationFollowCell.self, forCellWithReuseIdentifier: followCellReuseIdentifier)
        collectionView.register(NotificationLikeCommentCell.self, forCellWithReuseIdentifier: likeCellReuseIdentifier)
       
        collectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    private func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(followDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.followUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
    }
    
    private func loadNotifications() {
        notifications = DataService.shared.getNotifications()
        collectionView.reloadData()
    }
    
    private func fetchNotifications() {
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
                    strongSelf.activityIndicator.stop()
                    strongSelf.newNotifications.sort(by: { $0.timestamp > $1.timestamp })
                    strongSelf.notifications.insert(contentsOf: strongSelf.newNotifications, at: 0)
                    strongSelf.newNotifications.removeAll()
                    //strongSelf.loadNotifications()
                    
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.isHidden = false
                    strongSelf.collectionView.refreshControl?.endRefreshing()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadNotifications), object: nil, userInfo: ["notifications": 0])

                }
            case .failure(_):
                if strongSelf.loaded == false {
                    strongSelf.loaded = true
                    strongSelf.activityIndicator.stop()
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.isHidden = false
                    strongSelf.collectionView.refreshControl?.endRefreshing()
                }
            }
        }
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

    @objc func handleRefresh() {
        self.collectionView.refreshControl?.endRefreshing()
        
        HapticsManager.shared.triggerLightImpact()
 
        let cooldownTime: TimeInterval = 15.0
        if let lastRefreshTime = lastRefreshTime, Date().timeIntervalSince(lastRefreshTime) < cooldownTime {
            // Cooldown time hasn't passed, return without performing the refresh
            collectionView.refreshControl?.endRefreshing()
            return
        }
        
        lastRefreshTime = Date()

        // Schedule a task to set lastRefreshTime to nil after 20 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + cooldownTime) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.lastRefreshTime = nil
        }
        
        fetchNotifications()
    }
    
    
    func showBottomSpinner() {
        isFetchingMoreNotifications = true
    }
    
    func hideBottomSpinner() {
        isFetchingMoreNotifications = false
    }
}

extension NotificationsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loaded ? notifications.isEmpty ? 1 : notifications.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if notifications.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
            cell.delegate = self
            cell.set(withTitle: AppStrings.Notifications.Empty.title, withDescription: AppStrings.Notifications.Empty.content, withButtonText: AppStrings.Content.Post.Feed.start)
            return cell
        } else {
            let notification = notifications[indexPath.row]
            switch notification.kind {
                
            case .follow:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: followCellReuseIdentifier, for: indexPath) as! NotificationFollowCell
                cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
                cell.delegate = self
                
                return cell
            case .likePost, .likeCase:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: likeCellReuseIdentifier, for: indexPath) as! NotificationLikeCommentCell
                cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
                cell.delegate = self
                
                return cell
                
            case .replyPost, .replyCase, .replyPostComment, .replyCaseComment, .likePostReply, .likeCaseReply:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: likeCellReuseIdentifier, for: indexPath) as! NotificationLikeCommentCell
                cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
                cell.delegate = self
                
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !notifications.isEmpty else {
            return
        }
        
        if notifications[indexPath.row].kind == .follow {
            let uid = notifications[indexPath.row].uid
            let controller = UserProfileViewController(uid: uid)
            navigationController?.pushViewController(controller, animated: true)
            if !notifications[indexPath.row].isRead  {
                notifications[indexPath.row].set(isRead: true)
                DataService.shared.read(notification: notifications[indexPath.row])
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreNotifications()
        }
    }
}

extension NotificationsViewController: NotificationCellDelegate {
    
    func cell(_ cell: UICollectionViewCell, wantsToSeeContentFor notification: Notification) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        print(notification.kind)
        switch notification.kind {

        case .likePost:
            guard let contentId = notification.contentId else { return }
            let controller = DetailsPostViewController(postId: contentId, collectionViewLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
            notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: notifications[indexPath.row])
            collectionView.reloadData()
            
        case .likeCase:
            guard let contentId = notification.contentId else { return }
            let controller = DetailsCaseViewController(caseId: contentId, collectionViewLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
            notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: notifications[indexPath.row])
            collectionView.reloadData()
        case .follow:
            break
        case .replyPost:
            guard let contentId = notification.contentId else { return }
            let controller = DetailsPostViewController(postId: contentId, collectionViewLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
            notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: notifications[indexPath.row])
            collectionView.reloadData()
            
        case .replyCase:
            guard let contentId = notification.contentId else { return }
            let controller = DetailsCaseViewController(caseId: contentId, collectionViewLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
            notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: notifications[indexPath.row])
            collectionView.reloadData()
            
        case .replyPostComment:
            guard let contentId = notification.contentId, let path = notification.path?.dropLast(), let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            let controller = CommentPostRepliesViewController(postId: contentId, uid: uid, path: Array(path))
            navigationController?.pushViewController(controller, animated: true)
            notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: notifications[indexPath.row])
            collectionView.reloadData()
            
        case .replyCaseComment:
            guard let contentId = notification.contentId, let path = notification.path?.dropLast(), let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            let controller = CommentCaseRepliesViewController(caseId: contentId, uid: uid, path: Array(path))
            navigationController?.pushViewController(controller, animated: true)
            notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: notifications[indexPath.row])
            collectionView.reloadData()
        case .likePostReply:
            guard let contentId = notification.contentId, let path = notification.path, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            let controller = CommentPostRepliesViewController(postId: contentId, uid: uid, path: path)
            navigationController?.pushViewController(controller, animated: true)
            notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: notifications[indexPath.row])
            collectionView.reloadData()
        case .likeCaseReply:
            guard let contentId = notification.contentId, let path = notification.path, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            let controller = CommentCaseRepliesViewController(caseId: contentId, uid: uid, path: path)
            navigationController?.pushViewController(controller, animated: true)
            notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: notifications[indexPath.row])
            collectionView.reloadData()
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor notification: Notification, option: NotificationMenu) {
        
        switch option {
        case .delete:
            if let indexPath = collectionView.indexPath(for: cell) {
                NotificationService.deleteNotification(withId: notification.id) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        let popupView = PopUpBanner(title: AppStrings.Error.unknown, image: AppStrings.Icons.xmarkCircleFill, popUpKind: .destructive)
                        popupView.showTopPopup(inView: strongSelf.view)
                        HapticsManager.shared.triggerErrorHaptic()
                    } else {
                        strongSelf.collectionView.performBatchUpdates { [weak self] in
                            guard let strongSelf = self else { return }
                            DataService.shared.delete(notification: strongSelf.notifications[indexPath.row])
                            
                            strongSelf.notifications.remove(at: indexPath.row)
                            if !strongSelf.notifications.isEmpty {
                                strongSelf.collectionView.deleteItems(at: [indexPath])
                            }
                            
                            let popupView = PopUpBanner(title: AppStrings.Notifications.Delete.title, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                            popupView.showTopPopup(inView: strongSelf.view)

                        } completion: { [weak self] _ in
                            guard let strongSelf = self else { return }
                            if strongSelf.notifications.isEmpty {
                                strongSelf.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToFollow uid: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard let currentCell = cell as? NotificationFollowCell else { return }
        
        UserService.follow(uid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            
            currentCell.isUpdatingFollowingState = false
            
            if let _ = error {
                return
            }
            
            currentCell.viewModel?.notification.set(isFollowed: true)
            strongSelf.notifications[indexPath.row].set(isFollowed: true)
            strongSelf.userDidChangeFollow(uid: uid, didFollow: true)
            currentCell.setNeedsUpdateConfiguration()
            DataService.shared.edit(notification: strongSelf.notifications[indexPath.row], set: true, forKey: "isFollowed")
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToUnfollow uid: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard let currentCell = cell as? NotificationFollowCell else { return }
        
        UserService.unfollow(uid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            
            currentCell.isUpdatingFollowingState = false
            
            if let _ = error {
                return
            }
            
            currentCell.viewModel?.notification.set(isFollowed: false)
            strongSelf.notifications[indexPath.row].set(isFollowed: false)
            strongSelf.userDidChangeFollow(uid: uid, didFollow: false)
            currentCell.setNeedsUpdateConfiguration()
            DataService.shared.edit(notification: strongSelf.notifications[indexPath.row], set: false, forKey: "isFollowed")
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToViewProfile uid: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let notification = notifications[indexPath.row]
        guard !notification.uid.isEmpty else { return }
        let controller = UserProfileViewController(uid: notification.uid)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension NotificationsViewController {
    func getMoreNotifications() {
        
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
        collectionView.reloadData()
        hideBottomSpinner()
    }

}

extension NotificationsViewController: PrimaryEmptyCellDelegate {
    
    func didTapEmptyAction() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let controller = HomeOnboardingViewController(user: user)
        controller.delegate = self
       
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension NotificationsViewController: HomeOnboardingViewControllerDelegate {
    
    func didUpdateUser(user: User) {
        guard let tab = tabBarController as? MainTabController else { return }
        tab.user = user
    }
}


//MARK: - User Changes

extension NotificationsViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            if let index = users.firstIndex(where: { $0.uid! == user.uid! }) {
                users[index] = user
                collectionView.reloadData()
            }
        }
    }
}

extension NotificationsViewController: UserFollowDelegate {
    
    func userDidChangeFollow(uid: String, didFollow: Bool) {
        currentNotification = true
        ContentManager.shared.userFollowChange(uid: uid, isFollowed: didFollow)
    }
    
    @objc func followDidChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? UserFollowChange {
            
            if let index = notifications.firstIndex(where: { $0.kind == .follow && $0.uid == change.uid }) {
                notifications[index].set(isFollowed: change.isFollowed)
                DataService.shared.edit(notification: notifications[index], set: change.isFollowed, forKey: "isFollowed")
                collectionView.reloadData()
            }
        }
    }
}


    
