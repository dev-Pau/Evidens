//
//  SearchViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

private let topHeaderReuseIdentifier = "TopHeaderReuseIdentifier"
private let searchHeaderReuseIdentifier = "SearchHeaderReuseIdentifier"
private let tertiarySearchHeaderReuseIdentifier = "TertiarySearchHeaderReuseIdentifier"
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
    private var currentNotification: Bool = false
    private let activityIndicator = PrimaryLoadingView(frame: .zero)

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureNotificationObservers()
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
        
    }
    
    private func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(followDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.followUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(postLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.postLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.postBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.postComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postEditChange(_:)), name: NSNotification.Name(AppPublishers.Names.postEdit), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseRevisionChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseRevision), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseSolveChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseSolve), object: nil)
    }
    
    private func configureUI() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        view.backgroundColor = .systemBackground
        view.addSubviews(activityIndicator, collectionView)
        collectionView.isHidden = true

        collectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)

        collectionView.register(TertiarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: tertiarySearchHeaderReuseIdentifier)

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
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 0

                if sectionNumber == 1 && !strongSelf.posts.isEmpty && !strongSelf.networkFailure {
                    section.boundarySupplementaryItems = [header]
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                } else if sectionNumber == 2 && !strongSelf.cases.isEmpty && !strongSelf.networkFailure {
                    section.boundarySupplementaryItems = [header]
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
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

        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
            header.configureWith(title: AppStrings.Content.Search.whoToFollow, linkText: AppStrings.Content.Search.seeAll)
            header.hideSeeAllButton(users.count < 3)
            header.delegate = self
            header.tag = indexPath.section
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: tertiarySearchHeaderReuseIdentifier, for: indexPath) as! TertiarySearchHeader
            if indexPath.section == 1 {
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
        if indexPath.section == 0 {
            let controller = UserProfileViewController(user: users[indexPath.row])
            navigationController?.pushViewController(controller, animated: true)
            DatabaseManager.shared.addRecentUserSearches(withUid: users[indexPath.row].uid!)
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
            controller.discipline = user.discipline!
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
                
                strongSelf.userDidChangeFollow(uid: user.uid!, didFollow: true)
                
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
                
                strongSelf.userDidChangeFollow(uid: user.uid!, didFollow: false)
                
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

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)

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
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
        handleLikeUnlike(for: currentCell, at: indexPath)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
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

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
        handleLikeUnLike(for: currentCell, at: indexPath)

    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
       
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(didTapMenuOptionsFor post: Post, option: PostMenu) {
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

        navigationController?.pushViewController(controller, animated: true)
    }
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


//MARK: Post Miscellaneous

extension SearchViewController {
    
    private func handleLikeUnLike(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }

        let postId = post.postId
        let didLike = posts[indexPath.row].didLike
        postDidChangeLike(postId: postId, didLike: didLike)

        // Toggle the like state and count
        cell.viewModel?.post.didLike.toggle()
        self.posts[indexPath.row].didLike.toggle()
        
        cell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        self.posts[indexPath.row].likes = post.didLike ? post.likes - 1 : post.likes + 1
    }
    
    func handleBookmarkUnbookmark(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
    
        let postId = post.postId
        let didBookmark = posts[indexPath.row].didBookmark
        postDidChangeBookmark(postId: postId, didBookmark: didBookmark)
        
        // Toggle the bookmark state
        cell.viewModel?.post.didBookmark.toggle()
        self.posts[indexPath.row].didBookmark.toggle()
        
        
    }
}

//MARK: - Case Miscellaneous

extension SearchViewController {
    
    private func handleLikeUnlike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didLike = cases[indexPath.row].didLike
        
        caseDidChangeLike(caseId: caseId, didLike: didLike)

        // Toggle the like state and count
        cell.viewModel?.clinicalCase.didLike.toggle()
        self.cases[indexPath.row].didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        self.cases[indexPath.row].likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        
        
    }
    
    func handleBookmarkUnbookmark(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didBookmark = cases[indexPath.row].didBookmark
        caseDidChangeBookmark(caseId: caseId, didBookmark: didBookmark)
        
        // Toggle the bookmark state
        cell.viewModel?.clinicalCase.didBookmark.toggle()
        self.cases[indexPath.row].didBookmark.toggle()
        
    }
}

extension SearchViewController: PostChangesDelegate {
    func postDidChangeVisible(postId: String) {
        // Posts from current user are not displayed in this view controller.
        return
    }
    
    func postDidChangeComment(postId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }

    func postDidChangeLike(postId: String, didLike: Bool) {
        currentNotification = true
        ContentManager.shared.likePostChange(postId: postId, didLike: !didLike)
    }
    
