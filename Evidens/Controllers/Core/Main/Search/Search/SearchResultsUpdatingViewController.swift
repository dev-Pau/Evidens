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
private let recentSearchTextCellReuseIdentifier = "RecentSearchTextCellReuseIdentifier"
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
    func didTapRecents(_ text: String)
    func didTapSearchDiscipline(_ discipline: Discipline)
    func didTapSearchTopic(_ searchTopic: SearchTopics)
    func dismissKeyboard()
}

class SearchResultsUpdatingViewController: UIViewController, UINavigationControllerDelegate {
    
    private var viewModel = SearchResultsUpdatingViewModel()

    weak var searchResultsDelegate: SearchResultsUpdatingViewControllerDelegate?
    
    private var searchMode: SearchMode = .recents {
        didSet {
            searchCollectionView.isHidden = searchMode == .search
        }
    }
    
    private var zoomTransitioning = ZoomTransitioning()
    private let referenceMenu = ReferenceMenu()
    
    private var searchToolbar = SearchToolbar()

     private let scrollView: UIScrollView = {
         let scrollView = UIScrollView()
         scrollView.translatesAutoresizingMaskIntoConstraints = false
         scrollView.showsHorizontalScrollIndicator = false
         scrollView.isPagingEnabled = true
         scrollView.bounces = false
         scrollView.backgroundColor = .systemBackground
         return scrollView
     }()

    private lazy var searchCollectionView: UICollectionView = {
        let layout = createSearchLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var featuredCollectionView: UICollectionView = {
        let layout = createFeaturedLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var peopleCollectionView: UICollectionView = {
        let layout = createPeopleLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var postsCollectionView: UICollectionView = {
        let layout = createPostsLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

    private lazy var casesCollectionView: UICollectionView = {
        let layout = createCasesLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
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
        if !viewModel.searchLoaded { fetchRecentSearches() }
    }
    
    private func fetchRecentSearches() {
        viewModel.getRecentSearches { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.searchCollectionView.reloadData()
        }
    }
    
    private func createSearchLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env -> NSCollectionLayoutSection? in
            guard let strongSelf = self else { return nil }
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10)
            
            if sectionNumber == 0 {
                
                switch strongSelf.searchMode {
                    
                case .recents:
                    
                    if strongSelf.viewModel.users.isEmpty && strongSelf.viewModel.searches.isEmpty {
                        
                        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension:  .absolute(55))
                        let item = NSCollectionLayoutItem(layoutSize: size)
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
                        let section = NSCollectionLayoutSection(group: group)
                        
                        if !strongSelf.viewModel.searchLoaded { section.boundarySupplementaryItems = [header] }
                        
                        return section
                    } else {
                        let emptyUsers = strongSelf.viewModel.users.isEmpty
                        
                        let size = NSCollectionLayoutSize(widthDimension: emptyUsers ? .fractionalWidth(1) : .absolute(100), heightDimension: .absolute(80))
                        
                        let item = NSCollectionLayoutItem(layoutSize: size)
                        item.contentInsets.top = 10
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

                        let section = NSCollectionLayoutSection(group: group)
                        section.orthogonalScrollingBehavior = emptyUsers ? .none : .continuous
                        section.boundarySupplementaryItems = [header]
                        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                        return section
                    }
                case .keyword:
                    let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
                    let item = NSCollectionLayoutItem(layoutSize: size)
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    
                    return section
                    
                case .search:
                    return nil
                }
            } else {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                switch strongSelf.searchMode {
                    
                case .recents:
                    section.contentInsets.top = strongSelf.viewModel.users.isEmpty ? 0 : 10
                case .keyword:
                    section.contentInsets.top = strongSelf.viewModel.suggestions.isEmpty ? 0 : 10
                case .search:
                    break
                }
                
                return section
            }
        }
        
        return layout
    }
    
    private func createFeaturedLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env -> NSCollectionLayoutSection? in
            guard let strongSelf = self else { return nil }
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            let isEmpty = strongSelf.viewModel.topUsers.isEmpty && strongSelf.viewModel.topPosts.isEmpty && strongSelf.viewModel.topCases.isEmpty
            
