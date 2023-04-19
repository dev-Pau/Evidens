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

protocol SearchResultsUpdatingViewControllerDelegate: AnyObject {
    func didTapDisciplinesMenu(withOption option: String)
    func didTapShowCategoriesMenu(withCategory category: String)
}

class SearchResultsUpdatingViewController: UIViewController, UINavigationControllerDelegate {
    
    var toolbarHeightAnchor: NSLayoutConstraint!
    weak var searchResultsDelegate: SearchResultsUpdatingViewControllerDelegate?
    private var user: User
    
    private var dataLoaded: Bool = false
    // Used to track when a discipline is selected to fetch top content of each category
    private var isInSearchTopicMode: Bool = false
    // Used to track when a category discipline is selected in ordre to display the content selected
    private var isInSearchCategoryMode: Bool = false
    private var zoomTransitioning = ZoomTransitioning()
    private var selectedImage: UIImageView!

    private var topicSearched: String?
    private var categorySearched: Search.Topics = .people
    private var resultItemsCount: Int = 0

    private var recentSearches = [String]()
    private var recentUserSearches = [String]()
    private var users = [User]()
    
    private lazy var topUsers = [User]()
    private var usersLastSnapshot: QueryDocumentSnapshot?
    
    private lazy var topPosts = [Post]()
    private var postsLastSnapshot: QueryDocumentSnapshot?
    private lazy var topPostUsers = [User]()
    
    private lazy var topCases = [Case]()
    private lazy var topCaseUsers = [User]()
    private var caseLastSnapshot: QueryDocumentSnapshot?
    
    private lazy var topGroups = [Group]()
    private var groupsLastSnapshot: QueryDocumentSnapshot?
    
    private lazy var topJobs = [Job]()
    private var jobsLastSnapshot: QueryDocumentSnapshot?
    private lazy var topCompanies = [Company]()
    
    private let activityIndicator = MEProgressHUD(frame: .zero)
    
    private var searchedText: String = ""

    private var collectionView: UICollectionView!
    
    private let categoriesToolbar: MESearchToolbar = {
        let toolbar = MESearchToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        configureUI()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
        if !dataLoaded { fetchRecentSearches() }
    }
    
