//
//  SearchViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

private let reuseIdentifier = "RecentUserCell"
private let recentTextReuseIdentifier = "RecentTextCell"
private let recentHeaderReuseIdentifier = "RecentHeaderCell"

class SearchViewController: UIViewController {
    
    //MARK: - Properties
    
    private var recentSearchedText = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var users = [User]()
    private var filteredUsers = [User]()
    
    lazy var searchController = UISearchController(searchResultsController: nil)

    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }

    private let tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .grouped)
        tableView.separatorColor = .clear
        return tableView
    }()
    
    
    
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        let atrString = NSAttributedString(string: "Search", attributes: [.font: UIFont.systemFont(ofSize: 15)])
        searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.backgroundColor = lightColor
        searchBar.searchTextField.tintColor = primaryColor
        return searchBar
    }()
     
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRecents()
        //view.addSubview(UIView())
        navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        configureTableView()
        configureUI()
        //fetchUsers()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
        searchController.searchBar.searchTextField.becomeFirstResponder()
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
    
    //MARK: - Helpers
  
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.sectionHeaderTopPadding = 0
        
        tableView.register(RecentUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(RecentHeader.self, forHeaderFooterViewReuseIdentifier: recentHeaderReuseIdentifier)
        tableView.register(RecentTextCell.self, forCellReuseIdentifier: recentTextReuseIdentifier)
        //tableView.rowHeight = 64
        tableView.keyboardDismissMode = .onDrag
    }
    
    func configureUI() {
        let refresher = UIRefreshControl()
        
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refresher
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    func fetchRecents() {
        DatabaseManager.shared.fetchRecentSearches { recents in
            switch recents {
            case .success(let recentSearches):
                print(recentSearches)
                self.recentSearchedText = recentSearches
            case .failure(let error):
                print(error)
            }
        }
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    //MARK: - Actions
    @objc func handleRefresh() {
        HapticsManager.shared.vibrate(for: .success)
        recentSearchedText.removeAll()
        fetchRecents()
        
    }
}

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
                let controller = SearchResultsViewController()
                controller.searchedText = recentSearchedText[indexPath.row]
                
                let backItem = UIBarButtonItem()
                backItem.title = ""
                navigationItem.backBarButtonItem = backItem

                navigationController?.pushViewController(controller, animated: true)
            
        }
        //let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        //Navigate to profile controller of the selected user
        //let controller = ProfileViewController(user: user)
        //navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            tableView.performBatchUpdates {
                tableView.deleteRows(at: [indexPath], with: .fade)
                recentSearchedText.remove(at: indexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == 0 ? false : true
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
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