            if sectionNumber == 0 {
                // People section
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: isEmpty ? 0 : 10, bottom: 0, trailing: isEmpty ? 0 : 10)
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: isEmpty ? .fractionalHeight(0.6) : .absolute(73)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                if !strongSelf.viewModel.topUsers.isEmpty || !strongSelf.viewModel.featuredLoaded { section.boundarySupplementaryItems = [header] }
                return section
                
            } else if sectionNumber == 1 {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                if !strongSelf.viewModel.topPosts.isEmpty { section.boundarySupplementaryItems = [header] }
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                if !strongSelf.viewModel.topCases.isEmpty { section.boundarySupplementaryItems = [header] }
                return section
            }
        }
        
        return layout
    }

    private func createPeopleLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env -> NSCollectionLayoutSection? in
            guard let strongSelf = self else { return nil }
            let isEmpty = strongSelf.viewModel.people.isEmpty
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: isEmpty ? 0 : 10, bottom: 0, trailing: isEmpty ? 0 : 10)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: isEmpty ? .fractionalHeight(0.6) : .absolute(73)), subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            if !strongSelf.viewModel.peopleLoaded { section.boundarySupplementaryItems = [header] }
            
            return section
        }
        return layout
    }
    
    private func createPostsLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env -> NSCollectionLayoutSection? in
            guard let strongSelf = self else { return nil }
            let isEmpty = strongSelf.viewModel.posts.isEmpty

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: isEmpty ? .fractionalHeight(1) : .estimated(300)))
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: isEmpty ? .fractionalHeight(0.6) : .estimated(300)), subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            if !strongSelf.viewModel.postsLoaded { section.boundarySupplementaryItems = [header] }
            return section
        }
        
        return layout
    }
    
    private func createCasesLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env -> NSCollectionLayoutSection? in
            guard let strongSelf = self else { return nil }
            let isEmpty = strongSelf.viewModel.cases.isEmpty

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: isEmpty ? .fractionalHeight(1) : .estimated(300)))
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: isEmpty ? .fractionalHeight(0.6) : .estimated(300)), subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            if !strongSelf.viewModel.casesLoaded { section.boundarySupplementaryItems = [header] }
            return section
        }
        
        return layout
    }
        
    private func configureUI() {
        searchToolbar.translatesAutoresizingMaskIntoConstraints = false

        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self

        featuredCollectionView.delegate = self
        featuredCollectionView.dataSource = self
        
        peopleCollectionView.delegate = self
        peopleCollectionView.dataSource = self
        
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        
        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
        
        searchCollectionView.backgroundColor = .systemBackground
        searchCollectionView.keyboardDismissMode = .onDrag
      
        peopleCollectionView.backgroundColor = .systemBackground
        peopleCollectionView.keyboardDismissMode = .onDrag
        
        postsCollectionView.backgroundColor = .systemBackground
        postsCollectionView.keyboardDismissMode = .onDrag
        
        casesCollectionView.backgroundColor = .systemBackground
        casesCollectionView.keyboardDismissMode = .onDrag
        
        searchCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        searchCollectionView.register(SearchRecentsHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchRecentsHeaderReuseIdentifier)

        searchCollectionView.register(EmptyRecentsSearchCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)

        searchCollectionView.register(RecentUserCell.self, forCellWithReuseIdentifier: recentSearchesUserCellReuseIdentifier)
        searchCollectionView.register(RecentSearchCell.self, forCellWithReuseIdentifier: recentContentSearchReuseIdentifier)
        searchCollectionView.register(RecentTextCell.self, forCellWithReuseIdentifier: recentSearchTextCellReuseIdentifier)
        
        featuredCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        featuredCollectionView.register(PrimarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: topHeaderReuseIdentifier)
        featuredCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier)
        
        featuredCollectionView.register(ConnectUserCell.self, forCellWithReuseIdentifier: whoToFollowCellReuseIdentifier)
        featuredCollectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        featuredCollectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        featuredCollectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        featuredCollectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        featuredCollectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        
        featuredCollectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        featuredCollectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        
       
        peopleCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        peopleCollectionView.register(ConnectUserCell.self, forCellWithReuseIdentifier: whoToFollowCellReuseIdentifier)
        peopleCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier)
        
        
        postsCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        postsCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier)
        postsCollectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        postsCollectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        postsCollectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        postsCollectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        postsCollectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        
        casesCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        casesCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier)
        casesCollectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        casesCollectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        
        view.addSubviews(searchToolbar, scrollView, searchCollectionView)
        scrollView.addSubviews(featuredCollectionView, peopleCollectionView, postsCollectionView, casesCollectionView)
       
        NSLayoutConstraint.activate([
            searchToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: searchToolbar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.frame.width + 10),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            searchCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            
            featuredCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            featuredCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            featuredCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            featuredCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            
            peopleCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            peopleCollectionView.leadingAnchor.constraint(equalTo: featuredCollectionView.trailingAnchor, constant: 10),
            peopleCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            peopleCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            
            postsCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            postsCollectionView.leadingAnchor.constraint(equalTo: peopleCollectionView.trailingAnchor, constant: 10),
            postsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            postsCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            
            casesCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            casesCollectionView.leadingAnchor.constraint(equalTo: postsCollectionView.trailingAnchor, constant: 10),
            casesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            casesCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
        
        scrollView.contentSize.width = view.frame.width * 4 + 10 * 4
        scrollView.delegate = self
       
        viewModel.delegate = self
        searchToolbar.toolbarDelegate = self
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

    private func searchWithText() {
         viewModel.searchTimer?.invalidate()
         
         Task {
             await viewModel.getFeaturedContentForText()
         }

        searchMode = .search
    }
    
    private func getPostCell(forPostSource posts: [Post], forUserSource users: [User], forCollectionView collectionView: UICollectionView, forIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        if posts.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Filters.emptyTitle, description: AppStrings.Content.Filters.emptyContent, content: .dismiss)
            cell.delegate = self
            return cell
        } else {
            switch posts[indexPath.row].kind {
            case .plainText:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTextCell
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
                if let userIndex = users.firstIndex(where: { $0.uid == posts[indexPath.row].uid }) {
                    cell.set(user: users[userIndex])
                }
                
                cell.delegate = self
                return cell
                
            case .textWithImage:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
                if let userIndex = users.firstIndex(where: { $0.uid == posts[indexPath.row].uid }) {
                    cell.set(user: users[userIndex])
                }
                
                cell.delegate = self
                return cell
                
            case .textWithTwoImage:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
                if let userIndex = users.firstIndex(where: { $0.uid == posts[indexPath.row].uid }) {
                    cell.set(user: users[userIndex])
                }
                
                cell.delegate = self
                return cell
            case .textWithThreeImage:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
                
                if let userIndex = users.firstIndex(where: { $0.uid == posts[indexPath.row].uid }) {
                    cell.set(user: users[userIndex])
                }
                
                cell.delegate = self
                return cell
            case .textWithFourImage:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
                if let userIndex = users.firstIndex(where: { $0.uid == posts[indexPath.row].uid }) {
                    cell.set(user: users[userIndex])
                }
                cell.delegate = self
                return cell
            }
        }
    }
    
    private func getCaseCell(forCaseSource cases: [Case], forUserSource users: [User], forCollectionView collectionView: UICollectionView, forIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        
        if cases.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Filters.emptyTitle, description: AppStrings.Content.Filters.emptyContent, content: .dismiss)
            cell.delegate = self
            return cell
        } else {
            switch cases[indexPath.row].kind {
            case .text:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                
                if cases[indexPath.row].privacy == .anonymous {
                    cell.anonymize()
                } else {
                    if let userIndex = users.firstIndex(where: { $0.uid == cases[indexPath.row].uid }) {
                        cell.set(user: users[userIndex])
                    }
                }
                
                cell.delegate = self
                return cell
                
            case .image:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                
                if cases[indexPath.row].privacy == .anonymous {
                    cell.anonymize()
                } else {
                    if let userIndex = users.firstIndex(where: { $0.uid == cases[indexPath.row].uid }) {
                        cell.set(user: users[userIndex])
                    }
                }
                
                cell.delegate = self
                return cell
            }
        }
    }

    private func resetData() {
        viewModel.reset()
        featuredCollectionView.reloadData()
        peopleCollectionView.reloadData()
        postsCollectionView.reloadData()
        casesCollectionView.reloadData()
        searchToolbar.collectionViewDidScroll(for: 0)
        viewModel.isFirstLoad = false
    }
}