    private func fetchRecentSearches() {
        DatabaseManager.shared.fetchRecentSearches { recents in
            switch recents {
            case .success(let recentSearches):
                self.recentSearches = recentSearches
                DatabaseManager.shared.fetchRecentUserSearches { userRecents in
                    switch userRecents {
                    case .success(let recentUserSearches):
                        self.recentUserSearches = recentUserSearches
                    
                        if recentSearches.isEmpty && recentUserSearches.isEmpty {
                            // No recent searches
                            self.toolbarHeightAnchor.constant = 50
                            self.categoriesToolbar.layoutIfNeeded()
                            self.dataLoaded = true
                            self.collectionView.reloadData()
                        } else {
                            UserService.fetchUsers(withUids: recentUserSearches) { users in
                                self.users = users
                                self.toolbarHeightAnchor.constant = 50
                                self.categoriesToolbar.layoutIfNeeded()
                                self.dataLoaded = true
                                self.collectionView.reloadData()
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection? in
            if self.isInSearchCategoryMode {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: self.resultItemsCount == 0 ? .fractionalHeight(1) : .estimated(65)))
                
                //item.contentInsets.leading = 10
                //item.contentInsets.trailing = 10
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: self.resultItemsCount == 0 ? .fractionalHeight(0.9) : .estimated(65)), subitems: [item])
                
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: self.categorySearched == .people ? 10 : 0, bottom: 20, trailing: self.categorySearched == .people ? 10 : 0)
                
                if self.resultItemsCount != 0 {
                    section.boundarySupplementaryItems = [header]
                }
                
                return section
            } else if self.isInSearchTopicMode {
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)

                if sectionNumber == 0 {
                    
                    // People
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                    
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension:
                                                                                                        self.topUsers.isEmpty && self.topPosts.isEmpty && self.topCases.isEmpty && self.topGroups.isEmpty && self.topJobs.isEmpty ? .fractionalHeight(0.9) : .absolute(65)), subitems: [item])
                    
                    
                    let section = NSCollectionLayoutSection(group: group)
                    //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20 , trailing: 0)
                    
                    if !self.topUsers.isEmpty {
                        section.boundarySupplementaryItems = [header]
                        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0 , trailing: 10)
                    }
                    section.interGroupSpacing = 10
                    return section
                    
                } else {
                    // Posts, Cases, Groups & Jobs
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(65)))
                    
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(65)), subitems: [item])

                    let section = NSCollectionLayoutSection(group: group)
                    //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                    
                    if sectionNumber == 1 {
                        if !self.topPosts.isEmpty {
                            section.boundarySupplementaryItems = [header]
                            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                        }
                    } else if sectionNumber == 2 {
                        if !self.topCases.isEmpty {
                            section.boundarySupplementaryItems = [header]
                            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                        }
                    } else if sectionNumber == 3 {
                        if !self.topGroups.isEmpty {
                            section.boundarySupplementaryItems = [header]
                            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                        }
                    } else {
                        if !self.topJobs.isEmpty {
                            section.boundarySupplementaryItems = [header]
                            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                        }
                    }
                    //section.interGroupSpacing = 10
                    return section
                }
            } else {
                // Recents
                if sectionNumber == 0 {
                    let recentsIsEmpty = self.recentUserSearches.isEmpty && self.recentSearches.isEmpty
                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                    
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: recentsIsEmpty ? .fractionalWidth(1) : .absolute(100), heightDimension: recentsIsEmpty ? .absolute(55) : .absolute(80)), subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                    section.interGroupSpacing = 0
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                    if !recentsIsEmpty { section.boundarySupplementaryItems = [header] }
                    
                    return section
                } else {
                    
                    
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                    
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    //section.orthogonalScrollingBehavior = .groupPagingCentered
                    section.interGroupSpacing = 0
                    //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                    
                    return section
                }
            }
        }
        return layout
    }
    
    private func configureUI() {

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.keyboardDismissMode = .onDrag
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        view.addSubviews(activityIndicator, collectionView, categoriesToolbar)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbarHeightAnchor = categoriesToolbar.heightAnchor.constraint(equalToConstant: 0)
        toolbarHeightAnchor.isActive = true
        categoriesToolbar.searchDelegate = self

        
        NSLayoutConstraint.activate([
            categoriesToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),

            collectionView.topAnchor.constraint(equalTo: categoriesToolbar.bottomAnchor),
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
        collectionView.register(RecentSearchesUserCell.self, forCellWithReuseIdentifier: recentSearchesUserCellReuseIdentifier)
        collectionView.register(RecentContentSearchCell.self, forCellWithReuseIdentifier: recentContentSearchReuseIdentifier)
        
        collectionView.register(TopEmptyContentCell.self, forCellWithReuseIdentifier: emptyTopicsCellReuseIdentifier)
        collectionView.register(WhoToFollowCell.self, forCellWithReuseIdentifier: whoToFollowCellReuseIdentifier)
        collectionView.register(MainSearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: topHeaderReuseIdentifier)
        collectionView.register(TertiarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        
        collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        collectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        collectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        collectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        
        collectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        
        collectionView.register(BrowseJobCell.self, forCellWithReuseIdentifier: browseJobCellReuseIdentifier)
        
        collectionView.register(GroupCell.self, forCellWithReuseIdentifier: groupCellReuseIdentifier)
        
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "kek")
        
    }
    
    func restartSearchMenu() {
        categoriesToolbar.didRestoreMenu()
    }
    
    func fetchContentFor(topic: String, category: Search.Topics) {
        //resultItemsCount = 0
        SearchService.fetchContentWithTopicSelected(topic: topic, category: category, lastSnapshot: nil) { snapshot in
            switch category {
            case .people:
                guard !snapshot.isEmpty else {
                    self.resultItemsCount = 0
                    self.activityIndicator.stop()
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                    return
                }
                
                self.usersLastSnapshot = snapshot.documents.last
                self.topUsers = snapshot.documents.map({ User(dictionary: $0.data() )})
                var count = 0
                self.topUsers.enumerated().forEach { index, user in
                    UserService.checkIfUserIsFollowed(uid: user.uid!) { followed in
                        self.topUsers[index].isFollowed = followed
                        count += 1
                        if count == self.topUsers.count {
                            self.resultItemsCount = self.topUsers.count
                            self.activityIndicator.stop()
                            self.collectionView.reloadData()
                            self.collectionView.isHidden = false
                        }
                    }
                }
                
            case .posts:
                guard !snapshot.isEmpty else {
                    self.resultItemsCount = 0
                    self.activityIndicator.stop()
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                    return
                }
                self.postsLastSnapshot = snapshot.documents.last
                self.topPosts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data() )})
                PostService.getPostValuesFor(posts: self.topPosts) { posts in
                    self.topPosts = posts
                    let ownerUids = self.topPosts.map { $0.ownerUid }
                    UserService.fetchUsers(withUids: ownerUids) { users in
                        self.topPostUsers = users
                        self.resultItemsCount = self.topPosts.count
                        self.activityIndicator.stop()
                        self.collectionView.reloadData()
                        self.collectionView.isHidden = false
                    }
                }
                
            case .cases:
                guard !snapshot.isEmpty else {
                    self.resultItemsCount = 0
                    self.activityIndicator.stop()
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                    return
                }
                self.caseLastSnapshot = snapshot.documents.last
                self.topCases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data() )})
                CaseService.getCaseValuesFor(cases: self.topCases) { cases in
                    self.topCases = cases
                    let visibleOwnerUids = self.topCases.filter({ $0.privacyOptions == .visible }).map({ $0.ownerUid })
                    UserService.fetchUsers(withUids: visibleOwnerUids) { users in
                        self.topCaseUsers = users
                        self.resultItemsCount = self.topCases.count
                        self.activityIndicator.stop()
                        self.collectionView.reloadData()
                        self.collectionView.isHidden = false
                    }
                }
                 
            case .groups:
                guard !snapshot.isEmpty else {
                    self.resultItemsCount = 0
                    self.activityIndicator.stop()
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                    return
                }
                self.groupsLastSnapshot = snapshot.documents.last
                self.topGroups = snapshot.documents.map({ Group(groupId: $0.documentID, dictionary: $0.data() )})
                var aggrCount = 0
                self.topGroups.enumerated().forEach { index, group in
                    DatabaseManager.shared.fetchNumberOfGroupUsers(groupId: group.groupId) { members in
                        self.topGroups[index].members = members
                        aggrCount += 1
                        if aggrCount == self.topGroups.count {
                            self.resultItemsCount = self.topGroups.count
                            self.activityIndicator.stop()
                            self.collectionView.reloadData()
                            self.collectionView.isHidden = false
                        }
                    }
                }

                
            case .jobs:
                guard !snapshot.isEmpty else {
                    self.resultItemsCount = 0
                    self.activityIndicator.stop()
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                    return
                }
                self.jobsLastSnapshot = snapshot.documents.last
                self.topJobs = snapshot.documents.map({ Job(jobId: $0.documentID, dictionary: $0.data()) })
                let companyIds = self.topJobs.map { $0.companyId }
                JobService.fetchJobValuesFor(jobs: self.topJobs) { jobs in
                    self.topJobs = jobs
                    CompanyService.fetchCompanies(withIds: companyIds) { companies in
                        self.topCompanies = companies
                        self.resultItemsCount = self.topJobs.count
                        self.activityIndicator.stop()
                        self.collectionView.reloadData()
                        self.collectionView.isHidden = false
                    }
                }
            }
        }
    }
    
    func fetchTopFor(topic: String) {
        var count = 0
        
        UserService.fetchTopUsersWithTopic(topic: topic) { users in
            self.topUsers = users
            count += 1
            self.checkIfFetchedAllInfo(count: count)
        }
        
        PostService.fetchTopPostsForTopic(topic: topic) { posts in
            self.topPosts = posts
            guard !posts.isEmpty else {
                count += 1
                self.checkIfFetchedAllInfo(count: count)
                return
            }
            
            let uids = self.topPosts.map { $0.ownerUid }
            UserService.fetchUsers(withUids: uids) { users in
                self.topPostUsers = users
                count += 1
                self.checkIfFetchedAllInfo(count: count)
            }
        }
        
        CaseService.fetchTopCasesForTopic(topic: topic) { cases in
            self.topCases = cases
            guard !cases.isEmpty else {
                count += 1
                self.checkIfFetchedAllInfo(count: count)
                return
            }
            
            let uids = self.topCases.filter({ $0.privacyOptions == .visible }).map { $0.ownerUid }
            UserService.fetchUsers(withUids: uids) { users in
                self.topCaseUsers = users
                count += 1
                self.checkIfFetchedAllInfo(count: count)
            }
        }
        
        JobService.fetchTopJobsForTopic(topic: topic) { jobs in
            self.topJobs = jobs
            guard !jobs.isEmpty else {
                count += 1
                self.checkIfFetchedAllInfo(count: count)
                return
            }
            
            let ids = jobs.map({ $0.companyId })
            CompanyService.fetchCompanies(withIds: ids) { companies in
                self.topCompanies = companies
                count += 1
                self.checkIfFetchedAllInfo(count: count)
            }
        }
        
        GroupService.fetchTopGroupsForTopic(topic: topic) { groups in
            self.topGroups = groups
            count += 1
            self.checkIfFetchedAllInfo(count: count)
        }
    }
    
    func checkIfFetchedAllInfo(count: Int) {
        if count == 5 {
            self.activityIndicator.stop()
            self.collectionView.reloadData()
            self.collectionView.isHidden = false
            categoriesToolbar.showToolbar()
        }
    }
    
    func didSelectSearchCategoryFromMenu(_ category: String) {
        categoriesToolbar.didSelectSearchTopic(category)
    }
    
    func didSelectTopicFromMenu(_ topic: String) {
        if let searchTopic = Search.Topics(rawValue: topic) {
            categoriesToolbar.didSelectSearchCategory(searchTopic)
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
        /*
        if searchText.count > 5 {
            UIView.animate(withDuration: 0.2) {
                self.toolbarHeightAnchor.constant = 0
                self.view.layoutIfNeeded()
            }

        } else {
            UIView.animate(withDuration: 0.2) {
                self.toolbarHeightAnchor.constant = 50
                self.view.layoutIfNeeded()
            }
        }
         */
    }
}

