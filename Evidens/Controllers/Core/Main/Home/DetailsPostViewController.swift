//
//  DetailsPostViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/7/22.
//

import UIKit
import Firebase
import JGProgressHUD
import SafariServices

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let commentReuseIdentifier = "CommentCellReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"

private let homeTextCellReuseIdentifier = "CellTextReuseIdentifier"
private let homeImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let homeTwoImageTextCellReuseIdentifier = "HomeTwoImageTextCellReuseIdentifier"
private let homeThreeImageTextCellReuseIdentifier = "HomeThreeImageTextCellReuseIdentifier"
private let homeFourImageTextCellReuseIdentifier = "HomeFourImageTextCellReuseIdentifier"
private let deletedContentCellReuseIdentifier = "DeletedContentCellReuseIdentifier"

protocol DetailsPostViewControllerDelegate: AnyObject {
    func didTapLikeAction(forPost post: Post)
    func didTapBookmarkAction(forPost post: Post)
    func didComment(forPost post: Post)
    func didDeleteComment(forPost post: Post)
    func didEditPost(forPost post: Post)
}

class DetailsPostViewController: UICollectionViewController, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout {
    private var zoomTransitioning = ZoomTransitioning()
    private let referenceMenu = ReferenceMenu()
    private var selectedImage: UIImageView!
    private let activityIndicator = PrimaryProgressIndicatorView(frame: .zero)
    private var commentMenu = ContextMenu(display: .comment)
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    weak var delegate: DetailsPostViewControllerDelegate?
    private var commentsLastSnapshot: QueryDocumentSnapshot?
    private var commentsLoaded: Bool = false
    
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    private var post: Post
    private var user: User
    private var postId: String?
    
    private var likeDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var likePostValues: [IndexPath: Bool] = [:]
    private var likePostCount: [IndexPath: Int] = [:]
    
    private var bookmarkDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var bookmarkPostValues: [IndexPath: Bool] = [:]
    
    private var likeCommentDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var likeCommentValues: [IndexPath: Bool] = [:]
    private var likeCommentCount: [IndexPath: Int] = [:]
    
    private var comments = [Comment]()
    private var users = [User]()
    
