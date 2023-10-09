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
    
    private var viewModel = NotificationsViewModel()

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
        
        collectionView.register(NotificationConnectionCell.self, forCellWithReuseIdentifier: followCellReuseIdentifier)
        collectionView.register(NotificationLikeCommentCell.self, forCellWithReuseIdentifier: likeCellReuseIdentifier)
       
        collectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    private func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectionDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.connectUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
    }
    
    private func reloadData() {
        activityIndicator.stop()
        collectionView.reloadData()
        collectionView.isHidden = false
        collectionView.refreshControl?.endRefreshing()
    }
    
    private func loadNotifications() {
        viewModel.getNotifications()
        collectionView.reloadData()
    }
    
    private func fetchNotifications() {
        viewModel.getNewNotifications { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.reloadData()
        }
    }

    @objc func handleRefresh() {
        self.collectionView.refreshControl?.endRefreshing()
        
        HapticsManager.shared.triggerLightImpact()
 
        let cooldownTime: TimeInterval = 15.0
        if let lastRefreshTime = viewModel.lastRefreshTime, Date().timeIntervalSince(lastRefreshTime) < cooldownTime {

            collectionView.refreshControl?.endRefreshing()
            return
        }
        
        viewModel.lastRefreshTime = Date()

        DispatchQueue.main.asyncAfter(deadline: .now() + cooldownTime) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.lastRefreshTime = nil
        }
        
        fetchNotifications()
    }
}

