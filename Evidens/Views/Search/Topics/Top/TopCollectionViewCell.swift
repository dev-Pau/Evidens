//
//  UserCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/10/21.
//

import UIKit
import SDWebImage

private let topPeopleCellIdentifier = "TopCellIdentifier"
private let topPeopleHeaderReuseIdentifier = "TopHeaderReuseIdentifier"
private let topPostHeaderReuseIdentifier = "TopPostHeaderReuseIdentifier"
private let topCaseHeaderReuseIdentifier = "TopHeaderCaseReuseIdentifier"

class TopCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    private var topUsersFetched = [User]()
    
    /*
    var viewModel: UserCellViewModel? {
        didSet {
            configure()
        }
    }
     */
    
    // Top users fetched based on current user search
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .grouped)
        return tableView
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fetchTopUsers()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TopPeopleHeader.self, forHeaderFooterViewReuseIdentifier: topPeopleHeaderReuseIdentifier)
        tableView.register(TopPeopleCell.self, forCellReuseIdentifier: topPeopleCellIdentifier)
        tableView.register(TopPostHeader.self, forHeaderFooterViewReuseIdentifier: topPostHeaderReuseIdentifier)
        tableView.register(TopCaseHeader.self, forHeaderFooterViewReuseIdentifier: topCaseHeaderReuseIdentifier)
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
    func fetchTopUsers() {
        // Needs to create a new function to fetch with name
        UserService.fetchUsers { users in
            self.topUsersFetched = users
            self.tableView.reloadData()
        }
    }
}

extension TopCollectionViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: topPeopleHeaderReuseIdentifier) as! TopPeopleHeader
            return cell
        } else if section == 1 {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: topPostHeaderReuseIdentifier) as! TopPostHeader
            return cell
        } else {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: topCaseHeaderReuseIdentifier) as! TopCaseHeader
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return topUsersFetched.count
        } else {
            return topUsersFetched.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: topPeopleCellIdentifier, for: indexPath) as! TopPeopleCell
            cell.viewModel = TopPeopleCellViewModel(user: topUsersFetched[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: topPeopleCellIdentifier, for: indexPath) as! TopPeopleCell
            cell.viewModel = TopPeopleCellViewModel(user: topUsersFetched[indexPath.row])
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension TopCollectionViewCell: UITableViewDelegate {
    
}