extension SearchResultsUpdatingViewController: MESearchToolbarDelegate {
    func showCategoriesMenu(withCategory category: String) {
        searchResultsDelegate?.didTapShowCategoriesMenu(withCategory: category)
    }
    
    func showDisciplinesMenu(withOption option: String) {
        searchResultsDelegate?.didTapDisciplinesMenu(withOption: option)
    }

    func didRestoreMenu() {
        activityIndicator.stop()
        isInSearchTopicMode = false
        isInSearchCategoryMode = false
        collectionView.reloadData()
        collectionView.isHidden = false
    }
    
    func didSelectSearchTopic(_ category: String) {
        collectionView.isHidden = true
        topicSearched = category
        activityIndicator.start()
        isInSearchTopicMode = true
        isInSearchCategoryMode = false
        fetchTopFor(topic: category)

        // fetch top 3 of each
        // when is fetch, clal the toolbar to revert the animation
    }
    
    func didSelectSearchCategory(_ category: Search.Topics) {
        collectionView.isHidden = true
        activityIndicator.start()
        isInSearchCategoryMode = true
        categorySearched = category
        fetchContentFor(topic: topicSearched!, category: category)
    }
}

extension SearchResultsUpdatingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isInSearchCategoryMode {
            return 1
        } else if isInSearchTopicMode {
            if topUsers.isEmpty && topPosts.isEmpty && topCases.isEmpty && topGroups.isEmpty && topJobs.isEmpty { return 1 }
            return 5
        } else {
            return recentSearches.isEmpty && recentUserSearches.isEmpty ? 1 : 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isInSearchCategoryMode {
            return resultItemsCount == 0 ? 1 : resultItemsCount
        } else if isInSearchTopicMode {
            // User press a topic on the main toolbar
            if topUsers.isEmpty && topPosts.isEmpty && topCases.isEmpty && topGroups.isEmpty && topJobs.isEmpty { return 1 }
            
            if section == 0 {
                return topUsers.isEmpty ? 0 : topUsers.count
            } else if section == 1 {
                return topPosts.isEmpty ? 0 : topPosts.count
            } else if section == 2 {
                return topCases.isEmpty ? 0 : topCases.count
            } else if section == 3 {
                return topGroups.isEmpty ? 0 : topGroups.count
            } else {
                return topJobs.isEmpty ? 0 : topJobs.count
            }
        } else {
            // Recents information
            if !dataLoaded { return 0 }
            if recentSearches.isEmpty && recentUserSearches.isEmpty { return 1 } else {
                if section == 0 {
                    return users.count
                } else {
                    return recentSearches.count
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if !isInSearchTopicMode {
            // Recents
            if dataLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchRecentsHeaderReuseIdentifier, for: indexPath) as! SearchRecentsHeader
                //header.delegate = self
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            }
        } else {
            // Topic selected
            if isInSearchCategoryMode {
                if categorySearched == .people {
                    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: secondarySearchHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
                    header.configureWith(title: categorySearched.rawValue, linkText: "")
                    return header
                } else {
                    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: topHeaderReuseIdentifier, for: indexPath) as! MainSearchHeader
                    header.configureWith(title: categorySearched.rawValue, linkText: "")
                    return header
                }
            } else {
                
                if indexPath.section == 0 {
                    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: secondarySearchHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
                    header.configureWith(title: "People", linkText: "See All")
                    if topUsers.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
                    header.separatorView.isHidden = true
                    return header
                } else {
                    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! TertiarySearchHeader
                    
                    if indexPath.section == 1 {
                        header.configureWith(title: "Posts", linkText: "See All")
                        if topPosts.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
                        if topUsers.isEmpty { header.separatorView.isHidden = true } else { header.separatorView.isHidden = false }
                    } else if indexPath.section == 2 {
                        header.configureWith(title: "Cases", linkText: "See All")
                        if topUsers.isEmpty && topPosts.isEmpty { header.separatorView.isHidden = true } else { header.separatorView.isHidden = false }
                        if topCases.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
                    } else if indexPath.section == 3 {
                        header.configureWith(title: "Groups", linkText: "See All")
                        if topGroups.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
                        if topUsers.isEmpty && topPosts.isEmpty && topCases.isEmpty { header.separatorView.isHidden = true } else { header.separatorView.isHidden = false }
                    } else {
                        header.configureWith(title: "Jobs", linkText: "See All")
                        if topJobs.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
                        if topUsers.isEmpty && topPosts.isEmpty && topCases.isEmpty && topGroups.isEmpty { header.separatorView.isHidden = true } else { header.separatorView.isHidden = false }
                    }
                    return header
                    
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isInSearchCategoryMode {
            if resultItemsCount == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: UIImage(named: "content.empty"), title: "No content found", description: "Try removing some filters or rephrasing your search", buttonText: .removeFilters)
                cell.delegate = self
                return cell
            } else {
                switch categorySearched {
                case .people:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowCellReuseIdentifier, for: indexPath) as! WhoToFollowCell
                    cell.configureWithUser(user: topUsers[indexPath.row])
                    cell.followerDelegate = self
                    return cell
                case .posts:
                    switch topPosts[indexPath.row].type {
                    case .plainText:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        //cell.set(user: postUsers[index])
                        cell.delegate = self
                        return cell
                    case .textWithImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        //cell.set(user: postUsers[index])
                        cell.delegate = self
                        return cell
                    case .textWithTwoImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        //cell.set(user: postUsers[index])
                        cell.delegate = self
                        return cell
                    case .textWithThreeImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        //cell.delegate = self
                        return cell
                    case .textWithFourImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                    case .document:
                        return UICollectionViewCell()
                    case .poll:
                        return UICollectionViewCell()
                    case .video:
                        return UICollectionViewCell()
                    }
                case .cases:
                    switch topCases[indexPath.row].type {
                    case .text:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                        cell.viewModel = CaseViewModel(clinicalCase: topCases[indexPath.row])
                        if let userIndex = topCaseUsers.firstIndex(where: { $0.uid == topCases[indexPath.row].ownerUid }) {
                            cell.set(user: topCaseUsers[userIndex])
                        }
                        if indexPath.row == topCases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                    case .textWithImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                        cell.viewModel = CaseViewModel(clinicalCase: topCases[indexPath.row])
                        if let userIndex = topCaseUsers.firstIndex(where: { $0.uid == topCases[indexPath.row].ownerUid }) {
                            cell.set(user: topCaseUsers[userIndex])
                        }
                        if indexPath.row == topCases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                        
                    }
                case .groups:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellReuseIdentifier, for: indexPath) as! GroupCell
                    cell.viewModel = GroupViewModel(group: topGroups[indexPath.row])
                    if indexPath.row == topGroups.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                    return cell
                    
                case .jobs:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: browseJobCellReuseIdentifier, for: indexPath) as! BrowseJobCell
                    cell.viewModel = JobViewModel(job: topJobs[indexPath.row])
                    if let companyIndex = topCompanies.firstIndex(where: { $0.id == topJobs[indexPath.row].companyId }) {
                        cell.configureWithCompany(company: topCompanies[companyIndex])
                    }
                    if indexPath.row == topJobs.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                    cell.delegate = self
                    return cell
                }
            }
            
        } else if !isInSearchTopicMode {
            if recentSearches.isEmpty && recentUserSearches.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyRecentsSearchCell
                cell.set(title: "Try searching for people, content or any of the above filters")
                return cell
            } else {
                if indexPath.section == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentSearchesUserCellReuseIdentifier, for: indexPath) as! RecentSearchesUserCell
                    cell.configureWithUser(user: users[indexPath.row])
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentContentSearchReuseIdentifier, for: indexPath) as! RecentContentSearchCell
                    cell.viewModel = RecentTextCellViewModel(recentText: recentSearches[indexPath.row])
                    return cell
                }
            }
        } else {
            if topUsers.isEmpty && topPosts.isEmpty && topCases.isEmpty && topGroups.isEmpty && topJobs.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: UIImage(named: "content.empty"), title: "No content found", description: "Try removing some filters or rephrasing your search", buttonText: .removeFilters)
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
                switch topPosts[indexPath.row].type {
                case .plainText:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTextCell
                    cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                    if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                        cell.set(user: topPostUsers[userIndex])
                    }
                    if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    cell.delegate = self
                    return cell
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                    cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                    if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                        cell.set(user: topPostUsers[userIndex])
                    }
                    if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    cell.delegate = self
                    return cell
                case .textWithTwoImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                    cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                    if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                        cell.set(user: topPostUsers[userIndex])
                    }
                    if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    cell.delegate = self
                    return cell
                case .textWithThreeImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                    cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                    if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                        cell.set(user: topPostUsers[userIndex])
                    }
                    if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    cell.delegate = self
                    return cell
                case .textWithFourImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                    cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                    if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                        cell.set(user: topPostUsers[userIndex])
                    }
                    if indexPath.row == topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    cell.delegate = self
                    return cell
                case .document:
                    return UICollectionViewCell()
                case .poll:
                    return UICollectionViewCell()
                case .video:
                    return UICollectionViewCell()
                }
            } else if indexPath.section == 2 {
                // Top Cases
                
                switch topCases[indexPath.row].type {
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                    cell.viewModel = CaseViewModel(clinicalCase: topCases[indexPath.row])
                    if let userIndex = topCaseUsers.firstIndex(where: { $0.uid == topCases[indexPath.row].ownerUid }) {
                        cell.set(user: topCaseUsers[userIndex])
                    }
                    if indexPath.row == topCases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    cell.delegate = self
                    return cell
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: topCases[indexPath.row])
                    if let userIndex = topCaseUsers.firstIndex(where: { $0.uid == topCases[indexPath.row].ownerUid }) {
                        cell.set(user: topCaseUsers[userIndex])
                    }
                    if indexPath.row == topCases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                    cell.delegate = self
                    return cell
                    
                }
            } else if indexPath.section == 3 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellReuseIdentifier, for: indexPath) as! GroupCell
                cell.viewModel = GroupViewModel(group: topGroups[indexPath.row])
                
                if indexPath.row == topGroups.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                return cell
            } else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: browseJobCellReuseIdentifier, for: indexPath) as! BrowseJobCell
                cell.viewModel = JobViewModel(job: topJobs[indexPath.row])
                if let companyIndex = topCompanies.firstIndex(where: { $0.id == topJobs[indexPath.row].companyId }) {
                    cell.configureWithCompany(company: topCompanies[companyIndex])
                }
                if indexPath.row == topJobs.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                cell.delegate = self
                return cell
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isInSearchCategoryMode {
            // User is searching for a specific Discipline
            switch categorySearched {
                
            case .people:
                guard !topUsers.isEmpty else { return }
                let controller = UserProfileViewController(user: topUsers[indexPath.row])
                
                let backItem = UIBarButtonItem()
                backItem.title = ""
                backItem.tintColor = .label

                if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                    searchViewController.navigationItem.backBarButtonItem = backItem
                    navVC.pushViewController(controller, animated: true)
                    DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
                }
            case .posts:
                guard !topPosts.isEmpty else { return }
                
            case .cases:
                guard !topCases.isEmpty else { return }
                
            case .groups:
                guard !topGroups.isEmpty else { return }
                let controller = GroupPageViewController(group: topGroups[indexPath.row])
                let backItem = UIBarButtonItem()
                backItem.tintColor = .label
                backItem.title = ""

                if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                    searchViewController.navigationItem.backBarButtonItem = backItem
                    navVC.pushViewController(controller, animated: true)
                }
  
            case .jobs:
                guard !topJobs.isEmpty else { return }
                if let companyIndex = topCompanies.firstIndex(where: { $0.id == topJobs[indexPath.row].companyId }) {
                    let controller = JobDetailsViewController(job: topJobs[indexPath.row], company: topCompanies[companyIndex], user: user)
                    controller.delegate = self
                    let navController = UINavigationController(rootViewController: controller)
                    navController.modalPresentationStyle = .fullScreen
                    present(navController, animated: true)
                }
            }
        } else if isInSearchTopicMode {
            // User is searching for a specific Topic
            if indexPath.section == 0 {
                guard !topUsers.isEmpty else { return }
                let controller = UserProfileViewController(user: topUsers[indexPath.row])
                
                let backItem = UIBarButtonItem()
                backItem.title = ""
                backItem.tintColor = .label

                if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                    searchViewController.navigationItem.backBarButtonItem = backItem
                    navVC.pushViewController(controller, animated: true)
                    DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
                }
            }
            else if indexPath.section == 4 {
                // Jobs
                guard !topJobs.isEmpty else { return }
                if let companyIndex = topCompanies.firstIndex(where: { $0.id == topJobs[indexPath.row].companyId }) {
                    let controller = JobDetailsViewController(job: topJobs[indexPath.row], company: topCompanies[companyIndex], user: user)
                    controller.delegate = self
                    let navController = UINavigationController(rootViewController: controller)
                    navController.modalPresentationStyle = .fullScreen
                    present(navController, animated: true)
                }
            } else if indexPath.section == 3 {
                // Groups
                guard !topGroups.isEmpty else { return }
                let groupSelected = topGroups[indexPath.row]
                let controller = GroupPageViewController(group: groupSelected)
                
                let backItem = UIBarButtonItem()
                backItem.tintColor = .label
                backItem.title = ""

                if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                    searchViewController.navigationItem.backBarButtonItem = backItem
                    navVC.pushViewController(controller, animated: true)
                }
            }
        } else { return }
    }
}

