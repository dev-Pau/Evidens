//
//  SearchViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let topHeaderReuseIdentifier = "TopHeaderReuseIdentifier"
private let searchHeaderReuseIdentifier = "SearchHeaderReuseIdentifier"
private let tertiarySearchHeaderReuseIdentifier = "TertiarySearchHeaderReuseIdentifier"
private let categoriesCellReuseIdentifier  = "CategoriesCellReuseIdentifier"
private let whoToFollowCellReuseIdentifier = "WhoToFollowCellReuseIdentifier"

private let postTextCellReuseIdentifier = "PostTextCellReuseIdentifier"
private let postTextImageCellReuseIdentifier = "PostTextImageCellReuseIdentifier"

private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"

private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"
private let emptyCellReuseidentifier = "EmptyCellReuseIdentifier"

class SearchViewController: NavigationBarViewController, UINavigationControllerDelegate {
    
    //MARK: - Properties

    private var viewModel = SearchViewModel()
    private var searchController: UISearchController!
    private var collectionView: UICollectionView!

    private var zoomTransitioning = ZoomTransitioning()
    private let referenceMenu = ReferenceMenu()

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
        if !viewModel.presentingSearchResults {
            scrollDelegate?.enable()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !viewModel.presentingSearchResults {
            scrollDelegate?.disable()
        }
    }
    
    private func reloadData() {
        collectionView.reloadData()
    }
    

