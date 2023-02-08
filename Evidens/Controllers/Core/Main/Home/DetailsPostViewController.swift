//
//  DetailsPostViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/7/22.
//

import UIKit
import JGProgressHUD

private let reuseIdentifier = "CellTextReuseIdentifier"
private let headerReuseIdentifier = "HeaderReuseIdentifier"
private let commentReuseIdentifier = "CommentCellReuseIdentifier"

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
    func didEditPost(forPost post: Post)
}

class DetailsPostViewController: UICollectionViewController, UINavigationControllerDelegate {
    
    private var commentMenu = CommentsMenuLauncher()
    private var zoomTransitioning = ZoomTransitioning()

    var selectedImage: UIImageView!
    
    weak var delegate: DetailsPostViewControllerDelegate?
    weak var reviewDelegate: DetailsContentReviewDelegate?
    
    var indexPathSelected: Int?
    
    private var loaded: Bool = false
    
    var isReviewingPost: Bool = false
    var groupId: String?
    
    private var displayState: DisplayState = .none
    
    private var post: Post
    private var user: User

    private var comments: [Comment]?

    private var ownerComments: [User] = []
    
    
    private let progressIndicator = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        switch displayState {
            
        case .none:
            break
        case .photo:
            return
        case .others:
            let view = MENavigationBarTitleView(fullName: post.ownerFirstName + " " + post.ownerLastName, category: "Post")
            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
            navigationItem.titleView = view
        }
         */
         
        
        loaded = true
        configureNavigationBar()
        configureCollectionView()
        fetchComments()
        checkIfUserLikedPosts()
        checkIfUserBookmarkedPost()
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

    init(post: Post, user: User, collectionViewLayout: UICollectionViewFlowLayout) {
        self.post = post
        self.user = user

        super.init(collectionViewLayout: collectionViewLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchComments() {
        CommentService.fetchComments(forPost: post.postId) { fetchedComments in
            self.comments = fetchedComments
            
            fetchedComments.forEach { comment in
                UserService.fetchUser(withUid: comment.uid) { user in
                    self.ownerComments.append(user)
                    if self.ownerComments.count == fetchedComments.count {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
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
        collectionView.register(CommentsSectionHeader.self, forCellWithReuseIdentifier: headerReuseIdentifier)

        switch post.type {
        case .plainText:
            collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)
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
    
    func checkIfUserLikedPosts() {
        PostService.checkIfUserLikedPost(post: post) { didLike in
            self.post.didLike = didLike
            self.collectionView.reloadData()
        }
    }
    
    func checkIfUserBookmarkedPost() {
        PostService.checkIfUserBookmarkedPost(post: post) { didBookmark in
            self.post.didBookmark = didBookmark
            self.collectionView.reloadData()
        }
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if let comments = comments {
                if comments.isEmpty { return 0 } else {
                    if section == 1 {
                        return 1
                    } else {
                        return comments.count
                    }
                }
            }
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if post.type.postType == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTextCell
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
            if let comments = comments {
                if indexPath.section == 1 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! CommentsSectionHeader
                    cell.backgroundColor = .systemBackground
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentReuseIdentifier, for: indexPath) as! CommentCell
                    cell.authorButton.isHidden = true
                    cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
                    cell.delegate = self
                    
                    let userIndex = ownerComments.firstIndex { user in
                        if user.uid == comments[indexPath.row].uid {
                            return true
                        }
                        return false
                    }
                    
                    if let userIndex = userIndex {
                        cell.set(user: ownerComments[userIndex])
                    }

                    cell.backgroundColor = .systemBackground
                    return cell
                }
            } else {
                return UICollectionViewCell()
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
        let controller = CommentPostViewController(post: post, user: user)
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
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.delegate?.didTapLikeAction(forPost: post)
                    
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.delegate?.didTapLikeAction(forPost: post)
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            }
            
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            
            currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.delegate?.didTapLikeAction(forPost: post)
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in

                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.delegate?.didTapLikeAction(forPost: post)
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                    }
                }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            
            currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.delegate?.didTapLikeAction(forPost: post)
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.delegate?.didTapLikeAction(forPost: post)
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            
            currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.delegate?.didTapLikeAction(forPost: post)
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.delegate?.didTapLikeAction(forPost: post)
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            
            currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.delegate?.didTapLikeAction(forPost: post)
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.delegate?.didTapLikeAction(forPost: post)
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
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
                //Unbookmark post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            } else {
                //Bookmark post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            }
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                //Unbookmark post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            } else {
                //Bookmark post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                //Unbookmark post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            } else {
                //Bookmark post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                //Unbookmark post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            } else {
                //Bookmark post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                //Unbookmark post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.delegate?.didTapBookmarkAction(forPost: post)
                }
            } else {
                //Bookmark post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
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

    func didTapProfile(forUser user: User) {
        let controller = UserProfileViewController(user: user)
        displayState = .others
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = .label
        navigationItem.backBarButtonItem = backButton
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment) {
        commentMenu.comment = comment
        commentMenu.showCommentsSettings(in: view)
        
        commentMenu.completion = { delete in
            if let indexPath = self.collectionView.indexPath(for: cell) {
                self.deleteCommentAlert {
                    CommentService.deletePostComment(forPost: self.post, forCommentUid: comment.id) { deleted in
                        if deleted {
                            DatabaseManager.shared.deleteRecentComment(forCommentId: comment.id)
                            
                            self.collectionView.performBatchUpdates {
                                self.comments!.remove(at: indexPath.item)
                                self.collectionView.deleteItems(at: [indexPath])
                            }
                            let popupView = METopPopupView(title: "Comment deleted", image: "trash", popUpType: .destructive)
                            popupView.showTopPopup(inView: self.view)
                        }
                        else {
                            print("couldnt remove comment")
                        }
                    }
                }
            }
        }
    }
}

extension DetailsPostViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension DetailsPostViewController: CommentPostViewControllerDelegate {
    func didCommentPost(post: Post, user: User, comment: Comment) {
        comments?.append(comment)
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
