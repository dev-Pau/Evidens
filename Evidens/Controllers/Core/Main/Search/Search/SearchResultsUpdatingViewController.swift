//
//  SearchResultsUpdatingViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/2/23.
//

import UIKit
import Firebase

private let topHeaderReuseIdentifier = "TopHeaderReuseIdentifier"
private let searchHeaderReuseIdentifier = "SearchHeaderReuseIdentifier"
private let secondarySearchHeaderReuseIdentifier = "SecondarySearchHeaderReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let searchRecentsHeaderReuseIdentifier = "SearchRecentsHeaderReuseIdentifier"
private let recentSearchesUserCellReuseIdentifier = "RecentSearchesUserCellReuseIdentifier"
private let recentContentSearchReuseIdentifier = "RecentContentSearchReuseIdentifier"
private let whoToFollowCellReuseIdentifier = "WhoToFollowCellReuseIdentifier"
private let emptyTopicsCellReuseIdentifier = "EmptyTopicsCellReuseIdentifier"
private let emptyCategoriesTopicsCellReuseIdentifier = "EmptyCategoriesTopicsCellReuseIdentifier"

private let reuseIdentifier = "HomeTextCellReuseIdentifier"
private let homeImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let homeTwoImageTextCellReuseIdentifier = "HomeTwoImageTextCellReuseIdentifier"
private let homeThreeImageTextCellReuseIdentifier = "HomeThreeImageTextCellReuseIdentifier"
private let homeFourImageTextCellReuseIdentifier = "HomeFourImageTextCellReuseIdentifier"

private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"

private let groupCellReuseIdentifier = "GroupCellReuseIdentifier"

private let browseJobCellReuseIdentifier = "BrowseJobCellReuseIdentifier"
private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"
private let secondaryNetworkFailureCellReuseIdentifier = "SecondaryNetworkFailureCellReuseIdentifier"

protocol SearchResultsUpdatingViewControllerDelegate: AnyObject {
    func didTapSearchDiscipline(_ discipline: Discipline)
    func didTapSearchTopic(_ searchTopic: SearchTopics)
    func dismissKeyboard()
}

class SearchResultsUpdatingViewController: UIViewController, UINavigationControllerDelegate {
    
    var toolbarHeightAnchor: NSLayoutConstraint!
    weak var searchResultsDelegate: SearchResultsUpdatingViewControllerDelegate?

    private var dataLoaded: Bool = false
    private var zoomTransitioning = ZoomTransitioning()
    private var selectedImage: UIImageView!
    
    private var searchMode: SearchMode = .discipline
    private var searchTopic: SearchTopics = .people

    private var networkIssue = false
    
    private var isFetchingMoreContent: Bool = false
    private var bottomSpinner: BottomSpinnerView!
    
    private var searches = [String]()
    private var users = [User]()
    
    private var currentNotification: Bool = false
    
    private lazy var topUsers = [User]()
    private var usersLastSnapshot: QueryDocumentSnapshot?
    
    private lazy var topPosts = [Post]()
    private var postsLastSnapshot: QueryDocumentSnapshot?
    private lazy var topPostUsers = [User]()
    
    private lazy var topCases = [Case]()
    private lazy var topCaseUsers = [User]()
    private var caseLastSnapshot: QueryDocumentSnapshot?
    
    private let activityIndicator = PrimaryLoadingView(frame: .zero)
    private let referenceMenu = ReferenceMenu()
    
    private var collectionView: UICollectionView!
    
    private let searchToolbar: SearchToolbar = {
        let toolbar = SearchToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        configureUI()
        configureNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
        if !dataLoaded { fetchRecentSearches() }
    }
    