extension NotificationsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.loaded ? viewModel.notifications.isEmpty ? 1 : viewModel.notifications.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.notifications.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
            cell.delegate = self
            cell.set(withTitle: AppStrings.Notifications.Empty.title, withDescription: AppStrings.Notifications.Empty.content, withButtonText: AppStrings.Content.Post.Feed.start)
            return cell
        } else {
            let notification = viewModel.notifications[indexPath.row]
            switch notification.kind {
                
            case .connectionRequest:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: followCellReuseIdentifier, for: indexPath) as! NotificationConnectionCell
                cell.viewModel = NotificationViewModel(notification: viewModel.notifications[indexPath.row])
                cell.delegate = self
                
                return cell
            case .likePost, .likeCase:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: likeCellReuseIdentifier, for: indexPath) as! NotificationLikeCommentCell
                cell.viewModel = NotificationViewModel(notification: viewModel.notifications[indexPath.row])
                cell.delegate = self
                
                return cell
                
            case .replyPost, .replyCase, .replyPostComment, .replyCaseComment, .likePostReply, .likeCaseReply, .connectionAccept:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: likeCellReuseIdentifier, for: indexPath) as! NotificationLikeCommentCell
                cell.viewModel = NotificationViewModel(notification: viewModel.notifications[indexPath.row])
                cell.delegate = self
                
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !viewModel.notifications.isEmpty else {
            return
        }
        
        if viewModel.notifications[indexPath.row].kind == .connectionRequest {
            let uid = viewModel.notifications[indexPath.row].uid
            let controller = UserProfileViewController(uid: uid)
            navigationController?.pushViewController(controller, animated: true)
            if !viewModel.notifications[indexPath.row].isRead  {
                viewModel.notifications[indexPath.row].set(isRead: true)
                DataService.shared.read(notification: viewModel.notifications[indexPath.row])
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
        switch notification.kind {

        case .likePost:
            guard let contentId = notification.contentId else { return }
            let controller = DetailsPostViewController(postId: contentId, collectionViewLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
            viewModel.notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: viewModel.notifications[indexPath.row])
            collectionView.reloadData()
            
        case .likeCase:
            guard let contentId = notification.contentId else { return }
            let controller = DetailsCaseViewController(caseId: contentId, collectionViewLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
            viewModel.notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: viewModel.notifications[indexPath.row])
            collectionView.reloadData()
        case .connectionRequest:
            break
        case .replyPost:
            guard let contentId = notification.contentId else { return }
            let controller = DetailsPostViewController(postId: contentId, collectionViewLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
            viewModel.notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: viewModel.notifications[indexPath.row])
            collectionView.reloadData()
            
        case .replyCase:
            guard let contentId = notification.contentId else { return }
            let controller = DetailsCaseViewController(caseId: contentId, collectionViewLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
            viewModel.notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: viewModel.notifications[indexPath.row])
            collectionView.reloadData()
            
        case .replyPostComment:
            guard let contentId = notification.contentId, let path = notification.path?.dropLast(), let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            let controller = CommentPostRepliesViewController(postId: contentId, uid: uid, path: Array(path))
            navigationController?.pushViewController(controller, animated: true)
            viewModel.notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: viewModel.notifications[indexPath.row])
            collectionView.reloadData()
            
        case .replyCaseComment:
            guard let contentId = notification.contentId, let path = notification.path?.dropLast(), let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            let controller = CommentCaseRepliesViewController(caseId: contentId, uid: uid, path: Array(path))
            navigationController?.pushViewController(controller, animated: true)
            viewModel.notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: viewModel.notifications[indexPath.row])
            collectionView.reloadData()
        case .likePostReply:
            guard let contentId = notification.contentId, let path = notification.path, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            let controller = CommentPostRepliesViewController(postId: contentId, uid: uid, path: path)
            navigationController?.pushViewController(controller, animated: true)
            viewModel.notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: viewModel.notifications[indexPath.row])
            collectionView.reloadData()
        case .likeCaseReply:
            guard let contentId = notification.contentId, let path = notification.path, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            let controller = CommentCaseRepliesViewController(caseId: contentId, uid: uid, path: path)
            navigationController?.pushViewController(controller, animated: true)
            viewModel.notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: viewModel.notifications[indexPath.row])
            collectionView.reloadData()
        case .connectionAccept:
            let controller = UserProfileViewController(uid: notification.uid)
            navigationController?.pushViewController(controller, animated: true)
            viewModel.notifications[indexPath.row].set(isRead: true)
            DataService.shared.read(notification: viewModel.notifications[indexPath.row])
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
                            
                            DataService.shared.delete(notification: strongSelf.viewModel.notifications[indexPath.row])
                            
                            strongSelf.viewModel.notifications.remove(at: indexPath.row)
                            if !strongSelf.viewModel.notifications.isEmpty {
                                strongSelf.collectionView.deleteItems(at: [indexPath])
                            }
                            
                            let popupView = PopUpBanner(title: AppStrings.Notifications.Delete.title, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                            popupView.showTopPopup(inView: strongSelf.view)

                        } completion: { [weak self] _ in
                            guard let strongSelf = self else { return }
                            if strongSelf.viewModel.notifications.isEmpty {
                                strongSelf.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }

    func cell(_ cell: UICollectionViewCell, wantsToConnect uid: String) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        guard NetworkMonitor.shared.isConnected else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.network)
            return
        }
        
        let notification = viewModel.notifications[indexPath.row]
        
        viewModel.notifications.remove(at: indexPath.row)
        
        if !viewModel.notifications.isEmpty {
            collectionView.deleteItems(at: [indexPath])
        } else {
            collectionView.reloadData()
        }

        viewModel.connect(withUid: uid, currentUser: currentUser) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
            
            DataService.shared.delete(notification: notification)
            NotificationService.deleteNotification(withId: notification.id) { _ in }
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToIgnore uid: String) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard let tab = tabBarController as? MainTabController else { return }
        
        guard NetworkMonitor.shared.isConnected else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.network)
            return
        }
        
        let notification = viewModel.notifications[indexPath.row]
        
        viewModel.notifications.remove(at: indexPath.row)
        
        if !viewModel.notifications.isEmpty {
            collectionView.deleteItems(at: [indexPath])
        } else {
            collectionView.reloadData()
        }
        
        viewModel.ignore(withUid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
            
            DataService.shared.delete(notification: notification)
            NotificationService.deleteNotification(withId: notification.id) { _ in }
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToViewProfile uid: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let notification = viewModel.notifications[indexPath.row]
        guard !notification.uid.isEmpty else { return }
        let controller = UserProfileViewController(uid: notification.uid)
        navigationController?.pushViewController(controller, animated: true)
        viewModel.notifications[indexPath.row].set(isRead: true)
        DataService.shared.read(notification: viewModel.notifications[indexPath.row])
        collectionView.reloadData()
    }
}

extension NotificationsViewController {
    func getMoreNotifications() {
        viewModel.getMoreNotifications { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
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

//MARK: - User Changes

extension NotificationsViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            if let index = viewModel.users.firstIndex(where: { $0.uid! == user.uid! }) {
                viewModel.users[index] = user
                collectionView.reloadData()
            }
        }
    }
}

extension NotificationsViewController: UserConnectDelegate {
    func userDidChangeConnection(uid: String, phase: ConnectPhase) {
        viewModel.currentNotification = true
        ContentManager.shared.userConnectionChange(uid: uid, phase: phase)
    }
    
    @objc func connectionDidChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? UserConnectionChange {
            if let index = viewModel.notifications.firstIndex(where: { $0.kind == .connectionRequest && $0.uid == change.uid }) {
                viewModel.notifications.remove(at: index)
                collectionView.reloadData()
            }
            
            DataService.shared.deleteNotification(forKind: .connectionRequest, withUid: change.uid)

        }
    }
}


    
