//
//  PeopleCollectionViewCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/8/22.
//

import UIKit

private let topPeopleHeaderReuseIdentifier = "TopPeopleHeaderReuseIdentifier"
private let topPeopleCellReuseIdentifier = "TopPeopleCellReuseIdentifier"

class PeopleCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    private var usersFetched = [User]()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .grouped)
        return tableView
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fetchUsers()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TopPeopleHeader.self, forHeaderFooterViewReuseIdentifier: topPeopleHeaderReuseIdentifier)
        tableView.register(TopPeopleCell.self, forCellReuseIdentifier: topPeopleCellReuseIdentifier)
        addSubview(tableView)
        tableView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    /*
     func configure() {
     guard let viewModel = viewModel else { return }
     fullNameLabel.text = viewModel.firstName + " " + viewModel.lastName
     profileImageView.sd_setImage(with: viewModel.profileImageUrl)
     }
     */
    
    //MARK: - Actions
    
    //MARK: - API
    
    // Fetch top users based on current user search
    
    func fetchUsers() {
        UserService.fetchUsers { users in
            self.usersFetched = users
            self.tableView.reloadData()
        }
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
        return usersFetched.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: topPeopleCellReuseIdentifier, for: indexPath) as! TopPeopleCell
        cell.viewModel = TopPeopleCellViewModel(user: usersFetched[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}


extension PeopleCollectionViewCell: UITableViewDelegate {
    
}