    private func fetchMainSearchContent() {
        guard let tab = tabBarController as? MainTabController else { fatalError() }
        let user = tab.user
        
        viewModel.fetchMainSearchContent(forUser: user) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.reloadData()
        }
    }
    
    //MARK: - Helpers
    func configureNavigationBar() {

        let controller = SearchResultsUpdatingViewController()
        controller.searchResultsDelegate = self
        searchController = UISearchController(searchResultsController: controller)
        searchController.searchResultsUpdater = controller
        searchController.searchBar.delegate = controller
        
        searchController.searchBar.searchTextField.autocapitalizationType = .none
        searchController.searchBar.searchTextField.delegate = controller
        searchController.searchBar.placeholder = AppStrings.Search.Bar.search
        searchController.obscuresBackgroundDuringPresentation = false
        
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        let cornerRadius = (textField.sizeThatFits(textField.frame.size).height) / 2
 
        searchController.searchBar.searchTextField.layer.cornerRadius = cornerRadius
        searchController.searchBar.searchTextField.clipsToBounds = true
        
        searchController.searchBar.tintColor = primaryColor
        searchController.showsSearchResultsController = true
        
        searchController.delegate = self

        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        controller.hidesBottomBarWhenPushed = true
        self.definesPresentationContext = true
    }
    
    private func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectionDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.connectUser), object: nil)
        
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
    
    func searchLoaded() -> Bool {
        return viewModel.loaded
    }
    
    func scrollCollectionViewToTop() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    private func configureUI() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        view.backgroundColor = .systemBackground
        view.addSubviews(collectionView)
        collectionView.contentInset.bottom = 85
        collectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)

        collectionView.register(TertiarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: tertiarySearchHeaderReuseIdentifier)

        collectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseidentifier)
        
        collectionView.register(ConnectUserCell.self, forCellWithReuseIdentifier: whoToFollowCellReuseIdentifier)
        collectionView.register(PostTextCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        collectionView.register(PostTextImageCell.self, forCellWithReuseIdentifier: postTextImageCellReuseIdentifier)
      
        collectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        configureAddButton(primaryAppearance: true)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env -> NSCollectionLayoutSection? in
            guard let strongSelf = self else { return nil }

            if sectionNumber == 0 {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.loaded ? .estimated(44) : .absolute(50))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.networkFailure ? .estimated(200) : .absolute(63)))

                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.networkFailure ? .estimated(200) : .absolute(63)), subitems: [item])

                let section = NSCollectionLayoutSection(group: group)

                if !strongSelf.viewModel.users.isEmpty && !strongSelf.viewModel.networkFailure || !strongSelf.viewModel.loaded {
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                    section.boundarySupplementaryItems = [header]
                }
                
                return section
            } else {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(600)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(600)), subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 0

                if sectionNumber == 1 && !strongSelf.viewModel.posts.isEmpty && !strongSelf.viewModel.networkFailure {
                    section.boundarySupplementaryItems = [header]
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                } else if sectionNumber == 2 && !strongSelf.viewModel.cases.isEmpty && !strongSelf.viewModel.networkFailure {
                    section.boundarySupplementaryItems = [header]
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                }

                return section
            }
        }
        
        return layout
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.loaded ? viewModel.networkFailure ? 1 : viewModel.isEmpty ? 1 : 3 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if indexPath.section == 0 {
            if viewModel.loaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
                header.configureWith(title: AppStrings.Content.Search.whoToFollow, linkText: AppStrings.Content.Search.seeAll)
                header.hideSeeAllButton(viewModel.users.count < 3)
                
                header.delegate = self
                header.tag = indexPath.section
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            }

        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: tertiarySearchHeaderReuseIdentifier, for: indexPath) as! TertiarySearchHeader
            if indexPath.section == 1 {
                header.configureWith(title: AppStrings.Content.Search.postsForYou, linkText: AppStrings.Content.Search.seeAll)
                header.hideSeeAllButton(viewModel.posts.count < 3)
                header.delegate = self
                header.tag = indexPath.section
            } else {
                header.configureWith(title: AppStrings.Content.Search.casesForYou, linkText: AppStrings.Content.Search.seeAll)
                header.hideSeeAllButton(viewModel.cases.count < 3)
                header.delegate = self
                header.tag = indexPath.section
            }
            
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.loaded {
            if viewModel.networkFailure || viewModel.isEmpty {
                return 1
            } else {
                if section == 0 {
                    return min(3, viewModel.users.count)
                } else if section == 1 {
                    return min(3, viewModel.posts.count)
                } else {
                    return min(3, viewModel.cases.count)
                }
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.networkFailure {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
            cell.set(AppStrings.Network.Issues.Post.title)
            cell.delegate = self
            return cell
        } else if viewModel.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseidentifier, for: indexPath) as! PrimaryEmptyCell
            cell.set(withTitle: AppStrings.Content.Search.emptyTitle, withDescription: AppStrings.Content.Search.emptyContent)
            return cell
        } else {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowCellReuseIdentifier, for: indexPath) as! ConnectUserCell
                cell.viewModel = ConnectViewModel(user: viewModel.users[indexPath.row])
                cell.connectionDelegate = self
                return cell
            } else if indexPath.section == 1 {
                switch viewModel.posts[indexPath.row].kind {
                    
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextCellReuseIdentifier, for: indexPath) as! PostTextCell
                    cell.delegate = self
                    cell.viewModel = PostViewModel(post: viewModel.posts[indexPath.row])
                    
                    if let index = viewModel.postUsers.firstIndex(where:  { $0.uid == viewModel.posts[indexPath.row].uid }) {
                        cell.set(user: viewModel.postUsers[index])
                    }

                    return cell
                    
                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextImageCellReuseIdentifier, for: indexPath) as! PostTextImageCell
                    
                    cell.delegate = self
                   
                    cell.viewModel = PostViewModel(post: viewModel.posts[indexPath.row])
                    
                    if let index = viewModel.postUsers.firstIndex(where:  { $0.uid == viewModel.posts[indexPath.row].uid }) {
                        cell.set(user: viewModel.postUsers[index])
                    }
 
                    return cell
                }
            } else {
                switch viewModel.cases[indexPath.row].kind {
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                    
                    cell.delegate = self
                    
                    cell.viewModel = CaseViewModel(clinicalCase: viewModel.cases[indexPath.row])
                    
                    if viewModel.cases[indexPath.row].privacy == .anonymous {
                        cell.anonymize()
                    } else {
                        if let userIndex = viewModel.caseUsers.firstIndex(where: { $0.uid == viewModel.cases[indexPath.row].uid }) {
                            cell.set(user: viewModel.caseUsers[userIndex])
                        }
                    }

                    return cell
                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                    cell.delegate = self
                    cell.viewModel = CaseViewModel(clinicalCase: viewModel.cases[indexPath.row])
                    
                    if viewModel.cases[indexPath.row].privacy == .anonymous {
                        cell.anonymize()
                    } else {
                        if let userIndex = viewModel.caseUsers.firstIndex(where: { $0.uid == viewModel.cases[indexPath.row].uid }) {
                            cell.set(user: viewModel.caseUsers[userIndex])
                        }
                    }
                   
                    return cell
                }
            }
        }
    }
            
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard !viewModel.users.isEmpty, !viewModel.networkFailure else { return }
            let controller = UserProfileViewController(user: viewModel.users[indexPath.row])
            navigationController?.pushViewController(controller, animated: true)
            DatabaseManager.shared.addRecentUserSearches(withUid: viewModel.users[indexPath.row].uid!)
        }
    }
}

