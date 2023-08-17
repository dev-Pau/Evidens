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
private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"
private let emptyCellReuseIdentifier = "EmptyCellReuseIdentifier"

class NotificationsViewController: NavigationBarViewController {
    
    //MARK: - Properties
    
    private var notifications = [Notification]()
    private var users = [User]()
    private var posts = [Post]()
    private var cases = [Case]()
    
    private var postLike = [Post]()
    private var caseLike = [Case]()
    
    private var comments = [Comment]()
    private var followers: Int = 0
    
    private lazy var lockView = MEPrimaryBlurLockView(frame: view.bounds)
    
    private var loaded: Bool = false
    
    private var notificationsFirstSnapshot: QueryDocumentSnapshot?
    private var notificationsLastSnapshot: QueryDocumentSnapshot?
    
    private var networkProblem: Bool = false
    
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
        fetchNotifications()
    }
    
    private func configureCollectionView() {
        title = AppStrings.Settings.notificationsTitle
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
        
        collectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.register(NotificationFollowCell.self, forCellWithReuseIdentifier: followCellReuseIdentifier)
        collectionView.register(NotificationLikeCommentCell.self, forCellWithReuseIdentifier: likeCellReuseIdentifier)
       
        collectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    
    private func fetchNotifications() {
        let group = DispatchGroup()

        NotificationService.fetchNotifications(lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let snapshot):
                strongSelf.notificationsFirstSnapshot = snapshot.documents.first
                strongSelf.notificationsLastSnapshot = snapshot.documents.last
                
                strongSelf.notifications = snapshot.documents.map({ Notification(dictionary: $0.data()) })
                print(strongSelf.notifications)
                
                strongSelf.fetchAdditionalNotificationData(group: group)

            case .failure(let error):

                strongSelf.loaded = true
                
                if error == .network {
                    strongSelf.networkProblem = true
                }

                strongSelf.activityIndicator.stop()
                strongSelf.collectionView.refreshControl?.endRefreshing()
                strongSelf.collectionView.reloadData()
                strongSelf.collectionView.isHidden = false
                
                guard error != .notFound else {
                    return
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.loaded = true
                strongSelf.activityIndicator.stop()
                strongSelf.collectionView.reloadData()
                strongSelf.collectionView.isHidden = false
                strongSelf.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func fetchAdditionalNotificationData(group: DispatchGroup) {
        fetchFollowers(group: group)
        fetchUsers(group: group)
        fetchFollows(group: group)
        fetchPostLikes(group: group)
        fetchCaseLikes(group: group)
        fetchFollows(group: group)
        fetchPostComments(group: group)
        fetchCaseComments(group: group)
    }
    
    private func fetchFollowers(group: DispatchGroup) {
        group.enter()
        
        UserService.fetchNumberOfFollowers { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let followers):
                strongSelf.followers = followers
            case .failure(_):
                strongSelf.followers = 0
            }
     
            group.leave()
        }
    }
    
    private func fetchFollows(group: DispatchGroup) {
        group.enter()
        let followNotification = notifications.filter({ $0.kind == .follow }).first
        
        guard let followNotification = followNotification else {
            group.leave()
            return
        }
        
        let uid = followNotification.uid
        
        UserService.checkIfUserIsFollowed(withUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let isFollowed):
                if let notificationIndex = strongSelf.notifications.firstIndex(where: { $0.id == followNotification.id }) {
                    strongSelf.notifications[notificationIndex].userIsFollowed = isFollowed
                }
            case .failure(_):
                break
            }
            
            group.leave()
        }
    }

    private func fetchUsers(group: DispatchGroup) {
        group.enter()
        let uids = notifications.map { $0.uid }
        let uniqueUids = Array(Set(uids))

        UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
            guard let strongSelf = self else { return }
            strongSelf.users = users
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
        
        let postIds = notificationPostLikes.map({ $0.contentId })

        PostService.fetchPosts(withPostIds: postIds) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let posts):
                
                strongSelf.postLike = posts
                
                for post in posts {
                    group.enter()
                    if let notificationIndex = strongSelf.notifications.firstIndex(where: { $0.contentId == post.postId }) {
                        strongSelf.notifications[notificationIndex].post = post
                    }
                    group.leave()
                }
            case .failure(_):
                break
            }
            
            group.leave()
        }
    }
    
    private func fetchCaseLikes(group: DispatchGroup) {
        group.enter()
        let notificationCaseLikes = notifications.filter({ $0.kind == .likeCase })
        
        guard !notificationCaseLikes.isEmpty else {
            group.leave()
            return
        }
        
        let caseIds = notificationCaseLikes.map({ $0.contentId })
        
        CaseService.fetchCases(withCaseIds: caseIds) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let cases):
                strongSelf.caseLike = cases
                
                for clinicalCase in cases {
                    group.enter()
                    if let notificationIndex = strongSelf.notifications.firstIndex(where: { $0.contentId == clinicalCase.caseId }) {
                        strongSelf.notifications[notificationIndex].clinicalCase = clinicalCase
                    }
                    group.leave()
                }
            case .failure(_):
                break
            }
            
            group.leave()
        }
    }
    
    func fetchPostComments(group: DispatchGroup) {
        group.enter()
        
        let notificationCommentPost = notifications.filter({ $0.kind == .replyPost })
        
        guard !notificationCommentPost.isEmpty else {
            group.leave()
            return
        }
        
        CommentService.getRawPostComments(forNotifications: notificationCommentPost) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let comments):
                strongSelf.comments.append(contentsOf: comments)
                
                for comment in comments {
                    group.enter()
                    if let notificationIndex = strongSelf.notifications.firstIndex(where: { $0.commentId == comment.id }) {
                        strongSelf.notifications[notificationIndex].comment = comment
                    }
                    
                    group.leave()
                }
            case .failure(_):
                break
            }
            group.leave()
        }
    }
    
    private func fetchCaseComments(group: DispatchGroup) {
        group.enter()
        
        let notificationCommentCase = notifications.filter({ $0.kind == .replyCase })
        guard !notificationCommentCase.isEmpty else {
            group.leave()
            return
        }
        
        CommentService.getRawCaseComments(forNotifications: notificationCommentCase) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let comments):
                strongSelf.comments.append(contentsOf: comments)
                
                for comment in comments {
                    group.enter()
                    if let notificationIndex = strongSelf.notifications.firstIndex(where: { $0.commentId == comment.id }) {
                        strongSelf.notifications[notificationIndex].comment = comment
                    }
                    
                    group.leave()
                }
            case .failure(_):
                break
            }
            
            group.leave()
        }
    }

    @objc func handleRefresh() {
        HapticsManager.shared.vibrate(for: .success)
 
        guard notificationsFirstSnapshot != nil else {
            // Refreshing on an empty notifications collectionView. Check if the user has any new notification
            loaded = false
            networkProblem = false
            collectionView.isHidden = true
            activityIndicator.start()
            fetchNotifications()
            return
        }
        
        guard let notificationsFirstSnapshot = notificationsFirstSnapshot else {
            return
        }
        
        NotificationService.getNewNotifications(lastSnapshot: notificationsFirstSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let snapshot):
                // New group of notifications received. Get the ID of each notification.
                strongSelf.notificationsFirstSnapshot = snapshot.documents.first
                var newNotifications: [Notification] = snapshot.documents.map({ Notification(dictionary: $0.data()) })
                
                // Check if any new notification is an update of the ones already fetched by the user to delete duplicity
                let newNotificationIds = newNotifications.map({ $0.id })
                let uniquePreviousNotifications = strongSelf.notifications.filter({ newNotificationIds.contains($0.id) == false })
                // Get the full array of notifications (new ones + unique older ones) and keep the first 15
                newNotifications.append(contentsOf: uniquePreviousNotifications)
                let newSizedNotifications = Array(newNotifications.prefix(15))
                strongSelf.notifications = newSizedNotifications
                
                // Get unique users
                let newUniqueNotificationUserUids = Array(Set(newSizedNotifications.map({ $0.uid })))
                let currentFetchedUserUids = strongSelf.users.map { $0.uid }
                let newUidsToFetch = newUniqueNotificationUserUids.filter({ currentFetchedUserUids.contains($0) == false })
                
                UserService.fetchUsers(withUids: newUidsToFetch) { [weak self] newUsers in
                    guard let strongSelf = self else { return }
                    strongSelf.users.append(contentsOf: newUsers)
                    if let lastNotification = strongSelf.notifications.last {
                        NotificationService.getSnapshotForLastNotification(lastNotification) { lastSnapshot in
                            strongSelf.notificationsLastSnapshot = lastSnapshot.documents.last
                            strongSelf.collectionView.refreshControl?.endRefreshing()
                            strongSelf.collectionView.reloadData()
                        }
                    }
                }
                
            case .failure(_):
                strongSelf.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension NotificationsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loaded ? networkProblem ? 1 : notifications.isEmpty ? 1 : notifications.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if networkProblem {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
            cell.delegate = self
            return cell
        } else {
            if notifications.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                cell.delegate = self
                cell.set(withTitle: AppStrings.Notifications.Empty.title, withDescription: AppStrings.Notifications.Empty.content, withButtonText: AppStrings.Content.Post.Feed.start)
                return cell
            } else {
                if notifications[indexPath.row].kind == .follow {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: followCellReuseIdentifier, for: indexPath) as! NotificationFollowCell
                    cell.followers = followers
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !notifications.isEmpty else {
            return
        }
        
        if notifications[indexPath.row].kind == .follow {
            if let index = users.firstIndex(where: {$0.uid! == notifications[indexPath.row].uid }) {
                let controller = UserProfileViewController(user: users[index])
                navigationController?.pushViewController(controller, animated: true)
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
                NotificationService.deleteNotification(withId: notification.id) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        strongSelf.collectionView.performBatchUpdates { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.notifications.remove(at: indexPath.row)
                            strongSelf.collectionView.deleteItems(at: [indexPath])
                            let popupView = PopUpBanner(title: AppStrings.Notifications.Delete.title, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                            popupView.showTopPopup(inView: strongSelf.view)
                        }
                    }
                }
            }
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToFollow uid: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentCell = cell as? NotificationFollowCell else { return }

            UserService.follow(uid: uid) { [weak self] error in
                guard let strongSelf = self else { return }
                if let _ = error {
                    return
                }
                
                currentCell.viewModel?.notification.userIsFollowed = true
                strongSelf.notifications[indexPath.row].userIsFollowed = true
                
                currentCell.isUpdatingFollowingState = false
                currentCell.setNeedsUpdateConfiguration()
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToUnfollow uid: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard let currentCell = cell as? NotificationFollowCell else { return }
     
        currentCell.viewModel?.notification.userIsFollowed = false
        UserService.unfollow(uid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            
            if let _ = error {
                return
            }
            
            strongSelf.notifications[indexPath.row].userIsFollowed = false
            currentCell.isUpdatingFollowingState = false
            currentCell.setNeedsUpdateConfiguration()
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeeFollowingDetailsForNotification: Notification) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
       
        let controller = FollowersFollowingViewController(user: user)
        controller.followDelegate = self
       
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToViewPost post: Post) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        if let userIndex = users.firstIndex(where: { $0.uid == post.uid }) {
            let user = users[userIndex]
            let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToViewCase clinicalCase: Case) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        if clinicalCase.privacy == .anonymous {
            let controller = DetailsCaseViewController(clinicalCase: clinicalCase, collectionViewFlowLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            if let userIndex = users.firstIndex(where: { $0.uid == clinicalCase.uid }) {
                let user = users[userIndex]
                let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
         
    func cell(_ cell: UICollectionViewCell, wantsToViewProfile uid: String) {
        if let userIndex = users.firstIndex(where: { $0.uid == uid }) {
            let controller = UserProfileViewController(user: users[userIndex])
            navigationController?.pushViewController(controller, animated: true)
            DatabaseManager.shared.uploadRecentUserSearches(withUid: users[userIndex].uid!) { _ in }
        }
    }
}

extension NotificationsViewController: FollowersFollowingViewControllerDelegate {
    func didFollowUnfollowUser(withUid uid: String, didFollow: Bool) {
        let notification = notifications.filter { $0.kind == .follow }.first
        guard let notification = notification, notification.uid == uid else { return }
        print("before")
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            print("we have it")
            notifications[index].userIsFollowed = didFollow
            collectionView.reloadData()
        }
    }
}

extension NotificationsViewController {
    func getMoreNotifications() {
        NotificationService.fetchNotifications(lastSnapshot: notificationsLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.notificationsLastSnapshot = snapshot.documents.last
                let newNotifications = snapshot.documents.map({ Notification(dictionary: $0.data()) })
                
                strongSelf.notifications.append(contentsOf: newNotifications)
                
                
                let newNotificationUidsFetched = newNotifications.map { $0.uid }
                let newNotificationUniqueUidsFetched = Array(Set(newNotificationUidsFetched))
                
                let currentUserUids = strongSelf.users.map { $0.uid }
                
                let newNotificationUsersUidsToFetch = newNotificationUniqueUidsFetched.filter({ currentUserUids.contains($0) == false })
                
                UserService.fetchUsers(withUids: newNotificationUsersUidsToFetch) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.users.append(contentsOf: users)
                    strongSelf.collectionView.reloadData()
                }
            case .failure(_):
                break
            }
        }
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

extension NotificationsViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        loaded = false
        networkProblem = false
        collectionView.isHidden = true
        activityIndicator.start()
        fetchNotifications()
    }
}
