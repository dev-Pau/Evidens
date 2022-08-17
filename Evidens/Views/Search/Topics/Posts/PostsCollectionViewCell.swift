//
//  PostsCollectionViewCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/8/22.
//

import UIKit

private let topPostHeaderReuseIdentifier = "TopHeaderCaseReuseIdentifier"
private let topPostImageCellReuseIdentifier = "TopCaseImageCellReuseIdentifier"
private let topPostTextCellReuseIdentifier = "TopCaseTextCellReuseIdentifier"

class PostsCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    private var postsFetched = [Post]()
    
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
        fetchCases()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TopCaseHeader.self, forHeaderFooterViewReuseIdentifier: topPostHeaderReuseIdentifier)
        tableView.register(TopPostImageCell.self, forCellReuseIdentifier: topPostImageCellReuseIdentifier)
        tableView.register(TopPostTextCell.self, forCellReuseIdentifier: topPostTextCellReuseIdentifier)
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
    
    func fetchCases() {
        PostService.fetchPosts { posts in
            self.postsFetched = posts
            self.tableView.reloadData()
        }
    }
}

extension PostsCollectionViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: topPostHeaderReuseIdentifier) as! TopCaseHeader
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsFetched.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if postsFetched[indexPath.row].type == .plainText {
            let cell = tableView.dequeueReusableCell(withIdentifier: topPostTextCellReuseIdentifier, for: indexPath) as! TopPostTextCell
            cell.viewModel = PostViewModel(post: postsFetched[indexPath.row])
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: topPostImageCellReuseIdentifier, for: indexPath) as! TopPostImageCell
            cell.viewModel = PostViewModel(post: postsFetched[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}


extension PostsCollectionViewCell: UITableViewDelegate {
    
}

