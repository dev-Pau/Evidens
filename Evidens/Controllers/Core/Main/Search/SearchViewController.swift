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

private let reuseIdentifier = "HomeTextCellReuseIdentifier"
private let homeImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let homeTwoImageTextCellReuseIdentifier = "HomeTwoImageTextCellReuseIdentifier"
private let homeThreeImageTextCellReuseIdentifier = "HomeThreeImageTextCellReuseIdentifier"
private let homeFourImageTextCellReuseIdentifier = "HomeFourImageTextCellReuseIdentifier"


private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"


class SearchViewController: NavigationBarViewController, UINavigationControllerDelegate {
    
    //MARK: - Properties
    
    /*
     private var recentSearchedText = [String]() {
     didSet {
     tableView.reloadData()
     }
     }
     
     private var loaded: Bool = false
     
     private var users = [User]()
     private var filteredUsers = [User]()
     */
    private var searchController: UISearchController!
    
    /*
     private var inSearchMode: Bool {
     return searchController.isActive && !searchController.searchBar.text!.isEmpty
     }
     */
    /*
     private let tableView: UITableView = {
     let tableView = UITableView(frame: CGRect(), style: .grouped)
     tableView.separatorColor = .clear
     return tableView
     }()
     */
    private var collectionView: UICollectionView!
    private var professions = Profession.getAllProfessions()
    private var users = [User]()
    private var posts = [Post]()
    private var postUsers = [User]()
    private var cases = [Case]()
    private var caseUsers = [User]()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         DispatchQueue.main.async {
         self.fetchRecents()
         }
         */
        //fetchRecents()
        
        //let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        //searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        //navigationItem.titleView = searchBarContainer
        //searchBar.becomeFirstResponder()
        //let navLabel = UILabel()
        //let navTitle = NSMutableAttributedString(string: "Search", attributes:[.font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)])
        //navLabel.attributedText = navTitle
        //navigationItem.titleView = navLabel
        
        configureNavigationBar()
        //configureTableView()
        configureUI()
        fetchUsers()
        fetchPosts()
        fetchCases()
        
    }
    
    /*
     //MARK: - API
     func fetchUsers() {
     UserService.fetchUsers { users in
     self.users = users
     self.tableView.reloadData()
     }
     }
     */
    
    private func fetchUsers() {
        UserService.fetchWhoToFollowUsers { users in
            self.users = users
            self.collectionView.reloadSections(IndexSet(integer: 2))
        }
    }
    
    private func fetchPosts() {
        PostService.fetchPostsForYou { posts in
            self.posts = posts
            let uids = posts.map { $0.ownerUid }
            UserService.fetchUsers(withUids: uids) { users in
                self.postUsers = users
                self.collectionView.reloadSections(IndexSet(integer: 3))
            }
        }
    }
    
    private func fetchCases() {
        CaseService.fetchCasesForYou { cases in
            self.cases = cases
            let uids = cases.map { $0.ownerUid }
            UserService.fetchUsers(withUids: uids) { users in
                self.caseUsers = users
                self.collectionView.reloadSections(IndexSet(integer: 4))
            }
        }
    }
    
    //MARK: - Helpers
    func configureNavigationBar() {
        title = "Search"
        let controller = SearchResultsUpdatingViewController()
        //controller.delegate = self
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
    
    private func configureUI() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "kek")
        collectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        collectionView.register(MainSearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: topHeaderReuseIdentifier)
        collectionView.register(YourNewsCell.self, forCellWithReuseIdentifier: newsForYouCellReuseIdentifier)
        collectionView.register(RecentNewsCell.self, forCellWithReuseIdentifier: recentNewsCellReuseIdentifier)
        collectionView.register(WhoToFollowCell.self, forCellWithReuseIdentifier: whoToFollowCellReuseIdentifier)
        
        collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        collectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        collectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        collectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        
        collectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection? in
            if sectionNumber == 0 {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))

                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .absolute(260)), subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                section.boundarySupplementaryItems = [header]
                return section
            } else if sectionNumber == 1 {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))

                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .absolute(100)), subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                section.boundarySupplementaryItems = [header]

                return section
            } else if sectionNumber == 2 {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))

                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65)), subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
                section.boundarySupplementaryItems = [header]

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
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
                section.boundarySupplementaryItems = [header]
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
            header.configureWith(title: "News for you", linkText: "See All")
            return header
        } else if indexPath.section == 1 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: topHeaderReuseIdentifier, for: indexPath) as! MainSearchHeader
            header.configureWith(title: "Latest news", linkText: "See All")
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
            if indexPath.section == 2 {
                header.configureWith(title: "Who to follow", linkText: "See All")
            } else if indexPath.section == 3 {
                header.configureWith(title: "Posts for you", linkText: "See All")
            } else {
                header.configureWith(title: "Cases for you", linkText: "See All")
            }

            return header
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 5
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
            return cell
        } else if indexPath.section == 1  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentNewsCellReuseIdentifier, for: indexPath) as! RecentNewsCell
            return cell
        } else if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowCellReuseIdentifier, for: indexPath) as! WhoToFollowCell
            cell.configureWithUser(user: users[indexPath.row])
            return cell
        } else if indexPath.section == 3 {
            if let index = postUsers.firstIndex(where:  { $0.uid == posts[indexPath.row].ownerUid }) {
                switch posts[indexPath.row].type {
                case .plainText:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: postUsers[index])
                    return cell
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeImageTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: postUsers[index])
                    return cell
                case .textWithTwoImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: postUsers[index])
                    return cell
                case .textWithThreeImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: postUsers[index])
                    return cell
                case .textWithFourImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: postUsers[index])
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
                    //cell.delegate = self
                    return cell
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    cell.set(user: caseUsers[index])
                    //cell.delegate = self
                    return cell
                }
            }
        }
        return UICollectionViewCell()
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
