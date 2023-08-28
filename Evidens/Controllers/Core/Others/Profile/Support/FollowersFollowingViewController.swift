//
//  FollowersFollowingViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/10/22.
//

import UIKit
import Firebase

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let followFollowingCellReuseIdentifier = "FollowFollowingCellReuseIdentifier"
private let networkCellReuseIdentifier = "NetworkCellReuseIdentifier"

class FollowersFollowingViewController: UIViewController {
    
    private let user: User
    weak var delegate: CollectionViewDidScrollDelegate?
    
    private let networkToolbar = NetworkToolbar()
    private var spacingView = SpacingView()
    private var isScrollingHorizontally = false
    private var didFetchFollowing: Bool = false
    private var scrollIndex: Int = 0
    private var targetOffset: CGFloat = 0.0
    
    private var followingLastSnapshot: QueryDocumentSnapshot?
    private var followersLastSnapshot: QueryDocumentSnapshot?
    private var followersLoaded: Bool = false
    private var followingLoaded: Bool = false

    private var followerIndicatorView = UIActivityIndicatorView(style: .medium)
    private var followingIndicatorView = UIActivityIndicatorView(style: .medium)

    private var isFetchingMoreFollowers: Bool = false
    private var isFetchingMoreFollowing: Bool = false
    
    private var networkError = false