extension SearchResultsUpdatingViewController: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton(option: EmptyCellButtonOptions) {
        categoriesToolbar.didRestoreMenu()
    }
}

extension SearchResultsUpdatingViewController: BrowseJobCellDelegate, JobDetailsViewControllerDelegate {
    func didBookmark(job: Job, company: Company) {
        if let jobIndex = topJobs.firstIndex(where: { $0.jobId == job.jobId }) {
            topJobs[jobIndex].didBookmark.toggle()
            collectionView.reloadItems(at: [IndexPath(item: jobIndex, section: 0)])
        }
    }
    
    func didBookmarkJob(_ cell: UICollectionViewCell, job: Job) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        HapticsManager.shared.vibrate(for: .success)
        switch cell {
        case is BrowseJobCell:
            let currentCell = cell as! BrowseJobCell
            currentCell.viewModel?.job.didBookmark.toggle()
            
            if job.didBookmark {
                JobService.unbookmarkJob(job: job) { _ in
                    self.topJobs[indexPath.row].didBookmark = false
                    currentCell.isUpdatingJoiningState = false
                }
            } else {
                JobService.bookmarkJob(job: job) { _ in
                    self.topJobs[indexPath.row].didBookmark = true
                    currentCell.isUpdatingJoiningState = false
                }
            }
            
        default:
            print("No cell registered for this type")
        }
    }
}

