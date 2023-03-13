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

class WhoToFollowViewController: UIViewController {
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
        fetchUsers()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
    }
    
    private func configureNavigationBar() {

    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(WhoToFollowCell.self, forCellWithReuseIdentifier: whoToFollowReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
    }
    
    private func fetchUsers() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        UserService.fetchUsersToFollow(forUser: user, lastSnapshot: nil) { snapshot in
            self.usersLastSnapshot = snapshot.documents.last
            self.users = snapshot.documents.map({ User(dictionary: $0.data() )})
            self.users.enumerated().forEach { index, user in
                UserService.checkIfUserIsFollowed(uid: user.uid!) { followed in
                    self.users[index].isFollowed = followed
                    self.usersLoaded = true
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func getMoreUsers() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        UserService.fetchUsersToFollow(forUser: user, lastSnapshot: usersLastSnapshot) { snapshot in
            self.usersLastSnapshot = snapshot.documents.last
            //self.users = snapshot.documents.map({ User(dictionary: $0.data() )})
            var newUsers = snapshot.documents.map({ User(dictionary: $0.data() )})
            newUsers.enumerated().forEach { index, user in
                UserService.checkIfUserIsFollowed(uid: user.uid!) { followed in
                    //self.users[index].isFollowed = followed
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowReuseIdentifier, for: indexPath) as! WhoToFollowCell
        cell.configureWithUser(user: users[indexPath.row])
        cell.followerDelegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return usersLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 20, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let controller = UserProfileViewController()
        //controller.topBarHeight = topbarHeight
        //navigationController?.pushViewController(controller, animated: true)
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
            
            PostService.updateUserFeedAfterFollowing(userUid: user.uid!, didFollow: true)
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
            
            PostService.updateUserFeedAfterFollowing(userUid: user.uid!, didFollow: false)
        }
    }
}
