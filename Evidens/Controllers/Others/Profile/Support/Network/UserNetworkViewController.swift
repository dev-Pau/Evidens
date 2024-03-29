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
private let connectUserCellReuseIdentifier = "ConnectUserCellReuseIdentifier"
private let networkCellReuseIdentifier = "NetworkCellReuseIdentifier"

class UserNetworkViewController: UIViewController {

    private let viewModel: UserNetworkViewModel
    private let networkToolbar = NetworkToolbar()

    private var targetOffset: CGFloat = 0.0
    private var padding: CGFloat = 10.0

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .systemBackground
        scrollView.bounces = false
        return scrollView
    }()
    
    private var connectionCollectionView: UICollectionView!
    private var followerCollectionView: UICollectionView!
    private var followingCollectionView: UICollectionView!
    
    private var connectionSpacingView = SpacingView()
    private var followerSpacingView = SpacingView()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        getConnections()
    }
    
    private var firstLayoutLoad: Bool = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !firstLayoutLoad {
            configure()
            firstLayoutLoad = true
        }
    }
    
    init(user: User) {
        self.viewModel = UserNetworkViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = viewModel.user.firstName
    }
    
    private func configure() {
        connectionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createConnectionLayout())
        followerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createFollowerLayout())
        followingCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createFollowingLayout())
        
        connectionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        followerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        followingCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        connectionSpacingView.translatesAutoresizingMaskIntoConstraints = false
        followerSpacingView.translatesAutoresizingMaskIntoConstraints = false
        
        connectionCollectionView.register(LoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        connectionCollectionView.register(SecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        connectionCollectionView.register(ConnectUserCell.self, forCellWithReuseIdentifier: connectUserCellReuseIdentifier)
        
        followerCollectionView.register(LoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        followerCollectionView.register(SecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        followerCollectionView.register(ConnectUserCell.self, forCellWithReuseIdentifier: connectUserCellReuseIdentifier)
        
        followingCollectionView.register(LoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        followingCollectionView.register(SecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        followingCollectionView.register(ConnectUserCell.self, forCellWithReuseIdentifier: connectUserCellReuseIdentifier)

        connectionCollectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkCellReuseIdentifier)
        followingCollectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkCellReuseIdentifier)
        followerCollectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkCellReuseIdentifier)
        
        connectionCollectionView.delegate = self
        followerCollectionView.delegate = self
        followingCollectionView.delegate = self
        connectionCollectionView.dataSource = self
        followerCollectionView.dataSource = self
        followingCollectionView.dataSource = self
        
        view.backgroundColor = .systemBackground
        view.addSubviews(scrollView, networkToolbar)
        scrollView.addSubviews(connectionCollectionView, connectionSpacingView, followerCollectionView, followerSpacingView, followingCollectionView)
        
        NSLayoutConstraint.activate([
            networkToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            networkToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            networkToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            networkToolbar.heightAnchor.constraint(equalToConstant: 50),

            scrollView.topAnchor.constraint(equalTo: networkToolbar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.frame.width + padding),
            
            connectionCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            connectionCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            connectionCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            connectionCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            connectionSpacingView.topAnchor.constraint(equalTo: connectionCollectionView.topAnchor),
            connectionSpacingView.leadingAnchor.constraint(equalTo: connectionCollectionView.trailingAnchor),
            connectionSpacingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            connectionSpacingView.widthAnchor.constraint(equalToConstant: 10),

            followerCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            followerCollectionView.leadingAnchor.constraint(equalTo: connectionSpacingView.trailingAnchor),
            followerCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            followerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            followerSpacingView.topAnchor.constraint(equalTo: followerCollectionView.topAnchor),
            followerSpacingView.leadingAnchor.constraint(equalTo: followerCollectionView.trailingAnchor),
            followerSpacingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            followerSpacingView.widthAnchor.constraint(equalToConstant: 10),

            followingCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            followingCollectionView.leadingAnchor.constraint(equalTo: followerSpacingView.trailingAnchor),
            followingCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            followingCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        scrollView.delegate = self
       
        scrollView.contentSize.width = view.frame.width * 3 + 3 * 10
        
        networkToolbar.toolbarDelegate = self
    }
    
    private func createConnectionLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.connections.isEmpty ? .estimated(300) : .estimated(70))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: K.Paddings.Content.horizontalPadding, bottom: 0, trailing: K.Paddings.Content.horizontalPadding)
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.viewModel.connectionLoaded {
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        
        return layout
    }
    
    private func createFollowerLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.followers.isEmpty ? .estimated(300) : .estimated(70))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: K.Paddings.Content.horizontalPadding, bottom: 0, trailing: K.Paddings.Content.horizontalPadding)
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.viewModel.followersLoaded {
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        
        return layout
    }
    
    private func createFollowingLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.following.isEmpty ? .estimated(300) : .estimated(70))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: K.Paddings.Content.horizontalPadding, bottom: 0, trailing: K.Paddings.Content.horizontalPadding)
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.viewModel.followingLoaded {
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        
        return layout
    }
    
    private func getConnections() {
        viewModel.getConnections { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.connectionCollectionView.reloadData()
        }
    }
    
    private func fetchFollowers() {
        viewModel.getFollowers { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.followerCollectionView.reloadData()
        }
    }
    
    func fetchFollowing() {
        viewModel.getFollowing { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.followingCollectionView.reloadData()
        }
    }
    
    private func getMoreConnections() {
        viewModel.getMoreConnections { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.connectionCollectionView.reloadData()
        }
    }
    
    private func getMoreFollowers() {
        viewModel.getMoreFollowers { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.followerCollectionView.reloadData()
        }
    }
    
    private func getMoreFollowing() {
        viewModel.getMoreFollowing { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.followingCollectionView.reloadData()
        }
    }
}

