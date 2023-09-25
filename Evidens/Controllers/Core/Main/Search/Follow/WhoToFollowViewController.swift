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
    private var currentNotification: Bool = false
    
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
        configureNotificationObservers()
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
    
    private func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(followDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.followUser), object: nil)
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
        UserService.fetchUsersToFollow(forUser: user, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.usersLastSnapshot = snapshot.documents.last
                var users = snapshot.documents.map { User(dictionary: $0.data() ) }
                
                let group = DispatchGroup()
                
                for (index, user) in users.enumerated() {
                    group.enter()
                    UserService.checkIfUserIsFollowed(withUid: user.uid!) { [weak self] result in
                        guard let _ = self else { return }
                        switch result {
                            
                        case .success(let isFollowed):
                            users[index].set(isFollowed: isFollowed)
                        case .failure(_):
                            users[index].isFollowed = false
                        }
                        
                        group.leave()
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.usersLoaded = true
                        strongSelf.users = users
                        strongSelf.collectionView.reloadData()
                    }
                }
            case .failure(let error):
                strongSelf.usersLoaded = true
                guard error != .notFound else {
                    return
                }
                
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    private func getMoreUsers() {
        UserService.fetchUsersToFollow(forUser: user, lastSnapshot: usersLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.usersLastSnapshot = snapshot.documents.last
                var users = snapshot.documents.map { User(dictionary: $0.data() ) }
                
                let group = DispatchGroup()
                
                for (index, user) in users.enumerated() {
                    group.enter()
                    UserService.checkIfUserIsFollowed(withUid: user.uid!) { [weak self] result in
                        guard let _ = self else { return }
                        switch result {
                            
                        case .success(let isFollowed):
                            users[index].set(isFollowed: isFollowed)
                        case .failure(_):
                            users[index].isFollowed = false
                        }
                        
                        group.leave()
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.users.append(contentsOf: users)
                        strongSelf.collectionView.reloadData()
                    }
                }
            case .failure(_):
                break
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
        return users.isEmpty ? CGSize(width: view.frame.width - 20, height: view.frame.width) : CGSize(width: view.frame.width - 20, height: 73)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = UserProfileViewController(user: users[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension WhoToFollowViewController: UsersFollowCellDelegate {
    func didFollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        guard let uid = user.uid, let currentCell = cell as? WhoToFollowCell else { return }
        
        UserService.follow(uid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            currentCell.isUpdatingFollowState = false
            
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                currentCell.userIsFollowing = true
                
                strongSelf.userDidChangeFollow(uid: uid, didFollow: true)
                
                if let indexPath = strongSelf.collectionView.indexPath(for: cell) {
                    strongSelf.users[indexPath.row].isFollowed = true
                }
            }
        }
    }
    
    func didUnfollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        func didFollowOnFollower(_ cell: UICollectionViewCell, user: User) {
            guard let uid = user.uid, let currentCell = cell as? WhoToFollowCell else { return }
            
            UserService.follow(uid: uid) { [weak self] error in
                guard let strongSelf = self else { return }
                currentCell.isUpdatingFollowState = false
                
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    currentCell.userIsFollowing = false
                    
                    strongSelf.userDidChangeFollow(uid: uid, didFollow: false)
                    
                    if let indexPath = strongSelf.collectionView.indexPath(for: cell) {
                        strongSelf.users[indexPath.row].isFollowed = false
                    }
                }
            }
        }
    }
}

extension WhoToFollowViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        navigationController?.popViewController(animated: true)
    }
}


extension WhoToFollowViewController: UserFollowDelegate {
    
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
            if let index = users.firstIndex(where: { $0.uid! == change.uid }) {
                users[index].set(isFollowed: change.isFollowed)
                collectionView.reloadData()
            }
        }
    }
}

