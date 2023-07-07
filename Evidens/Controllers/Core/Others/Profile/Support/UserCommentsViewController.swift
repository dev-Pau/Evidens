//
//  UserCommentsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/8/22.
//

import UIKit
import JGProgressHUD

private let commentCellReuseIdentifier = "CommentCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"

class UserCommentsViewController: UIViewController {
    
    private let user: User
    private var commentLastTimestamp: Int64?
    private var recentComments = [RecentComment]()
    private var commentsLoaded: Bool = false
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let progressIndicator = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchFirstComments()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let view = MENavigationBarTitleView(fullName: user.firstName! + " " + user.lastName!, category: "Comments")
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(UserProfileCommentCell.self, forCellWithReuseIdentifier: commentCellReuseIdentifier)
    }
    
    private func fetchFirstComments() {
        DatabaseManager.shared.fetchProfileComments(lastTimestampValue: nil, forUid: user.uid!, completion: { result in
            switch result {
            case .success(let comments):
                guard !comments.isEmpty, let commentLastTimestamp = comments.last?.timestamp.milliseconds else { return }
                self.commentLastTimestamp = commentLastTimestamp / 1000
                self.recentComments = comments
                self.commentsLoaded = true
                self.collectionView.reloadData()
            case .failure(_):
                print("Error fetching comments")
            }
        })
    }
    
}

extension UserCommentsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commentsLoaded ? recentComments.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! UserProfileCommentCell
        cell.commentUserLabel.numberOfLines = 0
        cell.user = user
        cell.configure(recentComment: recentComments[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return commentsLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let comment = recentComments[indexPath.row]
        progressIndicator.show(in: view)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        self.navigationItem.backBarButtonItem = backItem
        
        if comment.source == .post {
            // Post
            PostService.fetchPost(withPostId: comment.referenceId) { post in
                self.progressIndicator.dismiss(animated: true)
                
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .vertical
                layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
                
                let controller = DetailsPostViewController(post: post, user: self.user, type: .regular, collectionViewLayout: layout)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            // Clinical Case
            CaseService.fetchCase(withCaseId: comment.referenceId) { clinicalCase in
                self.progressIndicator.dismiss(animated: true)
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .vertical
                layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
                
                let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: self.user, type: .regular, collectionViewFlowLayout: layout)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension UserCommentsViewController {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreComments()
        }
    }
    
    private func getMoreComments() {
        DatabaseManager.shared.fetchProfileComments(lastTimestampValue: commentLastTimestamp, forUid: user.uid!, completion: { result in
            switch result {
            case .success(let comments):
                guard !comments.isEmpty, let commentLastTimestamp = comments.last?.timestamp.milliseconds else { return }
                self.commentLastTimestamp = commentLastTimestamp / 1000
                self.recentComments.append(contentsOf: comments)
            case .failure(_):
                print("Error fetching comments")
            }
        })
    }
}