    private func fetchRecentSearches() {
        let group = DispatchGroup()
        
        group.enter()
        DatabaseManager.shared.fetchRecentSearches { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let searches):
                strongSelf.searches = searches
            case .failure(let error):
                guard error != .empty else {
                    group.leave()
                    return
                }
                
                if error == .network {
                    strongSelf.networkIssue = true
                }
                
                group.leave()
            }
        }
        
        group.enter()
        DatabaseManager.shared.fetchRecentUserSearches { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let uids):
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.users = users
                    group.leave()
                }
            case .failure(let error):
                guard error != .empty else {
                    group.leave()
                    return
                }
                
                if error == .network {
                    strongSelf.networkIssue = true
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.toolbarHeightAnchor.constant = 50
            strongSelf.searchToolbar.layoutIfNeeded()
            strongSelf.dataLoaded = true
            strongSelf.collectionView.reloadData()
            
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env -> NSCollectionLayoutSection? in
            guard let strongSelf = self else { return nil }
            switch strongSelf.searchMode {
                
            case .discipline:
                if sectionNumber == 0 {
                    let recentsIsEmpty = strongSelf.users.isEmpty && strongSelf.searches.isEmpty
                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.networkIssue ? .estimated(200) : .fractionalHeight(1)))

                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: strongSelf.networkIssue ? .fractionalWidth(1) : recentsIsEmpty ? .fractionalWidth(1) : .absolute(100), heightDimension: strongSelf.networkIssue ? .estimated(200) : recentsIsEmpty ? .absolute(55) : .absolute(80)), subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                    section.interGroupSpacing = 0
                    
                    if strongSelf.networkIssue || recentsIsEmpty {
                        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
                    } else {
                        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                    }

                    if !recentsIsEmpty { section.boundarySupplementaryItems = [header] }
                    
                    return section
                } else {
                    
                    
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                    
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    
                    section.interGroupSpacing = 0
                    
                    return section
                }
            case .topic:
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                if sectionNumber == 0 {
                    
                    // People
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.networkIssue ? .estimated(200) : .fractionalHeight(1)))
                    
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.networkIssue ? .estimated(200) : strongSelf.topUsers.isEmpty && strongSelf.topPosts.isEmpty && strongSelf.topCases.isEmpty ? .fractionalHeight(0.9) : .absolute(65)), subitems: [item])
                                                                                                        
                    let section = NSCollectionLayoutSection(group: group)
                    
                    if !strongSelf.topUsers.isEmpty {
                        section.boundarySupplementaryItems = [header]
                        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0 , trailing: 10)
                    }
                    section.interGroupSpacing = 10
                    return section
                    
                } else {
                    // Posts & Cases
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(65)))
                    
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(65)), subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    
                    if sectionNumber == 1 {
                        if !strongSelf.topPosts.isEmpty {
                            section.boundarySupplementaryItems = [header]
                            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                        }
                    } else if sectionNumber == 2 {
                        if !strongSelf.topCases.isEmpty {
                            section.boundarySupplementaryItems = [header]
                            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                        }
                    }
                    
                    return section
                }
            case .choose:
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                var height = NSCollectionLayoutDimension.fractionalHeight(0.9)
                var insets = NSDirectionalEdgeInsets()
                var isEmpty = false
                
                if strongSelf.networkIssue {
                    height = .estimated(200)
                    insets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                } else {
                    switch strongSelf.searchTopic {
                    case .people:
                        height = strongSelf.topUsers.isEmpty ? .fractionalHeight(0.9) : .estimated(65)
                        isEmpty = strongSelf.topUsers.isEmpty
                        insets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                    case .posts:
                        height = strongSelf.topPosts.isEmpty ? .fractionalHeight(0.9) : .estimated(65)
                        isEmpty = strongSelf.topPosts.isEmpty
                        insets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                    case .cases:
                        height = strongSelf.topCases.isEmpty ? .fractionalHeight(0.9) : .estimated(65)
                        isEmpty = strongSelf.topCases.isEmpty
                        insets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                    }
                }
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: height))
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: height), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = insets
                
                if !isEmpty && !strongSelf.networkIssue {
                    section.boundarySupplementaryItems = [header]
                }
                
                return section
            }
        }
        return layout
    }
        
    private func configureUI() {
        bottomSpinner = BottomSpinnerView(style: .medium)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.keyboardDismissMode = .onDrag
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        view.addSubviews(activityIndicator, collectionView, searchToolbar, bottomSpinner)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbarHeightAnchor = searchToolbar.heightAnchor.constraint(equalToConstant: 0)
        toolbarHeightAnchor.isActive = true
        searchToolbar.searchDelegate = self
        
        NSLayoutConstraint.activate([
            searchToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
            
            collectionView.topAnchor.constraint(equalTo: searchToolbar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            bottomSpinner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomSpinner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSpinner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSpinner.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        activityIndicator.stop()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(EmptyRecentsSearchCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.register(SearchRecentsHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchRecentsHeaderReuseIdentifier)
        collectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: secondarySearchHeaderReuseIdentifier)
        collectionView.register(RecentUserCell.self, forCellWithReuseIdentifier: recentSearchesUserCellReuseIdentifier)
        collectionView.register(RecentSearchCell.self, forCellWithReuseIdentifier: recentContentSearchReuseIdentifier)

        collectionView.register(WhoToFollowCell.self, forCellWithReuseIdentifier: whoToFollowCellReuseIdentifier)
        collectionView.register(PrimarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: topHeaderReuseIdentifier)
        collectionView.register(TertiarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        
        collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        collectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        collectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        collectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        
        collectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier)
        collectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.register(SecondaryNetworkFailureCell.self, forCellWithReuseIdentifier: secondaryNetworkFailureCellReuseIdentifier)
    }
    
    private func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(followDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.followUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postVisibleChange(_:)), name: NSNotification.Name(AppPublishers.Names.postVisibility), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.postLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.postBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.postComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postEditChange(_:)), name: NSNotification.Name(AppPublishers.Names.postEdit), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseVisibleChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseVisibility), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseRevisionChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseRevision), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseSolveChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseSolve), object: nil)
    }
    
    func restartSearchMenu() {
        searchToolbar.didRestoreMenu()
    }
    
    func fetchContentFor(discipline: Discipline, searchTopic: SearchTopics) {
        
        networkIssue = false
        
        SearchService.fetchContentWithDisciplineAndTopic(discipline: discipline, searchTopic: searchTopic, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                switch searchTopic {
                    
                case .people:
                    strongSelf.usersLastSnapshot = snapshot.documents.last
                    var users = snapshot.documents.map { User(dictionary: $0.data() )}

                    let uids = users.map { $0.uid! }
                    let group = DispatchGroup()
                    
                    for (index, uid) in uids.enumerated() {
                        group.enter()
                        UserService.checkIfUserIsFollowed(withUid: uid) { [weak self] result in
                            guard let _ = self else { return }
                            switch result {
                                
                            case .success(let isFollowed):
                                users[index].set(isFollowed: isFollowed)
                            case .failure(_):
                                users[index].set(isFollowed: false)
                            }
                            
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.topUsers = users
                        strongSelf.activityIndicator.stop()
                        strongSelf.collectionView.reloadData()
                        strongSelf.collectionView.isHidden = false
                    }
                case .posts:
                    strongSelf.postsLastSnapshot = snapshot.documents.last
                    let posts = snapshot.documents.map { Post(postId: $0.documentID, dictionary: $0.data()) }
                    
                    PostService.getPostValuesFor(posts: posts) { [weak self] values in
                        strongSelf.topPosts = values
                        
                        let uids = Array(Set(values.map { $0.uid }))

                        UserService.fetchUsers(withUids: uids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.topPostUsers = users
                            strongSelf.activityIndicator.stop()
                            strongSelf.collectionView.reloadData()
                            strongSelf.collectionView.isHidden = false
                        }
                    }

                case .cases:
                    strongSelf.caseLastSnapshot = snapshot.documents.last
                    let cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data() )}
                    
                    CaseService.getCaseValuesFor(cases: cases) { [weak self] values in
                        strongSelf.topCases = values
                        
                        let uids = cases.filter { $0.privacy == .regular }.map { $0.uid }

                        guard uids.isEmpty else {
                            strongSelf.activityIndicator.stop()
                            strongSelf.collectionView.reloadData()
                            strongSelf.collectionView.isHidden = false
                            return
                        }
                        
                        UserService.fetchUsers(withUids: uids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.topCaseUsers = users
                            strongSelf.activityIndicator.stop()
                            strongSelf.collectionView.reloadData()
                            strongSelf.collectionView.isHidden = false
                        }
                    }
                }
            case .failure(let error):

                switch searchTopic {
                    
                case .people:
                    strongSelf.topUsers.removeAll()
                case .posts:
                    strongSelf.topPosts.removeAll()
                case .cases:
                    strongSelf.topCases.removeAll()
                }

                guard error != .notFound else {
                    strongSelf.activityIndicator.stop()
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.isHidden = false
                    return
                }
                
                if error == .network {
                    strongSelf.networkIssue = true
                }
                
                strongSelf.activityIndicator.stop()
                strongSelf.collectionView.reloadData()
                strongSelf.collectionView.isHidden = false
            }
        }
    }
    
    func fetchTopFor(discipline: Discipline) {
        networkIssue = false
        let group = DispatchGroup()
        
        group.enter()
        UserService.fetchTopUsersWithDiscipline(discipline) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let users):
                strongSelf.topUsers = users
            case .failure(let error):
                if error != .notFound {
                    if error == .network {
                        strongSelf.networkIssue = true
                    }
                } else {
                    strongSelf.topUsers.removeAll()
                }
            }
            
            group.leave()
        }
        
        group.enter()
        PostService.fetchTopPostsWithDiscipline(discipline) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let posts):
                
                let uids = Array(Set(posts.map { $0.uid }))
                
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.topPosts = posts
                    strongSelf.topPostUsers = users
                    group.leave()
                }
            case .failure(let error):
                if error != .notFound {
                    if error == .network {
                        strongSelf.networkIssue = true
                    }
                } else {
                    strongSelf.topPosts.removeAll()
                    strongSelf.topPostUsers.removeAll()
                }

                group.leave()
            }
        }
        
        group.enter()
        CaseService.fetchTopCasesWithDiscipline(discipline) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let cases):
                
                let visibleCases = cases.filter { $0.privacy == .regular }
                let uids = Array(Set(visibleCases.map { $0.uid }))
                
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.topCases = cases
                    strongSelf.topCaseUsers = users
                    group.leave()
                }
                
            case .failure(let error):
                if error != .notFound {
                    if error == .network {
                        strongSelf.networkIssue = true
                    }
                } else {
                    strongSelf.topCases.removeAll()
                    strongSelf.topCaseUsers.removeAll()
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.activityIndicator.stop()
            strongSelf.collectionView.reloadData()
            strongSelf.collectionView.isHidden = false
            strongSelf.searchToolbar.showToolbar()
        }
    }
    
    func didSelectTopicFromMenu(_ topic: SearchTopics) {
        searchToolbar.didSelectTopicFromMenu(topic)
    }
    
    func didSelectDisciplineFromMenu(_ discipline: Discipline) {
        searchToolbar.didSelectDisciplineFromMenu(discipline)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard searchMode == .choose else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            if let discipline = searchToolbar.getDiscipline() {
                fetchMoreContent(discipline: discipline)
            }
            
        }
    }
    
    private func fetchMoreContent(discipline: Discipline) {
        
        guard !isFetchingMoreContent else {
            return
        }
        
        var lastSnapshot: QueryDocumentSnapshot?
        
        switch searchTopic {
            
        case .people:
            guard !topUsers.isEmpty else {
                return
            }
            
            lastSnapshot = usersLastSnapshot
            
        case .posts:
            guard !topPosts.isEmpty else {
                return
            }
            
            lastSnapshot = postsLastSnapshot
        case .cases:
            guard !topCases.isEmpty else {
                return
            }
            
            lastSnapshot = caseLastSnapshot
        }
        
        showBottomSpinner()
        
        SearchService.fetchContentWithDisciplineAndTopic(discipline: discipline, searchTopic: searchTopic, lastSnapshot: lastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                switch strongSelf.searchTopic {
                    
                case .people:
                    strongSelf.usersLastSnapshot = snapshot.documents.last
                    var users = snapshot.documents.map { User(dictionary: $0.data() )}

                    let uids = users.map { $0.uid! }
                    let group = DispatchGroup()
                    
                    for (index, uid) in uids.enumerated() {
                        group.enter()
                        UserService.checkIfUserIsFollowed(withUid: uid) { [weak self] result in
                            guard let _ = self else { return }
                            switch result {
                                
                            case .success(let isFollowed):
                                users[index].set(isFollowed: isFollowed)
                            case .failure(_):
                                users[index].set(isFollowed: false)
                            }
                            
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.topUsers.append(contentsOf: users)
                        strongSelf.activityIndicator.stop()
                        strongSelf.collectionView.reloadData()
                        strongSelf.collectionView.isHidden = false
                        strongSelf.hideBottomSpinner()
                    }
                case .posts:
                    strongSelf.postsLastSnapshot = snapshot.documents.last
                    let posts = snapshot.documents.map { Post(postId: $0.documentID, dictionary: $0.data()) }
                    
                    PostService.getPostValuesFor(posts: posts) { [weak self] values in
                        strongSelf.topPosts.append(contentsOf: values)
                        
                        let uids = Array(Set(values.map { $0.uid }))
                        
                        let currentUids = strongSelf.topPostUsers.map { $0.uid }
                        
                        let uidsToFetch = uids.filter { !currentUids.contains($0) }
                        
                        guard !uidsToFetch.isEmpty else {
                            strongSelf.activityIndicator.stop()
                            strongSelf.collectionView.reloadData()
                            strongSelf.collectionView.isHidden = false
                            strongSelf.hideBottomSpinner()
                            return
                        }

                        UserService.fetchUsers(withUids: uids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.topPostUsers.append(contentsOf: users)
                            strongSelf.activityIndicator.stop()
                            strongSelf.collectionView.reloadData()
                            strongSelf.collectionView.isHidden = false
                            strongSelf.hideBottomSpinner()
                        }
                    }

                case .cases:
                    strongSelf.caseLastSnapshot = snapshot.documents.last
                    let cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data() )}
                    
                    CaseService.getCaseValuesFor(cases: cases) { [weak self] values in
                        strongSelf.topCases.append(contentsOf: values)
                        
                        let uids = cases.filter { $0.privacy == .regular }.map { $0.uid }
                        
                        let currentUids = strongSelf.topCaseUsers.map { $0.uid }
                        
                        let uidsToFetch = uids.filter { !currentUids.contains($0) }
                        
                        guard uids.isEmpty else {
                            strongSelf.activityIndicator.stop()
                            strongSelf.collectionView.reloadData()
                            strongSelf.collectionView.isHidden = false
                            strongSelf.hideBottomSpinner()
                            return
                        }
                        
                        UserService.fetchUsers(withUids: uids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.topCaseUsers.append(contentsOf: users)
                            strongSelf.activityIndicator.stop()
                            strongSelf.collectionView.reloadData()
                            strongSelf.collectionView.isHidden = false
                            strongSelf.hideBottomSpinner()
                        }
                    }
                }
            case .failure(let error):
                strongSelf.hideBottomSpinner()
            }
        }
    }
    
    private func showBottomSpinner() {
        isFetchingMoreContent = true
        let collectionViewContentHeight = collectionView.contentSize.height
        
        if collectionView.frame.height < collectionViewContentHeight {
            bottomSpinner.startAnimating()
            collectionView.contentInset.bottom = 50
        }
    }
    
    private func hideBottomSpinner() {
        isFetchingMoreContent = false
        bottomSpinner.stopAnimating()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.contentInset.bottom = 0
        }
    }
}

