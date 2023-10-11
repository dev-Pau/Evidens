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
    
    private var viewModel = SearchResultsUpdatingViewModel()
    var toolbarHeightAnchor: NSLayoutConstraint!
    weak var searchResultsDelegate: SearchResultsUpdatingViewControllerDelegate?

    private var zoomTransitioning = ZoomTransitioning()

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
        if !viewModel.dataLoaded { fetchRecentSearches() }
    }
    
    private func fetchRecentSearches() {
        viewModel.getRecentSearches { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.toolbarHeightAnchor.constant = 50
            strongSelf.searchToolbar.layoutIfNeeded()
            strongSelf.collectionView.reloadData()
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env -> NSCollectionLayoutSection? in
            guard let strongSelf = self else { return nil }
            switch strongSelf.viewModel.searchMode {
                
            case .discipline:
                if sectionNumber == 0 {
                    let recentsIsEmpty = strongSelf.viewModel.users.isEmpty && strongSelf.viewModel.searches.isEmpty
                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.networkIssue ? .estimated(200) : .fractionalHeight(1)))

                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: strongSelf.viewModel.networkIssue ? .fractionalWidth(1) : recentsIsEmpty ? .fractionalWidth(1) : .absolute(100), heightDimension: strongSelf.viewModel.networkIssue ? .estimated(200) : recentsIsEmpty ? .absolute(55) : .absolute(80)), subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                    section.interGroupSpacing = 0
                    
                    if strongSelf.viewModel.networkIssue || recentsIsEmpty {
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
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.networkIssue ? .estimated(200) : .fractionalHeight(1)))
                    
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.networkIssue ? .estimated(200) : strongSelf.viewModel.topUsers.isEmpty && strongSelf.viewModel.topPosts.isEmpty && strongSelf.viewModel.topCases.isEmpty ? .fractionalHeight(0.9) : .absolute(73)), subitems: [item])
                                                                                                        
                    let section = NSCollectionLayoutSection(group: group)
                    
                    if !strongSelf.viewModel.topUsers.isEmpty {
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
                        if !strongSelf.viewModel.topPosts.isEmpty {
                            section.boundarySupplementaryItems = [header]
                            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                        }
                    } else if sectionNumber == 2 {
                        if !strongSelf.viewModel.topCases.isEmpty {
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
                
                if strongSelf.viewModel.networkIssue {
                    height = .estimated(200)
                    insets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                } else {
                    switch strongSelf.viewModel.searchTopic {
                    case .people:
                        height = strongSelf.viewModel.topUsers.isEmpty ? .fractionalHeight(0.9) : .estimated(65)
                        isEmpty = strongSelf.viewModel.topUsers.isEmpty
                        insets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                    case .posts:
                        height = strongSelf.viewModel.topPosts.isEmpty ? .fractionalHeight(0.9) : .estimated(65)
                        isEmpty = strongSelf.viewModel.topPosts.isEmpty
                        insets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                    case .cases:
                        height = strongSelf.viewModel.topCases.isEmpty ? .fractionalHeight(0.9) : .estimated(65)
                        isEmpty = strongSelf.viewModel.topCases.isEmpty
                        insets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                    }
                }
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: height))
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: height), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = insets
                
                if !isEmpty && !strongSelf.viewModel.networkIssue {
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
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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

        collectionView.register(ConnectUserCell.self, forCellWithReuseIdentifier: whoToFollowCellReuseIdentifier)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectionDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.connectUser), object: nil)
        
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
        viewModel.fetchContentFor(discipline: discipline, searchTopic: searchTopic) { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.activityIndicator.stop()
            strongSelf.collectionView.reloadData()
            strongSelf.collectionView.isHidden = false
        }
    }
    
    func fetchTopFor(discipline: Discipline) {
        viewModel.getTopFor(discipline: discipline) { [weak self] in
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
        guard viewModel.searchMode == .choose else { return }
        
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
        viewModel.fetchMoreContent(for: discipline) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.activityIndicator.stop()
            strongSelf.collectionView.reloadData()
            strongSelf.collectionView.isHidden = false
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
        searchBar.searchTextField.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

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
        viewModel.searchTopic = searchTopic
        searchResultsDelegate?.didTapSearchTopic(searchTopic)
        searchResultsDelegate?.dismissKeyboard()
    }
    
    func didSelectDiscipline(_ discipline: Discipline) {
        searchResultsDelegate?.dismissKeyboard()
        viewModel.searchMode = .topic
        collectionView.isHidden = true
        viewModel.isFetchingMoreContent = false
        activityIndicator.start()
        fetchTopFor(discipline: discipline)
    }
    
    func didSelectSearchTopic(_ searchTopic: SearchTopics) {
        collectionView.isHidden = true
        viewModel.searchMode = .choose
        activityIndicator.start()
        viewModel.isFetchingMoreContent = false
        viewModel.searchTopic = searchTopic
        if let discipline = searchToolbar.getDiscipline() {
            fetchContentFor(discipline: discipline, searchTopic: searchTopic)
        }
    }
    
    func didRestoreMenu() {
        viewModel.searchMode = .discipline
        activityIndicator.stop()
        collectionView.reloadData()
        viewModel.isFetchingMoreContent = false
        collectionView.isHidden = false
        
        if viewModel.searches.isEmpty && viewModel.users.isEmpty {
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
                    strongSelf.viewModel.topPosts.remove(at: indexPath.item)
                    if strongSelf.viewModel.topPosts.isEmpty {
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
                    strongSelf.viewModel.topCases.remove(at: indexPath.item)
                    if strongSelf.viewModel.topCases.isEmpty {
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
        switch viewModel.searchMode {
        case .discipline:
            return viewModel.networkIssue ? 1 : viewModel.searches.isEmpty && viewModel.users.isEmpty ? 1 : 2
        case .topic:
            return viewModel.topUsers.isEmpty && viewModel.topPosts.isEmpty && viewModel.topCases.isEmpty ? 1 : 3
        case .choose:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewModel.searchMode {
            
        case .discipline:
            if viewModel.networkIssue {
                return 1
            } else {
                if !viewModel.dataLoaded {
                    return 0
                }
                
                if viewModel.searches.isEmpty && viewModel.users.isEmpty {
                    return 1
                } else {
                    return section == 0 ? viewModel.users.count : viewModel.searches.count
                }
            }

        case .topic:
            if viewModel.networkIssue {
                return 1
            } else {
                if viewModel.topUsers.isEmpty && viewModel.topPosts.isEmpty && viewModel.topCases.isEmpty {
                    return 1
                } else {
                    if section == 0 {
                        return viewModel.topUsers.isEmpty ? 0 : viewModel.topUsers.count
                    } else if section == 1 {
                        return viewModel.topPosts.isEmpty ? 0 : viewModel.topPosts.count
                    } else {
                        return viewModel.topCases.isEmpty ? 0 : viewModel.topCases.count
                    }
                }
            }
        case .choose:
            if viewModel.networkIssue {
                return 1
            } else {
                switch viewModel.searchTopic {
                case .people:
                    return viewModel.topUsers.isEmpty ? 1 : viewModel.topUsers.count
                case .posts:
                    return viewModel.topPosts.isEmpty ? 1 : viewModel.topPosts.count
                case .cases:
                    return viewModel.topCases.isEmpty ? 1 : viewModel.topCases.count
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch viewModel.searchMode {
            
        case .discipline:
            if viewModel.dataLoaded {
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
                if viewModel.topUsers.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
                header.separatorView.isHidden = true
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! TertiarySearchHeader
                header.tag = indexPath.section
                header.delegate = self
                if indexPath.section == 1 {
                    header.configureWith(title: AppStrings.Search.Topics.posts, linkText: AppStrings.Content.Search.seeAll)

                    if viewModel.topPosts.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
                    if viewModel.topUsers.isEmpty { header.separatorView.isHidden = true } else { header.separatorView.isHidden = false }
                } else {
                    header.configureWith(title: AppStrings.Search.Topics.cases, linkText: AppStrings.Content.Search.seeAll)
                    
                    if viewModel.topUsers.isEmpty && viewModel.topPosts.isEmpty { header.separatorView.isHidden = true } else { header.separatorView.isHidden = false }
                    if viewModel.topCases.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
                }
                return header
            }
        case .choose:
            if viewModel.searchTopic == .people {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: secondarySearchHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
                header.configureWith(title: viewModel.searchTopic.title, linkText: "")
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: topHeaderReuseIdentifier, for: indexPath) as! PrimarySearchHeader
                header.configureWith(title: viewModel.searchTopic.title, linkText: "")
                return header
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch viewModel.searchMode {
            
        case .discipline:
            if viewModel.networkIssue {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: secondaryNetworkFailureCellReuseIdentifier, for: indexPath) as! SecondaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if viewModel.searches.isEmpty && viewModel.users.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyRecentsSearchCell
                    cell.set(title: AppStrings.Search.Empty.title)
                    return cell
                } else {
                    if indexPath.section == 0 {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentSearchesUserCellReuseIdentifier, for: indexPath) as! RecentUserCell
                        cell.configureWithUser(user: viewModel.users[indexPath.row])
                        return cell
                    } else {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentContentSearchReuseIdentifier, for: indexPath) as! RecentSearchCell
                        cell.viewModel = RecentTextViewModel(recentText: viewModel.searches[indexPath.row])
                        return cell
                    }
                }
            }
            
        case .topic:
            if viewModel.networkIssue {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if viewModel.topUsers.isEmpty && viewModel.topPosts.isEmpty && viewModel.topCases.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Filters.emptyTitle, description: AppStrings.Content.Filters.emptyContent, content: .dismiss)
                    
                    cell.delegate = self
                    return cell
                }
                
                if indexPath.section == 0 {

                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowCellReuseIdentifier, for: indexPath) as! ConnectUserCell
                    cell.viewModel = ConnectViewModel(user: viewModel.topUsers[indexPath.row])
                    cell.connectionDelegate = self
                    return cell
                    
                } else if indexPath.section == 1 {
                    // Top Posts
                    switch viewModel.topPosts[indexPath.row].kind {
                    case .plainText:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTextCell
                        cell.viewModel = PostViewModel(post: viewModel.topPosts[indexPath.row])
                        if let userIndex = viewModel.topPostUsers.firstIndex(where: { $0.uid == viewModel.topPosts[indexPath.row].uid }) {
                            cell.set(user: viewModel.topPostUsers[userIndex])
                        }
                        if indexPath.row == viewModel.topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                    case .textWithImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                        cell.viewModel = PostViewModel(post: viewModel.topPosts[indexPath.row])
                        if let userIndex = viewModel.topPostUsers.firstIndex(where: { $0.uid == viewModel.topPosts[indexPath.row].uid }) {
                            cell.set(user: viewModel.topPostUsers[userIndex])
                        }
                        if indexPath.row == viewModel.topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                    case .textWithTwoImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                        cell.viewModel = PostViewModel(post: viewModel.topPosts[indexPath.row])
                        if let userIndex = viewModel.topPostUsers.firstIndex(where: { $0.uid == viewModel.topPosts[indexPath.row].uid }) {
                            cell.set(user: viewModel.topPostUsers[userIndex])
                        }
                        if indexPath.row == viewModel.topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                    case .textWithThreeImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                        cell.viewModel = PostViewModel(post: viewModel.topPosts[indexPath.row])
                        if let userIndex = viewModel.topPostUsers.firstIndex(where: { $0.uid == viewModel.topPosts[indexPath.row].uid }) {
                            cell.set(user: viewModel.topPostUsers[userIndex])
                        }
                        if indexPath.row == viewModel.topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                    case .textWithFourImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                        cell.viewModel = PostViewModel(post: viewModel.topPosts[indexPath.row])
                        if let userIndex = viewModel.topPostUsers.firstIndex(where: { $0.uid == viewModel.topPosts[indexPath.row].uid }) {
                            cell.set(user: viewModel.topPostUsers[userIndex])
                        }
                        if indexPath.row == viewModel.topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                    }
                } else {
                    // Top Cases
                    switch viewModel.topCases[indexPath.row].kind {
                    case .text:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                        cell.viewModel = CaseViewModel(clinicalCase: viewModel.topCases[indexPath.row])
                        
                        if viewModel.topCases[indexPath.row].privacy == .anonymous {
                            cell.anonymize()
                        } else {
                            if let userIndex = viewModel.topCaseUsers.firstIndex(where: { $0.uid == viewModel.topCases[indexPath.row].uid }) {
                                cell.set(user: viewModel.topCaseUsers[userIndex])
                            }
                        }
                        
                        if indexPath.row == viewModel.topCases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                    case .image:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                        cell.viewModel = CaseViewModel(clinicalCase: viewModel.topCases[indexPath.row])
                        
                        if viewModel.topCases[indexPath.row].privacy == .anonymous {
                            cell.anonymize()
                        } else {
                            if let userIndex = viewModel.topCaseUsers.firstIndex(where: { $0.uid == viewModel.topCases[indexPath.row].uid }) {
                                cell.set(user: viewModel.topCaseUsers[userIndex])
                            }
                        }
                        
                        if indexPath.row == viewModel.topCases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                        cell.delegate = self
                        return cell
                        
                    }
                }
            }
            
        case .choose:
            if viewModel.networkIssue {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                switch viewModel.searchTopic {
                case .people:
                    if viewModel.topUsers.isEmpty {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                        cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Filters.emptyTitle, description: AppStrings.Content.Filters.emptyContent, content: .dismiss)
                        cell.delegate = self
                        return cell
                    } else {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowCellReuseIdentifier, for: indexPath) as! ConnectUserCell
                        cell.viewModel = ConnectViewModel(user: viewModel.topUsers[indexPath.row])
                        cell.connectionDelegate = self
                        return cell
                    }
                    
                case .posts:
                    if viewModel.topPosts.isEmpty {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                        cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Filters.emptyTitle, description: AppStrings.Content.Filters.emptyContent, content: .dismiss)
                        cell.delegate = self
                        return cell
                    } else {
                        switch viewModel.topPosts[indexPath.row].kind {
                        case .plainText:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTextCell
                            cell.viewModel = PostViewModel(post: viewModel.topPosts[indexPath.row])
                            if let userIndex = viewModel.topPostUsers.firstIndex(where: { $0.uid == viewModel.topPosts[indexPath.row].uid }) {
                                cell.set(user: viewModel.topPostUsers[userIndex])
                            }

                            cell.delegate = self
                            return cell
                        case .textWithImage:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                            cell.viewModel = PostViewModel(post: viewModel.topPosts[indexPath.row])
                            if let userIndex = viewModel.topPostUsers.firstIndex(where: { $0.uid == viewModel.topPosts[indexPath.row].uid }) {
                                cell.set(user: viewModel.topPostUsers[userIndex])
                            }

                            cell.delegate = self
                            return cell
                        case .textWithTwoImage:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                            cell.viewModel = PostViewModel(post: viewModel.topPosts[indexPath.row])
                            if let userIndex = viewModel.topPostUsers.firstIndex(where: { $0.uid == viewModel.topPosts[indexPath.row].uid }) {
                                cell.set(user: viewModel.topPostUsers[userIndex])
                            }

                            cell.delegate = self
                            return cell
                        case .textWithThreeImage:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                            cell.viewModel = PostViewModel(post: viewModel.topPosts[indexPath.row])
                            if let userIndex = viewModel.topPostUsers.firstIndex(where: { $0.uid == viewModel.topPosts[indexPath.row].uid }) {
                                cell.set(user: viewModel.topPostUsers[userIndex])
                            }
                            if indexPath.row == viewModel.topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }

                            return cell
                        case .textWithFourImage:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                            cell.viewModel = PostViewModel(post: viewModel.topPosts[indexPath.row])
                            if let userIndex = viewModel.topPostUsers.firstIndex(where: { $0.uid == viewModel.topPosts[indexPath.row].uid }) {
                                cell.set(user: viewModel.topPostUsers[userIndex])
                            }
                            if indexPath.row == viewModel.topPosts.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                            cell.delegate = self
                            return cell
                        }
                    }
                    
                case .cases:
                    if viewModel.topCases.isEmpty {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                        cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Filters.emptyTitle, description: AppStrings.Content.Filters.emptyContent, content: .dismiss)
                        cell.delegate = self
                        return cell
                    } else {
                        switch viewModel.topCases[indexPath.row].kind {
                        case .text:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                            cell.viewModel = CaseViewModel(clinicalCase: viewModel.topCases[indexPath.row])
                            
                            if viewModel.topCases[indexPath.row].privacy == .anonymous {
                                cell.anonymize()
                            } else {
                                if let userIndex = viewModel.topCaseUsers.firstIndex(where: { $0.uid == viewModel.topCases[indexPath.row].uid }) {
                                    cell.set(user: viewModel.topCaseUsers[userIndex])
                                }
                            }
                            
                            if indexPath.row == viewModel.topCases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                            cell.delegate = self
                            return cell
                        case .image:
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                            cell.viewModel = CaseViewModel(clinicalCase: viewModel.topCases[indexPath.row])
                            
                            if viewModel.topCases[indexPath.row].privacy == .anonymous {
                                cell.anonymize()
                            } else {
                                if let userIndex = viewModel.topCaseUsers.firstIndex(where: { $0.uid == viewModel.topCases[indexPath.row].uid }) {
                                    cell.set(user: viewModel.topCaseUsers[userIndex])
                                }
                            }
                            
                            if indexPath.row == viewModel.topCases.count - 1 { cell.actionButtonsView.separatorView.isHidden = true } else { cell.actionButtonsView.separatorView.isHidden = false }
                            cell.delegate = self
                            return cell
                        }
                    }
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch viewModel.searchMode {
            
        case .discipline:
            if indexPath.section == 0 {
                guard !viewModel.users.isEmpty else { return }
                let controller = UserProfileViewController(user: viewModel.users[indexPath.row])
                
                if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                    navVC.pushViewController(controller, animated: true)
                }
            }
        case .topic, .choose:
            switch viewModel.searchTopic {
                
            case .people:
                guard !viewModel.topUsers.isEmpty else { return }
                let controller = UserProfileViewController(user: viewModel.topUsers[indexPath.row])
                
                if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                    navVC.pushViewController(controller, animated: true)
                    DatabaseManager.shared.addRecentUserSearches(withUid: viewModel.topUsers[indexPath.row].uid!)
                }
            case .posts, .cases:
                break
            }
        }
    }
}