extension SearchResultsUpdatingViewController: UsersFollowCellDelegate {
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

extension SearchResultsUpdatingViewController: HomeCellDelegate {
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        
        #warning("Check if commenting works, because inside we get the user in the main tab controller and i'm not sure it's possible as in this controller we cannot get it.")
        let controller = CommentPostViewController(post: post, user: user, type: .regular, currentUser: self.user)
        controller.delegate = self
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
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
                    self.topPosts[indexPath.row].didLike = false
                    self.topPosts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.topPosts[indexPath.row].didLike = true
                    self.topPosts[indexPath.row].likes += 1
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: self.user, type: .likePost, post: post)
                }
            }
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.topPosts[indexPath.row].didLike = false
                    self.topPosts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.topPosts[indexPath.row].didLike = true
                    self.topPosts[indexPath.row].likes += 1
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: self.user, type: .likePost, post: post)
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.topPosts[indexPath.row].didLike = false
                    self.topPosts[indexPath.row].likes -= 1
                    
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.topPosts[indexPath.row].didLike = true
                    self.topPosts[indexPath.row].likes += 1
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: self.user, type: .likePost, post: post)
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.topPosts[indexPath.row].didLike = false
                    self.topPosts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.topPosts[indexPath.row].didLike = true
                    self.topPosts[indexPath.row].likes += 1
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: self.user, type: .likePost, post: post)
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.topPosts[indexPath.row].didLike = false
                    self.topPosts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.topPosts[indexPath.row].didLike = true
                    self.topPosts[indexPath.row].likes += 1
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: self.user, type: .likePost, post: post)
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

        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            searchViewController.navigationItem.backBarButtonItem = backItem
            navVC.pushViewController(controller, animated: true)
            DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
        }
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
                    self.topPosts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.topPosts[indexPath.row].didBookmark = true
                }
            }
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.topPosts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.topPosts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.topPosts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.topPosts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.topPosts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.topPosts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.topPosts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.topPosts[indexPath.row].didBookmark = true
                }
            }

        default:
            break
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) { return }

    func cell(wantsToSeeLikesFor post: Post) {
        let controller = PostLikesViewController(contentType: post)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label

        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            searchViewController.navigationItem.backBarButtonItem = backItem
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
        
        let controller = DetailsPostViewController(post: post, user: user, type: .regular, collectionViewLayout: layout)
        controller.delegate = self
       
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            searchViewController.navigationItem.backBarButtonItem = backItem
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
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        let controller = PostLikesViewController(contentType: clinicalCase)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label

        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            searchViewController.navigationItem.backBarButtonItem = backItem
            navVC.pushViewController(controller, animated: true)
        }
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        let controller = CommentCaseViewController(clinicalCase: clinicalCase, user: user, type: .regular, currentUser: self.user)
        controller.delegate = self
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
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
                    self.topCases[indexPath.row].didLike = false
                    self.topCases[indexPath.row].likes -= 1

                }
            } else {
                //Like post here
                CaseService.likeCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    self.topCases[indexPath.row].didLike = true
                    self.topCases[indexPath.row].likes += 1
                    NotificationService.uploadNotification(toUid: clinicalCase.ownerUid, fromUser: self.user, type: .likeCase, clinicalCase: clinicalCase)
                }
            }
            
        case is CaseTextImageCell:
            let currentCell = cell as! CaseTextImageCell
            currentCell.viewModel?.clinicalCase.didLike.toggle()
            if clinicalCase.didLike {
                //Unlike post here
                CaseService.unlikeCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                    self.topCases[indexPath.row].didLike = false
                    self.topCases[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                CaseService.likeCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    self.topCases[indexPath.row].didLike = true
                    self.topCases[indexPath.row].likes += 1
                    NotificationService.uploadNotification(toUid: clinicalCase.ownerUid, fromUser: self.user, type: .likeCase, clinicalCase: clinicalCase)
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
                    self.topCases[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                CaseService.bookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    self.topCases[indexPath.row].didBookmark = true
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
                    self.topCases[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                CaseService.bookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    self.topCases[indexPath.row].didBookmark = true
                    //NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            }
        default:
            print("Cell not registered")
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: Case.CaseMenuOptions) {
        switch option {
            #warning("implement menu options")
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

        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            searchViewController.navigationItem.backBarButtonItem = backItem
            navVC.pushViewController(controller, animated: true)
            DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
        }
        //let navigationController = UINavigationController(rootViewController: self)
        //navigationController.pushViewController(controller, animated: true)
        //navigationController?.pushViewController(UINavigationController(rootViewController: controller, animated: true))

    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        if let userIndex = topCaseUsers.firstIndex(where: { $0.uid == clinicalCase.ownerUid }) {
            let controller = CaseUpdatesViewController(clinicalCase: clinicalCase, user: topCaseUsers[userIndex])
            controller.controllerIsPushed = true

            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            
            if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                searchViewController.navigationItem.backBarButtonItem = backItem
                navVC.pushViewController(controller, animated: true)
            }

        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) { return }
    
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
        
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            searchViewController.navigationItem.backBarButtonItem = backItem
            navVC.pushViewController(controller, animated: true)
        }
    }
}

