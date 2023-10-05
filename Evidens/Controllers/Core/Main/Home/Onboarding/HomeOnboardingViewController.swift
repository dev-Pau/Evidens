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
    private var viewModel: HomeOnboardingViewModel
    private var collectionView: UICollectionView!

    /*
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
    */
    
    init(user: User) {
        self.viewModel = HomeOnboardingViewModel(user: user)
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
        configureCollectionView()
        configureUI()
        configureNotificationObservers()
        fetchUsers()
    }
    
    private func fetchUsers() {
        viewModel.fetchUsers { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
            
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.connect
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(followDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.followUser), object: nil)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingCellReuseIdentifier)
        collectionView.register(OnboardingHomeHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: onboardingHeaderReuseIdentifier)
        collectionView.register(UsersFollowFollowingCell.self, forCellWithReuseIdentifier: followFollowingCellReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.users.isEmpty ? .fractionalWidth(1) : .absolute(73))
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(55))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            return section
        }
        
        return layout
    }
}

extension HomeOnboardingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if viewModel.followersLoaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: onboardingHeaderReuseIdentifier, for: indexPath) as! OnboardingHomeHeader
            header.delegate = self
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingCellReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.users.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.User.emptyTitle, description: AppStrings.Content.User.emptyContent, content: .dismiss)
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: followFollowingCellReuseIdentifier, for: indexPath) as! UsersFollowFollowingCell
            cell.user = viewModel.users[indexPath.row]
            
            cell.followerDelegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = viewModel.users[indexPath.row]
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension HomeOnboardingViewController: OnboardingHomeHeaderDelegate {
    func didTapConfigureProfile() {
        let controller = ImageViewController(user: viewModel.user)
        controller.comesFromHomeOnboarding = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(notification:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
        
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen

        present(navVC, animated: true)
    }
    
    @objc func userDidChange(notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            delegate?.didUpdateUser(user: user)
            let controller = UserProfileViewController(user: user)
            
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
                strongSelf.viewModel.users[indexPath.row].set(isFollowed: true)
                strongSelf.userDidChangeFollow(uid: uid, didFollow: true)
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
                strongSelf.viewModel.users[indexPath.row].set(isFollowed: false)
                strongSelf.userDidChangeFollow(uid: uid, didFollow: false)
            }
        }
    }
}

extension HomeOnboardingViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        navigationController?.popViewController(animated: true)
    }
}

extension HomeOnboardingViewController: UserFollowDelegate {
    
    @objc func followDidChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? UserFollowChange {
            if let index = viewModel.users.firstIndex(where: { $0.uid! == change.uid }) {
                viewModel.users[index].set(isFollowed: change.isFollowed)
                collectionView.reloadData()
            }
        }
    }
    
    func userDidChangeFollow(uid: String, didFollow: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.userFollowChange(uid: uid, isFollowed: didFollow)
    }
}
