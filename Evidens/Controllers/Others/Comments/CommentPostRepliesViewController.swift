//
//  CommentRepliesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/4/23.
//

import UIKit
import Firebase

private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"
private let loadingCellReuseIdentifier = "LoadingHeaderReuseIdentifier"

private let commentPostExtendedCellReuseIdentifier = "CommentPostExtendedCellReuseIdentifier"
private let commentPostCellReuseIdentifier = "CommentCellReuseIdentifier"
private let deletedContentCellReuseIdentifier = "DeletedContentCellReuseIdentifier"

class CommentPostRepliesViewController: UIViewController {
    
    private var viewModel: CommentPostRepliesViewModel
   
    private var bottomAnchorConstraint: NSLayoutConstraint!
    private var commentMenuLauncher = ContextMenu(display: .comment)

    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    private var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        tabBarController?.tabBar.standardAppearance = appearance
        tabBarController?.tabBar.scrollEdgeAppearance = appearance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = separatorColor
        tabBarController?.tabBar.standardAppearance = appearance
        tabBarController?.tabBar.scrollEdgeAppearance = appearance
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewModel.firstLoad {
            let height = commentInputView.frame.height - 1
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            collectionView.verticalScrollIndicatorInsets.bottom = height
            viewModel.firstLoad = true
        }
    }

    init(path: [String], comment: Comment, user: User, post: Post) {
        self.viewModel = CommentPostRepliesViewModel(path: path, comment: comment, user: user, post: post)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(postId: String, uid: String, path: [String]) {
        self.viewModel = CommentPostRepliesViewModel(postId: postId, uid: uid, path: path)
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        configureCollectionView()
        configureNotificationObservers()
        configureNavigationBar()

        if viewModel.needsToFetch {
            fetchContent()
        } else {
            fetchRepliesForComment()
        }
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.replies
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.postComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.postCommentLike), object: nil)
    }
    
    @objc func handleKeyboardFrameChange(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        let convertedKeyboardFrame = view.convert(keyboardFrame, from: nil)
        let intersection = convertedKeyboardFrame.intersection(view.bounds)

        let keyboardHeight = view.bounds.maxY - intersection.minY

        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0

        let constant = -(keyboardHeight - tabBarHeight)
        UIView.animate(withDuration: animationDuration) {
            self.bottomAnchorConstraint.constant = constant
            self.view.layoutIfNeeded()
        }
    }
    
    private func fetchRepliesForComment() {
        viewModel.getReplies { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: addLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .systemBackground
        collectionView.register(SecondaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: loadingCellReuseIdentifier)
        collectionView.register(CommentPostCell.self, forCellWithReuseIdentifier: commentPostCellReuseIdentifier)
        collectionView.register(CommentPostExtendedCell.self, forCellWithReuseIdentifier: commentPostExtendedCellReuseIdentifier)
        collectionView.register(DeletedCommentCell.self, forCellWithReuseIdentifier: deletedContentCellReuseIdentifier)
        
        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        if !viewModel.needsToFetch {
            configureCommentInputView()
        }
    }
    
    private func addLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func configureCommentInputView() {

        if viewModel.post.visible == .regular {
            view.addSubviews(commentInputView)
            
            bottomAnchorConstraint = commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            NSLayoutConstraint.activate([
                bottomAnchorConstraint,
                commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
            
            commentInputView.set(placeholder: AppStrings.Content.Comment.voice)
        } else {
            commentInputView.removeFromSuperview()
        }
    }
    
    private func fetchContent() {

        viewModel.getContent { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            } else {
                strongSelf.viewModel.firstLoad = false
                strongSelf.collectionView.reloadData()
                strongSelf.configureCommentInputView()
                strongSelf.fetchRepliesForComment()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreReplies()
        }
    }
    
    private func getMoreReplies() {
        viewModel.getMoreComments { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
    
    private func handleLikeUnLike(for cell: CommentPostProtocol, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment else { return }
       
        let postId = viewModel.post.postId
        let commentId = comment.id
        let didLike = comment.didLike

        cell.viewModel?.comment.didLike.toggle()
        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        
        if indexPath.section == 0 {
            viewModel.comment.didLike.toggle()
            viewModel.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
            let commentPath = Array(viewModel.path.dropLast())
            postDidChangeCommentLike(postId: postId, path: commentPath, commentId: commentId, owner: comment.uid, didLike: didLike)
        } else {
            viewModel.comments[indexPath.row].didLike.toggle()
            viewModel.comments[indexPath.row].likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
            postDidChangeCommentLike(postId: postId, path: viewModel.path, commentId: commentId, owner: comment.uid, didLike: didLike)
        }
    }
}

extension CommentPostRepliesViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.commentLoaded ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return viewModel.commentsLoaded ? viewModel.networkFailure ? 1 : viewModel.comments.isEmpty ? 0 : viewModel.comments.count : 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if !viewModel.commentLoaded {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellReuseIdentifier, for: indexPath) as! LoadingCell
                return cell
            } else {
                switch viewModel.comment.visible {
                    
                case .regular, .anonymous:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentPostExtendedCellReuseIdentifier, for: indexPath) as! CommentPostExtendedCell
                    cell.delegate = self

                    cell.viewModel = CommentViewModel(comment: viewModel.comment)
                    cell.set(user: viewModel.user)
                    return cell

                case .deleted:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedContentCellReuseIdentifier, for: indexPath) as! DeletedCommentCell
                    cell.delegate = self
                    return cell
                }
            }
        } else {
            if !viewModel.commentsLoaded {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellReuseIdentifier, for: indexPath) as! LoadingCell
                return cell
            } else {
                if viewModel.networkFailure {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! SecondaryNetworkFailureCell
                    cell.delegate = self
                    return cell
                } else {
                    let comment = viewModel.comments[indexPath.row]
                    switch comment.visible {
                        
                    case .regular, .anonymous:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentPostCellReuseIdentifier, for: indexPath) as! CommentPostCell
                        cell.delegate = self
                        cell.viewModel = CommentViewModel(comment: viewModel.comments[indexPath.row])

                        if let index = viewModel.users.firstIndex(where: { $0.uid == viewModel.comments[indexPath.row].uid }) {
                            cell.set(user: viewModel.users[index], author: viewModel.user)
                        }
                        
                        return cell
                        
                    case .deleted:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedContentCellReuseIdentifier, for: indexPath) as! DeletedCommentCell
                        cell.delegate = self
                        cell.viewModel = CommentViewModel(comment: comment)
                        return cell
                    }
                }
            }
        }
    }
}