extension SearchResultsUpdatingViewController: UISearchResultsUpdating, UISearchBarDelegate, UITextFieldDelegate {
    func updateSearchResults(for searchController: UISearchController) { }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchMode = .recents
        viewModel.searchedText = ""
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        //searchToolbar.selectFirstIndex()
        resetData()
        searchCollectionView.reloadData()
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.searchMode = .recents
            strongSelf.viewModel.searchedText = ""
            strongSelf.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            //strongSelf.searchToolbar.selectFirstIndex()
            strongSelf.resetData()
            strongSelf.searchCollectionView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            viewModel.searchTimer?.invalidate()
            searchMode = .recents
            viewModel.searchedText = ""
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            //searchToolbar.selectFirstIndex()
            resetData()
            searchCollectionView.reloadData()
            return
        }

        viewModel.searchedText = searchText.trimmingCharacters(in: .whitespaces)

        if searchMode == .search {
            searchMode = .keyword
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            resetData()
            searchCollectionView.reloadData()
        }
        
        searchMode = .keyword
        viewModel.searchTimer?.invalidate()

        viewModel.searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let strongSelf = self else { return }

            Task {
                
                await strongSelf.viewModel.getSuggestionsWithText()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        DatabaseManager.shared.addRecentSearch(with: text)

        searchWithText()
        
        if !viewModel.searches.contains(text) {
            viewModel.searches.insert(text, at: 0)
        }
    }
}

