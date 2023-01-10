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
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"

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
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 74
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .systemBackground
        tableView.register(TopPostHeader.self, forHeaderFooterViewReuseIdentifier: topPostHeaderReuseIdentifier)
        tableView.register(TopPostTextCell.self, forCellReuseIdentifier: topPostTextCellReuseIdentifier)
        tableView.register(TopPostImageCell.self, forCellReuseIdentifier: topPostImageCellReuseIdentifier)
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
    
    func fetchTopPosts(withText text: String) {
        /*
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
         */
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
        return postsFetched.count > 0 ? postsFetched.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if postsFetched.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyContentCell
            cell.selectionStyle = .none
            cell.set(title: "No posts found for \(searchedText!)", description: "Try searching for something else.")
            return cell
        }
        
        
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