extension SearchResultsUpdatingViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searchBar.showsScopeBar = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchBar.showsScopeBar = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }
}

extension SearchResultsUpdatingViewController: SearchToolbarDelegate {
    func showMenuFor(discipline: Discipline) {
        searchResultsDelegate?.didTapSearchDiscipline(discipline)
        searchResultsDelegate?.dismissKeyboard()
    }
    
    func showMenuFor(searchTopic: SearchTopics) {
        self.searchTopic = searchTopic
        searchResultsDelegate?.didTapSearchTopic(searchTopic)
        searchResultsDelegate?.dismissKeyboard()
    }
    
    func didSelectDiscipline(_ discipline: Discipline) {
        searchResultsDelegate?.dismissKeyboard()
        searchMode = .topic
        collectionView.isHidden = true
        isFetchingMoreContent = false
        activityIndicator.start()
        fetchTopFor(discipline: discipline)
    }
    
    func didSelectSearchTopic(_ searchTopic: SearchTopics) {
        collectionView.isHidden = true
        searchMode = .choose
        activityIndicator.start()
        isFetchingMoreContent = false
        self.searchTopic = searchTopic
        if let discipline = searchToolbar.getDiscipline() {
            fetchContentFor(discipline: discipline, searchTopic: searchTopic)
        }
    }
    
