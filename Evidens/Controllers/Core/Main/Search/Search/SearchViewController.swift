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
    
    private let activityIndicator = PrimaryProgressIndicatorView(frame: .zero)
    private lazy var lockView = MEPrimaryBlurLockView(frame: view.bounds)
    
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
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        guard NetworkMonitor.shared.isConnected else {
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
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }

        if user.phase == .verified {
            let controller = SearchResultsUpdatingViewController(user: user)
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
        }
        
        self.definesPresentationContext = true
    }
    
    private func configureUI() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        view.backgroundColor = .systemBackground
        view.addSubviews(activityIndicator, collectionView)
        collectionView.isHidden = true

        collectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        collectionView.register(PrimarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: topHeaderReuseIdentifier)
       
        collectionView.register(NetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
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
            //searchController.didselect
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env -> NSCollectionLayoutSection? in
            guard let strongSelf = self else { return nil }

            if sectionNumber == 0 {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))

                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65)), subitems: [item])

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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! NetworkFailureCell
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
                    
                    if let index = caseUsers.firstIndex(where: { $0.uid == cases[indexPath.row].uid }) {
                        cell.set(user: caseUsers[index])
                    }
                    
                    cell.delegate = self
                    if indexPath.row == cases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    return cell
                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    
                    if let index = caseUsers.firstIndex(where: { $0.uid == cases[indexPath.row].uid }) {
                        cell.set(user: caseUsers[index])
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

        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is CaseTextCell:
            let currentCell = cell as! CaseTextCell
            currentCell.viewModel?.clinicalCase.didLike.toggle()
            if clinicalCase.didLike {
                //Unlike post here
                CaseService.unlikeCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                    self.cases[indexPath.row].didLike = false
                    self.cases[indexPath.row].likes -= 1

                }
            } else {
                //Like post here
                CaseService.likeCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    self.cases[indexPath.row].didLike = true
                    self.cases[indexPath.row].likes += 1
                }
            }
            
        case is CaseTextImageCell:
            let currentCell = cell as! CaseTextImageCell
            currentCell.viewModel?.clinicalCase.didLike.toggle()
            if clinicalCase.didLike {
                //Unlike post here
                CaseService.unlikeCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                    self.cases[indexPath.row].didLike = false
                    self.cases[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                CaseService.likeCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    self.cases[indexPath.row].didLike = true
                    self.cases[indexPath.row].likes += 1
                }
            }
        default:
            print("Cell not registered")
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is CaseTextCell:
            let currentCell = cell as! CaseTextCell
            currentCell.viewModel?.clinicalCase.didBookmark.toggle()
            if clinicalCase.didBookmark {
                //Unlike post here
                CaseService.unbookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks - 1
                    self.cases[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                CaseService.bookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    self.cases[indexPath.row].didBookmark = true
                }
            }
            
        case is CaseTextImageCell:
            let currentCell = cell as! CaseTextImageCell
            currentCell.viewModel?.clinicalCase.didBookmark.toggle()
            if clinicalCase.didBookmark {
                //Unlike post here
                CaseService.unbookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks - 1
                    self.cases[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                CaseService.bookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    self.cases[indexPath.row].didBookmark = true
                }
            }
        default:
            print("Cell not registered")
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
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

        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                }
            }
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                    
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                }
            }
            
        default:
            break
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
       
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    func cell(_ cell: UICollectionViewCell, didTapMenuOptionsFor post: Post, option: PostMenu) {
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
            #warning("fetch del text i mostrar")
            //let postReference = Reference(option: reference, referenceText: referenceText)
            //referenceMenuLauncher.reference = postReference
            //referenceMenuLauncher.delegate = self
            //referenceMenuLauncher.showImageSettings(in: view)
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                   
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
  
                    self.posts[indexPath.row].didBookmark = true
                }
            }
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                   
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                   
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                  
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                 
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                 
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                   
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                  
                    self.posts[indexPath.row].didBookmark = true
                }
            }

        default:
            break
        }
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
        
    }
    
    func didAddRevision(forCase clinicalCase: Case) { }
    
    func didDeleteComment(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[caseIndex].numberOfComments -= 1
            
            switch clinicalCase.kind {
            case .text:
                let cell = collectionView.cellForItem(at: IndexPath(item: caseIndex, section: 4)) as! CaseTextCell
                cell.viewModel?.clinicalCase.numberOfComments -= 1
                
            case .image:
                let cell = collectionView.cellForItem(at: IndexPath(item: caseIndex, section: 4)) as! CaseTextImageCell
                cell.viewModel?.clinicalCase.numberOfComments -= 1
            }
        }
    }
    
    func didTapLikeAction(forCase clinicalCase: Case) {
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 4)) {
                self.clinicalCase(cell, didLike: clinicalCase)
            }
        }
    }
    
    func didTapBookmarkAction(forCase clinicalCase: Case) {
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 4)) {
                self.clinicalCase(cell, didBookmark: clinicalCase)
            }
        }
    }
    
    func didComment(forCase clinicalCase: Case) {
        let caseIndex = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = caseIndex {
            cases[index].numberOfComments += 1
            collectionView.reloadItems(at: [IndexPath(item: index, section: 4)])
        }
    }
    
}

extension SearchViewController: DetailsPostViewControllerDelegate {
    func didDeleteComment(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex].numberOfComments -= 1
            
            switch post.kind {
            case .plainText:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 3)) as! HomeTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 3)) as! HomeImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithTwoImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 3)) as! HomeTwoImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithThreeImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 3)) as! HomeThreeImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithFourImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 3)) as! HomeFourImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
            }
        }
    }
    
    func didTapLikeAction(forPost post: Post) {
        let index = posts.firstIndex { homePost in
            if homePost.postId == post.postId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 3)) {
                self.cell(cell, didLike: post)
            }
        }
    }
    
    func didTapBookmarkAction(forPost post: Post) {
        let index = posts.firstIndex { homePost in
            if homePost.postId == post.postId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 3)) {
                self.cell(cell, didBookmark: post)
            }
        }
    }
    
    func didComment(forPost post: Post) {
        let index = posts.firstIndex { homePost in
            if homePost.postId == post.postId {
                return true
            }
            return false
        }
        
        if let index = index {

            posts[index].numberOfComments += 1
            
            switch post.kind {
            case .plainText:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 3)) as! HomeTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 3)) as! HomeImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithTwoImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 3)) as! HomeTwoImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithThreeImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 3)) as! HomeThreeImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithFourImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 3)) as! HomeFourImageTextCell
                cell.viewModel?.post.numberOfComments += 1
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

