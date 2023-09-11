//
//  DetailsPostViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/7/22.
//

import UIKit
import Firebase
import SafariServices

private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let commentReuseIdentifier = "CommentCellReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"

private let homeTextCellReuseIdentifier = "CellTextReuseIdentifier"
private let homeImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let homeTwoImageTextCellReuseIdentifier = "HomeTwoImageTextCellReuseIdentifier"
private let homeThreeImageTextCellReuseIdentifier = "HomeThreeImageTextCellReuseIdentifier"
private let homeFourImageTextCellReuseIdentifier = "HomeFourImageTextCellReuseIdentifier"
private let deletedContentCellReuseIdentifier = "DeletedContentCellReuseIdentifier"
private let deletedCellReuseIdentifier = "DeletedCellReuseIdentifier"

class DetailsPostViewController: UICollectionViewController, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout {
    private var zoomTransitioning = ZoomTransitioning()
    private let referenceMenu = ReferenceMenu()
    private var selectedImage: UIImageView!
    private let activityIndicator = PrimaryLoadingView(frame: .zero)
    private var commentMenu = ContextMenu(display: .comment)
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    private var commentsLastSnapshot: QueryDocumentSnapshot?
    private var commentsLoaded: Bool = false
    
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    private var post: Post
    private var user: User
    private var postId: String?
    
    private var networkFailure: Bool = false
    
    private var currentNotification: Bool = false
    
    private var isFetchingMoreComments: Bool = false
    