    func didRestoreMenu() {
        searchMode = .discipline
        activityIndicator.stop()
        collectionView.reloadData()
        isFetchingMoreContent = false
        collectionView.isHidden = false
        
        if searches.isEmpty && users.isEmpty {
            fetchRecentSearches()
        }
    }
    
    private func deletePost(withId id: String, at indexPath: IndexPath) {

        displayAlert(withTitle: AppStrings.Alerts.Title.deletePost, withMessage: AppStrings.Alerts.Subtitle.deletePost, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let _ = self else { return }
            
            PostService.deletePost(withId: id) { [weak self] error in

                guard let strongSelf = self else { return }
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.postDidChangeVisible(postId: id)
                    strongSelf.topPosts.remove(at: indexPath.item)
                    if strongSelf.topPosts.isEmpty {
                        strongSelf.collectionView.reloadData()
                    } else {
                        strongSelf.collectionView.deleteItems(at: [indexPath])
                    }
                }
            }
        }
    }

    private func deleteCase(withId id: String, at indexPath: IndexPath, privacy: CasePrivacy) {

        displayAlert(withTitle: AppStrings.Alerts.Title.deleteCase, withMessage: AppStrings.Alerts.Subtitle.deleteCase, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let _ = self else { return }
            
            CaseService.deleteCase(withId: id, privacy: privacy) { [weak self] error in

                guard let strongSelf = self else { return }
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.caseDidChangeVisible(caseId: id)
                    strongSelf.topCases.remove(at: indexPath.item)
                    if strongSelf.topCases.isEmpty {
                        strongSelf.collectionView.reloadData()
                    } else {
                        strongSelf.collectionView.deleteItems(at: [indexPath])
                    }
                }
            }
        }
    }
}