extension CommentPostRepliesViewController: CommentInputAccessoryViewDelegate {
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        inputView.commentTextView.resignFirstResponder()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        
        viewModel.addReply(comment, withCurrentUser: currentUser) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let _ = self else { return }
                    strongSelf.collectionView.performBatchUpdates { [weak self] in
                        guard let strongSelf = self else { return }
                        
                        strongSelf.viewModel.comments.insert(comment, at: 0)
                        
                        if strongSelf.viewModel.comments.count == 1 {
                            strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
                        } else {
                            strongSelf.collectionView.insertItems(at: [IndexPath(item: 0, section: 1)])
                        }
                    } completion: { [weak self] _ in
                        guard let strongSelf = self else { return }
                        strongSelf.collectionView.reloadSections(IndexSet(integer: 0))
                        strongSelf.postDidChangeComment(postId: strongSelf.viewModel.post.postId, path: strongSelf.viewModel.path, comment: comment, action: .add)
                    }
                }
            case .failure(let error):
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
}

extension CommentPostRepliesViewController: CommentCellDelegate {
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: CommentMenu) {
        if let indexPath = collectionView.indexPath(for: cell) {
            switch action {
            case .back:
                navigationController?.popViewController(animated: true)
            case .report:
                let controller = ReportViewController(source: .comment, contentUid: comment.uid, contentId: comment.id)
                let navVC = UINavigationController(rootViewController: controller)
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true)
            case .delete:
                displayAlert(withTitle: AppStrings.Alerts.Title.deleteComment, withMessage: AppStrings.Alerts.Subtitle.deleteComment, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                    guard let strongSelf = self else { return }

                    if indexPath.section == 0 {
                        // Raw post comment
                        let commentPath = Array(strongSelf.viewModel.path.dropLast())
                        
                        strongSelf.viewModel.deleteComment(forId: comment.id, forPath: commentPath) { [weak self] error in
                            guard let strongSelf = self else { return }
                            if let error {
                                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            } else {
                                strongSelf.viewModel.comment.visible = .deleted
                                
                                strongSelf.postDidChangeComment(postId: strongSelf.viewModel.post.postId, path: commentPath, comment: comment, action: .remove)
                                
                                strongSelf.commentInputView.removeFromSuperview()
                                strongSelf.commentInputView.isHidden = true
                                
                                strongSelf.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                                strongSelf.collectionView.verticalScrollIndicatorInsets.bottom = 0
                                strongSelf.collectionView.reloadData()
                                
                                let popupView = PopUpBanner(title: AppStrings.Content.Comment.delete, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                                popupView.showTopPopup(inView: strongSelf.view)
                            }
                        }
                    } else {
                        // Reply for the comments
                        strongSelf.viewModel.deleteComment(forId: comment.id, forPath: strongSelf.viewModel.path) { [weak self] error in
                            guard let strongSelf = self else { return }
                            if let error {
                                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            } else {
                                strongSelf.viewModel.comments[indexPath.row].visible = .deleted
                                strongSelf.viewModel.comment.numberOfComments -= 1
                                
                                strongSelf.collectionView.reloadData()
                                
                                strongSelf.postDidChangeComment(postId: strongSelf.viewModel.post.postId, path: strongSelf.viewModel.path, comment: comment, action: .remove)
                               
                                let popupView = PopUpBanner(title: AppStrings.Content.Reply.delete, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                                popupView.showTopPopup(inView: strongSelf.view)
                            }
                        }
                    }
                }
            }
        }
    }
            
    func didTapProfile(forUser user: User) {
        let controller = UserProfileViewController(user: user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func wantsToSeeRepliesFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        if let indexPath = collectionView.indexPath(for: cell) {
            guard indexPath.section != 0 else { return }
            if let userIndex = viewModel.users.firstIndex(where: { $0.uid == comment.uid }) {
                
                var path = viewModel.path
                path.append(comment.id)
                
                let controller = CommentPostRepliesViewController(path: path, comment: comment, user: viewModel.users[userIndex], post: viewModel.post)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func didTapLikeActionFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CommentPostProtocol else { return }
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
}

extension CommentPostRepliesViewController: DeletedCommentCellDelegate {
    
    func didTapReplies(_ cell: UICollectionViewCell, forComment comment: Comment) {
        if let userIndex = viewModel.users.firstIndex(where: { $0.uid == comment.uid }) {
            
            var path = viewModel.path
            path.append(comment.id)
            
            let controller = CommentPostRepliesViewController(path: path, comment: comment, user: viewModel.users[userIndex], post: viewModel.post)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapLearnMore() {
        commentInputView.resignFirstResponder()
        commentMenuLauncher.showImageSettings(in: view)
    }
}


extension CommentPostRepliesViewController: PostDetailedChangesDelegate {
    func postDidChangeComment(postId: String, path: [String], comment: Comment, action: CommentAction) {
        viewModel.currentNotification = true
        ContentManager.shared.commentPostChange(postId: postId, path: path, comment: comment, action: action)
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        // Check if the currentNotification flag is set, and if so, toggle it and return
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        // Check if the notification object is of type PostCommentChange
        if let change = notification.object as? PostCommentChange {

            // Check if the postId in the change object matches the postId of the current post
            guard change.postId == viewModel.post.postId else { return }

            switch change.action {
                
            case .add:

                let commentId = change.path.last
                
                if viewModel.comment.id == commentId {
                    // A new comment was added to the root comment
                    guard let tab = tabBarController as? MainTabController, let user = tab.user else { return }
                    
                    // Append the user to the users array
                    viewModel.users.append(user)
                    
                    // Increment the number of comments for the current comment and its view model
                    viewModel.comment.numberOfComments += 1
                   
                    // Insert the new comment at the beginning of the comments array and reload the collectionView
                    viewModel.comments.insert(change.comment, at: 0)
                    
                    collectionView.reloadData()
                } else if let index = viewModel.comments.firstIndex(where: { $0.id == change.path.last }) {
                    viewModel.comments[index].numberOfComments += 1
                    collectionView.reloadData()
                }

            case .remove:
                // Check if the comment is the root comment or a reply inside this comment
                if viewModel.comment.id == change.comment.id {
                    // Set the visibility of the current comment to 'deleted' and reload the collectionView
                    viewModel.comment.visible = .deleted
                    commentInputView.removeFromSuperview()
                    commentInputView.isHidden = true
                    
                    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    collectionView.verticalScrollIndicatorInsets.bottom = 0
                    
                    collectionView.reloadData()
                } else if let index = viewModel.comments.firstIndex(where: { $0.id == change.comment.id }) {
                    // Decrement the number of comments for the current comment and its view model
                    viewModel.comment.numberOfComments -= 1
                    // Set the visibility of the comment at the specified index to 'deleted' and reload the collectionView
                    viewModel.comments[index].visible = .deleted
                    collectionView.reloadData()
                } else if let index = viewModel.comments.firstIndex(where: { $0.id == change.path.last }) {
                    
                    viewModel.comments[index].numberOfComments -= 1
                    collectionView.reloadData()
                }
            }
        }
    }

    func postDidChangeCommentLike(postId: String, path: [String], commentId: String, owner: String, didLike: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.likeCommentPostChange(postId: postId, path: path, commentId: commentId, owner: owner, didLike: !didLike)
    }
    
    @objc func postCommentLikeChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostCommentLikeChange {
            guard change.postId == viewModel.post.postId else { return }
            
            if change.commentId == viewModel.comment.id {
                let likes = viewModel.comment.likes
                
                viewModel.comment.likes = change.didLike ? likes + 1 : likes - 1
                viewModel.comment.didLike = change.didLike
                collectionView.reloadData()
            } else if let index = viewModel.comments.firstIndex(where: { $0.id == change.commentId }) {
                let likes = viewModel.comments[index].likes
                
                viewModel.comments[index].didLike = change.didLike
                viewModel.comments[index].likes = change.didLike ? likes + 1 : likes - 1
                collectionView.reloadData()
            }
        }
    }
}

extension CommentPostRepliesViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            if viewModel.user.isCurrentUser {
                viewModel.user = user
                collectionView.reloadData()
            }
            
            if let index = viewModel.users.firstIndex(where: { $0.uid == user.uid }) {
                viewModel.users[index] = user
                collectionView.reloadData()
            }
        }
    }
}

extension CommentPostRepliesViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        viewModel.networkFailure = false
        viewModel.commentsLoaded = false
        collectionView.reloadData()
        fetchRepliesForComment()
    }
}