    private var comments = [Comment]()
    private var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNotificationObservers()
        configureNavigationBar()
        if let _ = postId {
            fetchPost()
        } else {
            fetchComments()
        }
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postVisibleChange(_:)), name: NSNotification.Name(AppPublishers.Names.postVisibility), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.postLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.postBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.postComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postEditChange(_:)), name: NSNotification.Name(AppPublishers.Names.postEdit), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.postCommentLike), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }

    init(post: Post, user: User, collectionViewLayout: UICollectionViewFlowLayout) {
        self.post = post
        self.user = user
        super.init(collectionViewLayout: collectionViewLayout)
    }
    
    init(postId: String, collectionViewLayout: UICollectionViewFlowLayout) {
        self.post = Post(postId: "", dictionary: [:])
        self.user = User(dictionary: [:])
        self.postId = postId
        super.init(collectionViewLayout: collectionViewLayout)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.bottomAnchorConstraint.constant = constant
            strongSelf.view.layoutIfNeeded()
        }
    }

    private func configureNavigationBar() {
        title = AppStrings.Content.Post.post
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.leftChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(SecondaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.register(CommentPostCell.self, forCellWithReuseIdentifier: commentReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.register(DeletedCommentCell.self, forCellWithReuseIdentifier: deletedContentCellReuseIdentifier)
        collectionView.register(DeletedContentCell.self, forCellWithReuseIdentifier: deletedCellReuseIdentifier)
        collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: homeTextCellReuseIdentifier)
        collectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        collectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        collectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        collectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        
        if postId == nil && post.visible == .regular {
            configureCommentInputView()
        }
    }
    
    private func configureCommentInputView() {
        
        view.addSubviews(commentInputView)
        
        bottomAnchorConstraint = commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            bottomAnchorConstraint,
            commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 47, right: 0)
        collectionView.verticalScrollIndicatorInsets.bottom = 47

        commentInputView.set(placeholder: AppStrings.Content.Comment.voice)
        
        guard let imageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, !imageUrl.isEmpty else { return }
        commentInputView.profileImageView.sd_setImage(with: URL(string: imageUrl))
    }
    
    private func fetchPost() {
        view.addSubviews(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
        ])
        
        collectionView.isHidden = true
        guard let postId = postId else { return }

        
        guard NetworkMonitor.shared.isConnected else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.network)
            return
        }
        
        PostService.fetchPost(withPostId: postId) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let post):
                strongSelf.post = post
                let uid = post.uid
                
                UserService.fetchUser(withUid: uid) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                        
                    case .success(let user):
                        strongSelf.user = user
                        strongSelf.collectionView.reloadData()
                        strongSelf.activityIndicator.stop()
                        strongSelf.activityIndicator.removeFromSuperview()
                        strongSelf.configureCommentInputView()
                        strongSelf.collectionView.isHidden = false
                        strongSelf.fetchComments()
                    case .failure(_):
                        break
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    private func fetchComments() {
        CommentService.fetchPostComments(forPost: post, forPath: [], lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.commentsLastSnapshot = snapshot.documents.last
                strongSelf.comments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
                
                CommentService.getPostCommentsValuesFor(forPost: strongSelf.post, forPath: [], forComments: strongSelf.comments) { [weak self] fetchedComments in
                    guard let strongSelf = self else { return }
                    strongSelf.comments = fetchedComments
                    
                    let uids = strongSelf.comments.map { $0.uid }
                    
                    strongSelf.comments.enumerated().forEach { [weak self] index, comment in
                        guard let strongSelf = self else { return }
                        strongSelf.comments[index].isAuthor = comment.uid == strongSelf.post.uid
                    }
                    
                    strongSelf.comments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    
                    UserService.fetchUsers(withUids: uids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users = users
                        strongSelf.commentsLoaded = true
                        
                        DispatchQueue.main.async {
                            strongSelf.collectionView.reloadData()
                        }
                    }
                }
            case .failure(let error):
                if error == .network {
                    strongSelf.networkFailure = true
                }
                
                strongSelf.commentsLoaded = true
                
                strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
            }
        }
    }
    
    private func getMoreComments() {

        guard commentsLastSnapshot != nil, !comments.isEmpty, !isFetchingMoreComments, commentsLoaded else { return }

        CommentService.fetchPostComments(forPost: post, forPath: [], lastSnapshot: commentsLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):
                strongSelf.commentsLastSnapshot = snapshot.documents.last
                
                var newComments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
                
                CommentService.getPostCommentsValuesFor(forPost: strongSelf.post, forPath: [], forComments: newComments) { [weak self] fetchedComments in
                    guard let strongSelf = self else { return }
                    
                    newComments = fetchedComments
                    newComments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    strongSelf.comments.append(contentsOf: newComments)
                    let newUserUids = newComments.map { $0.uid }
                    let currentUserUids = strongSelf.users.map { $0.uid }
                    let usersToFetch = newUserUids.filter { !currentUserUids.contains($0) }
                    
                    guard !usersToFetch.isEmpty else {
                        strongSelf.collectionView.reloadData()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: usersToFetch) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users.append(contentsOf: users)
                        strongSelf.collectionView.reloadData()
                    }
                }
                
            case.failure(_):
                break
            }
        }
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreComments()
        }
    }
    
    private func handleLikeUnLike(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        let postId = post.postId
        let didLike = post.didLike
        postDidChangeLike(postId: postId, didLike: didLike)

        cell.viewModel?.post.didLike.toggle()
        self.post.didLike.toggle()
        
        cell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        self.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
    }
    
    func handleBookmarkUnbookmark(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        let postId = post.postId
        let didBookmark = post.didBookmark
        postDidChangeBookmark(postId: postId, didBookmark: didBookmark)

        cell.viewModel?.post.didBookmark.toggle()
        self.post.didBookmark.toggle()
    }
    
    private func handleLikeUnLike(for cell: CommentPostCell, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment else { return }

        let postId = post.postId
        let commentId = comment.id
        let didLike = comment.didLike
        
        postDidChangeCommentLike(postId: postId, path: [], commentId: commentId, owner: comment.uid, didLike: didLike)
        
        // Toggle the like state and count
        cell.viewModel?.comment.didLike.toggle()
        self.comments[indexPath.row].didLike.toggle()
        
        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        self.comments[indexPath.row].likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
    }
    
    private func deletePost(withId id: String, at indexPath: IndexPath) {

        displayAlert(withTitle: AppStrings.Alerts.Title.deletePost, withMessage: AppStrings.Alerts.Subtitle.deletePost, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let _ = self else { return }
            
            PostService.deletePost(withId: id) { [weak self] error in

                guard let strongSelf = self else { return }
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.postDidChangeVisible(postId: id)
                    strongSelf.post.visible = .deleted
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    strongSelf.collectionView.verticalScrollIndicatorInsets.bottom = 0
                    strongSelf.commentInputView.removeFromSuperview()
                }
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? CGSize.zero : commentsLoaded ? comments.isEmpty ? CGSize.zero : CGSize.zero : CGSize(width: view.frame.width, height: 55)
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
            switch post.visible {
                
            case .regular:
                switch post.kind {
                    
                case .plainText:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTextCellReuseIdentifier, for: indexPath) as! HomeTextCell
                    cell.delegate = self
                    cell.postTextView.textContainer.maximumNumberOfLines = 0
                    cell.viewModel = PostViewModel(post: post)
                    cell.set(user: user)
                    return cell
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                    cell.delegate = self
                    cell.postTextView.textContainer.maximumNumberOfLines = 0
                    cell.viewModel = PostViewModel(post: post)
                    cell.set(user: user)
                    return cell
                case .textWithTwoImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                    cell.delegate = self
                    cell.postTextView.textContainer.maximumNumberOfLines = 0
                    cell.viewModel = PostViewModel(post: post)
                    cell.set(user: user)
                    return cell
                case .textWithThreeImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                    cell.delegate = self
                    cell.postTextView.textContainer.maximumNumberOfLines = 0
                    cell.viewModel = PostViewModel(post: post)
                    cell.set(user: user)
                    return cell
                case .textWithFourImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                    cell.delegate = self
                    cell.postTextView.textContainer.maximumNumberOfLines = 0
                    cell.viewModel = PostViewModel(post: post)
                    cell.set(user: user)
                    return cell
                }
            case .deleted:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedCellReuseIdentifier, for: indexPath) as! DeletedContentCell
                cell.setPost()
                return cell
            }
            
        } else {
            if networkFailure {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! SecondaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if comments.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    cell.multiplier = 0.5
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Comment.emptyTitle, description: AppStrings.Content.Comment.emptyPost, content: .comment)
                    cell.delegate = self
                    return cell
                } else {
                    let comment = comments[indexPath.row]
                    
                    switch comment.visible {
                        
                    case .regular:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentReuseIdentifier, for: indexPath) as! CommentPostCell
                        cell.delegate = self
                        cell.viewModel = CommentViewModel(comment: comment)
                        cell.setCompress()
                        
                        if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
                            cell.set(user: users[userIndex], author: user)
                        }

                        return cell
                        
                    case .anonymous:
                        fatalError()
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

