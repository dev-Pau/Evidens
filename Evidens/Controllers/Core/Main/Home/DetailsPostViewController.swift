//
//  DetailsPostViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/7/22.
//

import UIKit
import Firebase
import JGProgressHUD

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let commentHeaderReuseIdentifier = "CommentHeaderReuseIdentifier"
private let commentReuseIdentifier = "CommentCellReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"

private let homeTextCellReuseIdentifier = "CellTextReuseIdentifier"
private let homeImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let homeTwoImageTextCellReuseIdentifier = "HomeTwoImageTextCellReuseIdentifier"
private let homeThreeImageTextCellReuseIdentifier = "HomeThreeImageTextCellReuseIdentifier"
private let homeFourImageTextCellReuseIdentifier = "HomeFourImageTextCellReuseIdentifier"

enum DisplayState: Int {
    case none
    case photo
    case others
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

    var selectedImage: UIImageView!
    
    weak var delegate: DetailsPostViewControllerDelegate?
    weak var reviewDelegate: DetailsContentReviewDelegate?
    
    private var commentsLastSnapshot: QueryDocumentSnapshot?
    private var commentsLoaded: Bool = false
    
    var isReviewingPost: Bool = false
    var groupId: String?
    
    private var displayState: DisplayState = .none
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.delegate = self
        
        switch displayState {
            
        case .none:
            break
        case .photo:
            return
        case .others:
            let view = MENavigationBarTitleView(fullName: user.firstName! + " " + user.lastName!, category: "Post")
            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
            navigationItem.titleView = view
        }
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
    
    func fetchComments() {
        CommentService.fetchComments(forPost: post, forType: type, lastSnapshot: nil) { snapshot in
            guard !snapshot.isEmpty else {
                self.commentsLoaded = true
                self.collectionView.reloadSections(IndexSet(integer: 1))
                return
            }
            
            self.commentsLastSnapshot = snapshot.documents.last
            self.comments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
            let userUids = self.comments.map { $0.uid }
            UserService.fetchUsers(withUids: userUids) { users in
                self.users = users
                self.commentsLoaded = true
                self.collectionView.reloadSections(IndexSet(integer: 1))
            }
        }
    }
    
    private func configureNavigationBar() {
        let view = MENavigationBarTitleView(fullName: user.firstName! + " " + user.lastName!, category: "Post")
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view

        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: commentReuseIdentifier)
        collectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: commentHeaderReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        
        switch post.type {
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
        case .document:
            break
        case .poll:
            break
        case .video:
            break
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if commentsLoaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: commentHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
            header.configureWith(title: "   Comments", linkText: comments.count >= 15 ? "See All   " : "")
            if comments.count < 15 { header.hideSeeAllButton() }
            header.delegate = self
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? CGSize.zero : commentsLoaded ? comments.isEmpty ? CGSize.zero : CGSize(width: view.frame.width, height: 55) : CGSize(width: view.frame.width, height: 55)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : commentsLoaded ? comments.isEmpty ? 1 : comments.count : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if post.type.postType == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTextCellReuseIdentifier, for: indexPath) as! HomeTextCell
                cell.layer.borderWidth = 0
                cell.delegate = self
                cell.postTextLabel.numberOfLines = 0
                cell.viewModel = PostViewModel(post: post)
                cell.set(user: user)
                if isReviewingPost {
                    cell.reviewDelegate = self
                    cell.configureWithReviewOptions()
                }
                return cell
            } else if post.type.postType == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                cell.delegate = self
                cell.layer.borderWidth = 0
                cell.postTextLabel.numberOfLines = 0
                cell.viewModel = PostViewModel(post: post)
                cell.set(user: user)
                if isReviewingPost {
                    cell.reviewDelegate = self
                    cell.configureWithReviewOptions()
                }
                return cell
                
            } else if post.type.postType == 2 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                cell.delegate = self
                cell.postTextLabel.numberOfLines = 0
                cell.layer.borderWidth = 0
                cell.viewModel = PostViewModel(post: post)
                cell.set(user: user)
                if isReviewingPost {
                    cell.reviewDelegate = self
                    cell.configureWithReviewOptions()
                }
                return cell
            } else if post.type.postType == 3 {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                cell.delegate = self
                cell.layer.borderWidth = 0
                cell.postTextLabel.numberOfLines = 0
                cell.viewModel = PostViewModel(post: post)
                cell.set(user: user)
                if isReviewingPost {
                    cell.reviewDelegate = self
                    cell.configureWithReviewOptions()
                }
                return cell
            } else if post.type.postType == 4 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                cell.delegate = self
                cell.postTextLabel.numberOfLines = 0
                cell.layer.borderWidth = 0
                cell.viewModel = PostViewModel(post: post)
                cell.set(user: user)
                if isReviewingPost {
                    cell.reviewDelegate = self
                    cell.configureWithReviewOptions()
                }
                return cell
            }
            else {
                return UICollectionViewCell()
            }
        } else {
            if comments.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.multiplier = 0.5
                cell.configure(image: UIImage(named: "content.empty"), title: "No comments found", description: "This post has no comments, but it won't be that way for long. Be the first to comment.", buttonText: .comment)
                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentReuseIdentifier, for: indexPath) as! CommentCell
                cell.authorButton.isHidden = true
                cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
                cell.delegate = self
                
                let userIndex = users.firstIndex { user in
                    if user.uid == comments[indexPath.row].uid {
                        return true
                    }
                    return false
                }
                
                if let userIndex = userIndex {
                    cell.set(user: users[userIndex])
                }
                
                return cell
            }
        }
    }
}

