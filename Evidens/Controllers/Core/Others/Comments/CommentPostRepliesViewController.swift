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
private let commentCellReuseIdentifier = "CommentCellReuseIdentifier"
private let deletedContentCellReuseIdentifier = "DeletedContentCellReuseIdentifier"

class CommentPostRepliesViewController: UICollectionViewController {
    
    private var post: Post
    private var comment: Comment
    private var user: User
    
    private var comments = [Comment]()
    private var users = [User]()
    private let activityIndicator = PrimaryLoadingView(frame: .zero)
    private var currentNotification: Bool = false

    private var path: [String]
    
    private var commentsLoaded: Bool = false
    
    private var networkFailure: Bool = false
    
    private var lastReplySnapshot: QueryDocumentSnapshot?

    private let needsToFetch: Bool
    
    private var postId: String?
    private var uid: String?
    
    private var isFetchingMoreReplies: Bool = false

    private var bottomAnchorConstraint: NSLayoutConstraint!
    private var commentMenuLauncher = ContextMenu(display: .comment)

    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()

    init(path: [String], comment: Comment, user: User, post: Post) {
        self.comment = comment
        self.user = user
        self.post = post
        self.path = path
        self.needsToFetch = false
        let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)

            return section
       }

        super.init(collectionViewLayout: compositionalLayout)
    }
    
    init(postId: String, uid: String, path: [String]) {
        self.postId = postId
        self.uid = uid
        self.path = path
        self.needsToFetch = true
        
        self.user = User(dictionary: [:])
        self.comment = Comment(dictionary: [:])
        self.post = Post(postId: "", dictionary: [:])
        
        let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)

            return section
       }
        super.init(collectionViewLayout: compositionalLayout)
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
        configureUI()
        if needsToFetch {
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

        CommentService.fetchRepliesForPostComment(forPost: post, forPath: path, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.lastReplySnapshot = snapshot.documents.last
                let comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
                let replyUids = Array(Set(comments.map { $0.uid } ))
              
                CommentService.getPostCommentsValuesFor(forPost: strongSelf.post, forPath: strongSelf.path, forComments: comments) { [weak self] comments in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.comments = comments.sorted { $0.timestamp.seconds > $1.timestamp.seconds }
                    
                    strongSelf.comments.enumerated().forEach { [weak self] index, comment in
                        guard let strongSelf = self else { return }
                        strongSelf.comments[index].isAuthor = comment.uid == strongSelf.post.uid
                    }
                    
                    UserService.fetchUsers(withUids: replyUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users = users
                        strongSelf.commentsLoaded = true
                        strongSelf.collectionView.reloadData()
                    }
                }
                
            case .failure(let error):
                if error == .network {
                    strongSelf.networkFailure = true
                }
                strongSelf.commentsLoaded = true
                strongSelf.collectionView.reloadData()
            }
        }
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(SecondaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: loadingCellReuseIdentifier)
        collectionView.register(CommentPostCell.self, forCellWithReuseIdentifier: commentCellReuseIdentifier)
        collectionView.register(DeletedCommentCell.self, forCellWithReuseIdentifier: deletedContentCellReuseIdentifier)
        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        if !needsToFetch {
            configureCommentInputView()
        }
    }
    
    private func configureUI() {
        guard let imageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, imageUrl != "" else { return }
        commentInputView.profileImageView.sd_setImage(with: URL(string: imageUrl))
    }
    
    private func configureCommentInputView() {

        if post.visible == .regular {
            view.addSubviews(commentInputView)
            
            bottomAnchorConstraint = commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            NSLayoutConstraint.activate([
                bottomAnchorConstraint,
                commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
            
            commentInputView.set(placeholder: AppStrings.Content.Comment.voice)
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 47, right: 0)
            collectionView.verticalScrollIndicatorInsets.bottom = 47
        }
    }
    
    private func fetchContent() {
        collectionView.isHidden = true
        view.addSubviews(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
        ])
        
        guard NetworkMonitor.shared.isConnected else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.network)
            return
        }
        
        guard let postId = postId, let uid = uid else { return }
        PostService.getPlainPost(withPostId: postId) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let post):
                strongSelf.post = post
                let group = DispatchGroup()
                
                group.enter()
                UserService.fetchUser(withUid: uid) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let user):
                        strongSelf.user = user
                        group.leave()
                        
                    case .failure(_):
                        break
                    }
                }
                
                group.enter()
                
                CommentService.fetchReply(forPost: post, forPath: strongSelf.path) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let comment):
                        strongSelf.comment = comment
                        group.leave()
                        
                    case .failure(_):
                        break
                    }
                }
                
                group.notify(queue: .main) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.collectionView.reloadData()
                    strongSelf.activityIndicator.stop()
                    strongSelf.activityIndicator.removeFromSuperview()
                    strongSelf.configureCommentInputView()
                    strongSelf.collectionView.isHidden = false
                    strongSelf.fetchRepliesForComment()
                }
            case .failure(_):
                break
            }
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreReplies()
        }
    }
    
    private func getMoreReplies() {

        guard lastReplySnapshot != nil, !comments.isEmpty, !isFetchingMoreReplies, comment.numberOfComments > comments.count, commentsLoaded else {
            return
        }
        
        showBottomSpinner()
        
        CommentService.fetchRepliesForPostComment(forPost: post, forPath: path, lastSnapshot: lastReplySnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.lastReplySnapshot = snapshot.documents.last
                var comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
                
                let replyUids = Array(Set(comments.map { $0.uid } ))

                let currentUserUids = strongSelf.users.map { $0.uid }
                
                let usersToFetch = replyUids.filter { !currentUserUids.contains($0) }
                
                CommentService.getPostCommentsValuesFor(forPost: strongSelf.post, forPath: strongSelf.path, forComments: comments) { [weak self] newComments in
                    guard let strongSelf = self else { return }
                    comments = newComments
                    comments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    strongSelf.comments.append(contentsOf: comments)
                    
                    guard !usersToFetch.isEmpty else {
                        strongSelf.collectionView.reloadData()
                        strongSelf.hideBottomSpinner()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: usersToFetch) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users.append(contentsOf: users)
                        strongSelf.collectionView.reloadData()
                        strongSelf.hideBottomSpinner()
                    }
                    
                }
            case .failure(_):
                strongSelf.hideBottomSpinner()
            }
        }
    }
    
    func showBottomSpinner() {
        isFetchingMoreReplies = true
    }
    
    func hideBottomSpinner() {
        isFetchingMoreReplies = false
    }
    
    private func handleLikeUnLike(for cell: CommentPostCell, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment else { return }
        
        let postId = post.postId
        let commentId = comment.id
        let didLike = comment.didLike
       
        // Toggle the like state and count
        cell.viewModel?.comment.didLike.toggle()
        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        
        if indexPath.section == 0 {
            self.comment.didLike.toggle()
            self.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
            let commentPath = Array(path.dropLast())
            postDidChangeCommentLike(postId: postId, path: commentPath, commentId: commentId, owner: comment.uid, didLike: didLike)
        } else {
            comments[indexPath.row].didLike.toggle()
            comments[indexPath.row].likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
            postDidChangeCommentLike(postId: postId, path: path, commentId: commentId, owner: comment.uid, didLike: didLike)
        }
    }
}