extension SearchResultsUpdatingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch searchMode {
        case .discipline:
            return networkIssue ? 1 : searches.isEmpty && users.isEmpty ? 1 : 2
        case .topic:
            return topUsers.isEmpty && topPosts.isEmpty && topCases.isEmpty ? 1 : 3
        case .choose:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch searchMode {
            
        case .discipline:
            if networkIssue {
                return 1
            } else {
                if !dataLoaded {
                    return 0
                }
                
                if searches.isEmpty && users.isEmpty {
                    return 1
                } else {
                    return section == 0 ? users.count : searches.count
                }
            }

        case .topic:
            if networkIssue {
                return 1
            } else {
                if topUsers.isEmpty && topPosts.isEmpty && topCases.isEmpty {
                    return 1
                } else {
                    if section == 0 {
                        return topUsers.isEmpty ? 0 : topUsers.count
                    } else if section == 1 {
                        return topPosts.isEmpty ? 0 : topPosts.count
                    } else {
                        return topCases.isEmpty ? 0 : topCases.count
                    }
                }
            }
        case .choose:
            if networkIssue {
                return 1
            } else {
                switch searchTopic {
                case .people:
                    return topUsers.isEmpty ? 1 : topUsers.count
                case .posts:
                    return topPosts.isEmpty ? 1 : topPosts.count
                case .cases:
                    return topCases.isEmpty ? 1 : topCases.count
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch searchMode {
            
        case .discipline:
            if dataLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchRecentsHeaderReuseIdentifier, for: indexPath) as! SearchRecentsHeader
                header.delegate = self
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            }
        case .topic:
            if indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: secondarySearchHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
                header.delegate = self
                header.tag = indexPath.section
                header.configureWith(title: AppStrings.Search.Topics.people, linkText: AppStrings.Content.Search.seeAll)
                if topUsers.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
                header.separatorView.isHidden = true
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! TertiarySearchHeader
                header.tag = indexPath.section
                header.delegate = self
                if indexPath.section == 1 {
                    header.configureWith(title: AppStrings.Search.Topics.posts, linkText: AppStrings.Content.Search.seeAll)

                    if topPosts.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
                    if topUsers.isEmpty { header.separatorView.isHidden = true } else { header.separatorView.isHidden = false }
                } else {
                    header.configureWith(title: AppStrings.Search.Topics.cases, linkText: AppStrings.Content.Search.seeAll)
                    
                    if topUsers.isEmpty && topPosts.isEmpty { header.separatorView.isHidden = true } else { header.separatorView.isHidden = false }
                    if topCases.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
                }
                return header
            }
        case .choose:
            if searchTopic == .people {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: secondarySearchHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
                header.configureWith(title: searchTopic.title, linkText: "")
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: topHeaderReuseIdentifier, for: indexPath) as! PrimarySearchHeader
                header.configureWith(title: searchTopic.title, linkText: "")
                return header
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch searchMode {
            
        case .discipline:
            if networkIssue {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: secondaryNetworkFailureCellReuseIdentifier, for: indexPath) as! SecondaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if searches.isEmpty && users.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyRecentsSearchCell
                    cell.set(title: AppStrings.Search.Empty.title)
                    return cell
                } else {
                    if indexPath.section == 0 {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentSearchesUserCellReuseIdentifier, for: indexPath) as! RecentUserCell
                        cell.configureWithUser(user: users[indexPath.row])
                        return cell
                    } else {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentContentSearchReuseIdentifier, for: indexPath) as! RecentSearchCell
                        cell.viewModel = RecentTextViewModel(recentText: searches[indexPath.row])
                        return cell
                    }
                }
            }
            
        case .topic:
            if networkIssue {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if topUsers.isEmpty && topPosts.isEmpty && topCases.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Filters.emptyTitle, description: AppStrings.Content.Filters.emptyContent, content: .dismiss)
                    
                    cell.delegate = self
                    return cell
                }
                
                if indexPath.section == 0 {
                    // Top Users
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowCellReuseIdentifier, for: indexPath) as! WhoToFollowCell
                    cell.configureWithUser(user: topUsers[indexPath.row])
                    cell.followerDelegate = self
                    return cell
                    
                } else if indexPath.section == 1 {
                    // Top Posts
                    switch topPosts[indexPath.row].kind {
                    case .plainText:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].uid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                    case .textWithImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].uid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                    case .textWithTwoImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].uid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                    case .textWithThreeImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].uid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                    case .textWithFourImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].uid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                        
                    }
                } else {
                    // Top Cases
                    switch topCases[indexPath.row].kind {
                    case .text:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                        cell.viewModel = CaseViewModel(clinicalCase: topCases[indexPath.row])
                        
                        if topCases[indexPath.row].privacy == .anonymous {
                            cell.anonymize()
                        } else {
                            if let userIndex = topCaseUsers.firstIndex(where: { $0.uid == topCases[indexPath.row].uid }) {
                                cell.set(user: topCaseUsers[userIndex])
                            }
                        }
                        
                        if indexPath.row == topCases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                    case .image:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                        cell.viewModel = CaseViewModel(clinicalCase: topCases[indexPath.row])
                        
                        if topCases[indexPath.row].privacy == .anonymous {
                            cell.anonymize()
                        } else {
                            if let userIndex = topCaseUsers.firstIndex(where: { $0.uid == topCases[indexPath.row].uid }) {
                                cell.set(user: topCaseUsers[userIndex])
                            }
                        }
                        
                        if indexPath.row == topCases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                        
                    }
                }
            }
            
        case .choose:
            if networkIssue {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                switch searchTopic {
                case .people:
                    if topUsers.isEmpty {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                        cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Filters.emptyTitle, description: AppStrings.Content.Filters.emptyContent, content: .dismiss)
                        cell.delegate = self
                        return cell
                    } else {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowCellReuseIdentifier, for: indexPath) as! WhoToFollowCell
                        cell.configureWithUser(user: topUsers[indexPath.row])
                        cell.followerDelegate = self
                        return cell
                    }
                    
                case .posts:
                    if topPosts.isEmpty {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                        cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Filters.emptyTitle, description: AppStrings.Content.Filters.emptyContent, content: .dismiss)
                        cell.delegate = self
                        return cell
                    } else {
                        switch topPosts[indexPath.row].kind {
                        case .plainText:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTextCell
                            cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                            if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].uid }) {
                                cell.set(user: topPostUsers[userIndex])
                            }
                            //cell.set(user: postUsers[index])
                            cell.delegate = self
                            return cell
                        case .textWithImage:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                            cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                            if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].uid }) {
                                cell.set(user: topPostUsers[userIndex])
                            }
                            //cell.set(user: postUsers[index])
                            cell.delegate = self
                            return cell
                        case .textWithTwoImage:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                            cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                            if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].uid }) {
                                cell.set(user: topPostUsers[userIndex])
                            }
                            //cell.set(user: postUsers[index])
                            cell.delegate = self
                            return cell
                        case .textWithThreeImage:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                            cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                            if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].uid }) {
                                cell.set(user: topPostUsers[userIndex])
                            }
                            if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                            //cell.delegate = self
                            return cell
                        case .textWithFourImage:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                            cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                            if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].uid }) {
                                cell.set(user: topPostUsers[userIndex])
                            }
                            if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                            cell.delegate = self
                            return cell
                        }
                    }
                    
                case .cases:
                    if topCases.isEmpty {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                        cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Filters.emptyTitle, description: AppStrings.Content.Filters.emptyContent, content: .dismiss)
                        cell.delegate = self
                        return cell
                    } else {
                        switch topCases[indexPath.row].kind {
                        case .text:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                            cell.viewModel = CaseViewModel(clinicalCase: topCases[indexPath.row])
                            
                            if topCases[indexPath.row].privacy == .anonymous {
                                cell.anonymize()
                            } else {
                                if let userIndex = topCaseUsers.firstIndex(where: { $0.uid == topCases[indexPath.row].uid }) {
                                    cell.set(user: topCaseUsers[userIndex])
                                }
                            }
                            
                            if indexPath.row == topCases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                            cell.delegate = self
                            return cell
                        case .image:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                            cell.viewModel = CaseViewModel(clinicalCase: topCases[indexPath.row])
                            
                            if topCases[indexPath.row].privacy == .anonymous {
                                cell.anonymize()
                            } else {
                                if let userIndex = topCaseUsers.firstIndex(where: { $0.uid == topCases[indexPath.row].uid }) {
                                    cell.set(user: topCaseUsers[userIndex])
                                }
                            }
                            
                            if indexPath.row == topCases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                            cell.delegate = self
                            return cell
                        }
                    }
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch searchMode {
            
        case .discipline:
            if indexPath.section == 0 {
                guard !users.isEmpty else { return }
                let controller = UserProfileViewController(user: users[indexPath.row])
                
                if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                    navVC.pushViewController(controller, animated: true)
                }
            }
        case .topic, .choose:
            switch searchTopic {
                
            case .people:
                guard !topUsers.isEmpty else { return }
                let controller = UserProfileViewController(user: topUsers[indexPath.row])
                
                if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                    navVC.pushViewController(controller, animated: true)
                    DatabaseManager.shared.addRecentUserSearches(withUid: topUsers[indexPath.row].uid!)
                }
            case .posts, .cases:
                break
            }
        }
    }
}