    @objc func postLikeChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }

        if let change = notification.object as? PostLikeChange {
            if let index = posts.firstIndex(where: { $0.postId == change.postId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)), let currentCell = cell as? HomeCellProtocol {

                    let likes = self.posts[index].likes
                    
                    self.posts[index].likes = change.didLike ? likes + 1 : likes - 1
                    self.posts[index].didLike = change.didLike
                    
                    currentCell.viewModel?.post.didLike = change.didLike
                    currentCell.viewModel?.post.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
    
    func postDidChangeBookmark(postId: String, didBookmark: Bool) {
        currentNotification = true
        ContentManager.shared.bookmarkPostChange(postId: postId, didBookmark: !didBookmark)
    }
    
    @objc func postBookmarkChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostBookmarkChange {
            if let index = posts.firstIndex(where: { $0.postId == change.postId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)), let currentCell = cell as? HomeCellProtocol {
                    
                    self.posts[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.post.didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? PostCommentChange {
            if let index = posts.firstIndex(where: { $0.postId == change.postId }), change.path.isEmpty {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)), let currentCell = cell as? HomeCellProtocol {
                    
                    let comments = self.posts[index].numberOfComments

                    switch change.action {
                    case .add:
                        self.posts[index].numberOfComments = comments + 1
                        currentCell.viewModel?.post.numberOfComments = comments + 1
                    case .remove:
                        self.posts[index].numberOfComments = comments - 1
                        currentCell.viewModel?.post.numberOfComments = comments - 1
                    }
                }
            }
        }
    }
    
    @objc func postEditChange(_ notification: NSNotification) {
        if let change = notification.object as? PostEditChange {
            let post = change.post
            if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                posts[index] = post
                collectionView.reloadItems(at: [IndexPath(item: index, section: 1)])
            }
        }
    }
}

//MARK: - Case Changes

extension SearchViewController: CaseChangesDelegate {
   
    func caseDidChangeVisible(caseId: String) {
        return
    }
    
    func caseDidChangeLike(caseId: String, didLike: Bool) {
        currentNotification = true
        ContentManager.shared.likeCaseChange(caseId: caseId, didLike: !didLike)
    }
    
    
    @objc func caseLikeChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }

        if let change = notification.object as? CaseLikeChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 2)), let currentCell = cell as? CaseCellProtocol {

                    let likes = self.cases[index].likes
                    
                    self.cases[index].likes = change.didLike ? likes + 1 : likes - 1
                    self.cases[index].didLike = change.didLike
                    
                    currentCell.viewModel?.clinicalCase.didLike = change.didLike
                    currentCell.viewModel?.clinicalCase.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
    
    func caseDidChangeBookmark(caseId: String, didBookmark: Bool) {
        currentNotification = true
        ContentManager.shared.bookmarkCaseChange(caseId: caseId, didBookmark: !didBookmark)
    }
    
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }

        if let change = notification.object as? CaseBookmarkChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 2)), let currentCell = cell as? CaseCellProtocol {

                    self.cases[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.clinicalCase.didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 2)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.revision = .update
                    cases[index].revision = .update
                    collectionView.reloadData()
                }
            }
        }
    }

    @objc func caseCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseCommentChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }), change.path.isEmpty {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 2)) as? CaseCellProtocol {
                    
                    let comments = self.cases[index].numberOfComments

                    switch change.action {
                        
                    case .add:
                        cases[index].numberOfComments = comments + 1
                        cell.viewModel?.clinicalCase.numberOfComments = comments + 1
                    case .remove:
                        cases[index].numberOfComments = comments - 1
                        cell.viewModel?.clinicalCase.numberOfComments = comments - 1
                    }
                }
            }
        }
    }
    
    func caseDidChangeComment(caseId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }
    
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseSolveChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 2)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.phase = .solved
                    cases[index].phase = .solved
                    
                    if let diagnosis = change.diagnosis {
                        cases[index].revision = diagnosis
                        cell.viewModel?.clinicalCase.revision = diagnosis
                    }
                    
                    collectionView.reloadData()
                }
            }
        }
    }
}

extension SearchViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {

        if let user = notification.userInfo!["user"] as? User {
            
            if let postIndex = postUsers.firstIndex(where: { $0.uid! == user.uid! }) {
                postUsers[postIndex] = user
                collectionView.reloadData()
            }
            
            if let caseIndex = caseUsers.firstIndex(where: { $0.uid! == user.uid!}) {
                caseUsers[caseIndex] = user
                collectionView.reloadData()
            }
        }
    }
}

extension SearchViewController: UserFollowDelegate {
    
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










