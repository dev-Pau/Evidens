//
//  SearchViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

private let topHeaderReuseIdentifier = "TopHeaderReuseIdentifier"
private let searchHeaderReuseIdentifier = "SearchHeaderReuseIdentifier"
private let categoriesCellReuseIdentifier  = "CategoriesCellReuseIdentifier"
private let whoToFollowCellReuseIdentifier = "WhoToFollowCellReuseIdentifier"

private let homeTextCellReuseIdentifier = "HomeTextCellReuseIdentifier"
private let homeImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let homeTwoImageTextCellReuseIdentifier = "HomeTwoImageTextCellReuseIdentifier"
private let homeThreeImageTextCellReuseIdentifier = "HomeThreeImageTextCellReuseIdentifier"
private let homeFourImageTextCellReuseIdentifier = "HomeFourImageTextCellReuseIdentifier"

private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"

private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"
private let emptyCellReuseidentifier = "EmptyCellReuseIdentifier"

class SearchViewController: NavigationBarViewController, UINavigationControllerDelegate {
    
    //MARK: - Properties
    private var searchController: UISearchController!
    private var collectionView: UICollectionView!
    
    private var users = [User]()
    private var posts = [Post]()
    private var postUsers = [User]()
    private var cases = [Case]()
    private var caseUsers = [User]()
    private var zoomTransitioning = ZoomTransitioning()
    private let referenceMenu = ReferenceMenu()
    private var selectedImage: UIImageView!
    private var isEmpty: Bool = false
    private var networkFailure: Bool = false

    private let activityIndicator = PrimaryLoadingView(frame: .zero)
    private lazy var lockView = MEPrimaryBlurLockView(frame: view.bounds)
    
    private var likeDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var likeValues: [IndexPath: Bool] = [:]
    private var likeCount: [IndexPath: Int] = [:]
    