extension SearchViewController: PrimarySearchHeaderDelegate {
    func didTapSeeAll(_ header: UICollectionReusableView) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let tag = header.tag

        if tag == 0 {
            let controller = FindConnectionsViewController(user: user)
            controller.title = AppStrings.Content.Search.whoToFollow
            navigationController?.pushViewController(controller, animated: true)
        } else if tag == 1 {
            let controller = PostsViewController(source: .search, discipline: user.discipline!)
            controller.controllerIsBeeingPushed = true
            controller.title = AppStrings.Content.Search.postsForYou
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = CaseListViewController(user: user, contentSource: .search)
            controller.title = AppStrings.Content.Search.casesForYou
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension SearchViewController: ConnectUserCellDelegate {
    func didConnect(_ cell: UICollectionViewCell, connection: UserConnection) {
        
        guard let cell = cell as? ConnectUserCell, let indexPath = collectionView.indexPath(for: cell) else { return }
        guard let tab = self.tabBarController as? MainTabController, let currentUser = tab.user else { return }
        
        let user = viewModel.users[indexPath.row]
        
        switch connection.phase {
            
        case .connected:
            
            displayAlert(withTitle: AppStrings.Alerts.Title.remove, withMessage: AppStrings.Alerts.Subtitle.remove, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.withdraw, style: .destructive) { [weak self] in
                guard let strongSelf = self else { return }
                
                cell.disableButton()
                
                strongSelf.viewModel.unconnect(withUser: user) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    cell.enableButton()
                    
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        
                        cell.viewModel?.set(phase: .unconnect)
                        strongSelf.userDidChangeConnection(uid: user.uid!, phase: .unconnect)
                    }
                }
            }
        case .pending:
            displayAlert(withTitle: AppStrings.Alerts.Title.withdraw, withMessage: AppStrings.Alerts.Subtitle.withdraw, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.withdraw, style: .destructive) { [weak self] in
                guard let strongSelf = self else { return }
                
                cell.disableButton()
                
                strongSelf.viewModel.withdraw(withUser: user) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    cell.enableButton()
                    
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        cell.viewModel?.set(phase: .withdraw)
                        strongSelf.userDidChangeConnection(uid: user.uid!, phase: .withdraw)
                    }
                }
            }
        case .received:
            
            cell.disableButton()
            
            viewModel.accept(withUser: user, currentUser: currentUser) { [weak self] error in
                guard let strongSelf = self else { return }
                
                cell.enableButton()
                
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    cell.viewModel?.set(phase: .connected)
                    strongSelf.userDidChangeConnection(uid: user.uid!, phase: .connected)
                }
            }
        case .rejected:
            
            guard viewModel.hasWeeksPassedSince(forWeeks: 5, timestamp: connection.timestamp) else {
                displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.connectionDeny)
                return
            }
            
            cell.disableButton()
            
            viewModel.connect(withUser: user) { [weak self] error in
                guard let strongSelf = self else { return }
                
                cell.enableButton()
                
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    
                    cell.viewModel?.set(phase: .pending)
                    strongSelf.userDidChangeConnection(uid: user.uid!, phase: .pending)
                }
            }
        case .withdraw:
            
            guard viewModel.hasWeeksPassedSince(forWeeks: 3, timestamp: connection.timestamp) else {
                displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.connection)
                return
            }

            cell.disableButton()
            
            viewModel.connect(withUser: user) { [weak self] error in
                guard let strongSelf = self else { return }
                
                cell.enableButton()
                
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    
                    cell.viewModel?.set(phase: .pending)
                    strongSelf.userDidChangeConnection(uid: user.uid!, phase: .pending)
                }
            }
            
        case .unconnect:
            
            guard viewModel.hasWeeksPassedSince(forWeeks: 5, timestamp: connection.timestamp) else {
                displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.connection5)
                return
            }
            
            cell.disableButton()
            
            viewModel.connect(withUser: user) { [weak self] error in
                guard let strongSelf = self else { return }
                
                cell.enableButton()
                
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    
                    cell.viewModel?.set(phase: .pending)
                    strongSelf.userDidChangeConnection(uid: user.uid!, phase: .pending)
                }
            }
        case .none:
            
            cell.disableButton()
            
            viewModel.connect(withUser: user) { [weak self] error in
                guard let strongSelf = self else { return }
                
                cell.enableButton()

                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    cell.viewModel?.set(phase: .pending)
                    strongSelf.userDidChangeConnection(uid: user.uid!, phase: .pending)
                }
            }
        }
    }
}