extension DetailsPostViewController: HomeCellDelegate {
    func cell(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
       
        navigationController?.pushViewController(controller, animated: true)
    }

    func cell(didTapMenuOptionsFor post: Post, option: PostMenu) {
        switch option {
        case .delete:
            deletePost(withId: post.postId, at: IndexPath(item: 0, section: 0))
        case .edit:
            let controller = EditPostViewController(post: post)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            
            present(nav, animated: true)
        case .report:
            let controller = ReportViewController(source: .post, contentUid: user.uid!, contentId: post.postId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
            
        case .reference:
            guard let reference = post.reference else { return }
            referenceMenu.showImageSettings(in: view, forPostId: post.postId, forReferenceKind: reference)
            referenceMenu.delegate = self
        }
    }

    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        commentInputView.commentTextView.becomeFirstResponder()
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let currentCell = cell as? HomeCellProtocol else { return }
        handleLikeUnLike(for: currentCell, at: IndexPath(item: 0, section: 0))
    }
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        guard let currentCell = cell as? HomeCellProtocol else { return }
        handleBookmarkUnbookmark(for: currentCell, at: IndexPath(item: 0, section: 0))
    }
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        self.navigationController?.delegate = zoomTransitioning
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
        let controller = LikesViewController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) { return }
}

extension DetailsPostViewController: CommentCellDelegate {
    func didTapLikeActionFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CommentPostCell else { return }
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
    
