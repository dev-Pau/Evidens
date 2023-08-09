//
//  WhoToFollowViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/3/23.
//

import UIKit
import Firebase

private let whoToFollowReuseIdentifier = "WhoToFollowReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let emptyUsersCellReuseIdentifier = "EmptyUsersCellReuseIdentifier"

class WhoToFollowViewController: UIViewController {
    private var user: User
    private var usersLastSnapshot: QueryDocumentSnapshot?
    private var users = [User]()
    private var usersLoaded: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
        fetchUsers()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {

    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(WhoToFollowCell.self, forCellWithReuseIdentifier: whoToFollowReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyUsersCellReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
    }
    
    private func fetchUsers() {
        UserService.fetchUsersToFollow(forUser: user, lastSnapshot: nil) { snapshot in
            guard !snapshot.isEmpty else {
                self.usersLoaded = true
                self.collectionView.reloadData()
                return
            }

            self.usersLastSnapshot = snapshot.documents.last
            self.users = snapshot.documents.map({ User(dictionary: $0.data() )})
            var count = 0
            self.users.enumerated().forEach { index, user in
                UserService.checkIfUserIsFollowed(uid: user.uid!) { followed in
                    self.users[index].isFollowed = followed
                    count += 1
                    if count == self.users.count {
                        self.usersLoaded = true
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    private func getMoreUsers() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        UserService.fetchUsersToFollow(forUser: user, lastSnapshot: usersLastSnapshot) { snapshot in
            self.usersLastSnapshot = snapshot.documents.last
            var newUsers = snapshot.documents.map({ User(dictionary: $0.data() )})
            newUsers.enumerated().forEach { index, user in
                UserService.checkIfUserIsFollowed(uid: user.uid!) { followed in
                    newUsers[index].isFollowed = followed
                    self.users.append(newUsers[index])
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            getMoreUsers()
        }
    }
}

extension WhoToFollowViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usersLoaded ? users.isEmpty ? 1 : users.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if users.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyUsersCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.User.emptyTitle, description: AppStrings.Content.User.emptyContent, content: .dismiss)
            cell.delegate = self
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowReuseIdentifier, for: indexPath) as! WhoToFollowCell
        cell.configureWithUser(user: users[indexPath.row])
        cell.followerDelegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return usersLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return users.isEmpty ? CGSize(width: view.frame.width - 20, height: view.frame.width) : CGSize(width: view.frame.width - 20, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = UserProfileViewController(user: users[indexPath.row])
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
        controller.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension WhoToFollowViewController: UsersFollowCellDelegate {
    func didFollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! WhoToFollowCell
        UserService.follow(uid: user.uid!) { error in
            currentCell.isUpdatingFollowState = false
            if let _ = error {
                return
            }
            
            currentCell.userIsFollowing = true
            
            if let indexPath = self.collectionView.indexPath(for: cell) {
                self.users[indexPath.row].isFollowed = true
            }
            
        
        }
    }
    
    func didUnfollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! WhoToFollowCell
        UserService.unfollow(uid: user.uid!) { error in
            currentCell.isUpdatingFollowState = false
            if let _ = error {
                return
            }
            
            currentCell.userIsFollowing = false
            
            if let indexPath = self.collectionView.indexPath(for: cell) {
                self.users[indexPath.row].isFollowed = false
            }
            
        }
    }
}

extension WhoToFollowViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        navigationController?.popViewController(animated: true)
    }
}

extension WhoToFollowViewController: UserProfileViewControllerDelegate {
    func didFollowUser(user: User, didFollow: Bool) {
        if let userIndex = users.firstIndex(where: { $0.uid! == user.uid! }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: userIndex, section: 0)) as? WhoToFollowCell {
                if didFollow {
                    didFollowOnFollower(cell, user: user)
                } else {
                    didUnfollowOnFollower(cell, user: user)
                }
            }
        }
    }
}
