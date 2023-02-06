//
//  FollowersFollowingViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/10/22.
//

import UIKit

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let followFollowingCellReuseIdentifier = "FollowFollowingCellReuseIdentifier"

class FollowersFollowingViewController: UIViewController {
    
    private let user: User
    
    weak var delegate: CollectionViewDidScrollDelegate?
    
    private let topics = ["Followers", "Following"]
    
    private lazy var segmentedButtonsView: FollowersFollowingSegmentedButtonsView = {
        let segmentedButtonsView = FollowersFollowingSegmentedButtonsView()
        segmentedButtonsView.setLabelsTitles(titles: topics)
        segmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        segmentedButtonsView.backgroundColor = .systemBackground
        return segmentedButtonsView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private let followersCollectionView: UICollectionView = {
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
    
    private let followingCollectionView: UICollectionView = {
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
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    private var followersLoaded: Bool = false
    private var followingLoaded: Bool = false
    private var isFetchingOrDidFetchFollowing: Bool = false
    
    private var followers = [User]()
    private var followerIsFollowed = [UserFollow]()
    private var following = [User]()
    private var followingIsFollowed = [UserFollow]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
        fetchFollowerUsers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        followersCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.frame.height)
        followingCollectionView.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: scrollView.frame.height)
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = user.firstName
    }
    
    private func configure() {
        followersCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        followersCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        followersCollectionView.register(UsersFollowFollowingCell.self, forCellWithReuseIdentifier: followFollowingCellReuseIdentifier)
        
        followingCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        followingCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        followingCollectionView.register(UsersFollowFollowingCell.self, forCellWithReuseIdentifier: followFollowingCellReuseIdentifier)
        
        followersCollectionView.delegate = self
        followingCollectionView.delegate = self
        followersCollectionView.dataSource = self
        followingCollectionView.dataSource = self
        
        segmentedButtonsView.segmentedControlDelegate = self
        
        view.backgroundColor = .systemBackground
        
        view.addSubviews(segmentedButtonsView, separatorView, scrollView)
        NSLayoutConstraint.activate([
            segmentedButtonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedButtonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedButtonsView.heightAnchor.constraint(equalToConstant: 51),
            
            separatorView.topAnchor.constraint(equalTo: segmentedButtonsView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.delegate = self
        scrollView.addSubview(followersCollectionView)
        scrollView.addSubview(followingCollectionView)
        scrollView.contentSize.width = view.frame.width * 2
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > scrollView.frame.width * 0.2 &&  !isFetchingOrDidFetchFollowing { fetchFollowingUsers() }
        if scrollView.contentOffset.x == 0 { return }
        
        delegate = segmentedButtonsView
        delegate?.collectionViewDidScroll(for: scrollView.contentOffset.x / 2)
    }
    
    private func fetchFollowerUsers() {
        UserService.fetchFollowers(forUid: user.uid!, completion: { uids in
            uids.forEach { uid in
                UserService.fetchUser(withUid: uid!) { user in
                    self.followers.append(user)
                    UserService.checkIfUserIsFollowed(uid: uid!) { followed in
                        self.followerIsFollowed.append(UserFollow(dictionary: ["uid": uid!, "isFollow": followed]))
                        if self.followerIsFollowed.count == uids.count {
                            self.followersLoaded = true
                            self.followersCollectionView.reloadData()
                        }
                    }
                }
            }
        })
    }
    
    func fetchFollowingUsers() {
        isFetchingOrDidFetchFollowing = true
        UserService.fetchFollowing(forUid: user.uid!, completion: { uids in
            UserService.fetchUsers(withUids: uids) { users in
                self.following = users
                users.forEach({ self.followingIsFollowed.append(UserFollow(dictionary: ["uid": $0.uid!, "isFollow": true])) })
                self.followingLoaded = true
                self.followingCollectionView.reloadData()
                #warning("Create an array followoingIsfollowed with all to true in case user unfollows any following")
            }
        })
    }
}

extension FollowersFollowingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == followersCollectionView {
            return followersLoaded ? followers.isEmpty ? 1 : followers.count : 0
        } else {
            return followingLoaded ? following.isEmpty ? 1 : following.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == followersCollectionView {
            return followersLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 50)
        } else {
            return followingLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: followFollowingCellReuseIdentifier, for: indexPath) as! UsersFollowFollowingCell

        if collectionView == followersCollectionView {
            cell.followerDelegate = self
            cell.user = followers[indexPath.row]
            
            let userIndex = followerIsFollowed.firstIndex { user in
                if user.uid == followers[indexPath.row].uid! {
                    return true
                }
                return false
            }
            
            if let userIndex = userIndex {
                cell.userIsFollowing = followerIsFollowed[userIndex].isFollow
            }
            
        } else {
            cell.followingDelegate = self
            cell.user = following[indexPath.row]
            cell.userIsFollowing = true
        }
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == followersCollectionView {
            guard !followers.isEmpty else { return }
            
            let controller = UserProfileViewController(user: followers[indexPath.row])
            
            let backItem = UIBarButtonItem()
            backItem.tintColor = .label
            backItem.title = ""
            
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        } else {
            guard !following.isEmpty else { return }
            let controller = UserProfileViewController(user: following[indexPath.row])
            
            let backItem = UIBarButtonItem()
            backItem.tintColor = .label
            backItem.title = ""
            
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

//MARK: - SegmentedControlDelegate

extension FollowersFollowingViewController: SegmentedControlDelegate {
    func indexDidChange(from currentIndex: Int, to index: Int) {
        if currentIndex == index { return }

        switch currentIndex {
        case 0:
            let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x + view.frame.width))
            self.moveToFrame(contentOffset: contentOffset)
            
        case 1:
            let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x - view.frame.width))
            self.moveToFrame(contentOffset: contentOffset)
            
        default:
            print("Not found index to change position")
        }
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        UIView.animate(withDuration: 1) {
            self.scrollView.setContentOffset(CGPoint(x: contentOffset, y: self.scrollView.bounds.origin.y), animated: true)
        }
    }
}