extension SearchResultsUpdatingViewController: SearchResultsUpdatingViewModelDelegate {

    func topResultsDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.featuredCollectionView.reloadData()
        }
    }
    
    func suggestionsDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.searchCollectionView.reloadData()
        }
    }
    
    func peopleDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.peopleCollectionView.reloadData()
        }
    }
    
    func postsDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.postsCollectionView.reloadData()
        }
    }
    
    func casesDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.casesCollectionView.reloadData()
        }
    }
}

extension SearchResultsUpdatingViewController: UIScrollViewDelegate {
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        let offset = scrollView.contentOffset
      
        if scrollView != searchCollectionView {
            searchResultsDelegate?.dismissKeyboard()
        }
        
        if scrollView.contentOffset.y != 0 {
            viewModel.isScrollingHorizontally = false
        }
        
        if scrollView.contentOffset.y == 0 && viewModel.isScrollingHorizontally {
            searchToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
        }
        
        if scrollView.contentOffset.y == 0 && !viewModel.isScrollingHorizontally {
            viewModel.isScrollingHorizontally = true
            return
        }
        
        if scrollView.contentOffset.x > view.frame.width * 0.2 && !viewModel.isFetchingOrDidFetchPeople {
            Task { try await viewModel.searchPeople() }
        }
        
        if scrollView.contentOffset.x > view.frame.width * 1.2 && !viewModel.isFetchingOrDidFetchPosts {
            Task { try await viewModel.searchPosts() }
        }
        
        if scrollView.contentOffset.x > view.frame.width * 2.2 && !viewModel.isFetchingOrDidFetchCases {
            Task { try await viewModel.searchCases() }
        }

        switch scrollView.contentOffset.x {
        case 0 ..< view.frame.width + 10:
            if viewModel.isScrollingHorizontally { viewModel.scrollIndex = 0 }
        case view.frame.width + 10 ..< 2 * (view.frame.width + 10):
            if viewModel.isScrollingHorizontally { viewModel.scrollIndex = 1 }
        case 2 * (view.frame.width + 10) ..< 3 * (view.frame.width + 10):
            if viewModel.isScrollingHorizontally { viewModel.scrollIndex = 2 }
        default:
            if viewModel.isScrollingHorizontally { viewModel.scrollIndex = 3 }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        featuredCollectionView.isScrollEnabled = true
        peopleCollectionView.isScrollEnabled = true
        postsCollectionView.isScrollEnabled = true
        casesCollectionView.isScrollEnabled = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard searchMode == .search else { return }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            #warning("Fetch More")
            //if let discipline = searchToolbar.getDiscipline() {
              //  fetchMoreContent(discipline: discipline)
           // }
            
        }
    }
}


extension SearchResultsUpdatingViewController: SearchToolbarDelegate {
    
    func didTapIndex(_ index: Int) {
        scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width) + 10 * index, y: 0), animated: true)
        viewModel.scrollIndex = index
        
        guard viewModel.isFirstLoad else {
            viewModel.isFirstLoad.toggle()
            return
        }
        
        featuredCollectionView.isScrollEnabled = false
        peopleCollectionView.isScrollEnabled = false
        postsCollectionView.isScrollEnabled = false
        casesCollectionView.isScrollEnabled = false
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
                    
                    
                    #warning("veure com eliminem")
                    strongSelf.viewModel.topPosts.remove(at: indexPath.item)
                    if strongSelf.viewModel.topPosts.isEmpty {
                        //strongSelf.collectionView.reloadData()
                    } else {
                        //strongSelf.collectionView.deleteItems(at: [indexPath])
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
                        #warning("veure com eliminem")
                        //strongSelf.collectionView.reloadData()
                    } else {
                        //strongSelf.collectionView.deleteItems(at: [indexPath])
                    }
                }
            }
        }
    }
}