    func wantsToSeeRepliesFor(_ cell: UICollectionViewCell, forComment comment: Comment) {

        if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
            let controller = CommentPostRepliesViewController(path: [comment.id], comment: comment, user: users[userIndex], post: post)
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: CommentMenu) {
        switch action {
        case .report:
            let controller = ReportViewController(source: .comment, contentUid: comment.uid, contentId: comment.id)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
            
        case .delete:
            if let indexPath = self.collectionView.indexPath(for: cell) {
                
                displayAlert(withTitle: AppStrings.Alerts.Title.deleteComment, withMessage: AppStrings.Alerts.Subtitle.deleteComment, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                    guard let strongSelf = self else { return }
                    CommentService.deleteComment(forPost: strongSelf.post, forPath: [], forCommentId: comment.id) { [weak self] error in
                        guard let strongSelf = self else { return }
                        if let error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                           
                            strongSelf.comments[indexPath.item].visible = .deleted
                            strongSelf.collectionView.reloadItems(at: [indexPath])
                            strongSelf.post.numberOfComments -= 1
                            strongSelf.collectionView.reloadSections(IndexSet(integer: 0))
                            
                            strongSelf.postDidChangeComment(postId: strongSelf.post.postId, path: [], comment: comment, action: .remove)

                            let popupView = PopUpBanner(title: AppStrings.Content.Comment.delete, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                            popupView.showTopPopup(inView: strongSelf.view)
                        }
                    }
                }
            }
            
        case .back:
            navigationController?.popViewController(animated: true)
        }
    }
    
    func didTapProfile(forUser user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension DetailsPostViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension DetailsPostViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        commentInputView.commentTextView.becomeFirstResponder()
    }
}

extension DetailsPostViewController: ReferenceMenuDelegate {
    func didTapReference(reference: Reference) {
        switch reference.option {
        case .link:
            if let url = URL(string: reference.referenceText) {
                if UIApplication.shared.canOpenURL(url) {
                    presentSafariViewController(withURL: url)
                } else {
                    presentWebViewController(withURL: url)
                }
            }
        case .citation:
            let wordToSearch = reference.referenceText
            if let encodedQuery = wordToSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: AppStrings.URL.googleQuery + encodedQuery) {
                    if UIApplication.shared.canOpenURL(url) {
                        presentSafariViewController(withURL: url)
                    } else {
                        presentWebViewController(withURL: url)
                    }
                }
            }
        }
    }
}

extension DetailsPostViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
    }
}

extension DetailsPostViewController: CommentInputAccessoryViewDelegate {

    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        inputView.commentTextView.resignFirstResponder()
        
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        
        CommentService.addComment(comment, for: post) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                
                strongSelf.post.numberOfComments += 1
                
                strongSelf.users.append(currentUser)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let strongSelf = self else { return }
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
                        strongSelf.postDidChangeComment(postId: strongSelf.post.postId, path: [], comment: comment, action: .add)
                        if let cell = strongSelf.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? HomeCellProtocol {
                            cell.viewModel?.post.numberOfComments += 1
                        }
                    }
                }
            case .failure(let error):
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    func textDidChange(_ inputView: CommentInputAccessoryView) {
        collectionView.contentInset.bottom = inputView.frame.height - 3
        collectionView.verticalScrollIndicatorInsets.bottom = inputView.frame.height
        view.layoutIfNeeded()
    }
    
    func textDidBeginEditing() {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
}


extension DetailsPostViewController: DeletedCommentCellDelegate {
    func didTapReplies(_ cell: UICollectionViewCell, forComment comment: Comment) {

        guard comment.numberOfComments > 0 else { return }
        if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
            let controller = CommentPostRepliesViewController(path: [comment.id], comment: comment, user: users[userIndex], post: post)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapLearnMore() {
        commentInputView.resignFirstResponder()
        commentMenu.showImageSettings(in: view)
    }
}

extension DetailsPostViewController: PostChangesDelegate {
    func postDidChangeVisible(postId: String) {
        currentNotification = true
        ContentManager.shared.visiblePostChange(postId: postId)
    }
    
    @objc func postVisibleChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostVisibleChange {
            if post.postId == change.postId {
                post.visible = .deleted
                collectionView.reloadData()
                collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                collectionView.verticalScrollIndicatorInsets.bottom = 0
                commentInputView.removeFromSuperview()
            }
        }
    }
    
