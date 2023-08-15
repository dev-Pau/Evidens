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
    
    private var searches = [String]()
    private var users = [User]()
    
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
    
    private var likeDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var likeValues: [IndexPath: Bool] = [:]
    private var likeCount: [IndexPath: Int] = [:]
    
    private var bookmarkDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var bookmarkValues: [IndexPath: Bool] = [:]

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
                
                var height = NSCollectionLayoutDimension.fractionalHeight(0)
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
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.keyboardDismissMode = .onDrag
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        view.addSubviews(activityIndicator, collectionView, searchToolbar)
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
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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

                        let uids = Array(Set(values.map { $0.uid }))
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
                
                group.leave()
            }
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
        activityIndicator.start()
        fetchTopFor(discipline: discipline)
    }
    
    func didSelectSearchTopic(_ searchTopic: SearchTopics) {
        collectionView.isHidden = true
        searchMode = .choose
        activityIndicator.start()
        self.searchTopic = searchTopic
        if let discipline = searchToolbar.getDiscipline() {
            fetchContentFor(discipline: discipline, searchTopic: searchTopic)
        }
    }
    
    func didRestoreMenu() {
        searchMode = .discipline
        activityIndicator.stop()
        collectionView.reloadData()
        collectionView.isHidden = false
        
        if searches.isEmpty && users.isEmpty {
            fetchRecentSearches()
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
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            }
        case .topic:
            if indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: secondarySearchHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
                header.configureWith(title: AppStrings.Search.Topics.people, linkText: AppStrings.Content.Search.seeAll)
                if topUsers.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
                header.separatorView.isHidden = true
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! TertiarySearchHeader
                
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
            return
        case .topic, .choose:
            switch searchTopic {
                
            case .people:
                guard !topUsers.isEmpty else { return }
                let controller = UserProfileViewController(user: topUsers[indexPath.row])
                
                if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                    navVC.pushViewController(controller, animated: true)
                    guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
                    DatabaseManager.shared.uploadRecentUserSearches(withUid: uid) { _ in }
                }
            case .posts, .cases:
                break
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

extension SearchResultsUpdatingViewController: HomeCellDelegate {
    
    func cell(wantsToSeeHashtag hashtag: String) {
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            let controller = HashtagViewController(hashtag: hashtag)
            controller.postDelegate = self
            navVC.pushViewController(controller, animated: true)
            guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            DatabaseManager.shared.uploadRecentUserSearches(withUid: uid) { _ in }
        }
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
        
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            navVC.pushViewController(controller, animated: true)
            DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didTapMenuOptionsFor post: Post, option: PostMenu) {
        switch option {
        case .delete:
            #warning("Need to Implement Delete")
        case .edit:
            let controller = EditPostViewController(post: post)
            controller.delegate = self
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
        
        HapticsManager.shared.vibrate(for: .success)
        
        handleBookmarkUnbookmark(for: currentCell, at: indexPath)
    }
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) { return }
    
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
        controller.delegate = self
        
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            navVC.pushViewController(controller, animated: true)
        }
    }
}

extension SearchResultsUpdatingViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
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
        controller.delegate = self
        
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            navVC.pushViewController(controller, animated: true)
        }
    }
    
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        controller.caseDelegate = self
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
        switch option {
        case .delete:
            #warning("Implement Delete")
        case .revision:
            if let searchViewController = presentingViewController as? SearchViewController {
                if let user = searchViewController.getCurrentUser() {
                    let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)
                    controller.delegate = self
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
        case .solve:
            let controller = CaseDiagnosisViewController(clinicalCase: clinicalCase)
            controller.delegate = self
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
            DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
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
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) { return }
    
}

extension SearchResultsUpdatingViewController: DetailsPostViewControllerDelegate {