    private var bookmarkDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var bookmarkValues: [IndexPath: Bool] = [:]

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        fetchMainSearchContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }

    private func fetchMainSearchContent() {
        
        guard NetworkMonitor.shared.isConnected else {
            networkFailure = true
            activityIndicator.stop()
            collectionView.reloadData()
            collectionView.isHidden = false
            return
        }
        
        guard let tab = tabBarController as? MainTabController, let user = tab.user else {
            networkFailure = true
            activityIndicator.stop()
            collectionView.reloadData()
            collectionView.isHidden = false
            return
            
        }
      
        let group = DispatchGroup()
        
        group.enter()
        UserService.fetchSuggestedUsers { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let users):
                strongSelf.users = users
            case .failure(_):
                break
            }
            
            group.leave()
        }
        
        group.enter()
        PostService.fetchSuggestedPosts(forUser: user) { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .success(let posts):
                let uids = posts.map { $0.uid }
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.postUsers = users
                    strongSelf.posts = posts
                    group.leave()
                }
                
            case .failure(_):
                group.leave()
                break
            }
        }
      
        group.enter()
        CaseService.fetchSuggestedCases(forUser: user) { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .success(let cases):
                let uids = cases.map { $0.uid }
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.caseUsers = users
                    strongSelf.cases = cases
                    group.leave()
                }
                
            case .failure(_):
                group.leave()
                break
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.isEmpty = strongSelf.users.isEmpty && strongSelf.posts.isEmpty && strongSelf.cases.isEmpty ? true : false
            print(strongSelf.isEmpty)
            strongSelf.activityIndicator.stop()
            strongSelf.collectionView.reloadData()
            strongSelf.collectionView.isHidden = false
        }
    }
    
    //MARK: - Helpers
    func configureNavigationBar() {
        title = AppStrings.Title.search
        
        let controller = SearchResultsUpdatingViewController()
        controller.searchResultsDelegate = self
        searchController = UISearchController(searchResultsController: controller)
        searchController.searchResultsUpdater = controller
        searchController.searchBar.delegate = controller
        searchController.searchBar.placeholder = AppStrings.Title.search
        searchController.searchBar.searchTextField.layer.cornerRadius = 17
        searchController.searchBar.searchTextField.layer.masksToBounds = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = primaryColor
        searchController.showsSearchResultsController = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        self.definesPresentationContext = true
        
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        if user.phase == .verified {
            
        }

    }
    
    private func configureUI() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        view.backgroundColor = .systemBackground
        view.addSubviews(activityIndicator, collectionView)
        collectionView.isHidden = true

        collectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        collectionView.register(PrimarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: topHeaderReuseIdentifier)
       
        collectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseidentifier)
        
        collectionView.register(WhoToFollowCell.self, forCellWithReuseIdentifier: whoToFollowCellReuseIdentifier)
        collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: homeTextCellReuseIdentifier)
        collectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        collectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        collectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        collectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        
        collectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
        ])
        activityIndicator.start()
    }
    
    func resetSearchResultsUpdatingToolbar() {
        if let searchController = navigationItem.searchController?.searchResultsController as? SearchResultsUpdatingViewController {
            searchController.restartSearchMenu()
        }
    }
    
    func showSearchResults(forTopic topic: SearchTopics) {
        if let searchController = navigationItem.searchController?.searchResultsController as? SearchResultsUpdatingViewController {
            searchController.didSelectTopicFromMenu(topic)
        }
    }
    
    func showSearchResults(forDiscipline discipline: Discipline) {
        if let searchController = navigationItem.searchController?.searchResultsController as? SearchResultsUpdatingViewController {
            searchController.didSelectDisciplineFromMenu(discipline)
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env -> NSCollectionLayoutSection? in
            guard let strongSelf = self else { return nil }

            if sectionNumber == 0 {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.networkFailure ? .estimated(200) : .absolute(65)))

                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.networkFailure ? .estimated(200) : .absolute(65)), subitems: [item])

                let section = NSCollectionLayoutSection(group: group)

                if !strongSelf.users.isEmpty && !strongSelf.networkFailure {
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                    section.boundarySupplementaryItems = [header]
                }
                
                return section
            } else {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
                item.contentInsets.leading = -10
                item.contentInsets.trailing = -10
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 0

                
                if sectionNumber == 3 && !strongSelf.posts.isEmpty {
                    section.boundarySupplementaryItems = [header]
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                } else if sectionNumber == 4 && !strongSelf.cases.isEmpty {
                    section.boundarySupplementaryItems = [header]
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                }

                return section
            }
        }
        
        return layout
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return networkFailure ? 1 : isEmpty ? 1 : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: topHeaderReuseIdentifier, for: indexPath) as! PrimarySearchHeader
        
            if indexPath.section == 0 {
                header.configureWith(title: AppStrings.Content.Search.whoToFollow, linkText: AppStrings.Content.Search.seeAll)
                header.hideSeeAllButton(users.count < 3)
                header.delegate = self
                header.tag = indexPath.section
            } else if indexPath.section == 1 {
                header.configureWith(title: AppStrings.Content.Search.postsForYou, linkText: AppStrings.Content.Search.seeAll)
                header.hideSeeAllButton(posts.count < 3)
                header.delegate = self
                header.tag = indexPath.section
            } else {
                header.configureWith(title: AppStrings.Content.Search.casesForYou, linkText: AppStrings.Content.Search.seeAll)
                header.hideSeeAllButton(cases.count < 3)
                header.delegate = self
                header.tag = indexPath.section
            }

            return header
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if networkFailure || isEmpty {
            return 1
        } else {
            if section == 0 {
                return min(3, users.count)
            } else if section == 1 {
                return min(3, posts.count)
            } else {
                return min(3, cases.count)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if networkFailure {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
            cell.delegate = self
            return cell
        } else if isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseidentifier, for: indexPath) as! PrimaryEmptyCell
            cell.set(withTitle: AppStrings.Content.Search.emptyTitle, withDescription: AppStrings.Content.Search.emptyContent)
            return cell
        } else {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowCellReuseIdentifier, for: indexPath) as! WhoToFollowCell
                cell.configureWithUser(user: users[indexPath.row])
                cell.followerDelegate = self
                return cell
            } else if indexPath.section == 1 {
                switch posts[indexPath.row].kind {
                case .plainText:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTextCellReuseIdentifier, for: indexPath) as! HomeTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                    if let index = postUsers.firstIndex(where:  { $0.uid == posts[indexPath.row].uid }) {
                        cell.set(user: postUsers[index])
                    }
                    
                    cell.delegate = self
                    if indexPath.row == posts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    return cell
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                    if let index = postUsers.firstIndex(where:  { $0.uid == posts[indexPath.row].uid }) {
                        cell.set(user: postUsers[index])
                    }
                    
                    cell.delegate = self
                    if indexPath.row == posts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    return cell
                case .textWithTwoImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                    if let index = postUsers.firstIndex(where:  { $0.uid == posts[indexPath.row].uid }) {
                        cell.set(user: postUsers[index])
                    }
                    
                    cell.delegate = self
                    if indexPath.row == posts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    return cell
                case .textWithThreeImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                    if let index = postUsers.firstIndex(where:  { $0.uid == posts[indexPath.row].uid }) {
                        cell.set(user: postUsers[index])
                    }
                    
                    cell.delegate = self
                    if indexPath.row == posts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    return cell
                case .textWithFourImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                    if let index = postUsers.firstIndex(where:  { $0.uid == posts[indexPath.row].uid }) {
                        cell.set(user: postUsers[index])
                    }
                    
                    cell.delegate = self
                    if indexPath.row == posts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    return cell
                }
            } else {
                switch cases[indexPath.row].kind {
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    
                    if cases[indexPath.row].privacy == .anonymous {
                        cell.anonymize()
                    } else {
                        if let userIndex = caseUsers.firstIndex(where: { $0.uid == cases[indexPath.row].uid }) {
                            cell.set(user: caseUsers[userIndex])
                        }
                    }
                   
                    cell.delegate = self
                    if indexPath.row == cases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    return cell
                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    
                    if cases[indexPath.row].privacy == .anonymous {
                        cell.anonymize()
                    } else {
                        if let userIndex = caseUsers.firstIndex(where: { $0.uid == cases[indexPath.row].uid }) {
                            cell.set(user: caseUsers[userIndex])
                        }
                    }
                    
                    if indexPath.row == posts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    cell.delegate = self
                    return cell
                }
            }
        }
    }
            
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let controller = UserProfileViewController(user: users[indexPath.row])
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension SearchViewController: PrimarySearchHeaderDelegate {
    func didTapSeeAll(_ header: UICollectionReusableView) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let tag = header.tag

        if tag == 0 {
            let controller = WhoToFollowViewController(user: user)
            controller.title = AppStrings.Content.Search.whoToFollow
            navigationController?.pushViewController(controller, animated: true)
        } else if tag == 1 {
            let controller = HomeViewController(source: .search)
            controller.controllerIsBeeingPushed = true
            controller.user = user
            controller.title = AppStrings.Content.Search.postsForYou
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = CaseViewController(user: user, contentSource: .search)
            controller.title = AppStrings.Content.Search.casesForYou
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension SearchViewController: UsersFollowCellDelegate {
    func didFollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! WhoToFollowCell
        
        UserService.follow(uid: user.uid!) { [weak self] error in
            guard let strongSelf = self else { return }
            currentCell.isUpdatingFollowState = false

            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                currentCell.userIsFollowing = true
                
                if let indexPath = strongSelf.collectionView.indexPath(for: cell) {
                    strongSelf.users[indexPath.row].set(isFollowed: true)
                }
            }
        }
    }
    
    func didUnfollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! WhoToFollowCell
        UserService.unfollow(uid: user.uid!) { [weak self] error in
            guard let strongSelf = self else { return }
            currentCell.isUpdatingFollowState = false
            
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                currentCell.userIsFollowing = false
                if let indexPath = strongSelf.collectionView.indexPath(for: cell) {
                    strongSelf.users[indexPath.row].set(isFollowed: false)
                }
            }
        }
    }
}