    func postDidChangeComment(postId: String, path: [String], comment: Comment, action: CommentAction) {
        currentNotification = true
        ContentManager.shared.commentPostChange(postId: postId, path: path, comment: comment, action: action)
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostCommentChange {
            guard change.postId == self.post.postId else { return }
            
            switch change.action {
                
            case .add:
                // Check if the comment is directly a post reply
                if change.path.isEmpty {
                    if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? HomeCellProtocol {
                        guard let tab = tabBarController as? MainTabController, let user = tab.user else { return }
                        users.append(user)
                        
                        self.post.numberOfComments += 1
                        cell.viewModel?.post.numberOfComments += 1
                        
                        self.comments.insert(change.comment, at: 0)
                        collectionView.reloadData()
                    }
                    
                } else {
                    if let index = comments.firstIndex(where: { $0.id == change.path.last }) {
                        
                        if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) as? CommentPostCell {
                            comments[index].numberOfComments += 1
                            cell.viewModel?.comment.numberOfComments += 1
                            collectionView.reloadData()
                        }
                    }
                }
                
            case .remove:
                // Check if the comment is directly a post reply
                if change.path.isEmpty {
                    if let index = comments.firstIndex(where: { $0.id == change.comment.id }) {
                        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? HomeCellProtocol {
                            cell.viewModel?.post.numberOfComments -= 1
                            post.numberOfComments -= 1
                            
                            comments[index].visible = .deleted
                            collectionView.reloadData()
                        }
                    }
                } else {
                    if let index = comments.firstIndex(where: { $0.id == change.path.last }) {
                        if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) as? CommentPostCell {
                            comments[index].visible = .deleted
                            cell.viewModel?.comment.numberOfComments -= 1
                            collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }

    func postDidChangeLike(postId: String, didLike: Bool) {
        currentNotification = true
        ContentManager.shared.likePostChange(postId: postId, didLike: !didLike)
    }
    
    @objc func postLikeChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }

        if let change = notification.object as? PostLikeChange {
            guard change.postId == self.post.postId else { return }
            if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)), let currentCell = cell as? HomeCellProtocol {
                let likes = self.post.likes
                
                self.post.likes = change.didLike ? likes + 1 : likes - 1
                self.post.didLike = change.didLike
                
                currentCell.viewModel?.post.didLike = change.didLike
                currentCell.viewModel?.post.likes = change.didLike ? likes + 1 : likes - 1
            }
        }
    }
    
    func postDidChangeBookmark(postId: String, didBookmark: Bool) {
        currentNotification = true
        ContentManager.shared.bookmarkPostChange(postId: postId, didBookmark: !didBookmark)
    }
    
    
    @objc func postBookmarkChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostBookmarkChange {
            guard change.postId == self.post.postId else { return }
            if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)), let currentCell = cell as? HomeCellProtocol {
                
                self.post.didBookmark = change.didBookmark
                currentCell.viewModel?.post.didBookmark = change.didBookmark
            }
        }
    }
    
    @objc func postEditChange(_ notification: NSNotification) {
        if let change = notification.object as? PostEditChange {
            let post = change.post
            guard post.postId == self.post.postId else { return }
            self.post = post
            collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}

extension DetailsPostViewController: PostDetailedChangesDelegate {

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
            if let index = comments.firstIndex(where: { $0.id == change.commentId }), let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) as? CommentPostCell {
                
                let likes = self.comments[index].likes
                
                self.comments[index].likes = change.didLike ? likes + 1 : likes - 1
                self.comments[index].didLike = change.didLike
                
                cell.viewModel?.comment.didLike = change.didLike
                cell.viewModel?.comment.likes = change.didLike ? likes + 1 : likes - 1
            }
        }
    }
}

extension DetailsPostViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            
            if self.user.isCurrentUser {
                self.user = user
                configureNavigationBar()
                collectionView.reloadData()
            }
            
            if let index = users.firstIndex(where: { $0.uid! == user.uid! }) {
                users[index] = user
                collectionView.reloadData()
            }
        }
    }
}

extension DetailsPostViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        networkFailure = false
        commentsLoaded = false
        collectionView.reloadData()
        fetchComments()
    }
}