extension FollowersFollowingViewController: UsersFollowCellDelegate, UsersFollowingCellDelegate {
    func didFollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! UsersFollowFollowingCell
        UserService.follow(uid: user.uid!) { error in
            currentCell.isUpdatingFollowState = false
            if let _ = error {
                return
            }
            
            currentCell.userIsFollowing = true
            
            if let index = self.followerIsFollowed.firstIndex(where: { $0.uid == user.uid }) {
                self.followerIsFollowed[index].isFollow = true
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
            
            if let index = self.followerIsFollowed.firstIndex(where: { $0.uid == user.uid }) {
                self.followerIsFollowed[index].isFollow = false
                
                // Delete the user in the following UICollectionView
                if let followingIndex = self.following.firstIndex(where: { $0.uid == user.uid }), let following = self.followingIsFollowed.firstIndex(where: { $0.uid == user.uid }) {
                    self.following.remove(at: followingIndex)
                    self.followingIsFollowed.remove(at: following)
                    self.followingCollectionView.reloadData()
                }
            }
            
            PostService.updateUserFeedAfterFollowing(userUid: user.uid!, didFollow: false)
        }
    }
    
    func didFollowOnFollowing(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! UsersFollowFollowingCell
        UserService.follow(uid: user.uid!) { error in
            currentCell.isUpdatingFollowState = false
            if let _ = error {
                return
            }
            
            currentCell.userIsFollowing = true
            
            if let index = self.followingIsFollowed.firstIndex(where: { $0.uid == user.uid }) {
                self.followingIsFollowed[index].isFollow = true
            }
            
            PostService.updateUserFeedAfterFollowing(userUid: user.uid!, didFollow: true)
        }
    }
    
    func didUnfollowOnFollowing(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! UsersFollowFollowingCell
        UserService.unfollow(uid: user.uid!) { error in
            currentCell.isUpdatingFollowState = false
            if let _ = error {
                return
            }
            
            currentCell.userIsFollowing = false
            
            if let index = self.followingIsFollowed.firstIndex(where: { $0.uid == user.uid }) {
                self.followingIsFollowed[index].isFollow = false
            }
            
            PostService.updateUserFeedAfterFollowing(userUid: user.uid!, didFollow: false)
        }
    }
}
