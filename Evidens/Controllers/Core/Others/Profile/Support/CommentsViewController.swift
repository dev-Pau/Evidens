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
    
    private var user: User
    private var commentLastTimestamp: Int64?
    private var recentComments = [BaseComment]()
    private var commentsLoaded: Bool = false
    
    private var bottomSpinner: BottomSpinnerView!
    private var isFetchingMoreComments: Bool = false

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
        configureNotificationObservers()
        fetchFirstComments()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.rightArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        title = AppStrings.Content.Comment.comments.capitalized
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.postComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseReplyChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseReply), object: nil)
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        bottomSpinner = BottomSpinnerView(style: .medium)
        
        view.addSubviews(collectionView, bottomSpinner)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(UserProfileCommentCell.self, forCellWithReuseIdentifier: commentCellReuseIdentifier)
        
        NSLayoutConstraint.activate([
            bottomSpinner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomSpinner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSpinner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSpinner.heightAnchor.constraint(equalToConstant: 50)
        ])
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
    
    private func showBottomSpinner() {
        isFetchingMoreComments = true
        let collectionViewContentHeight = collectionView.contentSize.height
        
        if collectionView.frame.height < collectionViewContentHeight {
            bottomSpinner.startAnimating()
            collectionView.contentInset.bottom = 50
        }
    }
    
    private func hideBottomSpinner() {
        isFetchingMoreComments = false
        bottomSpinner.stopAnimating()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.contentInset.bottom = 0
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
            if comment.path.isEmpty {
                let controller = DetailsPostViewController(postId: comment.contentId, collectionViewLayout: layout)
                navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller = CommentPostRepliesViewController(postId: comment.contentId, uid: user.uid!, path: comment.path)
                navigationController?.pushViewController(controller, animated: true)
            }

        } else {
            #warning("fer el mateix que a sobre amb posts")
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            let controller = DetailsCaseViewController(caseId: comment.contentId, collectionViewLayout: layout)
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
        
        guard !isFetchingMoreComments, !recentComments.isEmpty else {
            return
        }
        
        showBottomSpinner()
        
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
            strongSelf.hideBottomSpinner()
        }
    }
}

extension CommentsViewController {
    
    @objc func postCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? PostCommentChange {
            
            if let index = recentComments.firstIndex(where: { $0.id == change.comment.id }) {
                
                switch change.action {
                case .add:
                    break
                case .remove:
                    recentComments.remove(at: index)
                    collectionView.reloadData()
                }
            }
        }
    }
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseCommentChange {
            if let index = recentComments.firstIndex(where: { $0.id == change.comment.id }) {
                
                switch change.action {
                case .add:
                    break
                    
                case .remove:
                    recentComments.remove(at: index)
                    collectionView.reloadData()
                }
            }
        }
    }
    
    @objc func caseReplyChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseReplyChange {
            if let index = recentComments.firstIndex(where: { $0.id == change.reply.id }) {
                
                switch change.action {
                case .add:
                    break
                    
                case .remove:
                    recentComments.remove(at: index)
                    collectionView.reloadData()
                }
            }
        }
    }
}

extension CommentsViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        
        
        if let user = notification.userInfo!["user"] as? User {
            if self.user.isCurrentUser {
                self.user = user
                collectionView.reloadData()
            }
        }
    }
}
