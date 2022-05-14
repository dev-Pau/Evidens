//
//  SearchViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

private let reuseIdentifier = "RecentCell"
private let recentHeaderReuseIdentifier = "RecentHeaderCell"

class SearchViewController: UIViewController {
    
    //MARK: - Properties
    
    private var users = [User]()
    private var filteredUsers = [User]()
    private let searchController = UISearchController(searchResultsController: nil)
    
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
        return searchBar
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(UIView())
        navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()

        configureTableView()
        configureUI()
        fetchUsers()
    }
    
    //MARK: - API
    func fetchUsers() {
        UserService.fetchUsers { users in
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Helpers
  
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = lightColor
        tableView.sectionHeaderTopPadding = 0
        tableView.register(RecentCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(RecentHeader.self, forHeaderFooterViewReuseIdentifier: recentHeaderReuseIdentifier)
        //tableView.rowHeight = 64
        tableView.keyboardDismissMode = .onDrag
    }
    
    func configureUI() {
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
}

//MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //let headerView = UIView()
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: recentHeaderReuseIdentifier)
        //headerView.addSubview(headerCell)
        return headerCell
    }
    
    // Returns the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 4
        
        //Display number of users we have on the database or filtered
        //return inSearchMode ? filteredUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RecentCell
        
        if indexPath.section == 0 {
            
        } else {
 
        }
        return cell
        
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        //let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        //cell.viewModel = UserCellViewModel(user: user)
        //return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

//MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        //Navigate to profile controller of the selected user
        //let controller = ProfileViewController(user: user)
        //navigationController?.pushViewController(controller, animated: true)
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
