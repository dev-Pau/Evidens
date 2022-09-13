//
//  NotificationsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/8/22.
//

import UIKit

private let followCellReuseIdentifier = "FollowCellReuseIdentifier"
private let likeCellReuseIdentifier = "LikeCellReuseIdentifier"

class NotificationsViewController: NavigationBarViewController {
    
    //MARK: - Properties
    
    private var notifications = [Notification]() {
        didSet { collectionView.reloadData() }
    }
    
    private lazy var notificationMenu = NotificationMenuLauncher()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = lightColor
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchNotifications()
    }

    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NotificationFollowCell.self, forCellWithReuseIdentifier: followCellReuseIdentifier)
        collectionView.register(NotificationLikeCommentCell.self, forCellWithReuseIdentifier: likeCellReuseIdentifier)
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    private func fetchNotifications() {
        NotificationService.fetchNotifications { notifications in
            self.notifications = notifications
            //Check if user is followed to update notifications button
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
    
    @objc func handleRefresh() {
        notifications.removeAll()
        fetchNotifications()
        refresher.endRefreshing()
    }
    
}

extension NotificationsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notifications.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if notifications[indexPath.row].type.rawValue == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: followCellReuseIdentifier, for: indexPath) as! NotificationFollowCell
            cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
            cell.delegate = self
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: likeCellReuseIdentifier, for: indexPath) as! NotificationLikeCommentCell
            cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
            cell.delegate = self
            return cell
        }

    }
}

extension NotificationsViewController: NotificationCellDelegate {
    

    func cell(_ cell: UICollectionViewCell, wantsToFollow uid: String, firstName: String) {
        switch cell {
        case is NotificationFollowCell:
            print("fljdskjklfljkfd")
            let currentCell = cell as! NotificationFollowCell
            UserService.unfollow(uid: uid) { error in
                if let _ = error {
                    return
                }
                
                currentCell.viewModel?.notification.userIsFollowed.toggle()
                let reportPopup = METopPopupView(title: "You followed \(firstName)", image: "plus.circle.fill")
                reportPopup.showTopPopup(inView: self.view)
            }
        default:
            print("Not registered")
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToUnfollow uid: String, firstName: String) {
        switch cell {
        case is NotificationFollowCell:
            print("flkjldjs")
            let currentCell = cell as! NotificationFollowCell
            UserService.unfollow(uid: uid) { error in
                if let _ = error {
                    return
                }

                currentCell.viewModel?.notification.userIsFollowed.toggle()
                let reportPopup = METopPopupView(title: "You unfollowed \(firstName)", image: "xmark.circle.fill")
                reportPopup.showTopPopup(inView: self.view)
            }
        default:
            print("Not registered")
        }
        
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToViewPost postId: String) {
        print("view post")
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToViewCase caseId: String) {
        print("show case here")
    }
    
    
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor notification: Notification) {
        notificationMenu.showNotificationSettings(in: view)
        notificationMenu.completion = { delete in
            if delete {
                // User wants to delete conversation
                if let indexPath = self.collectionView.indexPath(for: cell) {
                    NotificationService.deleteNotification(withUid: notification.id) { removed in
                        if removed {
                            self.collectionView.performBatchUpdates {
                                self.notifications.remove(at: indexPath.item)
                                self.collectionView.deleteItems(at: [indexPath])
                            }
                            let popupView = METopPopupView(title: "Notification deleted", image: "trash")
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
        UserService.fetchUser(withUid: uid) { user in
            let controller = UserProfileViewController(user: user)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .black
            self.navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(controller, animated: true)
            DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
        }
    }
}
