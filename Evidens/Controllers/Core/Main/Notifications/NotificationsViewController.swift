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

    private var postLike = [Post]()
    private var caseLike = [Case]()
    
    private var comments = [Comment]()
    private var followers: Int = 0
    
    private var loaded: Bool = false
    
    private var currentNotification: Bool = false
    private var notificationsFirstSnapshot: QueryDocumentSnapshot?
    private var notificationsLastSnapshot: QueryDocumentSnapshot?
    
    private var networkProblem: Bool = false
    private var bottomSpinner: BottomSpinnerView!
    
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
        fetchNotifications()
    }
    
    private func configureCollectionView() {
        title = AppStrings.Settings.notificationsTitle
       
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        
        bottomSpinner = BottomSpinnerView()

        view.addSubviews(activityIndicator, collectionView, bottomSpinner)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
            
            bottomSpinner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomSpinner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSpinner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSpinner.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        collectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
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

        NotificationCenter.default.addObserver(self, selector: #selector(postLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.postLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.postBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.postComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postVisibleChange(_:)), name: NSNotification.Name(AppPublishers.Names.postVisibility), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postEditChange(_:)), name: NSNotification.Name(AppPublishers.Names.postEdit), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseVisibleChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseVisibility), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseRevisionChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseRevision), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseSolveChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseSolve), object: nil)
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
            print("leave followers")
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
            
            print("leave follows")
            group.leave()
        }
    }

    private func fetchUsers(group: DispatchGroup) {
        group.enter()
        let uids = notifications.map { $0.uid }
        let uniqueUids = Array(Set(uids))

        UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
            guard let strongSelf = self else { return }
            
            // Insert the current user
            guard let tab = strongSelf.tabBarController as? MainTabController else { return }
            guard let user = tab.user else { return }
            
            strongSelf.users = users
            strongSelf.users.append(user)
            print("leave users")
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
            print("leave posts")

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
            print("leave cases")
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
            print("leave post comments")
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
                print(comments)
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
            
            print("leave case commensts")
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
        
        guard let _ = notificationsFirstSnapshot else {
            return
        }
        
        let cooldownTime: TimeInterval = 20.0
        if let lastRefreshTime = lastRefreshTime, Date().timeIntervalSince(lastRefreshTime) < cooldownTime {
            // Cooldown time hasn't passed, return without performing the refresh
            self.collectionView.refreshControl?.endRefreshing()
            return
        }
        
        lastRefreshTime = Date()

        // Schedule a task to set lastRefreshTime to nil after 20 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + cooldownTime) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.lastRefreshTime = nil
        }
        
        notificationsFirstSnapshot = nil
        notificationsLastSnapshot = nil
        
        notifications.removeAll()
        users.removeAll()

        postLike.removeAll()
        caseLike.removeAll()
        
        comments.removeAll()
        followers = 0

        fetchNotifications()
    }
    
    
    func showBottomSpinner() {
        isFetchingMoreNotifications = true
        let collectionViewContentHeight = collectionView.contentSize.height
        
        if collectionView.frame.height < collectionViewContentHeight {
            bottomSpinner.startAnimating()
            collectionView.contentInset.bottom = 50
        }
    }
    
    func hideBottomSpinner() {
        isFetchingMoreNotifications = false
        bottomSpinner.stopAnimating()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.contentInset.bottom = 0
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
    func cell(_ cell: UICollectionViewCell, wantsToViewPost post: Post?) {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        if let post {
            if let userIndex = users.firstIndex(where: { $0.uid == post.uid }) {
                let user = users[userIndex]
                let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)
                navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            guard let indexPath = collectionView.indexPath(for: cell) else { return }
            let notification = notifications[indexPath.row]
            let contentId = notification.contentId
            
            let controller = DetailsPostViewController(postId: contentId, collectionViewLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToViewCase clinicalCase: Case?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        if let clinicalCase {
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
        } else {
            guard let indexPath = collectionView.indexPath(for: cell) else { return }
            let notification = notifications[indexPath.row]
            let contentId = notification.contentId
            
            let controller = DetailsCaseViewController(caseId: contentId, collectionViewLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
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
        guard let currentCell = cell as? NotificationFollowCell else { return }
        
        UserService.follow(uid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            
            currentCell.isUpdatingFollowingState = false
            
            if let _ = error {
                return
            }
            
            currentCell.viewModel?.notification.userIsFollowed = true
            strongSelf.notifications[indexPath.row].userIsFollowed = true
            strongSelf.userDidChangeFollow(uid: uid, didFollow: true)
            currentCell.setNeedsUpdateConfiguration()
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
            
            currentCell.viewModel?.notification.userIsFollowed = false
            strongSelf.notifications[indexPath.row].userIsFollowed = false
            strongSelf.userDidChangeFollow(uid: uid, didFollow: false)
            currentCell.setNeedsUpdateConfiguration()
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeeFollowingDetailsForNotification: Notification) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
       
        let controller = FollowersFollowingViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToViewProfile uid: String) {
        if let userIndex = users.firstIndex(where: { $0.uid == uid }) {
            let controller = UserProfileViewController(user: users[userIndex])
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension NotificationsViewController {
    func getMoreNotifications() {
        guard !isFetchingMoreNotifications, !notifications.isEmpty else {
            return
        }
        
        showBottomSpinner()

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
                    strongSelf.hideBottomSpinner()
                }
            case .failure(_):
                strongSelf.hideBottomSpinner()
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


//MARK: - User Changes

extension NotificationsViewController {
    
    @objc func postVisibleChange(_ notification: NSNotification) {
        if let change = notification.object as? PostVisibleChange {
            for (index, notification) in notifications.enumerated() {
                if notification.contentId == change.postId {
                    self.notifications.remove(at: index)
                }
            }
            
            self.collectionView.reloadData()
            
        }
    }
    
    @objc func postLikeChange(_ notification: NSNotification) {
        if let change = notification.object as? PostLikeChange {
            
            for (index, notification) in notifications.enumerated() {
                if notification.contentId == change.postId {
                    if let likes = notifications[index].post?.likes {
                        self.notifications[index].post?.likes = change.didLike ? likes + 1 : likes - 1
                        self.notifications[index].post?.didLike = change.didLike
                    }
                }
            }
            self.collectionView.reloadData()
        }
    }
    
    @objc func postBookmarkChange(_ notification: NSNotification) {
        if let change = notification.object as? PostBookmarkChange {
            for (index, notification) in notifications.enumerated() {
                if notification.contentId == change.postId {
                    self.notifications[index].post?.didBookmark = change.didBookmark
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? PostCommentChange {
            for (index, notification) in notifications.enumerated() {
                if notification.contentId == change.postId {
                    if let comments = notifications[index].post?.numberOfComments {
                        
                        switch change.action {
                            
                        case .add:
                            self.notifications[index].post?.numberOfComments = comments + 1
                        case .remove:
                            self.notifications[index].post?.numberOfComments = comments + 1
                        }
                        
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func postEditChange(_ notification: NSNotification) {
        if let change = notification.object as? PostEditChange {
            let post = change.post
            for (index, notification) in notifications.enumerated() {
                if notification.contentId == post.postId {
                    notifications[index].post = post
                }
            }
            self.collectionView.reloadData()
        }
    }
}

extension NotificationsViewController {
    
    @objc func caseVisibleChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseVisibleChange {
            for (index, notification) in notifications.enumerated() {
                if notification.contentId == change.caseId {
                    self.notifications.remove(at: index)
                }
            }
            self.collectionView.reloadData()
        }
    }
    
    
    @objc func caseLikeChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseLikeChange {
            
            for (index, notification) in notifications.enumerated() {
                if notification.contentId == change.caseId {
                    if let likes = notifications[index].clinicalCase?.likes {
                        self.notifications[index].clinicalCase?.likes = change.didLike ? likes + 1 : likes - 1
                        self.notifications[index].clinicalCase?.didLike = change.didLike
                       
                    }
                }
            }
            
            self.collectionView.reloadData()
        }
    }
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseBookmarkChange {
            for (index, notification) in notifications.enumerated() {
                if notification.contentId == change.caseId {
                    self.notifications[index].clinicalCase?.didBookmark = change.didBookmark
                }
            }
            self.collectionView.reloadData()
        }
    }
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseCommentChange {
            for (index, notification) in notifications.enumerated() {
                if notification.contentId == change.caseId {
                    if let comments = notifications[index].clinicalCase?.numberOfComments {
                        
                        switch change.action {
                            
                        case .add:
                            self.notifications[index].clinicalCase?.numberOfComments = comments + 1
                        case .remove:
                            self.notifications[index].clinicalCase?.numberOfComments = comments + 1
                        }
                    }
                }
            }
            
            self.collectionView.reloadData()
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            for (index, notification) in notifications.enumerated() {
                if notification.contentId == change.caseId {
                    self.notifications[index].clinicalCase?.revision = .update
                }
            }
            self.collectionView.reloadData()
        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseSolveChange {
            for (index, notification) in notifications.enumerated() {
                if notification.contentId == change.caseId {
                    
                    self.notifications[index].clinicalCase?.phase = .solved
                    
                    if let diagnosis = change.diagnosis {
                        self.notifications[index].clinicalCase?.revision = diagnosis
                        
                    }
                }
            }
            self.collectionView.reloadData()
        }
    }
}

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
                notifications[index].userIsFollowed = change.isFollowed
                collectionView.reloadData()
            }
        }
    }
}


    