    private var currentNotification: Bool = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .systemBackground
        scrollView.bounces = false
        return scrollView
    }()
    
    private var followersCollectionView: UICollectionView!
    private var followingCollectionView: UICollectionView!
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()

    private var followers = [User]()
    private var following = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureNotificationObservers()
        configure()
        fetchFollowers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        followersCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.frame.height)
        spacingView.frame = CGRect(x: view.frame.width, y: 0, width: 10, height: scrollView.frame.height)
        followingCollectionView.frame = CGRect(x: view.frame.width + 10, y: 0, width: view.frame.width, height: scrollView.frame.height)
        
        scrollView.addSubviews(followerIndicatorView, followingIndicatorView)
        followerIndicatorView.frame = CGRect(x: 0, y: scrollView.frame.height - 50, width: view.frame.width, height: 50)
        followingIndicatorView.frame = CGRect(x: view.frame.width + 10, y: scrollView.frame.height - 50, width: view.frame.width, height: 50)
        
        followerIndicatorView.backgroundColor = .clear
        followingIndicatorView.backgroundColor = .clear
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = user.firstName
    }
    
    private func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(followDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.followUser), object: nil)
    }
    

    private func configure() {
        followersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createFollowerLayout())
        followingCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createFollowingLayout())
        
        followersCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        followersCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        followersCollectionView.register(UsersFollowFollowingCell.self, forCellWithReuseIdentifier: followFollowingCellReuseIdentifier)
        
        followingCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        followingCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        followingCollectionView.register(UsersFollowFollowingCell.self, forCellWithReuseIdentifier: followFollowingCellReuseIdentifier)

        followingCollectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkCellReuseIdentifier)
        followersCollectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkCellReuseIdentifier)

        followersCollectionView.delegate = self
        followingCollectionView.delegate = self
        followersCollectionView.dataSource = self
        followingCollectionView.dataSource = self
        
        view.backgroundColor = .systemBackground

        view.addSubviews(networkToolbar, scrollView)
        
        NSLayoutConstraint.activate([
            networkToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            networkToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            networkToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            networkToolbar.heightAnchor.constraint(equalToConstant: 50),
            
            scrollView.topAnchor.constraint(equalTo: networkToolbar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.delegate = self
        scrollView.addSubview(followersCollectionView)
        scrollView.addSubview(followingCollectionView)
        scrollView.addSubview(spacingView)
        scrollView.contentSize.width = view.frame.width * 2 + 10
        networkToolbar.toolbarDelegate = self
    }
    
    private func createFollowerLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.followers.isEmpty ? .estimated(300) : .absolute(65))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.followersLoaded {
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        
        return layout
    }
    
    private func createFollowingLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.networkError ? .estimated(200) : strongSelf.following.isEmpty ? .estimated(300) : .absolute(65))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.followersLoaded {
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        
        return layout
    }
    
    private func fetchFollowers() {
        UserService.fetchFollowers(forUid: user.uid!, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.followersLastSnapshot = snapshot.documents.last
                let uids = snapshot.documents.map { $0.documentID }
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.followers = users
                    
                    let uids = users.map { $0.uid! }
                    
                    let group = DispatchGroup()
                    
                    for (index, uid) in uids.enumerated() {
                        group.enter()
                        UserService.checkIfUserIsFollowed(withUid: uid) { [weak self] result in
                            guard let strongSelf = self else { return }
                            switch result {
                                
                            case .success(let isFollowed):
                                strongSelf.followers[index].set(isFollowed: isFollowed)
                            case .failure(_):
                                strongSelf.followers[index].set(isFollowed: false)
                            }
                            
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.followersLoaded = true
                        strongSelf.followersCollectionView.reloadData()
                    }
                }
                
            case .failure(let error):
                switch error {
                case .network:
                    strongSelf.followersLoaded = true
                    strongSelf.networkError = true
                    strongSelf.followersCollectionView.reloadData()
                case .notFound:
                    strongSelf.followersLoaded = true
                    strongSelf.followersCollectionView.reloadData()
                case .unknown:
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        }
    }
    
    func fetchFollowing() {
        didFetchFollowing = true
        UserService.fetchFollowing(forUid: user.uid!, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.followingLastSnapshot = snapshot.documents.last
                let uids = snapshot.documents.map { $0.documentID }
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.following = users
                    
                    strongSelf.following = strongSelf.following.map { follower in
                        var updatedFollower = follower
                        updatedFollower.isFollowed = true
                        return updatedFollower
                    }
                    
                    strongSelf.followingLoaded = true
                    strongSelf.followingCollectionView.reloadData()
                }
                
            case .failure(let error):
                switch error {
                    
                case .network:
                    strongSelf.followingLoaded = true
                    strongSelf.networkError = true
                    strongSelf.didFetchFollowing = true
                    strongSelf.followingCollectionView.reloadData()
                case .notFound:
                    strongSelf.followingLoaded = true
                    strongSelf.followingCollectionView.reloadData()
                    strongSelf.didFetchFollowing = true
                case .unknown:
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        }
    }
    
    private func getMoreFollowers() {
        
        guard !isFetchingMoreFollowers, !followers.isEmpty else {
            return
        }

        showFollowerBottomSpinner()
        
        UserService.fetchFollowers(forUid: user.uid!, lastSnapshot: followersLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.followersLastSnapshot = snapshot.documents.last
                let uids = snapshot.documents.map { $0.documentID }
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let _ = self else { return }
                
                    var newUsers = users
                    let newUids = users.map { $0.uid! }
                    
                    let group = DispatchGroup()
                    
                    for (index, uid) in newUids.enumerated() {
                        group.enter()
                        UserService.checkIfUserIsFollowed(withUid: uid) { [weak self] result in
                            guard let _ = self else { return }
                            switch result {
                                
                            case .success(let isFollowed):
                                newUsers[index].set(isFollowed: isFollowed)
                            case .failure(_):
                                newUsers[index].set(isFollowed: false)
                            }
                            
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.followers.append(contentsOf: newUsers)
                        strongSelf.hideFollowerBottomSpinner()
                        strongSelf.followersCollectionView.reloadData()
                    }
                }
            case .failure(_):
                strongSelf.hideFollowerBottomSpinner()
            }
        }
    }
    
    private func getMoreFollowing() {
        
        guard !isFetchingMoreFollowing, !following.isEmpty else {
            return
        }
        
        showFollowingBottomSpinner()

        UserService.fetchFollowing(forUid: user.uid!, lastSnapshot: followingLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.followingLastSnapshot = snapshot.documents.last
                let uids = snapshot.documents.map { $0.documentID }
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    
                    var newUsers = users

                    strongSelf.following = users
                    
                    newUsers = newUsers.map { follower in
                        var updatedFollower = follower
                        updatedFollower.isFollowed = true
                        return updatedFollower
                    }
                    
                    strongSelf.following.append(contentsOf: newUsers)
                    strongSelf.hideFollowingBottomSpinner()
                    strongSelf.followingCollectionView.reloadData()
                }
                
            case .failure(_):
                strongSelf.hideFollowingBottomSpinner()
            }
        }
    }
    
    func showFollowerBottomSpinner() {
        isFetchingMoreFollowers = true
        let collectionViewContentHeight = followersCollectionView.contentSize.height
        
        if followersCollectionView.frame.height < collectionViewContentHeight {
            followerIndicatorView.startAnimating()
            followersCollectionView.contentInset.bottom = 50
        }
    }
    
    func hideFollowerBottomSpinner() {
        isFetchingMoreFollowers = false
        followerIndicatorView.stopAnimating()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.followersCollectionView.contentInset.bottom = 0
        }
    }
    
    func showFollowingBottomSpinner() {
        isFetchingMoreFollowing = true
        let collectionViewContentHeight = followingCollectionView.contentSize.height
        
        if followingCollectionView.frame.height < collectionViewContentHeight {
            followingIndicatorView.startAnimating()
            followingCollectionView.contentInset.bottom = 50
        }
    }
    
    func hideFollowingBottomSpinner() {
        isFetchingMoreFollowing = false
        followingIndicatorView.stopAnimating()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.followingCollectionView.contentInset.bottom = 0
        }
    }
}