extension SearchResultsUpdatingViewController: CommentPostViewControllerDelegate {
    func didCommentPost(post: Post, user: User, comment: Comment) {
        if let postIndex = topPosts.firstIndex(where: { $0.postId == post.postId }) {
            topPosts[postIndex].numberOfComments += 1
            
            switch post.type {
            case .plainText:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithTwoImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeTwoImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithThreeImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeThreeImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithFourImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeFourImageTextCell
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
    
    func didDeletePostComment(post: Post, comment: Comment) {
        if let postIndex = topPosts.firstIndex(where: { $0.postId == post.postId }) {
            topPosts[postIndex].numberOfComments -= 1
            
            switch post.type {
            case .plainText:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithTwoImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeTwoImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithThreeImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeThreeImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithFourImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeFourImageTextCell
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
}

extension SearchResultsUpdatingViewController: DetailsPostViewControllerDelegate {
    func didTapLikeAction(forPost post: Post) {
        if let postIndex = topPosts.firstIndex(where: { $0.postId == post.postId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) {
                self.cell(cell, didLike: post)
            }
        }
    }
    
    func didTapBookmarkAction(forPost post: Post) {
        if let postIndex = topPosts.firstIndex(where: { $0.postId == post.postId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) {
                self.cell(cell, didBookmark: post)
            }
        }
    }
    
    func didComment(forPost post: Post) {
        let index = topPosts.firstIndex { homePost in
            if homePost.postId == post.postId {
                return true
            }
            return false
        }
        
        if let index = index {

            topPosts[index].numberOfComments += 1
            
            switch post.type {
            case .plainText:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: isInSearchCategoryMode ? 0 : 1)) as! HomeTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: isInSearchCategoryMode ? 0 : 1)) as! HomeImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithTwoImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: isInSearchCategoryMode ? 0 : 1)) as! HomeTwoImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithThreeImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: isInSearchCategoryMode ? 0 : 1)) as! HomeThreeImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithFourImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: isInSearchCategoryMode ? 0 : 1)) as! HomeFourImageTextCell
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
    
    func didDeleteComment(forPost post: Post) {
        if let postIndex = topPosts.firstIndex(where: { $0.postId == post.postId }) {
            topPosts[postIndex].numberOfComments -= 1
            
            switch post.type {
            case .plainText:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithTwoImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeTwoImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithThreeImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeThreeImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithFourImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: isInSearchCategoryMode ? 0 : 1)) as! HomeFourImageTextCell
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
    
    func didEditPost(forPost post: Post) { return }
}