extension SearchViewController: CaseCellDelegate {
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)
        controller.delegate = self
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        #warning("Implement Hashtag")
        //controller.caseDelegate = self
        //controller.postDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        let controller = LikesViewController(clinicalCase: clinicalCase)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)
        controller.delegate = self
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        
        handleLikeUnlike(for: currentCell, at: indexPath)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        
        handleBookmarkUnbookmark(for: currentCell, at: indexPath)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        // User won't find his/her content here so the only option remaining is to implement report
        switch option {
        case .delete:
            break
        case .revision:
            break
        case .solve:
            break
        case .report:
            let controller = ReportViewController(source: .clinicalCase, contentUid: clinicalCase.uid, contentId: clinicalCase.caseId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        if let userIndex = caseUsers.firstIndex(where: { $0.uid == clinicalCase.uid }) {
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: caseUsers[userIndex])
          
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        
        navigationController?.delegate = zoomTransitioning

        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        navigationController?.pushViewController(controller, animated: true)
    }

}

extension SearchViewController: HomeCellDelegate {
    func cell(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        controller.postDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.navigationController?.delegate = self
        
        let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)

        controller.delegate = self
       
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        
        handleLikeUnLike(for: currentCell, at: indexPath)

    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
       
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    func cell(_ cell: UICollectionViewCell, didTapMenuOptionsFor post: Post, option: PostMenu) {
        // User won't find his/her content here so the only option remaining is to implement report
        switch option {
        case .delete:
            break
        case .edit:
            break
        case .report:
            let controller = ReportViewController(source: .post, contentUid: post.uid, contentId: post.postId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        case .reference:
            guard let reference = post.reference else { return }
            referenceMenu.showImageSettings(in: view, forPostId: post.postId, forReferenceKind: reference)
            referenceMenu.delegate = self
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        
        handleBookmarkUnbookmark(for: currentCell, at: indexPath)
    }
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        self.navigationController?.delegate = zoomTransitioning
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
        let controller = LikesViewController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.navigationController?.delegate = self
        
        let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)

        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension SearchViewController: DetailsCaseViewControllerDelegate {
    func didSolveCase(forCase clinicalCase: Case, with diagnosis: CaseRevisionKind?) {
        return
    }
    
    func didAddRevision(forCase clinicalCase: Case) {
        return
    }
    
    func didDeleteComment(forCase clinicalCase: Case) {
        if let index = cases.firstIndex(where: {$0.caseId == clinicalCase.caseId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 2)), let currentCell = cell as? CaseCellProtocol {
                currentCell.viewModel?.clinicalCase.numberOfComments -= 1
                cases[index].numberOfComments -= 1
                collectionView.reloadItems(at: [IndexPath(item: index, section: 2)])
            }
        }
    }
    
    func didTapLikeAction(forCase clinicalCase: Case) {
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 2)), let currentCell = cell as? CaseCellProtocol {
                self.cases[index].didLike = clinicalCase.didLike
                self.cases[index].likes = clinicalCase.likes
                
                currentCell.viewModel?.clinicalCase.didLike = clinicalCase.didLike
                currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes
            }
        }
    }
    
    func didTapBookmarkAction(forCase clinicalCase: Case) {

        if let index = cases.firstIndex(where: {$0.caseId == clinicalCase.caseId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 2)), let currentCell = cell as? CaseCellProtocol {
                
                self.cases[index].didBookmark = clinicalCase.didBookmark
                currentCell.viewModel?.clinicalCase.didBookmark = clinicalCase.didBookmark
            }
        }
    }
    
    func didComment(forCase clinicalCase: Case) {
        if let index = cases.firstIndex(where: {$0.caseId == clinicalCase.caseId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 2)), let currentCell = cell as? CaseCellProtocol {
                currentCell.viewModel?.clinicalCase.numberOfComments += 1
                cases[index].numberOfComments += 1
                collectionView.reloadItems(at: [IndexPath(item: index, section: 2)])
            }
        }
    }
    
}