extension SearchResultsUpdatingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == searchCollectionView {
            switch searchMode {
            case .recents:
                return viewModel.searchLoaded ? (viewModel.searches.isEmpty && viewModel.users.isEmpty) ? 1 : 2 : 1
            case .keyword:
                return 2
            case .search:
                return 0
            }
        } else if collectionView == featuredCollectionView {
            return viewModel.topUsers.isEmpty && viewModel.topPosts.isEmpty && viewModel.topCases.isEmpty ? 1 : 3
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == searchCollectionView {
            switch searchMode {
            case .recents:
                
                if viewModel.searchLoaded {
                    if viewModel.searches.isEmpty && viewModel.users.isEmpty {
                        return 1
                    } else {
                        return section == 0 ? viewModel.users.count : viewModel.searches.count
                    }
                } else {
                    return 0
                }
            case .keyword:
                return section == 0 ? viewModel.suggestions.count : 1
            case .search:
                return 0
            }
        } else if collectionView == featuredCollectionView {

            if !viewModel.featuredLoaded {
                return 0
            } else {
                if viewModel.featuredNetwork || viewModel.topUsers.isEmpty && viewModel.topPosts.isEmpty && viewModel.topCases.isEmpty {
                    return 1
                } else {
                    if section == 0 {
                        return viewModel.topUsers.count
                    } else if section == 1 {
                        return viewModel.topPosts.count
                    } else {
                        return viewModel.topCases.count
                    }
                }
            }
        } else if collectionView == peopleCollectionView {
            return viewModel.peopleLoaded ? viewModel.peopleNetwork ? 1 : viewModel.people.isEmpty ? 1 : viewModel.people.count : 0
        } else if collectionView == postsCollectionView {
            return viewModel.postsLoaded ? viewModel.postsNetwork ? 1 : viewModel.posts.isEmpty ? 1 : viewModel.posts.count : 0
        } else {
            return viewModel.casesLoaded ? viewModel.casesNetwork ? 1 : viewModel.cases.isEmpty ? 1 : viewModel.cases.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == searchCollectionView {
            if viewModel.searchLoaded {
                switch searchMode {
                    
                case .recents:
                    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchRecentsHeaderReuseIdentifier, for: indexPath) as! SearchRecentsHeader
                    header.delegate = self
                    return header
                case .keyword:
                    fatalError()
                case .search:
                    fatalError()
                }
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            }
        } else if collectionView == featuredCollectionView {
            if viewModel.featuredLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: topHeaderReuseIdentifier, for: indexPath) as! PrimarySearchHeader
                header.delegate = self
                header.tag = indexPath.section
                
                if indexPath.section == 0 {
                    header.configureWith(title: AppStrings.Search.Topics.people, linkText: AppStrings.Content.Search.seeAll)
                    viewModel.topUsers.count >= 3 ? header.hideSeeAllButton(false) : header.hideSeeAllButton(true)
                } else if indexPath.section == 1 {
                    header.configureWith(title: AppStrings.Search.Topics.posts, linkText: AppStrings.Content.Search.seeAll)
                    viewModel.topPosts.count >= 3 ? header.hideSeeAllButton(false) : header.hideSeeAllButton(true)
                } else {
                    header.configureWith(title: AppStrings.Search.Topics.cases, linkText: AppStrings.Content.Search.seeAll)
                    viewModel.topCases.count >= 3 ? header.hideSeeAllButton(false) : header.hideSeeAllButton(true)
                }
                
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            }
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == searchCollectionView {
            switch searchMode {
                
            case .recents:
                
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
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentSearchTextCellReuseIdentifier, for: indexPath) as! RecentTextCell
                            cell.viewModel = RecentTextViewModel(recentText: viewModel.searches[indexPath.row])
                            return cell
                        }
                }
                
            case .keyword:
                if indexPath.section == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentContentSearchReuseIdentifier, for: indexPath) as! RecentSearchCell
                    cell.viewModel = RecentTextViewModel(recentText: viewModel.suggestions[indexPath.row].name)
                    cell.searchedText = viewModel.searchedText.trimmingCharacters(in: .whitespaces)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentSearchTextCellReuseIdentifier, for: indexPath) as! RecentTextCell
                    cell.viewModel = RecentTextViewModel(recentText: "\(AppStrings.Content.Search.search) \"\(viewModel.searchedText.trimmingCharacters(in: .whitespaces))\"")
                    return cell
                }
            case .search:
                fatalError()
            }
            
        } else if collectionView == featuredCollectionView {
            
            if viewModel.topUsers.isEmpty && viewModel.topPosts.isEmpty && viewModel.topCases.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Filters.emptyTitle, description: AppStrings.Content.Filters.emptyContent, content: .dismiss)
                cell.delegate = self
                return cell
            } else {
                if indexPath.section == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowCellReuseIdentifier, for: indexPath) as! ConnectUserCell
                    cell.viewModel = ConnectViewModel(user: viewModel.topUsers[indexPath.row])
                    cell.connectionDelegate = self
                    return cell
                    
                } else if indexPath.section == 1 {
                    return getPostCell(forPostSource: viewModel.topPosts, forUserSource: viewModel.topPostUsers, forCollectionView: collectionView, forIndexPath: indexPath)
                } else {
                    return getCaseCell(forCaseSource: viewModel.topCases, forUserSource: viewModel.topCaseUsers, forCollectionView: collectionView, forIndexPath: indexPath)
                }
            }
            
        } else if collectionView == peopleCollectionView {
            // People
            if viewModel.people.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCategoriesTopicsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Filters.emptyTitle, description: AppStrings.Content.Filters.emptyContent, content: .dismiss)
                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowCellReuseIdentifier, for: indexPath) as! ConnectUserCell
                cell.viewModel = ConnectViewModel(user: viewModel.people[indexPath.row])
                cell.connectionDelegate = self
                return cell
            }

        } else if collectionView == postsCollectionView {
            // Posts
            return getPostCell(forPostSource: viewModel.posts, forUserSource: viewModel.postUsers, forCollectionView: collectionView, forIndexPath: indexPath)
        } else {
            // Cases
            return getCaseCell(forCaseSource: viewModel.cases, forUserSource: viewModel.caseUsers, forCollectionView: collectionView, forIndexPath: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == searchCollectionView {
            switch searchMode {
                
            case .recents:
                if indexPath.section == 0 {
                    guard !viewModel.users.isEmpty else { return }
                    let controller = UserProfileViewController(user: viewModel.users[indexPath.row])
                    
                    if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                        navVC.pushViewController(controller, animated: true)
                    }
                } else {
                    guard !viewModel.searches.isEmpty else { return }
                    
                    viewModel.searchedText = viewModel.searches[indexPath.row]
                    searchWithText()
                    searchResultsDelegate?.didTapRecents(viewModel.searchedText)
                }
            case .keyword:
                var text = ""
                
                if indexPath.section == 0 {
                    guard !viewModel.suggestions.isEmpty else { return }
                    text = viewModel.suggestions[indexPath.row].name
                } else {
                    text = viewModel.searchedText
                }

                searchMode = .search
                searchWithText()

                searchResultsDelegate?.didTapRecents(text)
            case .search:
                fatalError()
            }
        } else if collectionView == featuredCollectionView {
            guard indexPath.section == 0, !viewModel.topUsers.isEmpty else {
                return
            }
            
            let controller = UserProfileViewController(user: viewModel.topUsers[indexPath.row])
            if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                navVC.pushViewController(controller, animated: true)
                DatabaseManager.shared.addRecentUserSearches(withUid: viewModel.topUsers[indexPath.row].uid!)
            }
        } else if collectionView == peopleCollectionView {
            guard !viewModel.people.isEmpty else { return }
            let controller = UserProfileViewController(user: viewModel.people[indexPath.row])
            
            if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
                navVC.pushViewController(controller, animated: true)
                DatabaseManager.shared.addRecentUserSearches(withUid: viewModel.people[indexPath.row].uid!)
            }
        }
    }
}