extension SearchViewController: CaseCellDelegate {
    func clinicalCase(didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete, .revision, .solve: break
        case .report:
            let controller = ReportViewController(source: .clinicalCase, contentUid: clinicalCase.uid, contentId: clinicalCase.caseId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        }
    }
    

    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User?) {
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user)

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
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user)
        
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
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        if let userIndex = viewModel.caseUsers.firstIndex(where: { $0.uid == clinicalCase.uid }) {
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: viewModel.caseUsers[userIndex])
          
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        viewModel.selectedImage = image[index]
        
        navigationController?.delegate = zoomTransitioning

        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension SearchViewController: PostCellDelegate {
    
    func cell(showURL urlString: String) {
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                presentSafariViewController(withURL: url)
            } else {
                presentWebViewController(withURL: url)
            }
        }
    }
    
    func cell(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        self.navigationController?.delegate = self
        
        let controller = DetailsPostViewController(post: post, user: user)

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
        viewModel.selectedImage = image[index]
        self.navigationController?.delegate = zoomTransitioning
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
        let controller = LikesViewController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) {
        self.navigationController?.delegate = self
        
        let controller = DetailsPostViewController(post: post, user: user)

        navigationController?.pushViewController(controller, animated: true)
    }
}

extension SearchViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return viewModel.selectedImage
    }
}

extension SearchViewController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        viewModel.presentingSearchResults = false
        scrollDelegate?.enable()
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        viewModel.presentingSearchResults = true
        scrollDelegate?.disable()
    }
}

extension SearchViewController: SearchResultsUpdatingViewControllerDelegate {
   
    func dismissKeyboard() {
        searchController.searchBar.searchTextField.resignFirstResponder()
    }
    
    func didTapRecents(_ text: String) {
        searchController.searchBar.text = text
        searchController.searchBar.resignFirstResponder()
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
        viewModel.networkFailure = false
        viewModel.loaded = false
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
        let didLike = viewModel.posts[indexPath.row].didLike
        postDidChangeLike(postId: postId, didLike: didLike)

        // Toggle the like state and count
        cell.viewModel?.post.didLike.toggle()
        viewModel.posts[indexPath.row].didLike.toggle()
        
        cell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        viewModel.posts[indexPath.row].likes = post.didLike ? post.likes - 1 : post.likes + 1
    }
    
    func handleBookmarkUnbookmark(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
    
        let postId = post.postId
        let didBookmark = viewModel.posts[indexPath.row].didBookmark
        postDidChangeBookmark(postId: postId, didBookmark: didBookmark)
        
        // Toggle the bookmark state
        cell.viewModel?.post.didBookmark.toggle()
        viewModel.posts[indexPath.row].didBookmark.toggle()
        
        
    }
}

//MARK: - Case Miscellaneous

extension SearchViewController {
    
    private func handleLikeUnlike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didLike = viewModel.cases[indexPath.row].didLike
        
        caseDidChangeLike(caseId: caseId, didLike: didLike)

        // Toggle the like state and count
        cell.viewModel?.clinicalCase.didLike.toggle()
        viewModel.cases[indexPath.row].didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        viewModel.cases[indexPath.row].likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
    }
    
    func handleBookmarkUnbookmark(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didBookmark = viewModel.cases[indexPath.row].didBookmark
        caseDidChangeBookmark(caseId: caseId, didBookmark: didBookmark)
        
        // Toggle the bookmark state
        cell.viewModel?.clinicalCase.didBookmark.toggle()
        viewModel.cases[indexPath.row].didBookmark.toggle()
        
    }
}

extension SearchViewController: PostChangesDelegate {
    func postDidChangeVisible(postId: String) {
        return
    }
    