extension SearchViewController: DetailsPostViewControllerDelegate {
    func didDeleteComment(forPost post: Post) {
        if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)), let currentCell = cell as? HomeCellProtocol {
                posts[index].numberOfComments -= 1
                currentCell.viewModel?.post.numberOfComments -= 1
            }
        }
    }
    
    func didTapLikeAction(forPost post: Post) {
        if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)), let currentCell = cell as? HomeCellProtocol {
                self.posts[index].didLike = post.didLike
                self.posts[index].likes = post.likes
                
                currentCell.viewModel?.post.didLike = post.didLike
                currentCell.viewModel?.post.likes = post.likes
            }
        }
    }
    
    func didTapBookmarkAction(forPost post: Post) {
        if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)), let currentCell = cell as? HomeCellProtocol {
                self.posts[index].didBookmark = post.didBookmark

                currentCell.viewModel?.post.didBookmark = post.didBookmark
            }
        }
    }
    
    func didComment(forPost post: Post) {
        if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)), let currentCell = cell as? HomeCellProtocol {
                posts[index].numberOfComments += 1
                currentCell.viewModel?.post.numberOfComments += 1
            }
        }
    }
    
    func didEditPost(forPost post: Post) { return }
}

extension SearchViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension SearchViewController: SearchResultsUpdatingViewControllerDelegate {
   
    func dismissKeyboard() {
        searchController.searchBar.searchTextField.resignFirstResponder()
    }
    
    func didTapSearchDiscipline(_ discipline: Discipline) {
        guard let tab = tabBarController as? MainTabController else { return }
        searchController.searchBar.searchTextField.resignFirstResponder()
        tab.showSearchMenu(withDisciplie: discipline)
    }
    
    func didTapSearchTopic(_ searchTopic: SearchTopics) {
        guard let tab = tabBarController as? MainTabController else { return }
        searchController.searchBar.searchTextField.resignFirstResponder()
        tab.showSearchMenu(withSearchTopic: searchTopic)
    }
}

