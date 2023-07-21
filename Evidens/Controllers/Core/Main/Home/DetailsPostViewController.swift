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

enum DisplayState {
    case none, photo, others

}
protocol DetailsPostViewControllerDelegate: AnyObject {
    func didTapLikeAction(forPost post: Post)
    func didTapBookmarkAction(forPost post: Post)
    func didComment(forPost post: Post)
    func didDeleteComment(forPost post: Post)
    func didEditPost(forPost post: Post)
}

class DetailsPostViewController: UICollectionViewController, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout {
    private var zoomTransitioning = ZoomTransitioning()
    private let referenceMenuLauncher = MEReferenceMenuLauncher()
    var selectedImage: UIImageView!
    
    
    private var commentMenuLauncher = MEContextMenuLauncher(menuLauncherData: Display(content: .comment))
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    weak var delegate: DetailsPostViewControllerDelegate?
    weak var reviewDelegate: DetailsContentReviewDelegate?
    
    private var commentsLastSnapshot: QueryDocumentSnapshot?
    private var commentsLoaded: Bool = false
    
    var isReviewingPost: Bool = false
    var groupId: String?
    
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    private var post: Post
    private var user: User
    private var type: Comment.CommentType
    
    private var comments = [Comment]()
    private var users = [User]()
    
    private let progressIndicator = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        fetchComments()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
        let fullName = user.name()
        let view = MENavigationBarTitleView(fullName: fullName, category: "Post")
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
    }
    
    init(post: Post, user: User, type: Comment.CommentType, collectionViewLayout: UICollectionViewFlowLayout) {
        self.post = post
        self.user = user
        self.type = type
        
        
        
        
        
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
        let view = MENavigationBarTitleView(fullName: fullName, category: "Post")
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        commentInputView.set(placeholder: "Voice your thoughts here...")
    }
    
    
    func configureCollectionView() {
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
    
    
    func fetchComments() {
        CommentService.fetchPostComments(forPost: post, forType: type, lastSnapshot: nil) { snapshot in
            guard !snapshot.isEmpty else {
                self.commentsLoaded = true
                self.collectionView.reloadSections(IndexSet(integer: 1))
                return
            }
            
            self.commentsLastSnapshot = snapshot.documents.last
            self.comments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
            
            CommentService.getPostCommentsValuesFor(forPost: self.post, forComments: self.comments, forType: self.type) { fetchedComments in
                self.comments = fetchedComments
                
                let uids = self.comments.map { $0.uid }
                
                self.comments.enumerated().forEach { index, comment in
                    self.comments[index].isAuthor = comment.uid == self.post.uid
                }
                
                self.comments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                
                UserService.fetchUsers(withUids: uids) { users in
                    self.users = users
                    self.commentsLoaded = true
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    private func getMoreComments() {
        guard commentsLastSnapshot != nil else { return }
        CommentService.fetchPostComments(forPost: post, forType: type, lastSnapshot: commentsLastSnapshot) { snapshot in
            guard !snapshot.isEmpty else {
                return
            }
            
            self.commentsLastSnapshot = snapshot.documents.last
            var newComments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
            CommentService.getPostCommentsValuesFor(forPost: self.post, forComments: newComments, forType: self.type) { fetchedComments in
                newComments = fetchedComments
                newComments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                self.comments.append(contentsOf: newComments)
                let newUserUids = newComments.map { $0.uid }
                let currentUserUids = self.users.map { $0.uid }
                let usersToFetch = newUserUids.filter { !currentUserUids.contains($0) }
                
                guard !usersToFetch.isEmpty else {
                    self.collectionView.reloadData()
                    return
                }
                
                UserService.fetchUsers(withUids: usersToFetch) { users in
                    self.users.append(contentsOf: users)
                    self.collectionView.reloadData()
                }
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
                    cell.authorButton.isHidden = true
                    
                    if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
                        cell.set(user: users[userIndex])
                    }
                    
                    if comments[indexPath.row].hasCommentFromAuthor {
                        if let image = user.profileUrl, !image.isEmpty {
                            cell.ownerPostImageView.sd_setImage(with: URL(string: image))
                        }
                    } else {
                        cell.ownerPostImageView.image = nil
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
    
    func cell(_ cell: UICollectionViewCell, wantsToSeeReference reference: Reference) {
        referenceMenuLauncher.reference = reference
        referenceMenuLauncher.delegate = self
        referenceMenuLauncher.showImageSettings(in: view)
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
            let controller = ReportViewController(source: .post, contentOwnerUid: user.uid!, contentId: post.postId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
            
        case .reference:
            guard let reference = post.reference else { return }
            #warning("fetch reference and show and uncomment")
            //let postReference = Reference(option: reference, referenceText: referenceText)
            //referenceMenuLauncher.reference = postReference
            //referenceMenuLauncher.delegate = self
            //referenceMenuLauncher.showImageSettings(in: view)
        }
    }

    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        commentInputView.commentTextView.becomeFirstResponder()
    }
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell
            currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                switch type {
                case .regular:
                    PostService.unlikePost(post: post) { _ in
                        currentCell.viewModel?.post.likes = post.likes - 1
                        self.delegate?.didTapLikeAction(forPost: post)
                    }
                }
                
            } else {
                //Like post here
                switch type {
                case .regular:
                    PostService.likePost(post: post) { _ in
                        currentCell.viewModel?.post.likes = post.likes + 1
                        self.delegate?.didTapLikeAction(forPost: post)
                    }
                }
            }
            
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            
            currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                switch type {
                case .regular:
                    PostService.unlikePost(post: post) { _ in
                        currentCell.viewModel?.post.likes = post.likes - 1
                        self.delegate?.didTapLikeAction(forPost: post)
                    }
                }
                
            } else {
                //Like post here
                switch type {
                case .regular:
                    PostService.likePost(post: post) { _ in
                        currentCell.viewModel?.post.likes = post.likes + 1
                        self.delegate?.didTapLikeAction(forPost: post)
                    }
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            
            currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                switch type {
                case .regular:
                    PostService.unlikePost(post: post) { _ in
                        currentCell.viewModel?.post.likes = post.likes - 1
                        self.delegate?.didTapLikeAction(forPost: post)
                    }
                }
                
            } else {
                //Like post here
                switch type {
                case .regular:
                    PostService.likePost(post: post) { _ in
                        currentCell.viewModel?.post.likes = post.likes + 1
                        self.delegate?.didTapLikeAction(forPost: post)
                    }
                }
            }

    case is HomeThreeImageTextCell:
        let currentCell = cell as! HomeThreeImageTextCell
        
        currentCell.viewModel?.post.didLike.toggle()
        if post.didLike {
            //Unlike post here
            switch type {
            case .regular:
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.delegate?.didTapLikeAction(forPost: post)
                }
            }
            
        } else {
            //Like post here
            switch type {
            case .regular:
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.delegate?.didTapLikeAction(forPost: post)
                }
            }
        }

        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            
            currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                switch type {
                case .regular:
                    PostService.unlikePost(post: post) { _ in
                        currentCell.viewModel?.post.likes = post.likes - 1
                        self.delegate?.didTapLikeAction(forPost: post)
                    }
                }
                
            } else {
                //Like post here
                switch type {
                case .regular:
                    PostService.likePost(post: post) { _ in
                        currentCell.viewModel?.post.likes = post.likes + 1
                        self.delegate?.didTapLikeAction(forPost: post)
                    }
                }
            }
            
        default:
            print("No cell registered")
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor post: Post, forAuthor user: User) { return }
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                switch type {
                case .regular:
                    PostService.unbookmarkPost(post: post) { _ in
                        self.delegate?.didTapBookmarkAction(forPost: post)
                    }
                }
                //Unbookmark post here
            } else {
                switch type {
                case .regular:
                    //Bookmark post here
                    PostService.bookmarkPost(post: post) { _ in
                        self.delegate?.didTapBookmarkAction(forPost: post)
                        
                    }
                }
            }
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                switch type {
                case .regular:
                    PostService.unbookmarkPost(post: post) { _ in
                        self.delegate?.didTapBookmarkAction(forPost: post)
                    }
                }
                //Unbookmark post here
            } else {
                switch type {
                case .regular:
                    //Bookmark post here
                    PostService.bookmarkPost(post: post) { _ in
                        self.delegate?.didTapBookmarkAction(forPost: post)
                        
                    }
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                switch type {
                case .regular:
                    PostService.unbookmarkPost(post: post) { _ in
                      
                        self.delegate?.didTapBookmarkAction(forPost: post)
                    }
                }
                //Unbookmark post here
            } else {
                switch type {
                case .regular:
                    //Bookmark post here
                    PostService.bookmarkPost(post: post) { _ in
                       
                        self.delegate?.didTapBookmarkAction(forPost: post)
                        
                    }
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                switch type {
                case .regular:
                    PostService.unbookmarkPost(post: post) { _ in
                       
                        self.delegate?.didTapBookmarkAction(forPost: post)
                    }
                }
                //Unbookmark post here
            } else {
                switch type {
                case .regular:
                    //Bookmark post here
                    PostService.bookmarkPost(post: post) { _ in
                      
                        self.delegate?.didTapBookmarkAction(forPost: post)
                        
                    }
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                switch type {
                case .regular:
                    PostService.unbookmarkPost(post: post) { _ in
                      
                        self.delegate?.didTapBookmarkAction(forPost: post)
                    }
                }
                //Unbookmark post here
            } else {
                switch type {
                case .regular:
                    //Bookmark post here
                    PostService.bookmarkPost(post: post) { _ in
                      
                        self.delegate?.didTapBookmarkAction(forPost: post)
                        
                    }
                }
            }
        default:
            print("No cell registered")
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        self.navigationController?.delegate = zoomTransitioning
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
        let controller = PostLikesViewController(contentType: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) { return }
}

extension DetailsPostViewController: CommentCellDelegate {
    func didTapLikeActionFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        let currentCell = cell as! CommentCell
        currentCell.viewModel?.comment.didLike.toggle()
        
        if comment.didLike {
            CommentService.unlikePostComment(forPost: post, forType: type, forCommentUid: comment.id) { _ in
                currentCell.viewModel?.comment.likes = comment.likes - 1
                self.comments[indexPath.row].didLike = false
                self.comments[indexPath.row].likes -= 1
            }
        } else {
            
            CommentService.likePostComment(forPost: post, forType: type, forCommentUid: comment.id) { _ in
                currentCell.viewModel?.comment.likes = comment.likes + 1
                self.comments[indexPath.row].didLike = true
                self.comments[indexPath.row].likes += 1
            }
        }
    }
    
    func wantsToSeeRepliesFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
            let controller = CommentPostRepliesViewController(comment: comment, user: users[userIndex], post: post, type: type, currentUser: user)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: Comment.CommentOptions) {
        switch action {
        case .report:
            let controller = ReportViewController(source: .comment, contentOwnerUid: comment.uid, contentId: comment.id)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        case .delete:
            if let indexPath = self.collectionView.indexPath(for: cell) {
                self.deleteCommentAlert {
                    CommentService.deletePostComment(forPost: self.post, forCommentUid: comment.id) { error in
                        if let error {
                            print(error.localizedDescription)
                        } else {
                            DatabaseManager.shared.deleteRecentComment(forCommentId: comment.id)
                            self.comments[indexPath.item].visible = .deleted
                            self.collectionView.reloadItems(at: [indexPath])
                            self.post.numberOfComments -= 1
                            self.collectionView.reloadSections(IndexSet(integer: 0))
                            self.delegate?.didDeleteComment(forPost: self.post)

                            let popupView = METopPopupView(title: "Comment deleted", image: "checkmark.circle.fill", popUpType: .regular)
                            popupView.showTopPopup(inView: self.view)
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

extension DetailsPostViewController: MEReferenceMenuLauncherDelegate {
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
                if let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
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
        
        CommentService.addComment(comment, for: post, from: currentUser, kind: type) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                
                strongSelf.post.numberOfComments += 1
                
                strongSelf.users.append(User(dictionary: [
                    "uid": currentUser.uid as Any,
                    "firstName": currentUser.firstName as Any,
                    "lastName": currentUser.lastName as Any,
                    "imageUrl": currentUser.profileUrl as Any,
                    "profession": currentUser.discipline as Any,
                    "category": currentUser.kind.rawValue as Any,
                    "speciality": currentUser.speciality as Any]))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    strongSelf.collectionView.performBatchUpdates {
                        strongSelf.comments.insert(comment, at: 0)
                        strongSelf.collectionView.insertItems(at: [IndexPath(item: 0, section: 1)])
                    } completion: { _ in
                        strongSelf.delegate?.didComment(forPost: strongSelf.post)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
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
            let controller = CommentPostRepliesViewController(comment: comment, user: users[userIndex], post: post, type: type, currentUser: user)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapLearnMore() {
        commentInputView.resignFirstResponder()
        commentMenuLauncher.showImageSettings(in: view)
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
            guard let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) else { return }
            switch cell {
            case is HomeTextCell:
                let currentCell = cell as! HomeTextCell
                currentCell.viewModel?.post.didLike.toggle()
                if post.didLike {
                    //Unlike post here
                    currentCell.viewModel?.post.likes = post.likes - 1
                } else {
                    currentCell.viewModel?.post.likes = post.likes + 1
                }
                
            case is HomeImageTextCell:
                let currentCell = cell as! HomeImageTextCell
                
                currentCell.viewModel?.post.didLike.toggle()
                if post.didLike {
                    //Unlike post here
                    currentCell.viewModel?.post.likes = post.likes - 1
                } else {
                    currentCell.viewModel?.post.likes = post.likes + 1
                }
                
            case is HomeTwoImageTextCell:
                let currentCell = cell as! HomeTwoImageTextCell
                
                currentCell.viewModel?.post.didLike.toggle()
                if post.didLike {
                    currentCell.viewModel?.post.likes = post.likes - 1
                } else {
                    currentCell.viewModel?.post.likes = post.likes + 1
                }
                
            case is HomeThreeImageTextCell:
                let currentCell = cell as! HomeThreeImageTextCell
                
                currentCell.viewModel?.post.didLike.toggle()
                if post.didLike {
                    currentCell.viewModel?.post.likes = post.likes - 1
                } else {
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.delegate?.didTapLikeAction(forPost: post)
                }
                
            case is HomeFourImageTextCell:
                let currentCell = cell as! HomeFourImageTextCell
                
                currentCell.viewModel?.post.didLike.toggle()
                if post.didLike {
                    currentCell.viewModel?.post.likes = post.likes - 1
                } else {
                    currentCell.viewModel?.post.likes = post.likes + 1
                }
                
            default:
                break
            }
        }
        
        delegate?.didTapLikeAction(forPost: post)
    }
    
    func didTapBookmarkAction(forPost post: Post) {
        if post.postId == self.post.postId {
            guard let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) else { return }
            switch cell {
            case is HomeTextCell:
                let currentCell = cell as! HomeTextCell
                currentCell.viewModel?.post.didBookmark.toggle()
                if post.didBookmark {
                  
                } else {
                   
                }
            case is HomeImageTextCell:
                let currentCell = cell as! HomeImageTextCell
                currentCell.viewModel?.post.didBookmark.toggle()
                if post.didBookmark {
                  
                } else {
                  
                }
            case is HomeTwoImageTextCell:
                let currentCell = cell as! HomeTwoImageTextCell
                currentCell.viewModel?.post.didBookmark.toggle()
                if post.didBookmark {
                  
                } else {
                   
                }

            case is HomeThreeImageTextCell:
                let currentCell = cell as! HomeThreeImageTextCell
                currentCell.viewModel?.post.didBookmark.toggle()
                if post.didBookmark {
                  
                } else {
                   
                }
            case is HomeFourImageTextCell:
                let currentCell = cell as! HomeFourImageTextCell
                currentCell.viewModel?.post.didBookmark.toggle()
                if post.didBookmark {
                   
                } else {
                   
                }
            default:
                print("No cell registered")
            }
        }
        
        delegate?.didTapBookmarkAction(forPost: post)
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

