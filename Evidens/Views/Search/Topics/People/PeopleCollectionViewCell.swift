//
//  PeopleCollectionViewCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/8/22.
//

import UIKit

private let topPeopleHeaderReuseIdentifier = "TopPeopleHeaderReuseIdentifier"
private let topPeopleCellReuseIdentifier = "TopPeopleCellReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"

class PeopleCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var searchedText: String? {
        didSet {
            guard let searchedText = searchedText else { return }
            fetchTopUsers(withText: searchedText)
        }
    }
    
    private var users = [User]()
    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .grouped)
        return tableView
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 74
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.register(TopPeopleHeader.self, forHeaderFooterViewReuseIdentifier: topPeopleHeaderReuseIdentifier)
        tableView.register(TopPeopleCell.self, forCellReuseIdentifier: topPeopleCellReuseIdentifier)
        tableView.register(EmptyContentCell.self, forCellReuseIdentifier: emptyContentCellReuseIdentifier)
        addSubview(tableView)
        tableView.frame = bounds
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    //MARK: - Actions
    
    //MARK: - API
    
    // Fetch top users based on current user search
    
    
    func fetchTopUsers(withText text: String) {
        UserService.fetchUsersWithText(text: text.capitalized) { users in
            self.users = users
            print(self.users.count)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        /*
        AlgoliaService.fetchTopUsers(withText: text) { searchUsers in
            if searchUsers.isEmpty {
                DispatchQueue.main.async {
                    self.tableView.isHidden = true
                    self.noResultsImageView.isHidden = false
                    self.noResultsLabel.isHidden = false
                }
                return
            }
            self.usersFetched = searchUsers
            DispatchQueue.main.async {
                self.tableView.isHidden = false
                self.noResultsImageView.isHidden = true
                self.noResultsLabel.isHidden = true
                self.tableView.reloadData()
            }
        }
         */
    }
}

extension PeopleCollectionViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: topPeopleHeaderReuseIdentifier) as! TopPeopleHeader
        return cell
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count > 0 ? users.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if users.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyContentCell
            cell.selectionStyle = .none
            cell.set(title: "No results found for \(searchedText!)", description: "Try searching for something else.")
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: topPeopleCellReuseIdentifier, for: indexPath) as! TopPeopleCell
        cell.user = users[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uid = users[indexPath.row].uid
        print(uid)
        
    }
}


extension PeopleCollectionViewCell: UITableViewDelegate {
    
}