    private let progressIndicator = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        if let _ = postId {
            fetchPost()
        } else {
            configureNavigationBar()
            fetchComments()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
        UIView.animate(withDuration: animationDuration) {
            self.bottomAnchorConstraint.constant = constant
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureNavigationBar() {
        let fullName = user.name()
        let view = CompoundNavigationBar(fullName: fullName, category: AppStrings.Content.Post.post)
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.leftChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        commentInputView.set(placeholder: AppStrings.Content.Comment.voice)
        
        guard let imageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String, !imageUrl.isEmpty else { return }
        commentInputView.profileImageView.sd_setImage(with: URL(string: imageUrl))
        commentInputView.isHidden = false
    }
    
    
    func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: commentReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.register(DeletedContentCell.self, forCellWithReuseIdentifier: deletedContentCellReuseIdentifier)
        switch post.kind {
        case .plainText:
            collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: homeTextCellReuseIdentifier)
        case .textWithImage:
            collectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        case .textWithTwoImage:
            collectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        case .textWithThreeImage:
            collectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        case .textWithFourImage:
            collectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        }
        
        view.addSubview(commentInputView)
        bottomAnchorConstraint = commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            bottomAnchorConstraint,
            commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 47, right: 0)
        collectionView.verticalScrollIndicatorInsets.bottom = 47
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
        commentInputView.isHidden = true
        guard let postId = postId else { return }
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
                        strongSelf.configureNavigationBar()
                        strongSelf.collectionView.reloadData()
                        strongSelf.activityIndicator.stop()
                        strongSelf.activityIndicator.removeFromSuperview()
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
        CommentService.fetchPostComments(forPost: post, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.commentsLastSnapshot = snapshot.documents.last
                strongSelf.comments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
                
                CommentService.getPostCommentsValuesFor(forPost: strongSelf.post, forComments: strongSelf.comments) { [weak self] fetchedComments in
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
                strongSelf.commentsLoaded = true
                strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
                
                guard error != .notFound else {
                    return
                }
                
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    private func getMoreComments() {
        guard commentsLastSnapshot != nil else { return }
        CommentService.fetchPostComments(forPost: post, lastSnapshot: commentsLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):
                strongSelf.commentsLastSnapshot = snapshot.documents.last
                
                var newComments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
                
                CommentService.getPostCommentsValuesFor(forPost: strongSelf.post, forComments: newComments) { [weak self] fetchedComments in
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
                
            case.failure(let error):
                guard error != .notFound else {
                    return
                }
                
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
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
        // Toggle the like state and count
        cell.viewModel?.post.didLike.toggle()
        self.post.didLike.toggle()
        
        cell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        self.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        
        self.delegate?.didTapLikeAction(forPost: self.post)
        
        // Cancel the previous debounce timer for this post, if any
        if let debounceTimer = likeDebounceTimers[indexPath] {
            debounceTimer.cancel()
        }
        
        // Store the initial like state and count
        if likePostValues[indexPath] == nil {
            likePostValues[indexPath] = post.didLike
            likePostCount[indexPath] = post.likes
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let likeValue = strongSelf.likePostValues[indexPath], let countValue = strongSelf.likePostCount[indexPath] else {
                return
            }

            // Prevent any database action if the value remains unchanged
            if cell.viewModel?.post.didLike == likeValue {
                strongSelf.likePostValues[indexPath] = nil
                strongSelf.likePostCount[indexPath] = nil
                return
            }

            if post.didLike {
                PostService.unlikePost(post: post) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        cell.viewModel?.post.didLike = likeValue
                        strongSelf.post.didLike = likeValue
                        
                        cell.viewModel?.post.likes = countValue
                        strongSelf.post.likes = countValue
                        
                        strongSelf.delegate?.didTapLikeAction(forPost: post)
                    }
                    
                    strongSelf.likePostValues[indexPath] = nil
                    strongSelf.likePostCount[indexPath] = nil
                }
            } else {
                PostService.likePost(post: post) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    // Revert to the previous like state and count if there's an error
                    if let _ = error {
                        cell.viewModel?.post.didLike = likeValue
                        strongSelf.post.didLike = likeValue
                        
                        cell.viewModel?.post.likes = countValue
                        strongSelf.post.likes = countValue
                        
                        strongSelf.delegate?.didTapLikeAction(forPost: post)
                    }
                    
                    strongSelf.likePostValues[indexPath] = nil
                    strongSelf.likePostCount[indexPath] = nil
                }
            }
            
            // Clean up the debounce timer
            strongSelf.likeDebounceTimers[indexPath] = nil
        }
        
        // Save the debounce timer
        likeDebounceTimers[indexPath] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
    
    func handleBookmarkUnbookmark(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        // Toggle the bookmark state
        cell.viewModel?.post.didBookmark.toggle()
        self.post.didBookmark.toggle()
        self.delegate?.didTapBookmarkAction(forPost: post)
        
        // Cancel the previous debounce timer for this post, if any
        if let debounceTimer = bookmarkDebounceTimers[indexPath] {
            debounceTimer.cancel()
        }
        
        // Store the initial bookmark state
        if bookmarkPostValues[indexPath] == nil {
            bookmarkPostValues[indexPath] = post.didBookmark
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let bookmarkValue = strongSelf.bookmarkPostValues[indexPath] else {
                return
            }

            // Prevent any database action if the value remains unchanged
            if cell.viewModel?.post.didBookmark == bookmarkValue {
                strongSelf.bookmarkPostValues[indexPath] = nil
                return
            }

            if post.didBookmark {
                PostService.unbookmark(post: post) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        cell.viewModel?.post.didBookmark = bookmarkValue
                        strongSelf.post.didBookmark = bookmarkValue
                    }
                    
                    strongSelf.bookmarkPostValues[indexPath] = nil
                }
            } else {
                PostService.bookmark(post: post) { [weak self] error in
                    guard let strongSelf = self else { return }

                    if let _ = error {
                        cell.viewModel?.post.didBookmark = bookmarkValue
                        strongSelf.post.didBookmark = bookmarkValue
    
                    }
                    
                    strongSelf.bookmarkPostValues[indexPath] = nil
                }
            }
            
            // Clean up the debounce timer
            strongSelf.bookmarkDebounceTimers[indexPath] = nil
        }
        
        // Save the debounce timer
        bookmarkDebounceTimers[indexPath] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
    
