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
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"

protocol HomeOnboardingViewControllerDelegate: AnyObject {
    func didUpdateUser(user: User)
}

class HomeOnboardingViewController: UIViewController {
    
    weak var delegate: HomeOnboardingViewControllerDelegate?
    
    private var user: User
    
    private var users = [User]()
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
        guard user.phase == .verified else {
            followersLoaded = true
            collectionView.reloadData()
            return
        }
        
        let group = DispatchGroup()
        
        UserService.fetchOnboardingUsers { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let users):
                strongSelf.users = users
                let uids = strongSelf.users.map { $0.uid! }
                
                var usersToRemove: [User] = []
                
                for (index, uid) in uids.enumerated() {
                    
                    group.enter()
                    
                    UserService.checkIfUserIsFollowed(withUid: uid) { [weak self] result in
                        guard let strongSelf = self else { return }
                        switch result {
                            
                        case .success(let isFollowed):
                            strongSelf.users[index].set(isFollowed: isFollowed)
                        case .failure(_):
                            usersToRemove.append(strongSelf.users[index])
                        }
                        
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    strongSelf.users.removeAll { usersToRemove.contains($0) }
                    
                    strongSelf.followersLoaded = true
                    strongSelf.collectionView.reloadData()
                }
                
            case .failure(let error):
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.connect
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
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension HomeOnboardingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if user.phase != .verified {
            return 0
        }
        
        return followersLoaded ? users.isEmpty ? 1 : users.count : 0
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
        return CGSize(width: view.frame.width, height: followersLoaded ? 165 : 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if users.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.User.emptyTitle, description: AppStrings.Content.User.emptyContent, content: .dismiss)
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: followFollowingCellReuseIdentifier, for: indexPath) as! UsersFollowFollowingCell
            cell.user = users[indexPath.row]
            
            cell.followerDelegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return users.isEmpty ? CGSize(width: view.frame.width, height: view.frame.width) : CGSize(width: view.frame.width, height: 66)
    }
}

extension HomeOnboardingViewController: OnboardingHomeHeaderDelegate {
    func didTapConfigureProfile() {
        let controller = ImageViewController(user: user)
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
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension HomeOnboardingViewController: UsersFollowCellDelegate {
    
    func didFollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        guard let currentCell = cell as? UsersFollowFollowingCell, let indexPath = collectionView.indexPath(for: currentCell) else { return }

        guard let uid = user.uid else { return }
        
        UserService.follow(uid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            currentCell.isUpdatingFollowState = false
            
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                currentCell.userIsFollowing = true
                strongSelf.users[indexPath.row].set(isFollowed: true)
            }
        }
    }
    
    func didUnfollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        guard let currentCell = cell as? UsersFollowFollowingCell, let indexPath = collectionView.indexPath(for: currentCell) else { return }
        
        guard let uid = user.uid else { return }
        
        UserService.unfollow(uid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            currentCell.isUpdatingFollowState = false
            
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                currentCell.userIsFollowing = false
                strongSelf.users[indexPath.row].set(isFollowed: false)
            }
        }
    }
}

extension HomeOnboardingViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        navigationController?.popViewController(animated: true)
    }
}