extension SearchResultsUpdatingViewController: PrimarySearchHeaderDelegate {
    func didTapSeeAll(_ header: UICollectionReusableView) {
        if header.tag == 0 {
            scrollView.setContentOffset(CGPoint(x: view.frame.width + 10, y: 0), animated: true)
        } else if header.tag == 1 {
            scrollView.setContentOffset(CGPoint(x: 2 * (view.frame.width + 10), y: 0), animated: true)
        } else {
            scrollView.setContentOffset(CGPoint(x: 3 * (view.frame.width + 10), y: 0), animated: true)
        }
    }
}

extension SearchResultsUpdatingViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        
    }
}


extension SearchResultsUpdatingViewController: ConnectUserCellDelegate {
    func didConnect(_ cell: UICollectionViewCell, connection: UserConnection) {
        guard let cell = cell as? ConnectUserCell, let searchViewController = presentingViewController as? SearchViewController else { return }

        guard let tab = searchViewController.tabBarController as? MainTabController, let currentUser = tab.user else { return }

        var collectionView: UICollectionView?
        var user: User?
        
        switch viewModel.scrollIndex {
        case 0:
            collectionView = featuredCollectionView
            if let indexPath = featuredCollectionView.indexPath(for: cell) {
                user = viewModel.topUsers[indexPath.row]
            }
        case 1:
            collectionView = peopleCollectionView
            if let indexPath = peopleCollectionView.indexPath(for: cell) {
                user = viewModel.people[indexPath.row]
            }
        default:
            break
        }
        
        #warning("falta acabar")
        guard let collectionView = collectionView, let user = user else { return }
        
        print(user.name())
  
        /*
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
         */
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
        switch viewModel.scrollIndex {
        case 0:
            guard let indexPath = featuredCollectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
            handleLikeUnLike(for: currentCell, at: indexPath)
        case 2:
            guard let indexPath = postsCollectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
            handleLikeUnLike(for: currentCell, at: indexPath)
        default:
            break
        }
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
            case .recents:
                return
            case .keyword:
                section = 1
            case .search:
                section = 0
            }
    #warning("falta implementar esborrar")
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
        switch viewModel.scrollIndex {
        case 0:
            guard let indexPath = featuredCollectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
            handleBookmarkUnbookmark(for: currentCell, at: indexPath)
        case 2:
            guard let indexPath = postsCollectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
            handleBookmarkUnbookmark(for: currentCell, at: indexPath)
        default:
            break
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        if let searchViewController = presentingViewController as? SearchViewController, let navVC = searchViewController.navigationController {
            switch viewModel.scrollIndex {
            case 0:
                guard let indexPath = featuredCollectionView.indexPath(for: cell) else { return }
                let post = viewModel.topPosts[indexPath.row]
                
                if let index = viewModel.topPostUsers.firstIndex(where: { $0.uid! == post.uid }) {
                    let controller = DetailsPostViewController(post: post, user: viewModel.topPostUsers[index], collectionViewLayout: layout)
                    navVC.pushViewController(controller, animated: true)
                }
            case 2:
                guard let indexPath = postsCollectionView.indexPath(for: cell) else { return }
                let post = viewModel.posts[indexPath.row]
                
                if let index = viewModel.postUsers.firstIndex(where: { $0.uid! == post.uid }) {
                    let controller = DetailsPostViewController(post: post, user: viewModel.postUsers[index], collectionViewLayout: layout)
                    navVC.pushViewController(controller, animated: true)
                }

            default:
                break
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
        print("can be main or cases collectionView")
        //guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
        //handleLikeUnlike(for: currentCell, at: indexPath)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        print("can be main or cases collectionView")
        //guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
        //handleBookmarkUnbookmark(for: currentCell, at: indexPath)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete:
            
            var section = 0
            
            switch searchMode {
            case .recents:
                return
            case .keyword:
                section = 2
            case .search:
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
        /*
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
         */
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
                    strongSelf.searchCollectionView.reloadData()
                }
            }
        }
    }
}

