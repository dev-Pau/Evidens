//
//  HomeOnboardingViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/2/23.
//

import UIKit

private let loadingCellReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let onboardingHeaderReuseIdentifier = "OnboardingHeaderReuseIdentifier"
private let followFollowingCellReuseIdentifier = "FollowFollowingCellReuseIdentifier"

protocol HomeOnboardingViewControllerDelegate: AnyObject {
    func didUpdateUser(user: User)
}

class HomeOnboardingViewController: UIViewController {
    
    weak var delegate: HomeOnboardingViewControllerDelegate?
    
    private var user: User
    
    private var users = [User]()
    private var userIsFollowed = [UserFollow]()
    private var followersLoaded: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        fetchUsers()
    }
    
    private func fetchUsers() {
        UserService.fetchUsers { users in
            self.users = users
            users.forEach { user in
                UserService.checkIfUserIsFollowed(uid: user.uid!) { followed in
                    self.userIsFollowed.append(UserFollow(dictionary: ["uid": user.uid!, "isFollow": followed]))
                    if self.userIsFollowed.count == users.count {
                        self.followersLoaded = true
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    private func configureNavigationBar() {
        title = "Connect"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingCellReuseIdentifier)
        collectionView.register(OnboardingHomeHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: onboardingHeaderReuseIdentifier)
        collectionView.register(UsersFollowFollowingCell.self, forCellWithReuseIdentifier: followFollowingCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension HomeOnboardingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return followersLoaded ? users.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if followersLoaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: onboardingHeaderReuseIdentifier, for: indexPath) as! OnboardingHomeHeader
            header.delegate = self
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingCellReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: followersLoaded ? 145 : 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: followFollowingCellReuseIdentifier, for: indexPath) as! UsersFollowFollowingCell
        cell.user = users[indexPath.row]
        
        cell.followerDelegate = self

        let userIndex = userIsFollowed.firstIndex { user in
            if user.uid == users[indexPath.row].uid! {
                return true
            }
            return false
        }
        
        if let userIndex = userIndex {
            cell.userIsFollowing = userIsFollowed[userIndex].isFollow
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
}

extension HomeOnboardingViewController: OnboardingHomeHeaderDelegate {
    func didTapConfigureProfile() {
        let controller = ImageRegistrationViewController(user: user)
        controller.comesFromHomeOnboarding = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("UserUpdateIdentifier"), object: nil)
        
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen

        present(navVC, animated: true)
    }
    
    @objc func didReceiveNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo!["user"] as? User {
            delegate?.didUpdateUser(user: userInfo)
            let controller = UserProfileViewController(user: userInfo)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension HomeOnboardingViewController: UsersFollowCellDelegate {
    func didFollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! UsersFollowFollowingCell
        UserService.follow(uid: user.uid!) { error in
            currentCell.isUpdatingFollowState = false
            if let _ = error {
                return
            }
            
            currentCell.userIsFollowing = true
            
            if let index = self.userIsFollowed.firstIndex(where: { $0.uid == user.uid }) {
                self.userIsFollowed[index].isFollow = true
            }
            
            PostService.updateUserFeedAfterFollowing(userUid: user.uid!, didFollow: true)
        }
    }
    
    func didUnfollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! UsersFollowFollowingCell
        UserService.unfollow(uid: user.uid!) { error in
            currentCell.isUpdatingFollowState = false
            if let _ = error {
                return
            }
            
            currentCell.userIsFollowing = false
            
            if let index = self.userIsFollowed.firstIndex(where: { $0.uid == user.uid }) {
                self.userIsFollowed[index].isFollow = false
            }
            
            PostService.updateUserFeedAfterFollowing(userUid: user.uid!, didFollow: false)
        }
    }
}
