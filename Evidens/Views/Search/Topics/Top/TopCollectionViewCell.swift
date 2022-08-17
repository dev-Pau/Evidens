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
private let topPostImageCellReuseIdentifier = "TopPostImageCellReuseIdentifier"
private let topCaseHeaderReuseIdentifier = "TopHeaderCaseReuseIdentifier"
private let topPostTextCellReuseIdentifier = "TopPostTextCellReuseIdentifier"
private let topCaseImageCellReuseIdentifier = "TopCaseImageCellReuseIdentifier"
private let topCaseTextCellReuseIdentifier = "TopCaseTextCellReuseIdentifier"

class TopCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    private var topUsersFetched = [User]()
    private var topPostsFetched = [Post]()
    private var topCasesFetched = [Case]()
    
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
        fetchTopPosts()
        fetchTopCases()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TopPeopleHeader.self, forHeaderFooterViewReuseIdentifier: topPeopleHeaderReuseIdentifier)
        tableView.register(TopPeopleCell.self, forCellReuseIdentifier: topPeopleCellIdentifier)
        tableView.register(TopPostHeader.self, forHeaderFooterViewReuseIdentifier: topPostHeaderReuseIdentifier)
        tableView.register(TopPostImageCell.self, forCellReuseIdentifier: topPostImageCellReuseIdentifier)
        tableView.register(TopPostTextCell.self, forCellReuseIdentifier: topPostTextCellReuseIdentifier)
        tableView.register(TopCaseHeader.self, forHeaderFooterViewReuseIdentifier: topCaseHeaderReuseIdentifier)
        tableView.register(TopCaseImageCell.self, forCellReuseIdentifier: topCaseImageCellReuseIdentifier)
        tableView.register(TopCaseTextCell.self, forCellReuseIdentifier: topCaseTextCellReuseIdentifier)
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
    
    func fetchTopPosts() {
        PostService.fetchTopPosts { posts in
            self.topPostsFetched = posts
            self.tableView.reloadData()
        }
    }
    
    func fetchTopCases() {
        CaseService.fetchCases { cases in
            self.topCasesFetched = cases
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
        } else if section == 1 {
            return topPostsFetched.count
        } else {
            return topCasesFetched.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: topPeopleCellIdentifier, for: indexPath) as! TopPeopleCell
            cell.viewModel = TopPeopleCellViewModel(user: topUsersFetched[indexPath.row])
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 1 {
            if topPostsFetched[indexPath.row].type == .plainText {
                let cell = tableView.dequeueReusableCell(withIdentifier: topPostTextCellReuseIdentifier, for: indexPath) as! TopPostTextCell
                cell.viewModel = PostViewModel(post: topPostsFetched[indexPath.row])
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: topPostImageCellReuseIdentifier, for: indexPath) as! TopPostImageCell
                cell.viewModel = PostViewModel(post: topPostsFetched[indexPath.row])
                cell.selectionStyle = .none
                return cell
            }

        } else {
            if topCasesFetched[indexPath.row].type == .text {
                let cell = tableView.dequeueReusableCell(withIdentifier: topCaseTextCellReuseIdentifier, for: indexPath) as! TopCaseTextCell
                cell.viewModel = CaseViewModel(clinicalCase: topCasesFetched[indexPath.row])
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: topCaseImageCellReuseIdentifier, for: indexPath) as! TopCaseImageCell
                cell.viewModel = CaseViewModel(clinicalCase: topCasesFetched[indexPath.row])
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 65
        } else if indexPath.section == 1 {
            return 200
        } else {
            return 200
        }
    }
}

extension TopCollectionViewCell: UITableViewDelegate {
    
}