//MARK: Post Miscellaneous

extension SearchResultsUpdatingViewController {
    
    private func handleLikeUnLike(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        cell.viewModel?.post.didLike.toggle()
        cell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        
        let postId = post.postId
        
        var didLike: Bool?
        
        switch viewModel.scrollIndex {
        case 0:
            didLike = viewModel.topPosts[indexPath.row].didLike
            viewModel.topPosts[indexPath.row].didLike.toggle()
            viewModel.topPosts[indexPath.row].likes = post.didLike ? post.likes - 1 : post.likes + 1
            
            if let index = viewModel.posts.firstIndex(where: { $0.postId == postId }) {
                let likes = viewModel.posts[index].likes
                
                viewModel.posts[index].likes = post.didLike ? likes - 1 : likes + 1
                viewModel.posts[index].didLike = !post.didLike
                postsCollectionView.reloadData()
            }
            
        case 2:
            didLike = viewModel.posts[indexPath.row].didLike
            viewModel.posts[indexPath.row].didLike.toggle()
            viewModel.posts[indexPath.row].likes = post.didLike ? post.likes - 1 : post.likes + 1
            
            if let index = viewModel.topPosts.firstIndex(where: { $0.postId == postId }) {
                
                let likes = viewModel.topPosts[index].likes
                
                viewModel.topPosts[index].likes = post.didLike ? likes - 1 : likes + 1
                viewModel.topPosts[index].didLike = !post.didLike
                featuredCollectionView.reloadData()
            }
        default:
            break
        }
        
        guard let didLike = didLike else { return }
        
        postDidChangeLike(postId: postId, didLike: didLike)
    }
    
    func handleBookmarkUnbookmark(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        cell.viewModel?.post.didBookmark.toggle()
        
        let postId = post.postId
        
        var didBookmark: Bool?
        
        switch viewModel.scrollIndex {
        case 0:
            didBookmark = viewModel.topPosts[indexPath.row].didBookmark
            viewModel.topPosts[indexPath.row].didBookmark.toggle()
            
            if let index = viewModel.posts.firstIndex(where: { $0.postId == postId }) {
                viewModel.posts[index].didBookmark = !post.didBookmark
                postsCollectionView.reloadData()
            }
        case 2:
            didBookmark = viewModel.posts[indexPath.row].didBookmark
            viewModel.posts[indexPath.row].didBookmark.toggle()
            
            if let index = viewModel.topPosts.firstIndex(where: { $0.postId == postId }) {
                viewModel.topPosts[index].didBookmark = !post.didBookmark
                featuredCollectionView.reloadData()
            }
        default:
            break
        }
        
        guard let didBookmark = didBookmark else { return }
        postDidChangeBookmark(postId: postId, didBookmark: didBookmark)
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
        /*
        viewModel.networkIssue = false
        
        switch viewModel.searchMode {
            
        case .recents:
            viewModel.dataLoaded = false
            collectionView.reloadData()
            fetchRecentSearches()
        case .keyword:
            if let discipline = searchToolbar.getDiscipline() {
                //activityIndicator.start()
                viewModel.dataLoaded = false
                collectionView.reloadData()
                //fkldjlkdsfjkl
                fetchTopFor(discipline: discipline)
            }
            
        case .choose:
            if let discipline = searchToolbar.getDiscipline() {
                //activityIndicator.start()
                viewModel.dataLoaded = false
                // dsljkfjklds
                collectionView.reloadData()
                fetchContentFor(discipline: discipline, searchTopic: viewModel.searchTopic)
            }
        }
         */
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
        #warning("here check both collectionviews that can have posts")
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }

