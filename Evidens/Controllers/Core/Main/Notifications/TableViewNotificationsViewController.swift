//
//  NotificationsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class TableViewNotificationsViewController: UITableViewController {
    
    //MARK: - Properties
    
    private let userImageView: UIImageView = {
        let iv = UIImageView()
        //iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
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
    
  
    private var notifications = [Notification]() {
        didSet { tableView.reloadData() }
    }
    
    private let refresher = UIRefreshControl()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        fetchNotifications()
        view.backgroundColor = .white
    }
    
    //MARK: - API
    
    func fetchNotifications() {
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
    
    //MARK: - Actions
    
    @objc func handleRefresh() {
        notifications.removeAll()
        fetchNotifications()
        refresher.endRefreshing()
    }
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane.fill"), style: .plain, target: self, action: #selector(didTapChat))
        
        navigationItem.rightBarButtonItem?.tintColor = .darkGray
        
        userImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        userImageView.layer.cornerRadius = 35 / 2
        let profileImageItem = UIBarButtonItem(customView: userImageView)
        userImageView.sd_setImage(with: URL(string: UserDefaults.standard.value(forKey: "userProfileImageUrl") as! String))
        navigationItem.leftBarButtonItem = profileImageItem
        
        navigationItem.titleView = searchBar
        
    }
    
    func configureTableView() {
        view.backgroundColor = .white
        
        
        tableView.register(NotificationFollowCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 150
        tableView.separatorStyle = .none
        
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refresher
    }
    
    @objc func didTapChat() {
        
    }
}

//MARK: - UITableViewDataSource

extension TableViewNotificationsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationFollowCell
        cell.delegate = self
        cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
        cell.backgroundColor = .white
        return cell
    }
     */
}

//MARK: - UITableViewDelegate

extension TableViewNotificationsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postId = notifications[indexPath.row].postId
        //Check if notification has a post associated
        if postId != "" {
            guard let postId = postId else { return }
            PostService.fetchPost(withPostId: postId) { post in
                let controller = HomeViewController()
                //controller.post = post
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

//MARK: - NotificationCellDelegate
/*
extension TableViewNotificationsViewController: NotificationCellDelegate {

    
    func cell(_ cell: NotificationFollowCell, wantsToViewProfile uid: String) {
        UserService.fetchUser(withUid: uid) { user in
            let controller = ProfileViewController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: NotificationFollowCell, wantsToFollow uid: String) {
        UserService.follow(uid: uid) { _ in
            cell.viewModel?.notification.userIsFollowed.toggle()
        }

    }
    
    func cell(_ cell: NotificationFollowCell, wantsToUnfollow uid: String) {
        UserService.unfollow(uid: uid) { _ in
            cell.viewModel?.notification.userIsFollowed.toggle()
        }
    }
    
    //TASK: - Search how to call this function on a generic cell click (if post is associated with the notification)
    func cell(_ cell: NotificationFollowCell, wantsToViewPost postId: String) {
        PostService.fetchPost(withPostId: postId) { post in
            let controller = HomeViewController(collectionViewLayout: UICollectionViewFlowLayout())
            controller.post = post
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    */
    