extension FollowersFollowingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == followersCollectionView {
            return followersLoaded ? networkError ? 1 : followers.isEmpty ? 1 : followers.count : 0
        } else {
            return followingLoaded ? networkError ? 1 : following.isEmpty ? 1 : following.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == followersCollectionView {
            if networkError {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if followers.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Network.Empty.followersTitle, description: AppStrings.Network.Empty.followersContent, content: .dismiss)
                    cell.delegate = self
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: followFollowingCellReuseIdentifier, for: indexPath) as! UsersFollowFollowingCell
                    cell.followerDelegate = self
                    cell.user = followers[indexPath.row]
                    
                    return cell
                }
            }
        } else {
            if networkError {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if following.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Network.Empty.followingTitle(forName: user.firstName!), description: AppStrings.Network.Empty.followingContent, content: .dismiss)
                    cell.delegate = self
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: followFollowingCellReuseIdentifier, for: indexPath) as! UsersFollowFollowingCell
                    cell.followingDelegate = self
                    cell.user = following[indexPath.row]
                    return cell
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == followersCollectionView {
            guard !followers.isEmpty else { return }
            
            let controller = UserProfileViewController(user: followers[indexPath.row])
            navigationController?.pushViewController(controller, animated: true)
        } else {
            guard !following.isEmpty else { return }
            let controller = UserProfileViewController(user: following[indexPath.row])
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension FollowersFollowingViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > view.frame.width {
            networkToolbar.reset()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            switch scrollIndex {
            case 0:
                getMoreFollowers()
            case 1:
                getMoreFollowing()
            default:
                break
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee.x
        self.targetOffset = targetOffset
        if targetOffset == view.frame.width {
            let desiredOffset = CGPoint(x: targetOffset + 10, y: 0)
            scrollView.setContentOffset(desiredOffset, animated: true)
            targetContentOffset.pointee = scrollView.contentOffset
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y != 0 {
            isScrollingHorizontally = false
        }
        
        if scrollView.contentOffset.y == 0 && isScrollingHorizontally {
            networkToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
        }
        
        if scrollView.contentOffset.y == 0 && !isScrollingHorizontally {
            isScrollingHorizontally = true
            return
        }
        
        if scrollView.contentOffset.x > view.frame.width * 0.2 && !didFetchFollowing {
            fetchFollowing()
        }
        
        let spacingWidth = spacingView.frame.width / 2
        
        switch scrollView.contentOffset.x {
        case 0 ..< view.frame.width:
            if isScrollingHorizontally { scrollIndex = 0 }
        case view.frame.width + spacingWidth ..< 2 * view.frame.width + spacingWidth:
            if isScrollingHorizontally { scrollIndex = 1 }
        default:
            break
        }
    }
}

extension FollowersFollowingViewController: UsersFollowCellDelegate, UsersFollowingCellDelegate {
    
    func didFollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! UsersFollowFollowingCell
        UserService.follow(uid: user.uid!) { [weak self] error in
            guard let strongSelf = self else { return }
            currentCell.isUpdatingFollowState = false
            
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                
                if let indexPath = strongSelf.followersCollectionView.indexPath(for: cell) {
                    currentCell.userIsFollowing = true
                    strongSelf.followers[indexPath.row].set(isFollowed: true)
                }

                strongSelf.userDidChangeFollow(uid: user.uid!, didFollow: true)
                if let index = strongSelf.following.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.following[index].set(isFollowed: true)
                    strongSelf.followingCollectionView.reloadData()
                }
            }
        }
    }
    
    func didUnfollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! UsersFollowFollowingCell
        UserService.unfollow(uid: user.uid!) { [weak self] error in
            guard let strongSelf = self else { return }
            currentCell.isUpdatingFollowState = false

            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                
                if let indexPath = strongSelf.followersCollectionView.indexPath(for: cell) {
                    currentCell.userIsFollowing = false
                    strongSelf.followers[indexPath.row].set(isFollowed: false)
                }

                strongSelf.userDidChangeFollow(uid: user.uid!, didFollow: false)
                if let followerIndex = strongSelf.following.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.following[followerIndex].set(isFollowed: false)
                    strongSelf.followingCollectionView.reloadData()
                }
            }
        }
    }
    
    func didFollowOnFollowing(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! UsersFollowFollowingCell
        UserService.follow(uid: user.uid!) { [weak self] error in
            guard let strongSelf = self else { return }
            currentCell.isUpdatingFollowState = false
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                
                if let indexPath = strongSelf.followingCollectionView.indexPath(for: cell) {
                    currentCell.userIsFollowing = true
                    strongSelf.following[indexPath.row].set(isFollowed: true)
                }
                
                strongSelf.userDidChangeFollow(uid: user.uid!, didFollow: true)
                if let index = strongSelf.followers.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.followers[index].set(isFollowed: true)
                    strongSelf.followersCollectionView.reloadData()
                }
            }
        }
    }
    
    func didUnfollowOnFollowing(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! UsersFollowFollowingCell
        UserService.unfollow(uid: user.uid!) { [weak self] error in
            guard let strongSelf = self else { return }
            currentCell.isUpdatingFollowState = false
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                
                if let indexPath = strongSelf.followingCollectionView.indexPath(for: cell) {
                    currentCell.userIsFollowing = false
                    strongSelf.following[indexPath.row].set(isFollowed: false)
                }

                strongSelf.userDidChangeFollow(uid: user.uid!, didFollow: false)
                if let index = strongSelf.followers.firstIndex(where: { $0.uid == user.uid }) {

                    strongSelf.followers[index].set(isFollowed: false)
                    strongSelf.followersCollectionView.reloadData()
                }
            }
        }
    }
}

