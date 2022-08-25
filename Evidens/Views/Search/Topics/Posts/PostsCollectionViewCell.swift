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
    
    var searchedText: String? {
        didSet {
            guard let searchedText = searchedText else { return }
            fetchTopPosts(withText: searchedText)
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .grouped)
        return tableView
    }()
    
    private lazy var noResultsImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.isHidden = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        return iv
    }()
    
    private lazy var noResultsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = grayColor
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 74
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(TopPostHeader.self, forHeaderFooterViewReuseIdentifier: topPostHeaderReuseIdentifier)
        tableView.register(TopPostTextCell.self, forCellReuseIdentifier: topPostTextCellReuseIdentifier)
        tableView.register(TopPostImageCell.self, forCellReuseIdentifier: topPostImageCellReuseIdentifier)
        addSubviews(tableView, noResultsImageView, noResultsLabel)
        tableView.frame = bounds
        
        noResultsLabel.text = "No results found"
        
        NSLayoutConstraint.activate([
            noResultsImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noResultsImageView.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            noResultsImageView.heightAnchor.constraint(equalToConstant: 65),
            noResultsImageView.widthAnchor.constraint(equalToConstant: 65),
            
            noResultsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            noResultsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            noResultsLabel.topAnchor.constraint(equalTo: noResultsImageView.bottomAnchor, constant: 10)
            
        ])
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
    
    func fetchTopPosts(withText text: String) {
        AlgoliaService.fetchPosts(withText: text) { postIDs in
            
            if postIDs.isEmpty {
                DispatchQueue.main.async {
                    self.tableView.isHidden = true
                    self.noResultsImageView.isHidden = false
                    self.noResultsLabel.isHidden = false
                }
                return
            }
            
            postIDs.forEach { id in
                PostService.fetchPost(withPostId: id) { post in
                    self.postsFetched.append(post)
                    if postIDs.count == self.postsFetched.count {
                        DispatchQueue.main.async {
                            self.tableView.isHidden = false
                            self.noResultsImageView.isHidden = true
                            self.noResultsLabel.isHidden = true
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

extension PostsCollectionViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: topPostHeaderReuseIdentifier) as! TopPostHeader
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
}


extension PostsCollectionViewCell: UITableViewDelegate {
    
}
