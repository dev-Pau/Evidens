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
    private var users = [User]()
    private var posts = [Post]()
    private var cases = [Case]()
    
    private var postLike = [Post]()
    private var caseLike = [Case]()
    
    private var comments = [Comment]()
    
    private var fetchedCount = 0

    private lazy var lockView = MEPrimaryBlurLockView(frame: view.bounds)
    
    private var loaded: Bool = false
    
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
    
    private let activityIndicator = MEProgressHUD(frame: .zero)
    
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
       
        collectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
    }
    
    private func fetchNotifications() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        NotificationService.fetchNotifications(lastSnapshot: nil) { snapshot in
            if snapshot.isEmpty {
                self.loaded = true
                self.activityIndicator.stop()
                if user.phase != .verified {
                    self.view.addSubview(self.lockView)
                }
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
                return
            }
            
            self.notificationsLastSnapshot = snapshot.documents.last
            self.notifications = snapshot.documents.map({ Notification(dictionary: $0.data()) })

            self.checkIfUserIsFollowed()
            self.fetchPostsForLikeNotification()
            self.fetchCaseForLikeNotification()
            self.fetchCommentsForPostCommentNotification()
            self.fetchCommentsForCaseCommentNotification()
            
            let userUids = self.notifications.map { $0.uid }
            let uniqueUserUids = Array(Set(userUids))
            UserService.fetchUsers(withUids: uniqueUserUids) { users in
                print("we got user users")
                self.users = users
                self.checkIfAllNotificationInfoIsFetched()
            }
        }
    }
    
    func checkIfUserIsFollowed() {
        var count = 0
        let notificationFollow = notifications.filter({ $0.type == .follow })
        notificationFollow.forEach { notification in
            UserService.checkIfUserIsFollowed(uid: notification.uid) { isFollowed in
                if let index = self.notifications.firstIndex(where: { $0.id == notification.id }) {
                    self.notifications[index].userIsFollowed = isFollowed
                    count += 1
                    if notificationFollow.count == count {
                        print("we got user is followed")
                        self.checkIfAllNotificationInfoIsFetched()
                    }
                }
            }
        }
    }
    
    func fetchPostsForLikeNotification() {
        let notificationPostLikes = notifications.filter({ $0.type == .likePost })
        guard !notificationPostLikes.isEmpty else {
            print("we got  posts")
            self.checkIfAllNotificationInfoIsFetched()
            return
        }
        
        var count = 0
        let postLikeIds = notificationPostLikes.map({ $0.postId ?? "" })
        PostService.fetchPosts(withPostIds: postLikeIds) { posts in
            print("we got  posts")
            self.postLike = posts
            
            posts.forEach { post in
                if let notificationIndex = self.notifications.firstIndex(where: { $0.postId ?? "" == post.postId }) {
                    
                    self.notifications[notificationIndex].post = post
                    count += 1
                    if posts.count == count {
                        self.checkIfAllNotificationInfoIsFetched()
                    }

                }
            }
        }
    }
    
    func fetchCaseForLikeNotification() {
        let notificationCaseLikes = notifications.filter({ $0.type == .likeCase })
        guard !notificationCaseLikes.isEmpty else {
            print("we got  cases")
            self.checkIfAllNotificationInfoIsFetched()
            return
        }
        
        var count = 0
        let caseLikeIds = notificationCaseLikes.map({ $0.caseId ?? "" })
        CaseService.fetchCases(withCaseIds: caseLikeIds) { cases in
            print("we got  cases")
            self.caseLike = cases
            cases.forEach { clinicalCase in
                if let notificationIndex = self.notifications.firstIndex(where: { $0.caseId ?? "" == clinicalCase.caseId }) {
                    self.notifications[notificationIndex].clinicalCase = clinicalCase
                    count += 1
                    if cases.count == count {
                        self.checkIfAllNotificationInfoIsFetched()
                    }
                }
            }
        }
    }
    
    func fetchCommentsForPostCommentNotification() {
        let notificationCommentPost = notifications.filter({ $0.type == .commentPost })
        guard !notificationCommentPost.isEmpty else {
            print("we got comment post")
            self.checkIfAllNotificationInfoIsFetched()
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
                        print("we got comment post")
                        self.checkIfAllNotificationInfoIsFetched()
                    }
                }
            }
        }
    }
    
    func fetchCommentsForCaseCommentNotification() {
        let notificationCommentCase = notifications.filter({ $0.type == .commentCase })
        guard !notificationCommentCase.isEmpty else {
            print("we got comment case empty")
            self.checkIfAllNotificationInfoIsFetched()
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
                        self.checkIfAllNotificationInfoIsFetched()
                    }
                }
            }
        }
    }
    
    func checkIfAllNotificationInfoIsFetched() {
        fetchedCount += 1
        if fetchedCount == 6 {
            self.loaded = true
            self.activityIndicator.stop()
            self.collectionView.reloadData()
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
        }
    }
}

extension NotificationsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loaded ? notifications.isEmpty ? 1 : notifications.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if notifications.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
            cell.set(withImage: UIImage(named: "notification.empty")!, withTitle: "Nothing to see here —— yet.", withDescription: "Complete your profile and connect with people you know to start receive notifications about your activity.", withButtonText: "   Learn more   ")
            return cell
        } else {
            if notifications[indexPath.row].type.rawValue == 2 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: followCellReuseIdentifier, for: indexPath) as! NotificationFollowCell
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
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor notification: Notification, option: Notification.NotificationMenuOptions) {
        
        switch option {
        case .delete:
            if let indexPath = collectionView.indexPath(for: cell) {
                NotificationService.deleteNotification(withUid: notification.id) { removed in
                    if removed {
                        self.collectionView.performBatchUpdates {
                            self.notifications.remove(at: indexPath.row)
                            self.collectionView.deleteItems(at: [indexPath])
                            let popupView = METopPopupView(title: "Notification successfully deleted", image: "checkmark.circle.fill", popUpType: .regular)
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
                NotificationService.uploadNotification(toUid: uid, fromUser: user, type: .follow)
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
    
    func cell(_ cell: UICollectionViewCell, wantsToViewPost postId: String) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        showLoadingView()
        PostService.fetchPost(withPostId: postId) { post in
            self.dismissLoadingView()
            
            let controller = DetailsPostViewController(post: post, user: user, type: .regular, collectionViewLayout: layout)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            self.navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToViewCase caseId: String) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        showLoadingView()
        
        CaseService.fetchCase(withCaseId: caseId) { clinicalCase in
            
            self.dismissLoadingView()
            
            let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, type: .regular, collectionViewFlowLayout: layout)
            
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

            let newNotificationUserUids = newNotifications.map { $0.uid }
            let newNotificationUniqueUserUids = Array(Set(newNotificationUserUids))
        #warning("Befroe fetching check if some of the new users are already present in the previous user array")

            UserService.fetchUsers(withUids: newNotificationUserUids) { users in
                self.users.append(contentsOf: users)
                self.collectionView.reloadData()
            }
        }
    }
}
