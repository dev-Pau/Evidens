//
//  SearchViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

private let topHeaderReuseIdentifier = "TopHeaderReuseIdentifier"
private let searchHeaderReuseIdentifier = "SearchHeaderReuseIdentifier"
private let newsForYouCellReuseIdentifier = "NewsForYouCellReuseIdentifier"
private let categoriesCellReuseIdentifier  = "CategoriesCellReuseIdentifier"
private let recentNewsCellReuseIdentifier = "RecentNewsCellReuseIdentifier"
private let whoToFollowCellReuseIdentifier = "WhoToFollowCellReuseIdentifier"

private let homeTextCellReuseIdentifier = "HomeTextCellReuseIdentifier"
private let homeImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let homeTwoImageTextCellReuseIdentifier = "HomeTwoImageTextCellReuseIdentifier"
private let homeThreeImageTextCellReuseIdentifier = "HomeThreeImageTextCellReuseIdentifier"
private let homeFourImageTextCellReuseIdentifier = "HomeFourImageTextCellReuseIdentifier"

private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"


class SearchViewController: NavigationBarViewController, UINavigationControllerDelegate {
    
    //MARK: - Properties
    private var searchController: UISearchController!
    
    private var collectionView: UICollectionView!
    private var contentLoaded: Bool = false
    private var professions = Profession.getAllProfessions()
    private var newsForYou = [New]()
    private var recentNews = [New]()
    private var users = [User]()
    private var posts = [Post]()
    private var postUsers = [User]()
    private var cases = [Case]()
    private var caseUsers = [User]()
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
    
    private let activityIndicator = MEProgressHUD(frame: .zero)
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
        
        var count = 0
        NewService.fetchTopNewsForYou { news in
            self.newsForYou = news
            count += 1
            self.checkIfAllTheContentIsFetched(count: count)
        }
        
        NewService.fetchTopRecentForYou { news in
            self.recentNews = news
            count += 1
            self.checkIfAllTheContentIsFetched(count: count)
        }
        
        UserService.fetchWhoToFollowUsers { users in
            self.users = users
            count += 1
            self.checkIfAllTheContentIsFetched(count: count)
        }
        
        PostService.fetchPostsForYou(user: user) { posts in
            guard !posts.isEmpty else {
                count += 1
                self.checkIfAllTheContentIsFetched(count: count)
                return
            }
            self.posts = posts
            let uids = posts.map { $0.ownerUid }
            UserService.fetchUsers(withUids: uids) { users in
                self.postUsers = users
                count += 1
                self.checkIfAllTheContentIsFetched(count: count)
            }
        }
        