extension UserNetworkViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == connectionCollectionView {
            return viewModel.connectionLoaded ? viewModel.networkError ? 1 : viewModel.connections.isEmpty ? 1 : viewModel.connections.count : 0
            
        } else if collectionView == followerCollectionView {
            return viewModel.followersLoaded ? viewModel.networkError ? 1 : viewModel.followers.isEmpty ? 1 : viewModel.followers.count : 0
            
        } else {
            return viewModel.followingLoaded ? viewModel.networkError ? 1 : viewModel.following.isEmpty ? 1 : viewModel.following.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! LoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == connectionCollectionView {
            if viewModel.networkError {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.set(AppStrings.Network.Issues.Users.title)
                cell.delegate = self
                return cell
            } else {
                if viewModel.connections.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! SecondaryEmptyCell
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Network.Empty.connection, description: AppStrings.Network.Empty.connectionContent, content: .dismiss)
                    cell.delegate = self
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: connectUserCellReuseIdentifier, for: indexPath) as! ConnectUserCell
                    cell.viewModel = ConnectViewModel(user: viewModel.connections[indexPath.row])
                    return cell
                }
            }
        } else if collectionView == followerCollectionView {
            if viewModel.networkError {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.set(AppStrings.Network.Issues.Users.title)
                cell.delegate = self
                return cell
            } else {
                if viewModel.followers.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! SecondaryEmptyCell
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Network.Empty.followersTitle, description: AppStrings.Network.Empty.followersContent, content: .dismiss)
                    cell.delegate = self
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: connectUserCellReuseIdentifier, for: indexPath) as! ConnectUserCell
                    cell.viewModel = ConnectViewModel(user: viewModel.followers[indexPath.row])
                    return cell
                }
            }
        } else {
            if viewModel.networkError {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.set(AppStrings.Network.Issues.Users.title)
                cell.delegate = self
                return cell
            } else {
                if viewModel.following.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! SecondaryEmptyCell
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Network.Empty.anyone, description: AppStrings.Network.Empty.followingContent, content: .dismiss)
                    cell.delegate = self
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: connectUserCellReuseIdentifier, for: indexPath) as! ConnectUserCell
                    cell.viewModel = ConnectViewModel(user: viewModel.following[indexPath.row])
                    return cell
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == connectionCollectionView {
            guard !viewModel.connections.isEmpty else { return }
            
            let controller = UserProfileViewController(user: viewModel.connections[indexPath.row])
            navigationController?.pushViewController(controller, animated: true)
        } else if collectionView == followerCollectionView {
            guard !viewModel.followers.isEmpty else { return }
            
            let controller = UserProfileViewController(user: viewModel.followers[indexPath.row])
            navigationController?.pushViewController(controller, animated: true)
        } else {
            guard !viewModel.following.isEmpty else { return }
            
            let controller = UserProfileViewController(user: viewModel.following[indexPath.row])
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension UserNetworkViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        guard !viewModel.isScrollingHorizontally else {
            return
        }

        if offsetY > contentHeight - height {
            switch viewModel.index {
            case 0:
                getMoreConnections()
            case 1:
                getMoreFollowers()
            case 2:
                getMoreFollowing()
            default:
                break
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollX = scrollView.contentSize.width
        
         if scrollView == connectionCollectionView || scrollView == followerCollectionView || scrollView == followingCollectionView {
             viewModel.isScrollingHorizontally = false
             
         } else if scrollView == self.scrollView {
             viewModel.isScrollingHorizontally = true
             networkToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
             
             if scrollView.contentOffset.x > view.frame.width * 0.2 && !viewModel.didFetchFollower {
                 fetchFollowers()
             }
             
             if scrollView.contentOffset.x > view.frame.width * 1.2 && !viewModel.didFetchFollowing {
                 fetchFollowing()
             }
             
             switch scrollView.contentOffset.x {
             case 0 ..< scrollX / 2:
                 viewModel.index = 0
             case scrollX / 2 ..< scrollX:
                 viewModel.index = 1
             default:
                 viewModel.index = 2
             }
         }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollView.isUserInteractionEnabled = true
        connectionCollectionView.isScrollEnabled = true
        followerCollectionView.isScrollEnabled = true
        followingCollectionView.isScrollEnabled = true
    }
}

extension UserNetworkViewController: SecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        navigationController?.popViewController(animated: true)
    }
}