    func didTapLikeAction(forPost post: Post) {
        
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        
        if let index = topPosts.firstIndex(where: { $0.postId == post.postId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? HomeCellProtocol {
                self.topPosts[index].didLike = post.didLike
                self.topPosts[index].likes = post.likes
                
                currentCell.viewModel?.post.didLike = post.didLike
                currentCell.viewModel?.post.likes = post.likes
            }
        }
    }
    
    func didTapBookmarkAction(forPost post: Post) {
        
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        
        if let index = topPosts.firstIndex(where: { $0.postId == post.postId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? HomeCellProtocol {
                self.topPosts[index].didBookmark = post.didBookmark

                currentCell.viewModel?.post.didBookmark = post.didBookmark
            }
        }
    }
    
    func didComment(forPost post: Post) {
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        
        if let index = topPosts.firstIndex(where: { $0.postId == post.postId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? HomeCellProtocol {
                topPosts[index].numberOfComments += 1
                currentCell.viewModel?.post.numberOfComments += 1
            }
        }
    }
    
    func didDeleteComment(forPost post: Post) {
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        
        if let index = topPosts.firstIndex(where: { $0.postId == post.postId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? HomeCellProtocol {
                topPosts[index].numberOfComments -= 1
                currentCell.viewModel?.post.numberOfComments -= 1
            }
        }
    }
    
    func didEditPost(forPost post: Post) {
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        
        if let postIndex = topPosts.firstIndex(where: { $0.postId == post.postId }) {
            topPosts[postIndex] = post
            collectionView.reloadItems(at: [IndexPath(item: postIndex, section: section)])
        }
    }
}

extension SearchResultsUpdatingViewController: DetailsCaseViewControllerDelegate {
    
    
    func didSolveCase(forCase clinicalCase: Case, with diagnosis: CaseRevisionKind?) {
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let index = topCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            topCases[index].phase = .solved
            if let diagnosis {
                topCases[index].revision = diagnosis
            }

            collectionView.reloadItems(at: [IndexPath(item: index, section: section)])
        }
    }
    
    func didAddRevision(forCase clinicalCase: Case) {
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let caseIndex = topCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            topCases[caseIndex].revision = clinicalCase.revision
            collectionView.reloadItems(at: [IndexPath(item: caseIndex, section: section)])
        }
    }
    
    func didTapLikeAction(forCase clinicalCase: Case) {
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let index = topCases.firstIndex(where: {$0.caseId == clinicalCase.caseId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? CaseCellProtocol {
                self.topCases[index].didLike = clinicalCase.didLike
                self.topCases[index].likes = clinicalCase.likes
                
                currentCell.viewModel?.clinicalCase.didLike = clinicalCase.didLike
                currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes
            }
        }
        
    }
    
    func didTapBookmarkAction(forCase clinicalCase: Case) {
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let index = topCases.firstIndex(where: {$0.caseId == clinicalCase.caseId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? CaseCellProtocol {
                
                self.topCases[index].didBookmark = clinicalCase.didBookmark
                currentCell.viewModel?.clinicalCase.didBookmark = clinicalCase.didBookmark
            }
        }
    }
    
    func didComment(forCase clinicalCase: Case) {
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let index = topCases.firstIndex(where: {$0.caseId == clinicalCase.caseId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? CaseCellProtocol {
                currentCell.viewModel?.clinicalCase.numberOfComments += 1
                topCases[index].numberOfComments += 1
                collectionView.reloadItems(at: [IndexPath(item: index, section: section)])
            }
        }
    }
    
    func didDeleteComment(forCase clinicalCase: Case) {
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let index = topCases.firstIndex(where: {$0.caseId == clinicalCase.caseId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? CaseCellProtocol {
                currentCell.viewModel?.clinicalCase.numberOfComments -= 1
                topCases[index].numberOfComments -= 1
                collectionView.reloadItems(at: [IndexPath(item: index, section: section)])
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
        #warning("implement kekl")
    }
}

extension SearchResultsUpdatingViewController: EditPostViewControllerDelegate {
    func didEditPost(post: Post) {
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        if let postIndex = topPosts.firstIndex(where: { $0.postId == post.postId }) {
            topPosts[postIndex] = post
            collectionView.reloadItems(at: [IndexPath(item: postIndex, section: section)])
        }
    }
}

extension SearchResultsUpdatingViewController: CaseDiagnosisViewControllerDelegate {
    func handleSolveCase(diagnosis: CaseRevision?, clinicalCase: Case?) {
        guard let clinicalCase = clinicalCase else { return }
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let index = topCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            topCases[index].phase = .solved
            if let diagnosis {
                topCases[index].revision = diagnosis.kind
            }

            collectionView.reloadItems(at: [IndexPath(item: index, section: section)])
        }
    }
}

extension SearchResultsUpdatingViewController: CaseUpdatesViewControllerDelegate {
    func didAddRevision(to clinicalCase: Case, _ revision: CaseRevision) {
        var section = 0
        
        switch searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let index = topCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            topCases[index].revision = clinicalCase.revision
            collectionView.reloadItems(at: [IndexPath(item: index, section: section)])
        }
    }
}

//MARK: Post Miscellaneous

extension SearchResultsUpdatingViewController {
    
    private func handleLikeUnLike(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        // Toggle the like state and count
        cell.viewModel?.post.didLike.toggle()
        self.topPosts[indexPath.row].didLike.toggle()
        
        cell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        self.topPosts[indexPath.row].likes = post.didLike ? post.likes - 1 : post.likes + 1
        
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
                        strongSelf.topPosts[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.post.likes = countValue
                        strongSelf.topPosts[indexPath.row].likes = countValue
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
                        strongSelf.topPosts[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.post.likes = countValue
                        strongSelf.topPosts[indexPath.row].likes = countValue
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
        self.topPosts[indexPath.row].didBookmark.toggle()
        
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
                        strongSelf.topPosts[indexPath.row].didBookmark = bookmarkValue
                    }
                    
                    strongSelf.bookmarkValues[indexPath] = nil
                }
            } else {
                PostService.bookmark(post: post) { [weak self] error in
                    guard let strongSelf = self else { return }

                    if let _ = error {
                        cell.viewModel?.post.didBookmark = bookmarkValue
                        strongSelf.topPosts[indexPath.row].didBookmark = bookmarkValue
    
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

extension SearchResultsUpdatingViewController {
    
    private func handleLikeUnlike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        // Toggle the like state and count
        cell.viewModel?.clinicalCase.didLike.toggle()
        self.topCases[indexPath.row].didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        self.topCases[indexPath.row].likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        
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
                        strongSelf.topCases[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.clinicalCase.likes = countValue
                        strongSelf.topCases[indexPath.row].likes = countValue
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
                        strongSelf.topCases[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.clinicalCase.likes = countValue
                        strongSelf.topCases[indexPath.row].likes = countValue
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
        self.topCases[indexPath.row].didBookmark.toggle()
        
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
                        strongSelf.topCases[indexPath.row].didBookmark = bookmarkValue
                    }
                    
                    strongSelf.bookmarkValues[indexPath] = nil
                }
            } else {
                CaseService.bookmarkCase(clinicalCase: clinicalCase) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        cell.viewModel?.clinicalCase.didBookmark = bookmarkValue
                        strongSelf.topCases[indexPath.row].didBookmark = bookmarkValue
                        
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
