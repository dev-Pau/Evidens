//
//  NotificationsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/8/22.
//

import UIKit

private let followCellReuseIdentifier = "FollowCellReuseIdentifier"
private let likeCellReuseIdentifier = "LikeCellReuseIdentifier"

class NotificationsViewController: UICollectionViewController {
    
    //MARK: - Properties
    
    private var notifications = [Notification]() {
        didSet { collectionView.reloadData() }
    }
    
    private lazy var notificationMenu = NotificationMenuLauncher()
    
    private lazy var userImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        let atrString = NSAttributedString(string: "Search", attributes: [.font : UIFont.systemFont(ofSize: 15)])
        searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.tintColor = primaryColor
        searchBar.searchTextField.backgroundColor = lightColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        // To resign first responder
        //navigationController?.navigationBar.isHidden = false
        searchBar.resignFirstResponder()
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), style: .plain, target: self, action: #selector(didTapChat))
        
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        userImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        userImageView.layer.cornerRadius = 35 / 2
        let profileImageItem = UIBarButtonItem(customView: userImageView)
        userImageView.sd_setImage(with: URL(string: UserDefaults.standard.value(forKey: "userProfileImageUrl") as! String))
        navigationItem.leftBarButtonItem = profileImageItem
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func configureCollectionView() {
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
    
    @objc func didTapChat() {
        
    }
    
    @objc func didTapProfile() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let controller = UserProfileViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        backItem.tintColor = .black
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleRefresh() {
        notifications.removeAll()
        fetchNotifications()
        refresher.endRefreshing()
    }
    
}

extension NotificationsViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notifications.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
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

extension NotificationsViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        backItem.tintColor = .black
        
        let controller = SearchViewController()
        navigationController?.pushViewController(controller, animated: true)

        return true
    }
}

extension NotificationsViewController: NotificationCellDelegate {
    

    func cell(_ cell: UICollectionViewCell, wantsToFollow uid: String, firstName: String) {
        UserService.unfollow(uid: uid) { error in
            if let _ = error {
                return
            }
            let reportPopup = METopPopupView(title: "You followed \(firstName)", image: "plus.circle.fill")
            reportPopup.showTopPopup(inView: self.view)
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToUnfollow uid: String, firstName: String) {
        UserService.unfollow(uid: uid) { error in
            if let _ = error {
                return
            }
            let reportPopup = METopPopupView(title: "You unfollowed \(firstName)", image: "xmark.circle.fill")
            reportPopup.showTopPopup(inView: self.view)
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToViewPost postId: String) {
        print("view psot")
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
        }
    }
}