        var section = 0
        
        switch searchMode {
            
        case .recents:
            break
        case .keyword:
            section = 1
        case .search:
            section = 0
        }
        
        if let change = notification.object as? PostVisibleChange {
            if let index = viewModel.topPosts.firstIndex(where: { $0.postId == change.postId }) {
                viewModel.topPosts.remove(at: index)
                if viewModel.topPosts.isEmpty {
                    //collectionView.reloadData()
                } else {
                    //collectionView.deleteItems(at: [IndexPath(item: index, section: section)])
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
        
        switch searchMode {
            
        case .recents:
            break
        case .keyword:
            section = 1
        case .search:
            section = 0
        }
        
        /*
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
         */
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
        
        switch searchMode {
            
        case .recents:
            break
        case .keyword:
            section = 1
        case .search:
            section = 0
        }
        
        /*
        if let change = notification.object as? PostBookmarkChange {
            if let index = viewModel.topPosts.firstIndex(where: { $0.postId == change.postId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? HomeCellProtocol {
    
                    viewModel.topPosts[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.post.didBookmark = change.didBookmark
                }
            }
        }
         */
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        
        var section = 0
        
        switch searchMode {
            
        case .recents:
            break
        case .keyword:
            section = 1
        case .search:
            section = 0
        }
        
        /*
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
         */
    }
    
    @objc func postEditChange(_ notification: NSNotification) {
        var section = 0
        
        switch searchMode {
            
        case .recents:
            break
        case .keyword:
            section = 1
        case .search:
            section = 0
        }
        /*
        if let change = notification.object as? PostEditChange {
            let post = change.post
            
            if let index = viewModel.topPosts.firstIndex(where: { $0.postId == post.postId }) {
                viewModel.topPosts[index] = post
                collectionView.reloadItems(at: [IndexPath(item: index, section: section)])
            }
        }
         */
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
        
        switch searchMode {
            
        case .recents:
            break
        case .keyword:
            section = 2
        case .search:
            section = 0
        }
        /*
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
         */
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
        
        switch searchMode {
            
        case .recents:
            break
        case .keyword:
            section = 2
        case .search:
            section = 0
        }
        
        /*
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
         */
    }
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        var section = 0
        
        switch searchMode {
            
        case .recents:
            break
        case .keyword:
            section = 2
        case .search:
            section = 0
        }
        
        /*
        if let change = notification.object as? CaseBookmarkChange {
            if let index = viewModel.topCases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)), let currentCell = cell as? CaseCellProtocol {
                    
                    viewModel.topCases[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.clinicalCase.didBookmark = change.didBookmark
                }
            }
        }
         */
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            
            var section = 0
            
            switch searchMode {
                
            case .recents:
                break
            case .keyword:
                section = 2
            case .search:
                section = 0
            }
            /*
            if let index = viewModel.topCases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.revision = .update
                    viewModel.topCases[index].revision = .update
                    collectionView.reloadData()
                }
            }
             */
        }
    }
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        
        var section = 0
        
        switch searchMode {
            
        case .recents:
            break
        case .keyword:
            section = 2
        case .search:
            section = 0
        }
        /*
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
         */
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        
        var section = 0
        
        switch searchMode {
            
        case .recents:
            break
        case .keyword:
            section = 2
        case .search:
            section = 0
        }
        
        /*
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
         */
    }
}

extension SearchResultsUpdatingViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
/*
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
 */
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
        /*
        if let change = notification.object as? UserConnectionChange {
            if let index = viewModel.topUsers.firstIndex(where: { $0.uid! == change.uid }) {
                viewModel.topUsers[index].editConnectionPhase(phase: change.phase)
                collectionView.reloadData()
            }
        }
         */
    }
}