extension CommentPostRepliesViewController: UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return commentsLoaded ? networkFailure ? 1 : comments.isEmpty ? 1 : comments.count : 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            switch comment.visible {
                
            case .regular, .anonymous:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! CommentPostCell
                    cell.delegate = self

                    cell.viewModel = CommentViewModel(comment: comment)
                    cell.setExpanded()
                    cell.set(user: user)
                    return cell

            case .deleted:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedContentCellReuseIdentifier, for: indexPath) as! DeletedCommentCell
                cell.delegate = self
                return cell
            }
        } else {
            if !commentsLoaded {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellReuseIdentifier, for: indexPath) as! LoadingCell
                return cell 
            } else {
                if networkFailure {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! SecondaryNetworkFailureCell
                    cell.delegate = self
                    return cell
                } else {
                    let comment = comments[indexPath.row]
                    switch comment.visible {
                        
                    case .regular, .anonymous:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! CommentPostCell
                        cell.delegate = self
                        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
                        cell.setCompress()
                        
                        if let index = users.firstIndex(where: { $0.uid == comments[indexPath.row].uid }) {
                            cell.set(user: users[index], author: user)
                        }
                        
                        return cell
                        
                    case .deleted:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedContentCellReuseIdentifier, for: indexPath) as! DeletedCommentCell
                        cell.delegate = self
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
        
        CommentService.addReply(comment, path: path, post: post) { [weak self] result in
    
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let comment):
                strongSelf.comment.numberOfComments += 1
                strongSelf.users.append(currentUser)
                
                // If the reply is not from the comment owner, we send a notification to the comment owner
                if strongSelf.comment.uid != comment.uid {
                    
                    var replyPath = strongSelf.path
                    replyPath.append(comment.id)
                    
                    FunctionsManager.shared.addNotificationOnPostReply(postId: strongSelf.post.postId, owner: strongSelf.comment.uid, path: replyPath, comment: comment)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let _ = self else { return }
                    strongSelf.collectionView.performBatchUpdates { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.comments.insert(comment, at: 0)
                        
                        if strongSelf.comments.count == 1 {
                            strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
                        } else {
                            strongSelf.collectionView.insertItems(at: [IndexPath(item: 0, section: 1)])
                        }
                        
                    } completion: { [weak self] _ in
                        guard let strongSelf = self else { return }
                        strongSelf.collectionView.reloadSections(IndexSet(integer: 0))
                        strongSelf.postDidChangeComment(postId: strongSelf.post.postId, path: strongSelf.path, comment: comment, action: .add)
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
                        let commentPath = Array(strongSelf.path.dropLast())
                        CommentService.deleteComment(forPost: strongSelf.post, forPath: commentPath, forCommentId: comment.id) { [weak self] error in
                            guard let strongSelf = self else { return }
                            if let error {
                                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            } else {
                                strongSelf.comment.visible = .deleted
                                
                                strongSelf.commentInputView.removeFromSuperview()
                                strongSelf.commentInputView.isHidden = true
                                
                                strongSelf.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                                strongSelf.collectionView.verticalScrollIndicatorInsets.bottom = 0
                                strongSelf.collectionView.reloadData()
                                
                                strongSelf.postDidChangeComment(postId: strongSelf.post.postId, path: commentPath, comment: comment, action: .remove)
                                
                                  let popupView = PopUpBanner(title: AppStrings.Content.Comment.delete, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                                  popupView.showTopPopup(inView: strongSelf.view)
                            }
                        }
                    } else {
                        // Reply for the comments
                        CommentService.deleteComment(forPost: strongSelf.post, forPath: strongSelf.path, forCommentId: comment.id) { [weak self] error in
                            guard let strongSelf = self else { return }
                            if let error {
                                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            } else {
                                strongSelf.comments[indexPath.row].visible = .deleted
                                strongSelf.comment.numberOfComments -= 1
                                
                                strongSelf.collectionView.reloadData()
                                
                                strongSelf.postDidChangeComment(postId: strongSelf.post.postId, path: strongSelf.path, comment: comment, action: .remove)
                               
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
            if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
                
                var path = self.path
                path.append(comment.id)
                
                let controller = CommentPostRepliesViewController(path: path, comment: comment, user: users[userIndex], post: post)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func didTapLikeActionFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CommentPostCell else { return }
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
}

extension CommentPostRepliesViewController: DeletedCommentCellDelegate {
    
    func didTapReplies(_ cell: UICollectionViewCell, forComment comment: Comment) { return }
    
    func didTapLearnMore() {
        commentInputView.resignFirstResponder()
        commentMenuLauncher.showImageSettings(in: view)
    }
}


extension CommentPostRepliesViewController: PostDetailedChangesDelegate {
    func postDidChangeComment(postId: String, path: [String], comment: Comment, action: CommentAction) {
        currentNotification = true
        ContentManager.shared.commentPostChange(postId: postId, path: path, comment: comment, action: action)
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        // Check if the currentNotification flag is set, and if so, toggle it and return
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        // Check if the notification object is of type PostCommentChange
        if let change = notification.object as? PostCommentChange {

            // Check if the postId in the change object matches the postId of the current post
            guard change.postId == self.post.postId else { return }

            if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CommentPostCell {
                
                switch change.action {
                    
                case .add:
                    // A new comment was added to the root comment of this view O or any other comment
                    
                    let commentId = change.path.last
                    
                    if comment.id == commentId {
                        // A new comment was added to the root comment
                        guard let tab = tabBarController as? MainTabController, let user = tab.user else { return }
                        
                        // Append the user to the users array
                        users.append(user)
                        
                        // Increment the number of comments for the current comment and its view model
                        comment.numberOfComments += 1
                        cell.viewModel?.comment.numberOfComments += 1
                        
                        // Insert the new comment at the beginning of the comments array and reload the collectionView
                        comments.insert(change.comment, at: 0)
                        
                        collectionView.reloadData()
                    } else if let index = comments.firstIndex(where: { $0.id == change.path.last }) {
                        comments[index].numberOfComments += 1
                        collectionView.reloadData()
                    }

                case .remove:
                    // Check if the comment is the root comment or a reply inside this comment
                    if comment.id == change.comment.id {
                        // Set the visibility of the current comment to 'deleted' and reload the collectionView
                        comment.visible = .deleted
                        commentInputView.removeFromSuperview()
                        commentInputView.isHidden = true
                        
                        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                        collectionView.verticalScrollIndicatorInsets.bottom = 0
                        
                        collectionView.reloadData()
                    } else if let index = comments.firstIndex(where: { $0.id == change.comment.id }) {
                        // Decrement the number of comments for the current comment and its view model
                        self.comment.numberOfComments -= 1
                        cell.viewModel?.comment.numberOfComments -= 1
                        // Set the visibility of the comment at the specified index to 'deleted' and reload the collectionView
                        comments[index].visible = .deleted
                        collectionView.reloadData()
                    }
                }
            }
        }
    }

    func postDidChangeCommentLike(postId: String, path: [String], commentId: String, owner: String, didLike: Bool) {
        currentNotification = true
        ContentManager.shared.likeCommentPostChange(postId: postId, path: path, commentId: commentId, owner: owner, didLike: !didLike)
    }
    
    @objc func postCommentLikeChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostCommentLikeChange {
            guard change.postId == self.post.postId else { return }
            
            if change.commentId == self.comment.id {
                if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CommentPostCell {
                    
                    let likes = self.comment.likes
                    
                    self.comment.likes = change.didLike ? likes + 1 : likes - 1
                    self.comment.didLike = change.didLike
                    
                    cell.viewModel?.comment.didLike = change.didLike
                    cell.viewModel?.comment.likes = change.didLike ? likes + 1 : likes - 1
                }
            } else if let index = comments.firstIndex(where: { $0.id == change.commentId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) as? CommentPostCell {
                    let likes = comments[index].likes
                    
                    comments[index].didLike = change.didLike
                    comments[index].likes = change.didLike ? likes + 1 : likes - 1
                    
                    cell.viewModel?.comment.didLike = change.didLike
                    cell.viewModel?.comment.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
}

extension CommentPostRepliesViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            if self.user.isCurrentUser {
                self.user = user
                collectionView.reloadData()
            }
            
            if let index = users.firstIndex(where: { $0.uid == user.uid }) {
                users[index] = user
                collectionView.reloadData()
            }
        }
    }
}

extension CommentPostRepliesViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        networkFailure = false
        commentsLoaded = false
        collectionView.reloadData()
        fetchRepliesForComment()
    }
}