    func postDidChangeComment(postId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }

    func postDidChangeLike(postId: String, didLike: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.likePostChange(postId: postId, didLike: !didLike)
    }
    
    @objc func postLikeChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }

        if let change = notification.object as? PostLikeChange {
            if let index = viewModel.posts.firstIndex(where: { $0.postId == change.postId }) {
                let likes = viewModel.posts[index].likes
                
                viewModel.posts[index].likes = change.didLike ? likes + 1 : likes - 1
                viewModel.posts[index].didLike = change.didLike

                collectionView.reloadData()
            }
        }
    }
    
    func postDidChangeBookmark(postId: String, didBookmark: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.bookmarkPostChange(postId: postId, didBookmark: !didBookmark)
    }
    
    @objc func postBookmarkChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostBookmarkChange {
            if let index = viewModel.posts.firstIndex(where: { $0.postId == change.postId }) {
                viewModel.posts[index].didBookmark = change.didBookmark
                collectionView.reloadData()
            }
        }
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? PostCommentChange {
            if let index = viewModel.posts.firstIndex(where: { $0.postId == change.postId }), change.path.isEmpty {
                let comments = viewModel.posts[index].numberOfComments

                switch change.action {
                case .add:
                    viewModel.posts[index].numberOfComments = comments + 1
                case .remove:
                    viewModel.posts[index].numberOfComments = comments - 1
                }
                
                collectionView.reloadData()
            }
        }
    }
    
    @objc func postEditChange(_ notification: NSNotification) {
        if let change = notification.object as? PostEditChange {
            let post = change.post
            if let index = viewModel.posts.firstIndex(where: { $0.postId == post.postId }) {
                viewModel.posts[index] = post
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
        viewModel.currentNotification = true
        ContentManager.shared.likeCaseChange(caseId: caseId, didLike: !didLike)
    }
    
    
    @objc func caseLikeChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }

        if let change = notification.object as? CaseLikeChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                let likes = viewModel.cases[index].likes
                
                viewModel.cases[index].likes = change.didLike ? likes + 1 : likes - 1
                viewModel.cases[index].didLike = change.didLike
                collectionView.reloadData()
            }
        }
    }
    
    func caseDidChangeBookmark(caseId: String, didBookmark: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.bookmarkCaseChange(caseId: caseId, didBookmark: !didBookmark)
    }
    
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }

        if let change = notification.object as? CaseBookmarkChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.cases[index].didBookmark = change.didBookmark
                collectionView.reloadData()
            }
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.cases[index].revision = .update
                collectionView.reloadData()
            }
        }
    }

    @objc func caseCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseCommentChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }), change.path.isEmpty {
                let comments = viewModel.cases[index].numberOfComments

                switch change.action {
                    
                case .add:
                    viewModel.cases[index].numberOfComments = comments + 1
                case .remove:
                    viewModel.cases[index].numberOfComments = comments - 1
                }
                
                collectionView.reloadData()
            }
        }
    }
    
    func caseDidChangeComment(caseId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }
    
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseSolveChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {

                viewModel.cases[index].phase = .solved
                
                if let diagnosis = change.diagnosis {
                    viewModel.cases[index].revision = diagnosis
                }
                
                collectionView.reloadData()
            }
        }
    }
}

extension SearchViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {

        if let user = notification.userInfo!["user"] as? User {
            
            if let postIndex = viewModel.postUsers.firstIndex(where: { $0.uid! == user.uid! }) {
                viewModel.postUsers[postIndex] = user
                collectionView.reloadData()
            }
            
            if let caseIndex = viewModel.caseUsers.firstIndex(where: { $0.uid! == user.uid!}) {
                viewModel.caseUsers[caseIndex] = user
                collectionView.reloadData()
            }
        }
    }
}

extension SearchViewController: UserConnectDelegate {
    func userDidChangeConnection(uid: String, phase: ConnectPhase) {
        viewModel.currentNotification = true
        ContentManager.shared.userConnectionChange(uid: uid, phase: phase)
    }
    
    @objc func connectionDidChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? UserConnectionChange {
            if let index = viewModel.users.firstIndex(where: { $0.uid! == change.uid }) {
                viewModel.users[index].editConnectionPhase(phase: change.phase)
                collectionView.reloadData()
            }
        }
    }
}










