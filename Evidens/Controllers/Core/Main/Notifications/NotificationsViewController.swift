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
private let skeletonNotificationCellReuseIdentifier = "SekeletonNotificationCellReuseIdentifier"

class NotificationsViewController: NavigationBarViewController {
    
    //MARK: - Properties
    
    private var notifications = [Notification]()
    private var users = [User]()
    
    private var loaded: Bool = false
    
    private var notificationsLastSnapshot: QueryDocumentSnapshot?
    
    private lazy var notificationMenu = NotificationMenuLauncher()
    
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
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No notifications yet"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Complete your profile and connect with people you know to start receive notifications about your activity."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isHidden = false
        titleLabel.isHidden = true
        descriptionLabel.isHidden = true
        configureCollectionView()
        fetchNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loaded { collectionView.reloadData() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if loaded {
            fetchNotifications()
        }
    }
    
    private func configureCollectionView() {
        title = "Notifications"
        //let navLabel = UILabel()
        //let navTitle = NSMutableAttributedString(string: "Notifications", attributes:[.font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)])
        //navLabel.attributedText = navTitle
        //navigationItem.titleView = navLabel
                                    
        view.addSubviews(collectionView, titleLabel, descriptionLabel)
        //collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NotificationFollowCell.self, forCellWithReuseIdentifier: followCellReuseIdentifier)
        collectionView.register(NotificationLikeCommentCell.self, forCellWithReuseIdentifier: likeCellReuseIdentifier)
        collectionView.register(SkeletonNotificationCell.self, forCellWithReuseIdentifier: skeletonNotificationCellReuseIdentifier)
       
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    private func fetchNotifications() {

        NotificationService.fetchNotifications(lastSnapshot: nil) { snapshot in

            if snapshot.count == 0 {
                // User don't have any notification, display view
                self.titleLabel.isHidden = false
                self.descriptionLabel.isHidden = false
                self.collectionView.isHidden = true
                return
            }

            self.notificationsLastSnapshot = snapshot.documents.last
            self.notifications = snapshot.documents.map({ Notification(dictionary: $0.data()) })
            
            self.notifications.forEach { notification in
                UserService.fetchUser(withUid: notification.uid) { user in
                    self.users.append(user)
                    self.loaded = true
                    self.collectionView.isScrollEnabled = true
                    self.collectionView.reloadData()
                }
            }
            
            self.collectionView.isHidden = false
            self.titleLabel.isHidden = true
            self.descriptionLabel.isHidden = true
            self.checkIfUserIsFollowed()
            
        }
    }
    
    func checkIfUserIsFollowed() {
        notifications.forEach { notification in
            guard notification.type == .follow else { return }
            
            UserService.checkIfUserIsFollowed(uid: notification.uid) { isFollowed in
                if let index = self.notifications.firstIndex(where: { $0.id == notification.id }) {
                    self.notifications[index].userIsFollowed = isFollowed
                }
            }
        }
    }
}

extension NotificationsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loaded ? notifications.count : 15
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if !loaded {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: skeletonNotificationCellReuseIdentifier, for: indexPath) as! SkeletonNotificationCell
            return cell
        }
        
        if notifications[indexPath.row].type.rawValue == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: followCellReuseIdentifier, for: indexPath) as! NotificationFollowCell
            cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
            cell.delegate = self
            
            let userIndex = users.firstIndex { user in
                if user.uid == notifications[indexPath.row].uid {
                    return true
                }
                return false
            }
            
            if let userIndex = userIndex {
                cell.set(user: users[userIndex])
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: likeCellReuseIdentifier, for: indexPath) as! NotificationLikeCommentCell
            cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
            cell.delegate = self
            
            
            let userIndex = users.firstIndex { user in
                if user.uid == notifications[indexPath.row].uid {
                    return true
                }
                return false
            }
            
            if let userIndex = userIndex {
                cell.set(user: users[userIndex])
            }
            
            return cell
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
    

    func cell(_ cell: UICollectionViewCell, wantsToFollow uid: String, firstName: String) {
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
                
                let reportPopup = METopPopupView(title: "You followed \(firstName)", image: "plus.circle.fill", popUpType: .regular)
                reportPopup.showTopPopup(inView: self.view)
                PostService.updateUserFeedAfterFollowing(userUid: uid, didFollow: true)
                NotificationService.uploadNotification(toUid: uid, fromUser: user, type: .follow)
            }
        default:
            break
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToUnfollow uid: String, firstName: String) {
        switch cell {
        case is NotificationFollowCell:
            let currentCell = cell as! NotificationFollowCell
            currentCell.viewModel?.notification.userIsFollowed = false
            UserService.unfollow(uid: uid) { error in
                if let _ = error {
                    return
                }

                let reportPopup = METopPopupView(title: "You unfollowed \(firstName)", image: "xmark.circle.fill", popUpType: .regular)
                reportPopup.showTopPopup(inView: self.view)
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
            
            let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
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
            
            let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(controller, animated: true)
        }

    }
    
    
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor notification: Notification) {
        notificationMenu.showNotificationSettings(in: view)
        notificationMenu.completion = { delete in
            print("Completion delete")
            if delete {
                print("DELETE Go")

                if let indexPath = self.collectionView.indexPath(for: cell) {
                    NotificationService.deleteNotification(withUid: notification.id) { removed in
                        if removed {
                            self.collectionView.performBatchUpdates {
                                self.notifications.remove(at: indexPath.item)
                                self.users.remove(at: indexPath.item)
                                self.collectionView.deleteItems(at: [indexPath])
                            }
                            
                            if self.notifications.count == 0 {
                                self.collectionView.isHidden = true
                                self.titleLabel.isHidden = false
                                self.descriptionLabel.isHidden = false
                                
                            }
                            
                            let popupView = METopPopupView(title: "Notification deleted", image: "trash", popUpType: .destructive)
                            popupView.showTopPopup(inView: self.view)
                        } else {
                            print("couldnt remove notification")
                        }
                    }
                }
            }
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
            self.notificationsLastSnapshot = snapshot.documents.last
            let documents = snapshot.documents
            let newNotifications = documents.map({ Notification(dictionary: $0.data()) })
            self.notifications.append(contentsOf: newNotifications)
            
            newNotifications.forEach { notification in
                UserService.fetchUser(withUid: notification.uid) { user in
                    self.users.append(user)
                    self.collectionView.reloadData()
                }
            }
        }
    }
}