extension DetailsPostViewController: HomeCellDelegate {
    func cell(_ cell: UICollectionViewCell, didTapMenuOptionsFor post: Post, option: Post.PostMenuOptions) {
        switch option {
        case .delete:
            print("delete post here")
        case .edit:
            let controller = EditPostViewController(post: post)
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            
            present(nav, animated: true)
        case .report:
            let reportPopup = METopPopupView(title: "Post reported", image: "flag.fill", popUpType: .regular)
            reportPopup.showTopPopup(inView: self.view)
            
        }
    }

    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        let controller = CommentPostViewController(post: post, user: user, type: type)
        controller.hidesBottomBarWhenPushed = true
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        displayState = .others
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        
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
                case .group:
                    //GroupService.likeGroupPost(groupId: post.groupId!, post: post) { _ in
                    //  currentCell.viewModel?.post.likes = post.likes + 1+
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.delegate?.didTapLikeAction(forPost: post)
                    // }
                }
                
            } else {
                //Like post here
                switch type {
                case .regular:
                    PostService.likePost(post: post) { _ in
                        currentCell.viewModel?.post.likes = post.likes + 1
                        self.delegate?.didTapLikeAction(forPost: post)
                        NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                    }
                case .group:
                    //GroupService.likeGroupPost(groupId: post.groupId!, post: post) { _ in
                    //  currentCell.viewModel?.post.likes = post.likes + 1
                    self.delegate?.didTapLikeAction(forPost: post)
                    currentCell.viewModel?.post.likes = post.likes + 1
                    //}
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
                case .group:
                    //GroupService.likeGroupPost(groupId: post.groupId!, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.delegate?.didTapLikeAction(forPost: post)
                    // }
                }
                
            } else {
                //Like post here
                switch type {
                case .regular:
                    PostService.likePost(post: post) { _ in
                        currentCell.viewModel?.post.likes = post.likes + 1
                        self.delegate?.didTapLikeAction(forPost: post)
                        NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                    }
                case .group:
                    //GroupService.likeGroupPost(groupId: post.groupId!, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.delegate?.didTapLikeAction(forPost: post)
                    //}
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
                case .group:
                    //GroupService.likeGroupPost(groupId: post.groupId!, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.delegate?.didTapLikeAction(forPost: post)
                    // }
                }
                
            } else {
                //Like post here
                switch type {
                case .regular:
                    PostService.likePost(post: post) { _ in
                        currentCell.viewModel?.post.likes = post.likes + 1
                        self.delegate?.didTapLikeAction(forPost: post)
                        NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                    }
                case .group:
                    //GroupService.likeGroupPost(groupId: post.groupId!, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.delegate?.didTapLikeAction(forPost: post)
                    //}
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
            case .group:
                //GroupService.likeGroupPost(groupId: post.groupId!, post: post) { _ in
                currentCell.viewModel?.post.likes = post.likes - 1
                self.delegate?.didTapLikeAction(forPost: post)
                // }
            }
            
        } else {
            //Like post here
            switch type {
            case .regular:
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.delegate?.didTapLikeAction(forPost: post)
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            case .group:
                //GroupService.likeGroupPost(groupId: post.groupId!, post: post) { _ in
                currentCell.viewModel?.post.likes = post.likes + 1
                self.delegate?.didTapLikeAction(forPost: post)
                //}
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
                case .group:
                    //GroupService.likeGroupPost(groupId: post.groupId!, post: post) { _ in
                      currentCell.viewModel?.post.likes = post.likes - 1
                        self.delegate?.didTapLikeAction(forPost: post)
                   // }
                }
                
            } else {
                //Like post here
                switch type {
                case .regular:
                    PostService.likePost(post: post) { _ in
                        currentCell.viewModel?.post.likes = post.likes + 1
                        self.delegate?.didTapLikeAction(forPost: post)
                        NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                    }
                case .group:
                    //GroupService.likeGroupPost(groupId: post.groupId!, post: post) { _ in
                      currentCell.viewModel?.post.likes = post.likes + 1
                        self.delegate?.didTapLikeAction(forPost: post)
                    //}
                }
            }
            
            
        default:
            print("No cell registered")
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
       
            let controller = UserProfileViewController(user: user)
        displayState = .others
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
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
                        currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                        self.delegate?.didTapBookmarkAction(forPost: post)
                    }
                case .group:
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
                //Unbookmark post here
            } else {
                switch type {
                case .regular:
                    //Bookmark post here
                    PostService.bookmarkPost(post: post) { _ in
                        currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                        self.delegate?.didTapBookmarkAction(forPost: post)
                        
                    }
                case .group:
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            }
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                switch type {
                case .regular:
                    PostService.unbookmarkPost(post: post) { _ in
                        currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                        self.delegate?.didTapBookmarkAction(forPost: post)
                    }
                case .group:
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
                //Unbookmark post here
            } else {
                switch type {
                case .regular:
                    //Bookmark post here
                    PostService.bookmarkPost(post: post) { _ in
                        currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                        self.delegate?.didTapBookmarkAction(forPost: post)
                        
                    }
                case .group:
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                switch type {
                case .regular:
                    PostService.unbookmarkPost(post: post) { _ in
                        currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                        self.delegate?.didTapBookmarkAction(forPost: post)
                    }
                case .group:
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
                //Unbookmark post here
            } else {
                switch type {
                case .regular:
                    //Bookmark post here
                    PostService.bookmarkPost(post: post) { _ in
                        currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                        self.delegate?.didTapBookmarkAction(forPost: post)
                        
                    }
                case .group:
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                switch type {
                case .regular:
                    PostService.unbookmarkPost(post: post) { _ in
                        currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                        self.delegate?.didTapBookmarkAction(forPost: post)
                    }
                case .group:
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
                //Unbookmark post here
            } else {
                switch type {
                case .regular:
                    //Bookmark post here
                    PostService.bookmarkPost(post: post) { _ in
                        currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                        self.delegate?.didTapBookmarkAction(forPost: post)
                        
                    }
                case .group:
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                switch type {
                case .regular:
                    PostService.unbookmarkPost(post: post) { _ in
                        currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                        self.delegate?.didTapBookmarkAction(forPost: post)
                    }
                case .group:
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
                //Unbookmark post here
            } else {
                switch type {
                case .regular:
                    //Bookmark post here
                    PostService.bookmarkPost(post: post) { _ in
                        currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                        self.delegate?.didTapBookmarkAction(forPost: post)
                        
                    }
                case .group:
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            }
        default:
            print("No cell registered")
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        //self.navigationController?.delegate = self
        
        let map: [UIImage] = image.compactMap { $0.image }
        self.navigationController?.delegate = zoomTransitioning
        selectedImage = image[index]
        displayState = .photo
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        //controller.customDelegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .clear
        navigationItem.backBarButtonItem = backItem

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
        let controller = PostLikesViewController(contentType: post)
        displayState = .others
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) {
        return
    }
}

extension DetailsPostViewController: CommentCellDelegate {
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: Comment.CommentOptions) {
        switch action {
        case .report:
            reportCommentAlert {
                DatabaseManager.shared.reportPostComment(forCommentId: comment.id) { reported in
                    if reported {
                        let popupView = METopPopupView(title: "Comment reported", image: "exclamationmark.bubble", popUpType: .destructive)
                        popupView.showTopPopup(inView: self.view)
                    }
                }
            }
        case .delete:
            if let indexPath = self.collectionView.indexPath(for: cell) {
                self.deleteCommentAlert {
                    CommentService.deletePostComment(forPost: self.post, forCommentUid: comment.id) { deleted in
                        if deleted {
                            DatabaseManager.shared.deleteRecentComment(forCommentId: comment.id)
                            self.post.numberOfComments -= 1
                            self.collectionView.performBatchUpdates {
                                self.comments.remove(at: indexPath.item)
                                self.collectionView.deleteItems(at: [indexPath])
                            }
                            self.collectionView.reloadSections(IndexSet(integer: 0))
                            self.delegate?.didDeleteComment(forPost: self.post)
                            let popupView = METopPopupView(title: "Comment deleted", image: "trash", popUpType: .destructive)
                            popupView.showTopPopup(inView: self.view)
                        }
                        else {
                            print("couldnt remove comment")
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
        displayState = .others
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = .label
        navigationItem.backBarButtonItem = backButton
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension DetailsPostViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension DetailsPostViewController: CommentPostViewControllerDelegate {
    func didDeletePostComment(post: Post, comment: Comment) {
        if let commentIndex = comments.firstIndex(where: { $0.id == comment.id }) {
            self.post.numberOfComments -= 1
            comments.remove(at: commentIndex)
            collectionView.reloadData()
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [IndexPath(item: commentIndex, section: 1)])
                delegate?.didDeleteComment(forPost: post)
            }
        }
    }
    
    func didCommentPost(post: Post, user: User, comment: Comment) {
        if comments.isEmpty {
            comments = [comment]
            users = [user]
        } else {
            comments.append(comment)
            users.append(user)
        }

        self.post.numberOfComments += 1
        collectionView.reloadData()
        delegate?.didComment(forPost: post)
    }
}

extension DetailsPostViewController: ReviewContentGroupDelegate {
    func didTapAcceptContent(contentId: String, type: ContentGroup.GroupContentType) {
        guard let groupId = groupId else { return }
        progressIndicator.show(in: view)
        DatabaseManager.shared.approveGroupPost(withGroupId: groupId, withPostId: contentId) { approved in
            self.progressIndicator.dismiss(animated: true)
            if approved {
                self.reviewDelegate?.didTapAcceptContent(type: .post, contentId: contentId)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func didTapCancelContent(contentId: String, type: ContentGroup.GroupContentType) {
        guard let groupId = groupId else { return }
        displayMEDestructiveAlert(withTitle: "Delete post", withMessage: "Are you sure you want to delete this post?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
            self.progressIndicator.show(in: self.view)
            DatabaseManager.shared.denyGroupPost(withGroupId: groupId, withPostId: contentId) { denied in
                self.progressIndicator.dismiss(animated: true)
                if denied {
                    self.reviewDelegate?.didTapCancelContent(type: .post, contentId: contentId)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
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
    func didTapEmptyCellButton(option: EmptyCellButtonOptions) {
        let controller = CommentPostViewController(post: post, user: user, type: type)
        controller.hidesBottomBarWhenPushed = true
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        displayState = .others
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension DetailsPostViewController: MainSearchHeaderDelegate {
    func didTapSeeAll(_ header: UICollectionReusableView) {
        let controller = CommentPostViewController(post: post, user: user, type: type)
        controller.hidesBottomBarWhenPushed = true
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        displayState = .others
        navigationController?.pushViewController(controller, animated: true)
    }
}