    private func handleLikeUnLike(for cell: CommentCell, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment else { return }
        
        // Toggle the like state and count
        cell.viewModel?.comment.didLike.toggle()
        self.comments[indexPath.row].didLike.toggle()

        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        self.comments[indexPath.row].likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        
        // Cancel the previous debounce timer for this comment, if any
        if let debounceTimer = likeCommentDebounceTimers[indexPath] {
            debounceTimer.cancel()
        }
        
        // Store the initial like state and count
        if likeCommentValues[indexPath] == nil {
            likeCommentValues[indexPath] = comment.didLike
            likeCommentCount[indexPath] = comment.likes
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let likeValue = strongSelf.likeCommentValues[indexPath], let countValue = strongSelf.likeCommentCount[indexPath] else {
                return
            }

            // Prevent any database action if the value remains unchanged
            if cell.viewModel?.comment.didLike == likeValue {
                strongSelf.likeCommentValues[indexPath] = nil
                strongSelf.likeCommentCount[indexPath] = nil
                return
            }

            if comment.didLike {
                CommentService.unlikeComment(forPost: strongSelf.post, forCommentId: comment.id) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let _ = error {
                        cell.viewModel?.comment.didLike = likeValue
                        strongSelf.comments[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.comment.likes = countValue
                        strongSelf.comments[indexPath.row].likes = countValue
                    }
                    
                    strongSelf.likeCommentValues[indexPath] = nil
                    strongSelf.likeCommentCount[indexPath] = nil
                }
            } else {
                CommentService.likeComment(forPost: strongSelf.post, forCommentId: comment.id) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let _ = error {
                        cell.viewModel?.comment.didLike = likeValue
                        strongSelf.comments[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.comment.likes = countValue
                        strongSelf.comments[indexPath.row].likes = countValue
                    }
                    
                    strongSelf.likeCommentValues[indexPath] = nil
                    strongSelf.likeCommentCount[indexPath] = nil
                }
                
            }

            // Clean up the debounce timer
            strongSelf.likeCommentDebounceTimers[indexPath] = nil
        }
        
        // Save the debounce timer
        likeCommentDebounceTimers[indexPath] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
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
        return section == 0 ? 1 : commentsLoaded ? comments.isEmpty ? 1 : comments.count : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
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
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentReuseIdentifier, for: indexPath) as! CommentCell
                    cell.commentTextView.isSelectable = false
                    cell.delegate = self
                    cell.viewModel = CommentViewModel(comment: comment)

                    if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
                        cell.set(user: users[userIndex])
                    }
                    
                    return cell
                    
                case .anonymous:
                    fatalError()
                case .deleted:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedContentCellReuseIdentifier, for: indexPath) as! DeletedContentCell
                    cell.delegate = self
                    cell.viewModel = CommentViewModel(comment: comment)
                    return cell
                }
            }
        }
    }
}