        CaseService.fetchCasesForYou(user: user) { cases in
            guard !cases.isEmpty else {
                count += 1
                self.checkIfAllTheContentIsFetched(count: count)
                return
            }
            
            self.cases = cases
            let uids = cases.map { $0.ownerUid }
            UserService.fetchUsers(withUids: uids) { users in
                self.caseUsers = users
                count += 1
                self.checkIfAllTheContentIsFetched(count: count)
            }
        }
    }

    func checkIfAllTheContentIsFetched(count: Int) {
        if count == 5 {
            guard let tab = tabBarController as? MainTabController else { return }
            guard let user = tab.user else { return }
            
            self.activityIndicator.stop()
            
            if user.phase != .verified {
                self.view.addSubview(self.lockView)
            }
            
            self.collectionView.reloadData()
            self.collectionView.isHidden = false
        }
    }

    //MARK: - Helpers
    func configureNavigationBar() {
        title = "Search"
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        if user.phase == .verified {
            let controller = SearchResultsUpdatingViewController()
            searchController = UISearchController(searchResultsController: controller)
            searchController.searchResultsUpdater = controller
            searchController.searchBar.delegate = controller
            searchController.searchBar.placeholder = "Search"
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.tintColor = primaryColor
            searchController.showsSearchResultsController = true
            navigationItem.hidesSearchBarWhenScrolling = false
            navigationItem.searchController = searchController
        }
    }
    
    private func configureUI() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        view.backgroundColor = .systemBackground
        view.addSubviews(activityIndicator, collectionView)
        collectionView.isHidden = true

        collectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        collectionView.register(MainSearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: topHeaderReuseIdentifier)
        collectionView.register(YourNewsCell.self, forCellWithReuseIdentifier: newsForYouCellReuseIdentifier)
        collectionView.register(RecentNewsCell.self, forCellWithReuseIdentifier: recentNewsCellReuseIdentifier)
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
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection? in
            if sectionNumber == 0 {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .absolute(260)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.interGroupSpacing = 7
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                section.boundarySupplementaryItems = [header]
                return section
            } else if sectionNumber == 1 {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))

                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .absolute(100)), subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.interGroupSpacing = 7
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                section.boundarySupplementaryItems = [header]

                return section
            } else if sectionNumber == 2 {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))

                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65)), subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                //section.interGroupSpacing = 10
              
                if !self.users.isEmpty {
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
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

                
                if sectionNumber == 3 && !self.posts.isEmpty {
                    section.boundarySupplementaryItems = [header]
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                } else if sectionNumber == 4 && !self.cases.isEmpty {
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
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: topHeaderReuseIdentifier, for: indexPath) as! MainSearchHeader
            header.tag = 0
            header.delegate = self
            header.configureWith(title: "News for you", linkText: "See All")
            return header
        } else if indexPath.section == 1 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: topHeaderReuseIdentifier, for: indexPath) as! MainSearchHeader
            header.tag = 1
            header.configureWith(title: "Latest news", linkText: "See All")
            header.delegate = self
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
            if indexPath.section == 2 {
                header.configureWith(title: "Who to follow", linkText: "See All")
                header.delegate = self
                header.tag = 2
            } else if indexPath.section == 3 {
                header.configureWith(title: "Posts for you", linkText: "See All")
                header.delegate = self
                header.tag = 3
            } else {
                header.configureWith(title: "Cases for you", linkText: "See All")
                header.delegate = self
                header.tag = 4
            }

            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return newsForYou.count
        } else if section == 1 {
            return recentNews.count
        } else if section == 2 {
            return min(3, users.count)
        } else if section == 3 {
            return min(3, posts.count)
        } else {
            return min(3, cases.count)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsForYouCellReuseIdentifier, for: indexPath) as! YourNewsCell
            cell.viewModel = NewViewModel(new: newsForYou[indexPath.row])
            return cell
        } else if indexPath.section == 1  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentNewsCellReuseIdentifier, for: indexPath) as! RecentNewsCell
            cell.viewModel = NewViewModel(new: recentNews[indexPath.row])
            return cell
        } else if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowCellReuseIdentifier, for: indexPath) as! WhoToFollowCell
            cell.configureWithUser(user: users[indexPath.row])
            cell.followerDelegate = self
            return cell
        } else if indexPath.section == 3 {
            if let index = postUsers.firstIndex(where:  { $0.uid == posts[indexPath.row].ownerUid }) {
                switch posts[indexPath.row].type {
                case .plainText:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTextCellReuseIdentifier, for: indexPath) as! HomeTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: postUsers[index])
                    cell.delegate = self
                    return cell
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: postUsers[index])
                    cell.delegate = self
                    return cell
                case .textWithTwoImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: postUsers[index])
                    cell.delegate = self
                    return cell
                case .textWithThreeImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: postUsers[index])
                    cell.delegate = self
                    return cell
                case .textWithFourImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: postUsers[index])
                    cell.delegate = self
                    return cell
                case .document:
                    return UICollectionViewCell()
                case .poll:
                    return UICollectionViewCell()
                case .video:
                    return UICollectionViewCell()
                }
            }
        } else {
            if let index = caseUsers.firstIndex(where: { $0.uid == cases[indexPath.row].ownerUid }){
                switch cases[indexPath.row].type {
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    cell.set(user: caseUsers[index])
                    cell.delegate = self
                    return cell
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    cell.set(user: caseUsers[index])
                    cell.delegate = self
                    return cell
                }
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard !newsForYou.isEmpty else { return }
            let controller = NewViewController(new: newsForYou[indexPath.row])
            controller.topBarHeight = topbarHeight - statusBarHeight
         
            //navigationController?.setNavigationBarHidden(true, animated: false)
            
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.section == 1 {
            guard !recentNews.isEmpty else { return }
            let controller = NewViewController(new: recentNews[indexPath.row])
            controller.topBarHeight = topbarHeight - statusBarHeight
         
            //navigationController?.setNavigationBarHidden(true, animated: false)
            
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.section == 2 {
            let controller = UserProfileViewController(user: users[indexPath.row])
            let backItem = UIBarButtonItem()
            backItem.tintColor = .label
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension SearchViewController: MainSearchHeaderDelegate {
    func didTapSeeAll(_ header: UICollectionReusableView) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let tag = header.tag
        var text = ""
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label

        navigationItem.backBarButtonItem = backItem
        
        if tag == 0 {
            text = "News for You"
            let controller = NewsListViewController()
            controller.title = text
            navigationController?.pushViewController(controller, animated: true)
        } else if tag == 1 {
            text = "Latest News"
            let controller = NewsListViewController()
            controller.title = text
            navigationController?.pushViewController(controller, animated: true)
        } else if tag == 2 {
            text = "Who to follow"
            let controller = WhoToFollowViewController()
            controller.title = text
            navigationController?.pushViewController(controller, animated: true)
        } else if tag == 3 {
            text = "Posts for you"
            let controller = HomeViewController(contentSource: .search)
            controller.controllerIsBeeingPushed = true
            controller.displaysSinglePost = true
            controller.user = user
            controller.title = text
            navigationController?.pushViewController(controller, animated: true)
        } else {
            text = "Cases for you"
            let controller = CaseViewController(user: user, contentSource: .search)
            navigationController?.pushViewController(controller, animated: true)
            controller.title = text
            
        }
    }
}

extension SearchViewController: UsersFollowCellDelegate {
    func didFollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! WhoToFollowCell
        UserService.follow(uid: user.uid!) { error in
            currentCell.isUpdatingFollowState = false
            if let _ = error {
                return
            }
            
            currentCell.userIsFollowing = true
            
            if let indexPath = self.collectionView.indexPath(for: cell) {
                self.users[indexPath.row].isFollowed = true
            }
            
            PostService.updateUserFeedAfterFollowing(userUid: user.uid!, didFollow: true)
        }
    }
    
    func didUnfollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! WhoToFollowCell
        UserService.unfollow(uid: user.uid!) { error in
            currentCell.isUpdatingFollowState = false
            if let _ = error {
                return
            }
            
            currentCell.userIsFollowing = false
            
            if let indexPath = self.collectionView.indexPath(for: cell) {
                self.users[indexPath.row].isFollowed = false
            }
            
            PostService.updateUserFeedAfterFollowing(userUid: user.uid!, didFollow: false)
        }
    }
}


extension SearchViewController: CaseCellDelegate {
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        let controller = PostLikesViewController(contentType: clinicalCase)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        let controller = CommentCaseViewController(clinicalCase: clinicalCase, user: user, type: .regular)
        controller.delegate = self
        controller.hidesBottomBarWhenPushed = true
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
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
                    NotificationService.uploadNotification(toUid: clinicalCase.ownerUid, fromUser: user, type: .likeCase, clinicalCase: clinicalCase)
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
                    NotificationService.uploadNotification(toUid: clinicalCase.ownerUid, fromUser: user, type: .likeCase, clinicalCase: clinicalCase)
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
                    //NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
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
                    //NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            }
        default:
            print("Cell not registered")
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: Case.CaseMenuOptions) {
        switch option {
        case .delete:
            break
        case .update:
            break
        case .solved:
            break
        case .report:
            let reportPopup = METopPopupView(title: "Case successfully reported", image: "checkmark.circle.fill", popUpType: .regular)
            reportPopup.showTopPopup(inView: self.view)
        case .edit:
            break
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        if let userIndex = caseUsers.firstIndex(where: { $0.uid == clinicalCase.ownerUid }) {
            let controller = CaseUpdatesViewController(clinicalCase: clinicalCase, user: caseUsers[userIndex])
            controller.controllerIsPushed = true

            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            self.navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        self.navigationController?.delegate = zoomTransitioning

        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .clear
        navigationItem.backBarButtonItem = backItem

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, type: .regular, collectionViewFlowLayout: layout)
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension SearchViewController: HomeCellDelegate {
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        let controller = CommentPostViewController(post: post, user: user, type: .regular)
        controller.delegate = self
        //displayState = displaysSinglePost ? .others : .none
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        controller.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
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
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
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
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
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
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
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
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
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
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            }
            
        default:
            break
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    func cell(_ cell: UICollectionViewCell, didTapMenuOptionsFor post: Post, option: Post.PostMenuOptions) {
        switch option {
        case .delete:
            break
        case .edit:
            break
        case .report:
            let reportPopup = METopPopupView(title: "Post reported", image: "flag.fill", popUpType: .regular)
            reportPopup.showTopPopup(inView: self.view)
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
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.posts[indexPath.row].didBookmark = true
                }
            }
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
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
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        //controller.customDelegate = self
       
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .clear
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
        let controller = PostLikesViewController(contentType: post)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.navigationController?.delegate = self
        
        let controller = DetailsPostViewController(post: post, user: user, type: .regular, collectionViewLayout: layout)

        controller.delegate = self
       
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

  /*
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemBackground
        tableView.sectionHeaderTopPadding = 0
        
        tableView.register(RecentUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(RecentHeader.self, forHeaderFooterViewReuseIdentifier: recentHeaderReuseIdentifier)
        tableView.register(RecentTextCell.self, forCellReuseIdentifier: recentTextReuseIdentifier)
        //tableView.rowHeight = 64
        tableView.keyboardDismissMode = .onDrag
    }
   */
    /*
    func configureUI() {
        let refresher = UIRefreshControl()
        
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refresher
        //view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    func fetchRecents() {
        DatabaseManager.shared.fetchRecentSearches { recents in
            self.loaded = true
            switch recents {
            case .success(let recentSearches):
                print(recentSearches)
                self.recentSearchedText = recentSearches
            case .failure(let error):
                print(error)
            }
        }
        tableView.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }
     */
    
    /*
    //MARK: - Actions
    @objc func handleRefresh() {
        HapticsManager.shared.vibrate(for: .success)
        recentSearchedText.removeAll()
        fetchRecents()
        
    }
     */


/*
//MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: recentHeaderReuseIdentifier) as! RecentHeader
            headerCell.delegate = self
            return headerCell
        } else {
            return nil
        }
        
    }
    
    // Returns the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return recentSearchedText.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 20 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RecentUserCell
            cell.delegate = self
            //cell.recentUsers = users[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: recentTextReuseIdentifier, for: indexPath) as! RecentTextCell
            cell.viewModel = RecentTextCellViewModel(recentText: recentSearchedText[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }  
        //let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        //let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        //cell.viewModel = UserCellViewModel(user: user)
        //return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        } else {
            return 50
            
        }
    }
     
    
}

//MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            
            // Press on recent text cell
            
            // When we have full text Search this is the good approach
            let controller = SearchResultsViewController()
            controller.searchedText = recentSearchedText[indexPath.row]
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
            fetchRecents()

        }
        //let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        //Navigate to profile controller of the selected user
        //let controller = ProfileViewController(user: user)
        //navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - UISearchBarDelegate


extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        
        DatabaseManager.shared.uploadRecentSearches(with: text) { _ in
            // Text uploaded to recent searches of user
        }
        
        let controller = SearchResultsViewController()
        controller.searchedText = text
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem

        navigationController?.pushViewController(controller, animated: true)
    }
}


//MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        //Search for first or last name
        filteredUsers = users.filter({ $0.firstName!.contains(searchText) || $0.lastName!.contains(searchText)
        })
        self.tableView.reloadData()
    }
}

extension SearchViewController: RecentUserCellDelegate {
    func didTapProfileFor(_ user: User) {
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        let controller = UserProfileViewController(user: user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
}

extension SearchViewController: RecentHeaderDelegate {

    func didTapClearButton() {
        deleteRecentSearchesAlert {
            DatabaseManager.shared.deleteRecentSearches { result in
                switch result {
                case .success(_):
                    self.recentSearchedText.removeAll()
                    self.fetchRecents()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
*/

extension SearchViewController: CommentCaseViewControllerDelegate {
    func didDeleteCaseComment(clinicalCase: Case, comment: Comment) {
        didDeleteComment(forCase: clinicalCase)
    }
    
    func didCommentCase(clinicalCase: Case, user: User, comment: Comment) {
        let caseIndex = cases.firstIndex { searchCase in
            if searchCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = caseIndex {
            cases[index].numberOfComments += 1
            collectionView.reloadSections(IndexSet(integer: 4))
        }
    }
}

extension SearchViewController: DetailsCaseViewControllerDelegate {
    func didDeleteComment(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[caseIndex].numberOfComments -= 1
            
            switch clinicalCase.type {
            case .text:
                let cell = collectionView.cellForItem(at: IndexPath(item: caseIndex, section: 4)) as! CaseTextCell
                cell.viewModel?.clinicalCase.numberOfComments -= 1
                
            case .textWithImage:
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
            collectionView.reloadSections(IndexSet(integer: 4))
        }
    }
    
    func didAddUpdate(forCase clinicalCase: Case) { return }
    
    func didAddDiagnosis(forCase clinicalCase: Case) { return }
}

extension SearchViewController: DetailsPostViewControllerDelegate {
    func didDeleteComment(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex].numberOfComments -= 1
            
            switch post.type {
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
                
            case .document:
                break
            case .poll:
                break
            case .video:
                break
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
            
            switch post.type {
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
                
            case .document:
                break
            case .poll:
                break
            case .video:
                break
            }

        }
    }
    
    func didEditPost(forPost post: Post) { return }
}

extension SearchViewController: CommentPostViewControllerDelegate {
    func didDeletePostComment(post: Post, comment: Comment) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex].numberOfComments -= 1
            
            switch post.type {
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
                
            case .document:
                break
            case .poll:
                break
            case .video:
                break
            }
        }
    }
    
    func didCommentPost(post: Post, user: User, comment: Comment) {
        let postIndex = posts.firstIndex { homePost in
            if homePost.postId == post.postId { return true }
            return false
        }
        
        if let index = postIndex {
            posts[index].numberOfComments += 1
            
            switch post.type {
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
                
            case .document:
                break
            case .poll:
                break
            case .video:
                break
            }
        }
    }
}

extension SearchViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}