extension SearchResultsUpdatingViewController: PrimarySearchHeaderDelegate {
    func didTapSeeAll(_ header: UICollectionReusableView) {
        
        switch viewModel.searchMode {
            
        case .discipline, .choose:
            break
        case .topic:
            if header.tag == 0 {
                // People
                if let searchViewController = presentingViewController as? SearchViewController,  let navVC = searchViewController.navigationController, let user = searchViewController.getCurrentUser() {
                    let controller = FindConnectionsViewController(user: user)
                    controller.title = AppStrings.Content.Search.whoToFollow
                    navVC.pushViewController(controller, animated: true)
                }
                
            } else if header.tag == 1 {
                // Posts
                if let searchViewController = presentingViewController as? SearchViewController,  let navVC = searchViewController.navigationController, let discipline = searchToolbar.getDiscipline() {
                    let controller = HomeViewController(source: .search, discipline: discipline)
                    controller.controllerIsBeeingPushed = true
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


extension SearchResultsUpdatingViewController: ConnectUserCellDelegate {
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
                        strongSelf.userDidChangeConnection(uid: user.uid!, phase: .withdraw)
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
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
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
            
            switch viewModel.searchMode {
            case .discipline:
                return
            case .topic:
                section = 1
            case .choose:
                section = 0
            }
            
            if let index = viewModel.topPosts.firstIndex(where: { $0.postId == post.postId }) {
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
        let post = viewModel.topPosts[indexPath.row]
        if let index = viewModel.topPostUsers.firstIndex(where: { $0.uid! == post.uid }) {
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                let controller = DetailsPostViewController(post: post, user: viewModel.topPostUsers[index], collectionViewLayout: layout)
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
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
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
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
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
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
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
            
            switch viewModel.searchMode {
            case .discipline:
                return
            case .topic:
                section = 2
            case .choose:
                section = 0
            }
            
            if let index = viewModel.topCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
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
        if let userIndex = viewModel.topCaseUsers.firstIndex(where: { $0.uid == clinicalCase.uid }) {
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: viewModel.topCaseUsers[userIndex])
            
            if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                navVC.pushViewController(controller, animated: true)
            }
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let clinicalCase = viewModel.topCases[indexPath.row]
        
        self.navigationController?.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        switch clinicalCase.privacy {
            
        case .regular:
            if let index = viewModel.topCaseUsers.firstIndex(where: { $0.uid! == clinicalCase.uid }) {
                let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: viewModel.topCaseUsers[index], collectionViewFlowLayout: layout)
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
                    strongSelf.viewModel.users.removeAll()
                    strongSelf.viewModel.searches.removeAll()
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
        let didLike = viewModel.topPosts[indexPath.row].didLike
        postDidChangeLike(postId: postId, didLike: didLike)

        // Toggle the like state and count
        cell.viewModel?.post.didLike.toggle()
        viewModel.topPosts[indexPath.row].didLike.toggle()
        
        cell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        viewModel.topPosts[indexPath.row].likes = post.didLike ? post.likes - 1 : post.likes + 1
    }
    
    func handleBookmarkUnbookmark(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        let postId = post.postId
        let didBookmark = viewModel.topPosts[indexPath.row].didBookmark
        postDidChangeBookmark(postId: postId, didBookmark: didBookmark)
        
        // Toggle the bookmark state
        cell.viewModel?.post.didBookmark.toggle()
        viewModel.topPosts[indexPath.row].didBookmark.toggle()
        
    }
}

//MARK: - Case Miscellaneous

extension SearchResultsUpdatingViewController {
    
    private func handleLikeUnlike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didLike = viewModel.topCases[indexPath.row].didLike
        caseDidChangeLike(caseId: caseId, didLike: didLike)
        
        // Toggle the like state and count
        cell.viewModel?.clinicalCase.didLike.toggle()
        viewModel.topCases[indexPath.row].didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        viewModel.topCases[indexPath.row].likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        
    }
    
    func handleBookmarkUnbookmark(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didBookmark = viewModel.topCases[indexPath.row].didBookmark
        caseDidChangeBookmark(caseId: caseId, didBookmark: didBookmark)
        
        // Toggle the bookmark state
        cell.viewModel?.clinicalCase.didBookmark.toggle()
        viewModel.topCases[indexPath.row].didBookmark.toggle()
        
    }
}

extension SearchResultsUpdatingViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        
        viewModel.networkIssue = false
        
        switch viewModel.searchMode {
            
        case .discipline:
            viewModel.dataLoaded = false
            collectionView.reloadData()
            fetchRecentSearches()
        case .topic:
            if let discipline = searchToolbar.getDiscipline() {
                activityIndicator.start()
                viewModel.dataLoaded = false
                collectionView.isHidden = true
                fetchTopFor(discipline: discipline)
            }
            
        case .choose:
            if let discipline = searchToolbar.getDiscipline() {
                activityIndicator.start()
                viewModel.dataLoaded = false
                collectionView.isHidden = true
                fetchContentFor(discipline: discipline, searchTopic: viewModel.searchTopic)
            }
        }
    }
}


extension SearchResultsUpdatingViewController: PostChangesDelegate {
    func postDidChangeComment(postId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }
    
    func postDidChangeVisible(postId: String) {
        viewModel.currentNotification = true
        ContentManager.shared.visiblePostChange(postId: postId)
    }
    
    @objc func postVisibleChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }

        var section = 0
        
        switch viewModel.searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? PostVisibleChange {
            if let index = viewModel.topPosts.firstIndex(where: { $0.postId == change.postId }) {
                viewModel.topPosts.remove(at: index)
                if viewModel.topPosts.isEmpty {
                    collectionView.reloadData()
                } else {
                    collectionView.deleteItems(at: [IndexPath(item: index, section: section)])
                }
            }
        }
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
        
        
        var section = 0
        
        switch viewModel.searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? PostLikeChange {
            if let index = viewModel.topPosts.firstIndex(where: { $0.postId == change.postId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? HomeCellProtocol {
                    
                    let likes = viewModel.topPosts[index].likes
                    
                    viewModel.topPosts[index].likes = change.didLike ? likes + 1 : likes - 1
                    viewModel.topPosts[index].didLike = change.didLike
                    
                    currentCell.viewModel?.post.didLike = change.didLike
                    currentCell.viewModel?.post.likes = change.didLike ? likes + 1 : likes - 1
                }
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
        
        var section = 0
        
        switch viewModel.searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        
        
        if let change = notification.object as? PostBookmarkChange {
            if let index = viewModel.topPosts.firstIndex(where: { $0.postId == change.postId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? HomeCellProtocol {
    
                    viewModel.topPosts[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.post.didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        
        var section = 0
        
        switch viewModel.searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? PostCommentChange {
            if let index = viewModel.topPosts.firstIndex(where: { $0.postId == change.postId }), change.path.isEmpty {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? HomeCellProtocol {
                    
                    let comments = viewModel.topPosts[index].numberOfComments

                    switch change.action {
                    case .add:
                        viewModel.topPosts[index].numberOfComments = comments + 1
                        currentCell.viewModel?.post.numberOfComments = comments + 1
                    case .remove:
                        viewModel.topPosts[index].numberOfComments = comments - 1
                        currentCell.viewModel?.post.numberOfComments = comments - 1
                    }
                }
            }
        }
    }
    
    @objc func postEditChange(_ notification: NSNotification) {
        var section = 0
        
        switch viewModel.searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 1
        case .choose:
            section = 0
        }
        if let change = notification.object as? PostEditChange {
            let post = change.post
            
            if let index = viewModel.topPosts.firstIndex(where: { $0.postId == post.postId }) {
                viewModel.topPosts[index] = post
                collectionView.reloadItems(at: [IndexPath(item: index, section: section)])
            }
        }
    }
}

extension SearchResultsUpdatingViewController: CaseChangesDelegate {
   
    func caseDidChangeVisible(caseId: String) {
        viewModel.currentNotification = true
        ContentManager.shared.visibleCaseChange(caseId: caseId)
    }
    
    @objc func caseVisibleChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }

        var section = 0
        
        switch viewModel.searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? CaseVisibleChange {
            if let index = viewModel.topCases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.topCases.remove(at: index)
                if viewModel.topCases.isEmpty {
                    collectionView.reloadData()
                } else {
                    collectionView.deleteItems(at: [IndexPath(item: index, section: section)])
                }
            }
        }
    }
    
    func caseDidChangeLike(caseId: String, didLike: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.likeCaseChange(caseId: caseId, didLike: !didLike)
    }
    
    func caseDidChangeBookmark(caseId: String, didBookmark: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.bookmarkCaseChange(caseId: caseId, didBookmark: !didBookmark)
    }

    func caseDidChangeComment(caseId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }
    
    @objc func caseLikeChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        
        var section = 0
        
        switch viewModel.searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? CaseLikeChange {
            if let index = viewModel.topCases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? CaseCellProtocol {
                    
                    let likes = viewModel.topCases[index].likes
                    
                    viewModel.topCases[index].likes = change.didLike ? likes + 1 : likes - 1
                    viewModel.topCases[index].didLike = change.didLike
                    
                    currentCell.viewModel?.clinicalCase.didLike = change.didLike
                    currentCell.viewModel?.clinicalCase.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        var section = 0
        
        switch viewModel.searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? CaseBookmarkChange {
            if let index = viewModel.topCases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? CaseCellProtocol {
                    
                    viewModel.topCases[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.clinicalCase.didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            
            var section = 0
            
            switch viewModel.searchMode {
                
            case .discipline:
                break
            case .topic:
                section = 2
            case .choose:
                section = 0
            }
            
            if let index = viewModel.topCases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.revision = .update
                    viewModel.topCases[index].revision = .update
                    collectionView.reloadData()
                }
            }
        }
    }
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        
        var section = 0
        
        switch viewModel.searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? CaseCommentChange {
            if let index = viewModel.topCases.firstIndex(where: { $0.caseId == change.caseId }), change.path.isEmpty {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? CaseCellProtocol {
                    
                    let comments = viewModel.topCases[index].numberOfComments
                    
                    switch change.action {
                    case .add:
                        viewModel.topCases[index].numberOfComments = comments + 1
                        currentCell.viewModel?.clinicalCase.numberOfComments = comments + 1
                    case .remove:
                        viewModel.topCases[index].numberOfComments = comments - 1
                        currentCell.viewModel?.clinicalCase.numberOfComments = comments - 1
                    }
                }
            }
        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        
        var section = 0
        
        switch viewModel.searchMode {
            
        case .discipline:
            break
        case .topic:
            section = 2
        case .choose:
            section = 0
        }
        
        if let change = notification.object as? CaseSolveChange {
            if let index = viewModel.topCases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)) as? CaseCellProtocol  {
                    
                    cell.viewModel?.clinicalCase.phase = .solved
                    viewModel.topCases[index].phase = .solved
                    
                    if let diagnosis = change.diagnosis {
                        viewModel.topCases[index].revision = diagnosis
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
            
            if let postIndex = viewModel.topPostUsers.firstIndex(where: { $0.uid! == user.uid! }) {
                viewModel.topPostUsers[postIndex] = user
                collectionView.reloadData()
            }
            
            if let caseIndex = viewModel.topCaseUsers.firstIndex(where: { $0.uid! == user.uid!}) {
                viewModel.topCaseUsers[caseIndex] = user
                collectionView.reloadData()
            }
            
            if let caseIndex = viewModel.users.firstIndex(where: { $0.uid! == user.uid!}) {
                viewModel.users[caseIndex] = user
                collectionView.reloadData()
            }
        }
    }
}

extension SearchResultsUpdatingViewController: UserConnectDelegate {
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
            if let index = viewModel.topUsers.firstIndex(where: { $0.uid! == change.uid }) {
                viewModel.topUsers[index].editConnectionPhase(phase: change.phase)
                collectionView.reloadData()
            }
        }
    }
}