extension SearchResultsUpdatingViewController: CommentCaseViewControllerDelegate {
    func didCommentCase(clinicalCase: Case, user: User, comment: Comment) {
        let caseIndex = topCases.firstIndex { searchCase in
            if searchCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = caseIndex {
            topCases[index].numberOfComments += 1
            collectionView.reloadItems(at: [IndexPath(item: index, section: isInSearchCategoryMode ? 0 : 2)])
        }
    }
    
    func didDeleteCaseComment(clinicalCase: Case, comment: Comment) {
        if let caseIndex = topCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            topCases[caseIndex].numberOfComments -= 1
            
            switch clinicalCase.type {
            case .text:
                let cell = collectionView.cellForItem(at: IndexPath(item: caseIndex, section: isInSearchCategoryMode ? 0 : 2)) as! CaseTextCell
                cell.viewModel?.clinicalCase.numberOfComments -= 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: caseIndex, section: isInSearchCategoryMode ? 0 : 2)) as! CaseTextImageCell
                cell.viewModel?.clinicalCase.numberOfComments -= 1
            }
        }
    }
}

extension SearchResultsUpdatingViewController: DetailsCaseViewControllerDelegate {
    func didTapLikeAction(forCase clinicalCase: Case) {
        let index = topCases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: isInSearchCategoryMode ? 0 : 2)) {
                self.clinicalCase(cell, didLike: clinicalCase)
            }
        }
    }
    
    func didTapBookmarkAction(forCase clinicalCase: Case) {
        let index = topCases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: isInSearchCategoryMode ? 0 : 2)) {
                self.clinicalCase(cell, didBookmark: clinicalCase)
            }
        }
    }
    
    func didComment(forCase clinicalCase: Case) {
        let caseIndex = topCases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = caseIndex {
            topCases[index].numberOfComments += 1
            collectionView.reloadItems(at: [IndexPath(item: index, section: isInSearchCategoryMode ? 0 : 2)])
        }
    }
    
    func didAddUpdate(forCase clinicalCase: Case) { }
    
    func didAddDiagnosis(forCase clinicalCase: Case) { }
    
    func didDeleteComment(forCase clinicalCase: Case) {
        if let caseIndex = topCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            topCases[caseIndex].numberOfComments -= 1
            
            switch clinicalCase.type {
            case .text:
                let cell = collectionView.cellForItem(at: IndexPath(item: caseIndex, section: isInSearchCategoryMode ? 0 : 2)) as! CaseTextCell
                cell.viewModel?.clinicalCase.numberOfComments -= 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: caseIndex, section: isInSearchCategoryMode ? 0 : 2)) as! CaseTextImageCell
                cell.viewModel?.clinicalCase.numberOfComments -= 1
            }
        }
    }
}