extension SearchResultsUpdatingViewController: PrimarySearchHeaderDelegate {
    func didTapSeeAll(_ header: UICollectionReusableView) {

        switch searchMode {
            
        case .discipline, .choose:
            break
        case .topic:
            if header.tag == 0 {
                // People
                if let searchViewController = presentingViewController as? SearchViewController,  let navVC = searchViewController.navigationController, let user = searchViewController.getCurrentUser() {
                    let controller = WhoToFollowViewController(user: user)
                    controller.title = AppStrings.Content.Search.whoToFollow
                    navVC.pushViewController(controller, animated: true)
                }
                
            } else if header.tag == 1 {
                // Posts
                if let searchViewController = presentingViewController as? SearchViewController,  let navVC = searchViewController.navigationController, let discipline = searchToolbar.getDiscipline() {
                    let controller = HomeViewController(source: .search)
                    controller.controllerIsBeeingPushed = true
                    controller.discipline = discipline
                    controller.title = discipline.name
                    navVC.pushViewController(controller, animated: true)
                }
            } else {
                // Cases
                if let searchViewController = presentingViewController as? SearchViewController,  let navVC = searchViewController.navigationController, let user = searchViewController.getCurrentUser(), let discipline = searchToolbar.getDiscipline() {
                    let controller = CaseViewController(user: user, contentSource: .search)
                    controller.title = discipline.name
                    navVC.pushViewController(controller, animated: true)
                }
            }
        }
    }
}

extension SearchResultsUpdatingViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        searchToolbar.didRestoreMenu()
    }
}

extension SearchResultsUpdatingViewController: UsersFollowCellDelegate {
    func didFollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! WhoToFollowCell
        
        UserService.follow(uid: user.uid!) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                currentCell.userIsFollowing = true
                
                strongSelf.userDidChangeFollow(uid: user.uid!, didFollow: true)
                
                if let indexPath = strongSelf.collectionView.indexPath(for: cell) {
                    strongSelf.topUsers[indexPath.row].set(isFollowed: true)
                }
            }
        }
    }
    
    func didUnfollowOnFollower(_ cell: UICollectionViewCell, user: User) {
        let currentCell = cell as! WhoToFollowCell
        UserService.unfollow(uid: user.uid!) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                currentCell.userIsFollowing = false
                
                strongSelf.userDidChangeFollow(uid: user.uid!, didFollow: false)
                
                if let indexPath = strongSelf.collectionView.indexPath(for: cell) {
                    strongSelf.topUsers[indexPath.row].set(isFollowed: false)
                }
            }
        }
    }
}

extension SearchResultsUpdatingViewController: HomeCellDelegate {
    
    func cell(wantsToSeeHashtag hashtag: String) {
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            let controller = HashtagViewController(hashtag: hashtag)
            navVC.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.navigationController?.delegate = self
        
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)
            navVC.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            navVC.pushViewController(controller, animated: true)
        }
    }
    
    func cell(didTapMenuOptionsFor post: Post, option: PostMenu) {
        switch option {
        case .delete:
            var section = 0
            
            switch searchMode {
            case .discipline:
                return
            case .topic:
                section = 1
            case .choose:
                section = 0
            }
            
            if let index = topPosts.firstIndex(where: { $0.postId == post.postId }) {
                deletePost(withId: post.postId, at: IndexPath(item: index, section: section))
            }
            
        case .edit:
            let controller = EditPostViewController(post: post)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        case .report:
            guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            let controller = ReportViewController(source: .post, contentUid: uid, contentId: post.postId)
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
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let post = topPosts[indexPath.row]
        if let index = topPostUsers.firstIndex(where: { $0.uid! == post.uid }) {
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                let controller = DetailsPostViewController(post: post, user: topPostUsers[index], collectionViewLayout: layout)
                navVC.pushViewController(controller, animated: true)
            }
        }
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
        let controller = LikesViewController(post: post)
        
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            navVC.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.navigationController?.delegate = self
        
        let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)
     
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            navVC.pushViewController(controller, animated: true)
        }
    }
}

