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

private let browseJobCellReuseIdentifier = "BrowseJobCellReuseIdentifier"

class SearchResultsUpdatingViewController: UIViewController {
    
    var toolbarHeightAnchor: NSLayoutConstraint!
    
    private var dataLoaded: Bool = false
    private var isInSearchTopicMode: Bool = false
    private var isInSearchCategoryMode: Bool = false
    
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
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                
                
                //let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: self.categorySearched == .people ? .fractionalHeight(1) : .estimated(65)))
                
                #warning("previous it was with the instructoin above but only worked for empty people")
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: self.resultItemsCount == 0 ? .fractionalHeight(1) : .estimated(65)))
                
                item.contentInsets.leading = 10
                item.contentInsets.trailing = 10
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: self.resultItemsCount == 0 ? .fractionalHeight(0.9) : .estimated(65)), subitems: [item])
                
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                
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
                    
                    item.contentInsets.leading = 10
                    item.contentInsets.trailing = 10
                    
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension:
                                                                                                        self.topUsers.isEmpty && self.topPosts.isEmpty && self.topCases.isEmpty && self.topGroups.isEmpty && self.topJobs.isEmpty ? .fractionalHeight(0.9) : .absolute(65)), subitems: [item])
                    
                    
                    let section = NSCollectionLayoutSection(group: group)
                    //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20 , trailing: 0)
                    
                    if !self.topUsers.isEmpty {
                        section.boundarySupplementaryItems = [header]
                        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0 , trailing: 0)
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
                            //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                        }
                    } else if sectionNumber == 2 {
                        if !self.topCases.isEmpty {
                            section.boundarySupplementaryItems = [header]
                            //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                        }
                    } else if sectionNumber == 3 {
                        if !self.topGroups.isEmpty {
                            section.boundarySupplementaryItems = [header]
                            //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                        }
                    } else {
                        if !self.topJobs.isEmpty {
                            section.boundarySupplementaryItems = [header]
                            //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                        }
                    }
                    section.interGroupSpacing = 10
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
        
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "kek")
        
    }
    
    func fetchContentFor(topic: String, category: Search.Topics) {
        //resultItemsCount = 0
        SearchService.fetchContentWithTopicSelected(topic: topic, category: category, lastSnapshot: nil) { snapshot in
            switch category {
            case .people:
                self.usersLastSnapshot = snapshot.documents.last
                self.topUsers = snapshot.documents.map({ User(dictionary: $0.data() )})
                self.resultItemsCount = self.topUsers.count
                self.activityIndicator.stop()
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
                
            case .posts:
                self.postsLastSnapshot = snapshot.documents.last
                self.topPosts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data() )})
                self.resultItemsCount = self.topPosts.count
                self.activityIndicator.stop()
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
                
            case .cases:
                self.caseLastSnapshot = snapshot.documents.last
                self.topCases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data() )})
                self.resultItemsCount = self.topCases.count
                self.activityIndicator.stop()
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
                
            case .groups:
                self.groupsLastSnapshot = snapshot.documents.last
                self.topGroups = snapshot.documents.map({ Group(groupId: $0.documentID, dictionary: $0.data() )})
                self.resultItemsCount = self.topGroups.count
                self.activityIndicator.stop()
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
                
            case .jobs:
                self.jobsLastSnapshot = snapshot.documents.last
                self.topJobs = snapshot.documents.map({ Job(jobId: $0.documentID, dictionary: $0.data()) })
                self.resultItemsCount = self.topJobs.count
                self.activityIndicator.stop()
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
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
            
            let uids = self.topCases.map { $0.ownerUid }
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
    }
    
    func checkIfFetchedAllInfo(count: Int) {
        if count == 4 {
            self.activityIndicator.stop()
            self.collectionView.reloadData()
            self.collectionView.isHidden = false
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

    func didRestoreMenu() {
        activityIndicator.stop()
        isInSearchTopicMode = false
        isInSearchCategoryMode = false
        collectionView.reloadData()
        collectionView.isHidden = false
    }
    
    func didSelectSearchTopic(_ category: String) {
        print(category)
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
            //return 2
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
            if indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: topHeaderReuseIdentifier, for: indexPath) as! MainSearchHeader
                header.configureWith(title: "People", linkText: "See All")
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! TertiarySearchHeader
                if indexPath.section == 1 {
                    header.configureWith(title: "Posts", linkText: "See All")
                    if topUsers.isEmpty { header.separatorView.isHidden = true }
                } else if indexPath.section == 2 {
                    header.configureWith(title: "Cases", linkText: "See All")
                    if topUsers.isEmpty && topPosts.isEmpty { header.separatorView.isHidden = true }
                } else if indexPath.section == 3 {
                    header.configureWith(title: "Groups", linkText: "See All")
                    if topUsers.isEmpty && topPosts.isEmpty && topCases.isEmpty { header.separatorView.isHidden = true }
                } else {
                    header.configureWith(title: "Jobs", linkText: "See All")
                    if topUsers.isEmpty && topPosts.isEmpty && topCases.isEmpty && topGroups.isEmpty { header.separatorView.isHidden = true }
                }
                return header
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
                        //cell.delegate = self
                        return cell
                    case .textWithImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeImageTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        //cell.set(user: postUsers[index])
                        //cell.delegate = self
                        return cell
                    case .textWithTwoImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        //cell.set(user: postUsers[index])
                        //cell.delegate = self
                        return cell
                    case .textWithThreeImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        //cell.set(user: postUsers[index])
                        //cell.delegate = self
                        return cell
                    case .textWithFourImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                        cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                        if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                            cell.set(user: topPostUsers[userIndex])
                        }
                        //cell.set(user: postUsers[index])
                        //cell.delegate = self
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
                        //cell.set(user: caseUsers[index])
                        //cell.delegate = self
                        return cell
                    case .textWithImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                        cell.viewModel = CaseViewModel(clinicalCase: topCases[indexPath.row])
                        if let userIndex = topCaseUsers.firstIndex(where: { $0.uid == topCases[indexPath.row].ownerUid }) {
                            cell.set(user: topCaseUsers[userIndex])
                        }
                        return cell
                    
                }
                case .groups:
#warning("put the groups cell")
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kek", for: indexPath)
                    cell.backgroundColor = .systemPink
                    return cell

                case .jobs:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: browseJobCellReuseIdentifier, for: indexPath) as! BrowseJobCell
                    cell.viewModel = JobViewModel(job: topJobs[indexPath.row])
                    if let companyIndex = topCompanies.firstIndex(where: { $0.id == topJobs[indexPath.row].companyId }) {
                        cell.configureWithCompany(company: topCompanies[companyIndex])
                    }
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
                    //cell.set(user: postUsers[index])
                    //cell.delegate = self
                    return cell
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeImageTextCell
                    cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                    if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                        cell.set(user: topPostUsers[userIndex])
                    }
                    //cell.set(user: postUsers[index])
                    //cell.delegate = self
                    return cell
                case .textWithTwoImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                    cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                    if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                        cell.set(user: topPostUsers[userIndex])
                    }
                    //cell.set(user: postUsers[index])
                    //cell.delegate = self
                    return cell
                case .textWithThreeImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                    cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                    if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                        cell.set(user: topPostUsers[userIndex])
                    }
                    //cell.set(user: postUsers[index])
                    //cell.delegate = self
                    return cell
                case .textWithFourImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                    cell.viewModel = PostViewModel(post: topPosts[indexPath.row])
                    if let userIndex = topPostUsers.firstIndex(where: { $0.uid == topPosts[indexPath.row].ownerUid }) {
                        cell.set(user: topPostUsers[userIndex])
                    }
                    //cell.set(user: postUsers[index])
                    //cell.delegate = self
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
                    //cell.set(user: caseUsers[index])
                    //cell.delegate = self
                    return cell
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: topCases[indexPath.row])
                    if let userIndex = topCaseUsers.firstIndex(where: { $0.uid == topCases[indexPath.row].ownerUid }) {
                        cell.set(user: topCaseUsers[userIndex])
                    }
                    //cell.set(user: caseUsers[index])
                    //cell.delegate = self
                    return cell
                    
                }
            } else if indexPath.section == 3 {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kek", for: indexPath)
                cell.backgroundColor = .systemPink
                return cell
                
            } else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: browseJobCellReuseIdentifier, for: indexPath) as! BrowseJobCell
                cell.viewModel = JobViewModel(job: topJobs[indexPath.row])
                if let companyIndex = topCompanies.firstIndex(where: { $0.id == topJobs[indexPath.row].companyId }) {
                    cell.configureWithCompany(company: topCompanies[companyIndex])
                }
                return cell
                
            }
        }
    }
}

extension SearchResultsUpdatingViewController: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton(option: EmptyCellButtonOptions) {
        categoriesToolbar.didRestoreMenu()
    }
}
