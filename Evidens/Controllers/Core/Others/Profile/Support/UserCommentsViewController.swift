//
//  UserCommentsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/8/22.
//

import UIKit

private let commentCellReuseIdentifier = "CommentCellReuseIdentifier"

class UserCommentsViewController: UICollectionViewController {
    
    private let user: User
    
    var recentComments = [[String: Any]]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchComments()
        configureCollectionView()
    }
    
    init(user: User, collectionViewFlowLayout: UICollectionViewFlowLayout) {
        self.user = user
        super.init(collectionViewLayout: collectionViewFlowLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let view = MENavigationBarTitleView(fullName: user.firstName! + " " + user.lastName!, category: "Comments")
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(UserProfileCommentCell.self, forCellWithReuseIdentifier: commentCellReuseIdentifier)
    }
    
    private func fetchComments() {
        if let uid = user.uid {
            DatabaseManager.shared.fetchProfileComments(for: uid) { result in
                switch result {
                    
                case .success(let comments):
                    self.recentComments = comments
                case .failure(_):
                    print("Error fetching comments")
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentComments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! UserProfileCommentCell
        cell.caseTitleLabel.numberOfLines = 0
        cell.commentUserLabel.numberOfLines = 0
        cell.configure(commentInfo: recentComments[indexPath.row], user: user)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let commentTapped = recentComments[indexPath.row]
        if let commentType = commentTapped["type"] as? Int {
            if commentType == 0 {
                // Post
                if let postID = commentTapped["refUid"] as? String {
                    showLoadingView()
                    PostService.fetchPost(withPostId: postID) { post in
                        self.dismissLoadingView()
                        
                        let layout = UICollectionViewFlowLayout()
                        layout.scrollDirection = .vertical
                        layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
                        layout.minimumLineSpacing = 0
                        layout.minimumInteritemSpacing = 0
                        
                        let controller = DetailsPostViewController(post: post, user: self.user, collectionViewLayout: layout)
                        
                        let backItem = UIBarButtonItem()
                        backItem.title = ""
                        self.navigationItem.backBarButtonItem = backItem
                        
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                    
                }
            } else {
                // Clinical Case
                if let caseID = commentTapped["refUid"] as? String {
                    showLoadingView()
                    CaseService.fetchCase(withCaseId: caseID) { clinicalCase in
                        self.dismissLoadingView()
                        
                        let layout = UICollectionViewFlowLayout()
                        layout.scrollDirection = .vertical
                        layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
                        layout.minimumLineSpacing = 0
                        layout.minimumInteritemSpacing = 0
                        
                        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: self.user, collectionViewFlowLayout: layout)
                        
                        let backItem = UIBarButtonItem()
                        backItem.title = ""
                        self.navigationItem.backBarButtonItem = backItem
                        
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
        }
    }
}
