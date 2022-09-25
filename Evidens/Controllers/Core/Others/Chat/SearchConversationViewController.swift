//
//  SearchConversationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/9/22.
//

import UIKit

protocol SearchConversationViewControllerDelegate: AnyObject {
    func didTapUser(user: User)
}

private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let conversationCellReuseIdentifier = "ConversationCellReuseIdentifier"

class SearchConversationViewController: UIViewController {
    
    private var users: [User]
    private var filteredUsers = [User]()
    
    private var loaded: Bool = false
    
    lazy var searchController = UISearchController(searchResultsController: nil)
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .grouped)
        tableView.separatorColor = .clear
        return tableView
    }()
    
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        let atrString = NSAttributedString(string: "Search conversations", attributes: [.font: UIFont.systemFont(ofSize: 15)])
        searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.backgroundColor = lightColor
        searchBar.searchTextField.tintColor = primaryColor
        return searchBar
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
        searchBar.delegate = self
        configureTableView()
        configureUI()
    }
    
    init(users: [User]) {
        self.users = users
        print(users)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
        searchController.searchBar.searchTextField.becomeFirstResponder()
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.sectionHeaderTopPadding = 0
        
        tableView.estimatedRowHeight = 74
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(EmptyContentCell.self, forCellReuseIdentifier: emptyContentCellReuseIdentifier)
        tableView.register(NewConversationCell.self, forCellReuseIdentifier: conversationCellReuseIdentifier)
        //tableView.register(RecentTextCell.self, forCellReuseIdentifier: recentTextReuseIdentifier)
        tableView.keyboardDismissMode = .onDrag
    }
    
    func configureUI() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
}

extension SearchConversationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loaded ? filteredUsers.count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !loaded {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyContentCell
            cell.selectionStyle = .none
            cell.set(title: "Search conversations", description: "Try searching for active conversations.")
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: conversationCellReuseIdentifier, for: indexPath) as! NewConversationCell
        cell.set(user: filteredUsers[indexPath.row])
        return cell
    }
    
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return loaded ? 200 : 70
    }
     */
}

//MARK: - UITableViewDelegate

extension SearchConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        if indexPath.section == 1 {
            
            // Press on recent text cell
            
            // When we have full text Search this is the good approach
            let controller = SearchResultsViewController()
            controller.searchedText = recentSearchedText[indexPath.row]
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
            fetchRecents()
         */
    }
}

//MARK: - UISearchBarDelegate


extension SearchConversationViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            loaded = false
            tableView.reloadData()
            return
        }
        loaded = true
        filterConversations(with: text.lowercased())
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        searchBar.resignFirstResponder()
        filterConversations(with: text.lowercased())
    }
    
    func filterConversations(with text: String) {
        let result: [User] = users.filter { $0.firstName!.lowercased().contains(text) || $0.lastName!.lowercased().contains(text) }
        filteredUsers = result
        tableView.reloadData()
    }
}