extension SearchResultsUpdatingViewController: CaseCellDelegate {
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)

        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            navVC.pushViewController(controller, animated: true)
        }
    }
    
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        let controller = LikesViewController(clinicalCase: clinicalCase)
        
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            navVC.pushViewController(controller, animated: true)
        }
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)
        
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            navVC.pushViewController(controller, animated: true)
        }
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
        switch option {
        case .delete:
            
            var section = 0
            
            switch searchMode {
            case .discipline:
                return
            case .topic:
                section = 2
            case .choose:
                section = 0
            }
            
            if let index = topCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                deleteCase(withId: clinicalCase.caseId, at: IndexPath(item: index, section: section), privacy: clinicalCase.privacy)
            }
            
        case .revision:
            if let searchViewController = presentingViewController as? SearchViewController {
                if let user = searchViewController.getCurrentUser() {
                    let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
        case .solve:
            let controller = CaseDiagnosisViewController(clinicalCase: clinicalCase)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        case .report:
            let controller = ReportViewController(source: .clinicalCase, contentUid: clinicalCase.uid, contentId: clinicalCase.caseId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            navVC.pushViewController(controller, animated: true)
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        if let userIndex = topCaseUsers.firstIndex(where: { $0.uid == clinicalCase.uid }) {
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: topCaseUsers[userIndex])
            
            if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                navVC.pushViewController(controller, animated: true)
            }
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let clinicalCase = topCases[indexPath.row]
        
        self.navigationController?.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        switch clinicalCase.privacy {
            
        case .regular:
            if let index = topCaseUsers.firstIndex(where: { $0.uid! == clinicalCase.uid }) {
                let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: topCaseUsers[index], collectionViewFlowLayout: layout)
                if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                    navVC.pushViewController(controller, animated: true)
                }
            }
        case .anonymous:
            let controller = DetailsCaseViewController(clinicalCase: clinicalCase, collectionViewFlowLayout: layout)
            if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                navVC.pushViewController(controller, animated: true)
            }
        }
    }
}

extension SearchResultsUpdatingViewController: ReferenceMenuDelegate {
    func didTapReference(reference: Reference) {
        switch reference.option {
        case .link:
            if let url = URL(string: reference.referenceText) {
                if UIApplication.shared.canOpenURL(url) {
                    let webViewController = WebViewController(url: url)
                    let navVC = UINavigationController(rootViewController: webViewController)
                    present(navVC, animated: true, completion: nil)
                }
            }
        case .citation:
            let wordToSearch = reference.referenceText
            if let encodedQuery = wordToSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
                    let webViewController = WebViewController(url: url)
                    let navVC = UINavigationController(rootViewController: webViewController)
                    present(navVC, animated: true, completion: nil)
                }
            }
        }
    }
}

extension SearchResultsUpdatingViewController: SearchRecentsHeaderDelegate {
    func didTapClearSearches() {

        displayAlert(withTitle: AppStrings.Alerts.Title.clearRecents, withMessage: AppStrings.Alerts.Subtitle.clearRecents, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Miscellaneous.clear, style: .destructive) { [weak self] in
            guard let _ = self else { return }
            DatabaseManager.shared.deleteRecentSearches { [weak self] error in
                guard let strongSelf = self else { return }
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.users.removeAll()
                    strongSelf.searches.removeAll()
                    strongSelf.collectionView.reloadData()
                }
            }
        }
    }
}

//MARK: Post Miscellaneous

extension SearchResultsUpdatingViewController {
    
    private func handleLikeUnLike(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        
        let postId = post.postId
        let didLike = topPosts[indexPath.row].didLike
        postDidChangeLike(postId: postId, didLike: didLike)

        // Toggle the like state and count
        cell.viewModel?.post.didLike.toggle()
        self.topPosts[indexPath.row].didLike.toggle()
        
        cell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        self.topPosts[indexPath.row].likes = post.didLike ? post.likes - 1 : post.likes + 1
    }
    
    func handleBookmarkUnbookmark(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        let postId = post.postId
        let didBookmark = topPosts[indexPath.row].didBookmark
        postDidChangeBookmark(postId: postId, didBookmark: didBookmark)
        
        // Toggle the bookmark state
        cell.viewModel?.post.didBookmark.toggle()
        self.topPosts[indexPath.row].didBookmark.toggle()
        
    }
}

//MARK: - Case Miscellaneous

extension SearchResultsUpdatingViewController {
    
    private func handleLikeUnlike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didLike = self.topCases[indexPath.row].didLike
        caseDidChangeLike(caseId: caseId, didLike: didLike)
        
        // Toggle the like state and count
        cell.viewModel?.clinicalCase.didLike.toggle()
        self.topCases[indexPath.row].didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        self.topCases[indexPath.row].likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        
    }
    
    func handleBookmarkUnbookmark(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didBookmark = self.topCases[indexPath.row].didBookmark
        caseDidChangeBookmark(caseId: caseId, didBookmark: didBookmark)
        
        // Toggle the bookmark state
        cell.viewModel?.clinicalCase.didBookmark.toggle()
        self.topCases[indexPath.row].didBookmark.toggle()
        
    }
}

extension SearchResultsUpdatingViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        networkIssue = false
        
        switch searchMode {
            
        case .discipline:
            dataLoaded = false
            collectionView.reloadData()
            fetchRecentSearches()
        case .topic:
            if let discipline = searchToolbar.getDiscipline() {
                activityIndicator.start()
                dataLoaded = false
                collectionView.isHidden = true
                fetchTopFor(discipline: discipline)
            }
            
        case .choose:
            if let discipline = searchToolbar.getDiscipline() {
                activityIndicator.start()
                dataLoaded = false
                collectionView.isHidden = true
                fetchContentFor(discipline: discipline, searchTopic: searchTopic)
            }
        }
    }
}


extension SearchResultsUpdatingViewController: PostChangesDelegate {
    func postDidChangeComment(postId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }
    
