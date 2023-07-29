//
//  NotificationsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/8/22.
//

import UIKit
import Firebase
import JGProgressHUD

private let followCellReuseIdentifier = "FollowCellReuseIdentifier"
private let likeCellReuseIdentifier = "LikeCellReuseIdentifier"
private let emptyCellReuseIdentifier = "EmptyCellReuseIdentifier"

class NotificationsViewController: NavigationBarViewController {
    
    //MARK: - Properties
    
    private var notifications = [Notification]()
    private var users = [User]()
    private var posts = [Post]()
    private var cases = [Case]()
    
    private var followCellIndexPath = IndexPath()
    private var progressIndicator = JGProgressHUD()
    
    private var postLike = [Post]()
    private var caseLike = [Case]()
    
    private var comments = [Comment]()
    private var userFollowers: Int = 0
    
    private var fetchedCount = 0

    private lazy var lockView = MEPrimaryBlurLockView(frame: view.bounds)
    
    private var loaded: Bool = false
    
    private var notificationsFirstSnapshot: QueryDocumentSnapshot?
    private var notificationsLastSnapshot: QueryDocumentSnapshot?
    
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
    
    private let activityIndicator = PrimaryProgressIndicatorView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchNotifications()
    }
    
    private func configureCollectionView() {
        title = "Notifications"
        view.addSubviews(activityIndicator, collectionView)
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        collectionView.register(NotificationFollowCell.self, forCellWithReuseIdentifier: followCellReuseIdentifier)
        collectionView.register(NotificationLikeCommentCell.self, forCellWithReuseIdentifier: likeCellReuseIdentifier)
       
        collectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    
    private func fetchNotifications() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }

        let group = DispatchGroup()
        
        group.enter()
        NotificationService.fetchNotifications(lastSnapshot: nil) { snapshot in
            if snapshot.isEmpty {
                self.handleEmptyNotifications(user: user)
                group.leave()
                return
            }
            
            self.handleNotificationsSnapshot(snapshot.documents)
            
            group.enter()
            UserService.fetchNumberOfFollowers { followers in
                self.userFollowers = followers
                print("followers fetched")
                group.leave()
            }
            
            self.fetchAdditionalNotificationData(group: group)
            
            group.notify(queue: .main) {
                print("all fetched")
                self.handleAllNotificationInfoFetched(user: user)
            }
            group.leave()
        }
    }
    
    private func handleEmptyNotifications(user: User) {
        self.loaded = true
        self.activityIndicator.stop()
        if user.phase != .verified {
            self.view.addSubview(self.lockView)
        }
        self.collectionView.refreshControl?.endRefreshing()
        self.collectionView.reloadData()
        self.collectionView.isHidden = false
    }
    
    private func handleNotificationsSnapshot(_ snapshot: [QueryDocumentSnapshot]) {
        self.notificationsFirstSnapshot = snapshot.first
        self.notificationsLastSnapshot = snapshot.last
        self.notifications = snapshot.map({ Notification(dictionary: $0.data()) })
    }
    
    private func fetchAdditionalNotificationData(group: DispatchGroup) {
        fetchUsers(group: group)
        fetchPostLikes(group: group)
        fetchCaseLikes(group: group)
        fetchPostComments(group: group)
        fetchCaseComments(group: group)
    }
    
    private func fetchUsers(group: DispatchGroup) {
        group.enter()
        let userUids = self.notifications.map { $0.uid }
        let uniqueUserUids = Array(Set(userUids))

        UserService.fetchUsers(withUids: uniqueUserUids) { users in
            self.users = users
            print("users fetched")
            group.leave()
        }
    }
    
    private func fetchPostLikes(group: DispatchGroup) {
        group.enter()
        let notificationPostLikes = notifications.filter({ $0.kind == .likePost })
        
        guard !notificationPostLikes.isEmpty else {
            group.leave()
            return
        }
        
        var count = 0
        let postLikeIds = notificationPostLikes.map({ $0.contentId })

        PostService.fetchPosts(withPostIds: postLikeIds) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let posts):
                strongSelf.postLike = posts
                
                posts.forEach { post in
                    if let notificationIndex = strongSelf.notifications.firstIndex(where: { $0.contentId == post.postId }) {
                        strongSelf.notifications[notificationIndex].post = post
                        count += 1
                        if posts.count == count {
                            print("like posts")
                            group.leave()
                        }
                    }
                }
            case .failure(let error):
                break
                #warning("on this controller need to think how to handle errors as well")
            }
        }
    }
    
    private func fetchCaseLikes(group: DispatchGroup) {
        group.enter()
        let notificationCaseLikes = notifications.filter({ $0.kind == .likeCase })
        
        guard !notificationCaseLikes.isEmpty else {
            group.leave()
            print("like cases empty")
            return
        }
        
        var count = 0
        let caseLikeIds = notificationCaseLikes.map({ $0.contentId })

        CaseService.fetchCases(withCaseIds: caseLikeIds) { cases in
            self.caseLike = cases
            cases.forEach { clinicalCase in
                if let notificationIndex = self.notifications.firstIndex(where: { $0.contentId == clinicalCase.caseId }) {
                    self.notifications[notificationIndex].clinicalCase = clinicalCase
                    count += 1
                    if cases.count == count {
                        print("like cases")
                        group.leave()
                    }
                }
            }
        }
    }
    
    func fetchPostComments(group: DispatchGroup) {
        group.enter()
        let notificationCommentPost = notifications.filter({ $0.kind == .replyPost })
        guard !notificationCommentPost.isEmpty else {
            group.leave()
            print("comments post empty")
            return
        }
        
        CommentService.fetchNotificationPostComments(withNotifications: notificationCommentPost) { comments in
            self.comments.append(contentsOf: comments)
            var count = 0
            comments.forEach { comment in
                if let notificationIndex = self.notifications.firstIndex(where: { $0.commentId == comment.id }) {
                    self.notifications[notificationIndex].comment = comment
                    count += 1
                    if comments.count == count {
                        print("comments post")
                        group.leave()
                    }
                }
            }
        }
    }
    
    private func fetchCaseComments(group: DispatchGroup) {
        group.enter()
        let notificationCommentCase = notifications.filter({ $0.kind == .replyCase })
        guard !notificationCommentCase.isEmpty else {
            group.leave()
            print("comments case empty")
            return
        }
        
        CommentService.fetchNotificationCaseComments(withNotifications: notificationCommentCase) { comments in
            self.comments.append(contentsOf: comments)
            var count = 0
            comments.forEach { comment in
                if let notificationIndex = self.notifications.firstIndex(where: { $0.commentId == comment.id }) {
                    self.notifications[notificationIndex].comment = comment
                    count += 1
                    if comments.count == count {
                        print("comments case")
                        group.leave()
                    }
                }
            }
        }
    }
    
    private func handleAllNotificationInfoFetched(user: User) {
        self.loaded = true
        self.activityIndicator.stop()
        self.collectionView.reloadData()
        self.collectionView.isHidden = false
        self.collectionView.refreshControl?.endRefreshing()
    }

    @objc func handleRefresh() {
        HapticsManager.shared.vibrate(for: .success)
        guard notificationsFirstSnapshot != nil else {
            // Refreshing on an empty notifications collectionView. Check if the user has any new notification
            fetchNotifications()
            return
        }
        
        NotificationService.getNewNotifications(lastSnapshot: notificationsFirstSnapshot!) { snapshot in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                // Refreshing without having any new notification
                self.collectionView.refreshControl?.endRefreshing()
                return
            }
            
            // New group of notifications received. Get the ID of each notification.
            self.notificationsFirstSnapshot = snapshot.documents.first
            
            var newNotifications: [Notification] = snapshot.documents.map({ Notification(dictionary: $0.data()) })

            // Check if any new notification is an update of the ones already fetched by the user to delete duplicity
            let newNotificationIds = newNotifications.map({ $0.id })
            let uniquePreviousNotifications = self.notifications.filter({ newNotificationIds.contains($0.id) == false })
            // Get the full array of notifications (new ones + unique older ones) and keep the first 15
            newNotifications.append(contentsOf: uniquePreviousNotifications)
            let newSizedNotifications = Array(newNotifications.prefix(15))
            self.notifications = newSizedNotifications
            
            // Get unique users
            let newUniqueNotificationUserUids = Array(Set(newSizedNotifications.map({ $0.uid })))
            let currentFetchedUserUids = self.users.map { $0.uid }
            let newUidsToFetch = newUniqueNotificationUserUids.filter({ currentFetchedUserUids.contains($0) == false })
            UserService.fetchUsers(withUids: newUidsToFetch) { newUsers in
                self.users.append(contentsOf: newUsers)
                if let lastNotification = self.notifications.last {
                    NotificationService.getSnapshotForLastNotification(lastNotification) { lastSnapshot in
                        self.notificationsLastSnapshot = lastSnapshot.documents.last
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension NotificationsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loaded ? notifications.isEmpty ? 1 : notifications.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if notifications.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
            cell.set(withImage: UIImage(named: "notification.empty")!, withTitle: "Nothing to see here —— yet.", withDescription: "Complete your profile and connect with people you know to start receive notifications about your activity.", withButtonText: "   Learn more   ")
            return cell
        } else {
            if notifications[indexPath.row].kind == .follow {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: followCellReuseIdentifier, for: indexPath) as! NotificationFollowCell
                cell.followers = userFollowers
                cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
                cell.delegate = self
                
                if let userIndex = users.firstIndex(where: { $0.uid == notifications[indexPath.row].uid }) {
                    cell.set(user: users[userIndex])
                }
                
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: likeCellReuseIdentifier, for: indexPath) as! NotificationLikeCommentCell
                cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
                cell.delegate = self
                
                if let userIndex = users.firstIndex(where: { $0.uid == notifications[indexPath.row].uid }) {
                    cell.set(user: users[userIndex])
                }
                
                return cell
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
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor notification: Notification, option: NotificationMenu) {
        
        switch option {
        case .delete:
            if let indexPath = collectionView.indexPath(for: cell) {
                NotificationService.deleteNotification(withUid: notification.id) { removed in
                    if removed {
                        self.collectionView.performBatchUpdates {
                            self.notifications.remove(at: indexPath.row)
                            self.collectionView.deleteItems(at: [indexPath])
                            let popupView = PopUpBanner(title: "Notification successfully deleted", image: "checkmark.circle.fill", popUpKind: .regular)
                            popupView.showTopPopup(inView: self.view)
                        }
                    }
                }
            }
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToFollow uid: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        switch cell {
        case is NotificationFollowCell:
            let currentCell = cell as! NotificationFollowCell
            currentCell.viewModel?.notification.userIsFollowed = true
            UserService.follow(uid: uid) { error in
                if let _ = error {
                    return
                }
                
                self.notifications[indexPath.row].userIsFollowed = true
                currentCell.isUpdatingFollowingState = false
                currentCell.setNeedsUpdateConfiguration()
                PostService.updateUserFeedAfterFollowing(userUid: uid, didFollow: true)
            }
        default:
            break
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToUnfollow uid: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        switch cell {
        case is NotificationFollowCell:
            let currentCell = cell as! NotificationFollowCell
            currentCell.viewModel?.notification.userIsFollowed = false
            UserService.unfollow(uid: uid) { error in
                if let _ = error {
                    return
                }
                
                self.notifications[indexPath.row].userIsFollowed = false
                currentCell.isUpdatingFollowingState = false
                currentCell.setNeedsUpdateConfiguration()
                PostService.updateUserFeedAfterFollowing(userUid: uid, didFollow: false)
            }
        default:
            break
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeeFollowingDetailsForNotification: Notification) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        guard let indexSelected = collectionView.indexPath(for: cell) else { return }
        followCellIndexPath = indexSelected
        let controller = FollowersFollowingViewController(user: user)
        controller.followDelegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        self.navigationItem.backBarButtonItem = backItem
        
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToViewPost postId: String) {
        #warning("details post vc should fetch it instead of here")
        /*
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        progressIndicator.show(in: view)
        PostService.fetchPost(withPostId: postId) { post in
            self.progressIndicator.dismiss(animated: true)
            
            let controller = DetailsPostViewController(post: post, user: user, type: .regular, collectionViewLayout: layout)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            self.navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
         */
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToViewCase caseId: String) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        progressIndicator.show(in: view)
        
        CaseService.fetchCase(withCaseId: caseId) { clinicalCase in
            
            self.progressIndicator.dismiss(animated: true)
            
            let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            self.navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToViewProfile uid: String) {
        let userIndex = users.firstIndex { user in
            if user.uid == uid {
                return true
            }
            return false
        }
        
        if let userIndex = userIndex {
            let controller = UserProfileViewController(user: users[userIndex])
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .black
            self.navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(controller, animated: true)
            DatabaseManager.shared.uploadRecentUserSearches(withUid: users[userIndex].uid!) { _ in }
        }
    }
}

extension NotificationsViewController: FollowersFollowingViewControllerDelegate {
    func didFollowUnfollowUser(withUid uid: String, didFollow: Bool) {
        let followNotification = notifications[followCellIndexPath.row]
        if let userIndex = users.firstIndex(where: { $0.uid == notifications[followCellIndexPath.row].uid }) {
            if users[userIndex].uid! == uid, let cell = collectionView.cellForItem(at: followCellIndexPath) as? NotificationFollowCell {
                // User edited the user displayed in the cell
                if didFollow {
                    self.cell(cell, wantsToFollow: uid)
                } else {
                    self.cell(cell, wantsToUnfollow: uid)
                }
            }
        }
    }
}

extension NotificationsViewController {
    func getMoreNotifications() {
        NotificationService.fetchNotifications(lastSnapshot: notificationsLastSnapshot) { snapshot in
            if snapshot.isEmpty {
            #warning("No mor enotifications? maybe show alert saying it idk")
                return
            }
            self.notificationsLastSnapshot = snapshot.documents.last
            let documents = snapshot.documents
            let newNotifications = documents.map({ Notification(dictionary: $0.data()) })
            self.notifications.append(contentsOf: newNotifications)

            let newNotificationUidsFetched = newNotifications.map { $0.uid }
            let newNotificationUniqueUniqueUidsFetched = Array(Set(newNotificationUidsFetched))
            
            let currentUserUids = self.users.map { $0.uid }
            
            let newNotificationUsersUidsToFetch = newNotificationUniqueUniqueUidsFetched.filter({ currentUserUids.contains($0) == false })
        #warning("Befroe fetching check if some of the new users are already present in the previous user array")
            UserService.fetchUsers(withUids: newNotificationUsersUidsToFetch) { users in
                self.users.append(contentsOf: users)
                self.collectionView.reloadData()
            }
        }
    }
}