extension FollowersFollowingViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        navigationController?.popViewController(animated: true)
    }
}

extension FollowersFollowingViewController: NetworkToolbarDelegate {
    func didTapIndex(_ index: Int) {
        scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width) + index * 10, y: 0), animated: true)
    }
}

extension FollowersFollowingViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        networkError = false
        
        switch scrollIndex {
        case 0:
            followersLoaded = false
            followersCollectionView.reloadData()
            fetchFollowers()
        case 1:
            followingLoaded = false
            followingCollectionView.reloadData()
            fetchFollowing()
            
        default:
            break
        }
    }
}

extension FollowersFollowingViewController: UserFollowDelegate {
    
    func userDidChangeFollow(uid: String, didFollow: Bool) {
        currentNotification = true
        ContentManager.shared.userFollowChange(uid: uid, isFollowed: didFollow)
    }
    
    @objc func followDidChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? UserFollowChange {
            if let followerIndex = followers.firstIndex(where: { $0.uid! == change.uid }) {
                followers[followerIndex].set(isFollowed: change.isFollowed)
                followersCollectionView.reloadData()
            }
            
            if let followingIndex = following.firstIndex(where: { $0.uid! == change.uid }) {
                following[followingIndex].set(isFollowed: change.isFollowed)
                followingCollectionView.reloadData()
            }
        }
    }
}