extension SearchViewController: ReferenceMenuDelegate {
    func didTapReference(reference: Reference) {
        switch reference.option {
        case .link:
            if let url = URL(string: reference.referenceText) {
                if UIApplication.shared.canOpenURL(url) {
                    presentSafariViewController(withURL: url)
                } else {
                    presentWebViewController(withURL: url)
                }
            }
        case .citation:
            let wordToSearch = reference.referenceText
            if let encodedQuery = wordToSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: AppStrings.URL.googleQuery + encodedQuery) {
                    if UIApplication.shared.canOpenURL(url) {
                        presentSafariViewController(withURL: url)
                    } else {
                        presentWebViewController(withURL: url)
                    }
                }
            }
        }
    }
}

extension SearchViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        networkFailure = false
        collectionView.isHidden = true
        activityIndicator.start()
        fetchMainSearchContent()
    }
}

extension SearchViewController {
    func getCurrentUser() -> User? {
        guard let tab = tabBarController as? MainTabController else { return nil }
        guard let user = tab.user else { return nil }
        return user
    }
}

extension SearchViewController: EditPostViewControllerDelegate {
    func didEditPost(post: Post) {
        
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex] = post
            collectionView.reloadItems(at: [IndexPath(item: postIndex, section: 1)])
        }
    }
}

//MARK: Post Miscellaneous

extension SearchViewController {
    
    private func handleLikeUnLike(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        // Toggle the like state and count
        cell.viewModel?.post.didLike.toggle()
        self.posts[indexPath.row].didLike.toggle()
        
        cell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        self.posts[indexPath.row].likes = post.didLike ? post.likes - 1 : post.likes + 1
        
        // Cancel the previous debounce timer for this post, if any
        if let debounceTimer = likeDebounceTimers[indexPath] {
            debounceTimer.cancel()
        }
        
        // Store the initial like state and count
        if likeValues[indexPath] == nil {
            likeValues[indexPath] = post.didLike
            likeCount[indexPath] = post.likes
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let likeValue = strongSelf.likeValues[indexPath], let countValue = strongSelf.likeCount[indexPath] else {
                return
            }

            // Prevent any database action if the value remains unchanged
            if cell.viewModel?.post.didLike == likeValue {
                strongSelf.likeValues[indexPath] = nil
                strongSelf.likeCount[indexPath] = nil
                return
            }

            if post.didLike {
                PostService.unlikePost(post: post) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        cell.viewModel?.post.didLike = likeValue
                        strongSelf.posts[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.post.likes = countValue
                        strongSelf.posts[indexPath.row].likes = countValue
                    }
                    
                    strongSelf.likeValues[indexPath] = nil
                    strongSelf.likeCount[indexPath] = nil
                }
            } else {
                PostService.likePost(post: post) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    // Revert to the previous like state and count if there's an error
                    if let _ = error {
                        cell.viewModel?.post.didLike = likeValue
                        strongSelf.posts[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.post.likes = countValue
                        strongSelf.posts[indexPath.row].likes = countValue
                    }
                    
                    strongSelf.likeValues[indexPath] = nil
                    strongSelf.likeCount[indexPath] = nil
                }
            }
            
            // Clean up the debounce timer
            strongSelf.likeDebounceTimers[indexPath] = nil
        }
        
        // Save the debounce timer
        likeDebounceTimers[indexPath] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
    
    func handleBookmarkUnbookmark(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        // Toggle the bookmark state
        cell.viewModel?.post.didBookmark.toggle()
        self.posts[indexPath.row].didBookmark.toggle()
        
        // Cancel the previous debounce timer for this post, if any
        if let debounceTimer = bookmarkDebounceTimers[indexPath] {
            debounceTimer.cancel()
        }
        
        // Store the initial bookmark state
        if bookmarkValues[indexPath] == nil {
            bookmarkValues[indexPath] = post.didBookmark
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let bookmarkValue = strongSelf.bookmarkValues[indexPath] else {
                return
            }

            // Prevent any database action if the value remains unchanged
            if cell.viewModel?.post.didBookmark == bookmarkValue {
                strongSelf.bookmarkValues[indexPath] = nil
                return
            }

            if post.didBookmark {
                PostService.unbookmark(post: post) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        cell.viewModel?.post.didBookmark = bookmarkValue
                        strongSelf.posts[indexPath.row].didBookmark = bookmarkValue
                    }
                    
                    strongSelf.bookmarkValues[indexPath] = nil
                }
            } else {
                PostService.bookmark(post: post) { [weak self] error in
                    guard let strongSelf = self else { return }

                    if let _ = error {
                        cell.viewModel?.post.didBookmark = bookmarkValue
                        strongSelf.posts[indexPath.row].didBookmark = bookmarkValue
    
                    }
                    
                    strongSelf.bookmarkValues[indexPath] = nil
                }
            }
            