extension UserNetworkViewController: NetworkToolbarDelegate {
    func didTapIndex(_ index: Int) {
        
        switch viewModel.index {
        case 0:
            connectionCollectionView.setContentOffset(connectionCollectionView.contentOffset, animated: false)
        case 1:
            followerCollectionView.setContentOffset(followerCollectionView.contentOffset, animated: false)
        case 2:
            followingCollectionView.setContentOffset(followingCollectionView.contentOffset, animated: false)
        default:
            break
        }
        
        let scrollX = index == 0 ? 0 : scrollView.contentSize.width / CGFloat(3) * CGFloat(index)
        
        guard viewModel.isFirstLoad else {
            viewModel.isFirstLoad.toggle()
            scrollView.setContentOffset(CGPoint(x: scrollX, y: 0), animated: true)
            viewModel.index = index
            return
        }
        
        connectionCollectionView.isScrollEnabled = false
        followerCollectionView.isScrollEnabled = false
        followingCollectionView.isScrollEnabled = false
        self.scrollView.isUserInteractionEnabled = false

        scrollView.setContentOffset(CGPoint(x: scrollX, y: 0), animated: true)
        viewModel.index = index
    }
}

extension UserNetworkViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        viewModel.networkError = false
        
        switch viewModel.index {
        case 0:
            viewModel.connectionLoaded = false
            connectionCollectionView.reloadData()
            getConnections()
        case 1:
            viewModel.followersLoaded = false
            followerCollectionView.reloadData()
            fetchFollowers()
            
        default:
            viewModel.followingLoaded = false
            followingCollectionView.reloadData()
            fetchFollowing()
        }
    }
}
