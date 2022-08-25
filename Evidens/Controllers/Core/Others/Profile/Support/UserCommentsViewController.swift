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
        configureNavigationBar()
        configureCollectionView()
    }
    
    init(user: User, collectionViewFlowLayout: UICollectionViewFlowLayout) {
        self.user = user
        super.init(collectionViewLayout: collectionViewFlowLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        
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
}
