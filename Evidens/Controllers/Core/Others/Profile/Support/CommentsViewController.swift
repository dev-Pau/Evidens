//
//  CommentsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/8/22.
//

import UIKit

private let commentCellReuseIdentifier = "CommentCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"

class CommentsViewController: UIViewController {
    
    private let user: User
    private var commentLastTimestamp: Int64?
    private var recentComments = [BaseComment]()
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
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.rightArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let view = CompoundNavigationBar(fullName: user.firstName!, category: AppStrings.Content.Comment.comments.capitalized)
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
        DatabaseManager.shared.fetchRecentComments(lastTimestampValue: nil, forUid: user.uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comments):
                guard !comments.isEmpty, let timeInterval = comments.last?.timestamp else { return }
                strongSelf.commentLastTimestamp = Int64(timeInterval * 1000)
                strongSelf.recentComments = comments
                strongSelf.commentsLoaded = true
                strongSelf.collectionView.reloadData()
            case .failure(let error):
                strongSelf.commentsLoaded = true
                strongSelf.collectionView.reloadData()
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
}

extension CommentsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
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

        if comment.source == .post {

            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let controller = DetailsPostViewController(postId: comment.referenceId, collectionViewLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            let controller = DetailsCaseViewController(caseId: comment.referenceId, collectionViewLayout: layout)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension CommentsViewController {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreComments()
        }
    }
    
    private func getMoreComments() {
        DatabaseManager.shared.fetchRecentComments(lastTimestampValue: commentLastTimestamp, forUid: user.uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comments):
                guard !comments.isEmpty, let timeInterval = comments.last?.timestamp else { return }
                strongSelf.commentLastTimestamp = Int64(timeInterval * 1000)
                strongSelf.recentComments.append(contentsOf: comments)
            case .failure(_):
                break
            }
        }
    }
}