    func postDidChangeVisible(postId: String) {
        currentNotification = true
        ContentManager.shared.visiblePostChange(postId: postId)
    }
    
    @objc func postVisibleChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }

        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? PostVisibleChange {
            if let index = topPosts.firstIndex(where: { $0.postId == change.postId }) {
                topPosts.remove(at: index)
                if topPosts.isEmpty {
                    collectionView.reloadData()
                } else {
                    collectionView.deleteItems(at: [IndexPath(item: index, section: section)])
                }
            }
        }
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
        
        
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? PostLikeChange {
            if let index = topPosts.firstIndex(where: { $0.postId == change.postId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? HomeCellProtocol {
                    
                    let likes = self.topPosts[index].likes
                    
                    self.topPosts[index].likes = change.didLike ? likes + 1 : likes - 1
                    self.topPosts[index].didLike = change.didLike
                    
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
        
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        
        
        if let change = notification.object as? PostBookmarkChange {
            if let index = topPosts.firstIndex(where: { $0.postId == change.postId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? HomeCellProtocol {
    
                    self.topPosts[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.post.didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? PostCommentChange {
            if let index = topPosts.firstIndex(where: { $0.postId == change.postId }), change.path.isEmpty {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? HomeCellProtocol {
                    
                    let comments = self.topPosts[index].numberOfComments

                    switch change.action {
                    case .add:
                        self.topPosts[index].numberOfComments = comments + 1
                        currentCell.viewModel?.post.numberOfComments = comments + 1
                    case .remove:
                        self.topPosts[index].numberOfComments = comments - 1
                        currentCell.viewModel?.post.numberOfComments = comments - 1
                    }
                }
            }
        }
    }
    
    @objc func postEditChange(_ notification: NSNotification) {
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        if let change = notification.object as? PostEditChange {
            let post = change.post
            
            if let index = topPosts.firstIndex(where: { $0.postId == post.postId }) {
                topPosts[index] = post
                collectionView.reloadItems(at: [IndexPath(item: index, section: section)])
            }
        }
    }
}

extension SearchResultsUpdatingViewController: CaseChangesDelegate {
   
    func caseDidChangeVisible(caseId: String) {
        currentNotification = true
        ContentManager.shared.visibleCaseChange(caseId: caseId)
    }
    
    @objc func caseVisibleChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }

        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? CaseVisibleChange {
            if let index = topCases.firstIndex(where: { $0.caseId == change.caseId }) {
                topCases.remove(at: index)
                if topCases.isEmpty {
                    collectionView.reloadData()
                } else {
                    collectionView.deleteItems(at: [IndexPath(item: index, section: section)])
                }
            }
        }
    }
    
    func caseDidChangeLike(caseId: String, didLike: Bool) {
        currentNotification = true
        ContentManager.shared.likeCaseChange(caseId: caseId, didLike: !didLike)
    }
    
    func caseDidChangeBookmark(caseId: String, didBookmark: Bool) {
        currentNotification = true
        ContentManager.shared.bookmarkCaseChange(caseId: caseId, didBookmark: !didBookmark)
    }

    func caseDidChangeComment(caseId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }
    
    @objc func caseLikeChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? CaseLikeChange {
            if let index = topCases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? CaseCellProtocol {
                    
                    let likes = self.topCases[index].likes
                    
                    self.topCases[index].likes = change.didLike ? likes + 1 : likes - 1
                    self.topCases[index].didLike = change.didLike
                    
                    currentCell.viewModel?.clinicalCase.didLike = change.didLike
                    currentCell.viewModel?.clinicalCase.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? CaseBookmarkChange {
            if let index = topCases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? CaseCellProtocol {
                    
                    self.topCases[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.clinicalCase.didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            
            var section = 0
            
            switch searchMode {
                
            case .discipline:
                break
            case .topic:
                section = 2
            case .choose:
                section = 0
            }
            
            if let index = topCases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.revision = .update
                    topCases[index].revision = .update
                    collectionView.reloadData()
                }
            }
        }
    }
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? CaseCommentChange {
            if let index = topCases.firstIndex(where: { $0.caseId == change.caseId }), change.path.isEmpty {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? CaseCellProtocol {
                    
                    let comments = self.topCases[index].numberOfComments
                    
                    switch change.action {
                    case .add:
                        self.topCases[index].numberOfComments = comments + 1
                        currentCell.viewModel?.clinicalCase.numberOfComments = comments + 1
                    case .remove:
                        self.topCases[index].numberOfComments = comments - 1
                        currentCell.viewModel?.clinicalCase.numberOfComments = comments - 1
                    }
                }
            }
        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? CaseSolveChange {
            if let index = topCases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)) as? CaseCellProtocol  {
                    
                    cell.viewModel?.clinicalCase.phase = .solved
                    topCases[index].phase = .solved
                    
                    if let diagnosis = change.diagnosis {
                        topCases[index].revision = diagnosis
                        cell.viewModel?.clinicalCase.revision = diagnosis
                    }
                    
                    collectionView.reloadData()
                }
            }
        }
    }
}

extension SearchResultsUpdatingViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {

        if let user = notification.userInfo!["user"] as? User {
            
            if let postIndex = topPostUsers.firstIndex(where: { $0.uid! == user.uid! }) {
                topPostUsers[postIndex] = user
                collectionView.reloadData()
            }
            
            if let caseIndex = topCaseUsers.firstIndex(where: { $0.uid! == user.uid!}) {
                topCaseUsers[caseIndex] = user
                collectionView.reloadData()
            }
            
            if let caseIndex = users.firstIndex(where: { $0.uid! == user.uid!}) {
                users[caseIndex] = user
                collectionView.reloadData()
            }
        }
    }
}

extension SearchResultsUpdatingViewController: UserFollowDelegate {
    
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
            if let index = topUsers.firstIndex(where: { $0.uid! == change.uid }) {
                topUsers[index].set(isFollowed: change.isFollowed)
                collectionView.reloadData()
            }
        }
    }
}




