extension DetailsPostViewController: HomeCellDelegate {
    func cell(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        controller.postDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

    func cell(_ cell: UICollectionViewCell, didTapMenuOptionsFor post: Post, option: PostMenu) {
        switch option {
        case .delete:
            #warning("Implement Post Deletion")
        case .edit:
            let controller = EditPostViewController(post: post)
            controller.delegate = self
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
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let currentCell = cell as? HomeCellProtocol else { return }
        HapticsManager.shared.vibrate(for: .success)
        handleLikeUnLike(for: currentCell, at: IndexPath(item: 0, section: 0))
    }
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        guard let currentCell = cell as? HomeCellProtocol else { return }
        HapticsManager.shared.vibrate(for: .success)
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
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        let currentCell = cell as! CommentCell
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
    
    func wantsToSeeRepliesFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
            let controller = CommentPostRepliesViewController(comment: comment, user: users[userIndex], post: post, currentUser: user)
            controller.delegate = self
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
                
                displayAlert(withTitle: AppStrings.Alerts.Title.deleteConversation, withMessage: AppStrings.Alerts.Subtitle.deleteConversation, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                    guard let strongSelf = self else { return }
                    CommentService.deleteComment(forPost: strongSelf.post, forCommentId: comment.id) { [weak self] error in
                        guard let strongSelf = self else { return }
                        if let error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                            DatabaseManager.shared.deleteRecentComment(forCommentId: comment.id)
                            strongSelf.comments[indexPath.item].visible = .deleted
                            strongSelf.collectionView.reloadItems(at: [indexPath])
                            strongSelf.post.numberOfComments -= 1
                            strongSelf.collectionView.reloadSections(IndexSet(integer: 0))
                            strongSelf.delegate?.didDeleteComment(forPost: strongSelf.post)

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

extension DetailsPostViewController: EditPostViewControllerDelegate {
    func didEditPost(post: Post) {
        self.post = post
        collectionView.reloadSections(IndexSet(integer: 0))
        delegate?.didEditPost(forPost: post)
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

extension DetailsPostViewController: CommentPostRepliesViewControllerDelegate {

    func didDeleteReply(withRefComment refComment: Comment, comment: Comment) {
        if let commentIndex = comments.firstIndex(where: { $0.id == refComment.id }) {
            comments[commentIndex].numberOfComments -= 1
            collectionView.reloadItems(at: [IndexPath(item: commentIndex, section: 1)])
        }
    }
    
    func didDeleteComment(comment: Comment) {
        if let commentIndex = comments.firstIndex(where: { $0.id == comment.id }) {
            self.comments[commentIndex].visible = .deleted
            self.post.numberOfComments -= 1
            self.collectionView.reloadItems(at: [IndexPath(item: commentIndex, section: 1)])
            self.collectionView.reloadSections(IndexSet(integer: 0))
            self.delegate?.didDeleteComment(forPost: self.post)
        }
    }
    
    func didAddReplyToComment(comment: Comment) {
        if let commentIndex = comments.firstIndex(where: { $0.id == comment.id }) {
            self.comments[commentIndex].numberOfComments += 1
            let hasCommentFromAuthor = self.comments[commentIndex].hasCommentFromAuthor
            
            if !hasCommentFromAuthor {
                self.comments[commentIndex].hasCommentFromAuthor = comment.uid == self.comments[commentIndex].uid
            }
            
            collectionView.reloadItems(at: [IndexPath(item: commentIndex, section: 1)])
        }
    }
    
    func didLikeComment(comment: Comment) {
        if let commentIndex = comments.firstIndex(where: { $0.id == comment.id }) {
            comments[commentIndex].didLike = comment.didLike
            comments[commentIndex].likes = comment.likes
            collectionView.reloadItems(at: [IndexPath(item: commentIndex, section: 1)])
        }
    }
}

extension DetailsPostViewController: CommentInputAccessoryViewDelegate {

    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        inputView.commentTextView.resignFirstResponder()
        
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        
        CommentService.addComment(comment, for: post, from: currentUser) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                
                strongSelf.post.numberOfComments += 1
                
                strongSelf.users.append(User(dictionary: [
                    "uid": currentUser.uid as Any,
                    "firstName": currentUser.firstName as Any,
                    "lastName": currentUser.lastName as Any,
                    "imageUrl": currentUser.profileUrl as Any,
                    "discipline": currentUser.discipline as Any,
                    "kind": currentUser.kind.rawValue as Any,
                    "speciality": currentUser.speciality as Any]))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.collectionView.performBatchUpdates {
                        strongSelf.comments.insert(comment, at: 0)
                        strongSelf.collectionView.insertItems(at: [IndexPath(item: 0, section: 1)])
                    } completion: { [weak self] _ in
                        guard let strongSelf = self else { return }
                        strongSelf.delegate?.didComment(forPost: strongSelf.post)
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


extension DetailsPostViewController: DeletedContentCellDelegate {
    func didTapReplies(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        guard comment.numberOfComments > 0 else { return }
        if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
            let controller = CommentPostRepliesViewController(comment: comment, user: users[userIndex], post: post, currentUser: user)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapLearnMore() {
        commentInputView.resignFirstResponder()
        commentMenu.showImageSettings(in: view)
    }
}


extension DetailsPostViewController: DetailsPostViewControllerDelegate {
    
    func didEditPost(forPost post: Post) {
        delegate?.didEditPost(forPost: post)
        if post.postId == self.post.postId {
            self.post = post
            collectionView.reloadSections(IndexSet(integer: 0))
            delegate?.didEditPost(forPost: post)
        }
    }
    
    func didTapLikeAction(forPost post: Post) {
        if post.postId == self.post.postId {
            guard let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)), let currentCell = cell as? HomeCellProtocol else { return }
            HapticsManager.shared.vibrate(for: .success)
            handleLikeUnLike(for: currentCell, at: IndexPath(item: 0, section: 0))
        }
    }
    
    func didTapBookmarkAction(forPost post: Post) {
        if post.postId == self.post.postId {
            guard let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)), let currentCell = cell as? HomeCellProtocol else { return }
            HapticsManager.shared.vibrate(for: .success)
            handleBookmarkUnbookmark(for: currentCell, at: IndexPath(item: 0, section: 0))
        }
    }
    
    func didComment(forPost post: Post) {
        if post.postId == self.post.postId {
            fetchComments()
        }
        
        delegate?.didComment(forPost: post)
        
    }
    
    func didDeleteComment(forPost post: Post) {
        if post.postId == self.post.postId {
            fetchComments()
        }
        
        delegate?.didDeleteComment(forPost: post)
    }
}