            // Clean up the debounce timer
            strongSelf.bookmarkDebounceTimers[indexPath] = nil
        }
        
        // Save the debounce timer
        bookmarkDebounceTimers[indexPath] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
}

//MARK: - Case Miscellaneous

extension SearchViewController {
    
    private func handleLikeUnlike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        // Toggle the like state and count
        cell.viewModel?.clinicalCase.didLike.toggle()
        self.cases[indexPath.row].didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        self.cases[indexPath.row].likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        
        // Cancel the previous debounce timer for this post, if any
        if let debounceTimer = likeDebounceTimers[indexPath] {
            debounceTimer.cancel()
        }
        
        // Store the initial like state and count
        if likeValues[indexPath] == nil {
            likeValues[indexPath] = clinicalCase.didLike
            likeCount[indexPath] = clinicalCase.likes
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            
            guard let likeValue = strongSelf.likeValues[indexPath], let countValue = strongSelf.likeCount[indexPath] else {
                return
            }
            
            // Prevent any database action if the value remains unchanged
            if cell.viewModel?.clinicalCase.didLike == likeValue {
                strongSelf.likeValues[indexPath] = nil
                strongSelf.likeCount[indexPath] = nil
                return
            }
            
            if clinicalCase.didLike {
                CaseService.unlikeCase(clinicalCase: clinicalCase) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        cell.viewModel?.clinicalCase.didLike = likeValue
                        strongSelf.cases[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.clinicalCase.likes = countValue
                        strongSelf.cases[indexPath.row].likes = countValue
                    }
                    
                    strongSelf.likeValues[indexPath] = nil
                    strongSelf.likeCount[indexPath] = nil
                }
            } else {
                CaseService.likeCase(clinicalCase: clinicalCase) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    // Revert to the previous like state and count if there's an error
                    if let _ = error {
                        cell.viewModel?.clinicalCase.didLike = likeValue
                        strongSelf.cases[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.clinicalCase.likes = countValue
                        strongSelf.cases[indexPath.row].likes = countValue
                    }
                    
                    strongSelf.likeValues[indexPath] = nil
                    strongSelf.likeCount[indexPath] = nil
                }
            }
            
            // Clean up the debounce timer
            strongSelf.likeDebounceTimers[indexPath] = nil
        }
        
        // Save the debounce timer
        likeDebounceTimers[indexPath] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
    
    func handleBookmarkUnbookmark(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        // Toggle the bookmark state
        cell.viewModel?.clinicalCase.didBookmark.toggle()
        self.cases[indexPath.row].didBookmark.toggle()
        
        // Cancel the previous debounce timer for this post, if any
        if let debounceTimer = bookmarkDebounceTimers[indexPath] {
            debounceTimer.cancel()
        }
        
        // Store the initial bookmark state
        if bookmarkValues[indexPath] == nil {
            bookmarkValues[indexPath] = clinicalCase.didBookmark
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            
            guard let bookmarkValue = strongSelf.bookmarkValues[indexPath] else {
                return
            }
            
            // Prevent any database action if the value remains unchanged
            if cell.viewModel?.clinicalCase.didBookmark == bookmarkValue {
                strongSelf.bookmarkValues[indexPath] = nil
                return
            }
            
            if clinicalCase.didBookmark {
                CaseService.unbookmarkCase(clinicalCase: clinicalCase) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        cell.viewModel?.clinicalCase.didBookmark = bookmarkValue
                        strongSelf.cases[indexPath.row].didBookmark = bookmarkValue
                    }
                    
                    strongSelf.bookmarkValues[indexPath] = nil
                }
            } else {
                CaseService.bookmarkCase(clinicalCase: clinicalCase) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        cell.viewModel?.clinicalCase.didBookmark = bookmarkValue
                        strongSelf.cases[indexPath.row].didBookmark = bookmarkValue
                        
                    }
                    
                    strongSelf.bookmarkValues[indexPath] = nil
                }
            }
            
            // Clean up the debounce timer
            strongSelf.bookmarkDebounceTimers[indexPath] = nil
        }
        
        // Save the debounce timer
        bookmarkDebounceTimers[indexPath] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
}










