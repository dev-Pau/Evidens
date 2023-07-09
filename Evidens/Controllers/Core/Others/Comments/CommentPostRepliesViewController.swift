//
//  CommentRepliesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/4/23.
//

import UIKit
import Firebase

private let loadingCellReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let commentCellReuseIdentifier = "CommentCellReuseIdentifier"

protocol CommentsRepliesViewControllerDelegate: AnyObject {
    func didLikeComment(comment: Comment)
    func didAddReplyToComment(comment: Comment)
    func didDeleteReply(withRefComment refComment: Comment, comment: Comment)
    func didDeleteComment(comment: Comment)
}

class CommentPostRepliesViewController: UICollectionViewController {
    private let currentUser: User
    private let type: Comment.CommentType
    private let post: Post
    private var comment: Comment
    private var comments = [Comment]()
    private let user: User
    private var users = [User]()
    private var referenceCommentId: String
    private var commentsLoaded: Bool = false
    private var lastReplySnapshot: QueryDocumentSnapshot?
    private let repliesEnabled: Bool
    weak var delegate: CommentsRepliesViewControllerDelegate?
    private var bottomAnchorConstraint: NSLayoutConstraint!

    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    init(referenceCommentId: String? = nil, comment: Comment, user: User, post: Post, type: Comment.CommentType, currentUser: User, repliesEnabled: Bool? = true) {
        self.comment = comment
        self.user = user
        self.post = post
        self.type = type
        self.currentUser = currentUser
        self.repliesEnabled = repliesEnabled ?? true
        self.referenceCommentId = referenceCommentId ?? ""
        let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            section.contentInsets.leading = sectionIndex == 0 ? .zero : 50
            return section
       }

        super.init(collectionViewLayout: compositionalLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        configureCollectionView()
        configureNavigationBar()
        configureUI()
        fetchRepliesForComment()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func configureNavigationBar() {
        title = "Replies"
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
    
    private func fetchRepliesForComment() {
        guard repliesEnabled else {
            commentsLoaded = true
            return
        }
        
        CommentService.fetchRepliesForPostComment(forPost: post, type: type, forCommentId: comment.id, lastSnapshot: nil) { snapshot in
            guard !snapshot.isEmpty else {
                self.commentsLoaded = true
                self.collectionView.reloadData()
                return
            }
            
            self.lastReplySnapshot = snapshot.documents.last
            let comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
            
            let replyUids = comments.map { $0.uid }

            CommentService.getPostRepliesCommmentsValuesFor(forPost: self.post, forComment: self.comment, forReplies: comments, forType: self.type) { fetchedReplies in
                UserService.fetchUsers(withUids: replyUids) { users in
                    self.users = users
                    self.comments = fetchedReplies.sorted { $0.timestamp.seconds > $1.timestamp.seconds }
                    self.commentsLoaded = true
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MELoadingCell.self, forCellWithReuseIdentifier: loadingCellReuseIdentifier)
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: commentCellReuseIdentifier)
        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }
    
    private func configureUI() {
        guard let imageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String, imageUrl != "" else { return }
        commentInputView.profileImageView.sd_setImage(with: URL(string: imageUrl))
    }
}

extension CommentPostRepliesViewController: UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return repliesEnabled ? 2 : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : commentsLoaded ? comments.count : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 && !commentsLoaded {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellReuseIdentifier, for: indexPath) as! MELoadingCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! CommentCell
            cell.delegate = self
            cell.showingRepliesForComment = indexPath.section == 0 ? true : false
            cell.isReply = indexPath.section == 1 ? true : false
            cell.viewModel = CommentViewModel(comment: indexPath.section == 0 ? comment : comments[indexPath.row])
            if indexPath.section == 0 {
                cell.set(user: user)
            } else {
                let userIndex = users.firstIndex { user in
                    return user.uid == comments[indexPath.row].uid
                }!
                
                cell.set(user: users[userIndex])
            }
            
            if indexPath.section == 1 {
                cell.separatorView.isHidden = true
                cell.commentActionButtons.commentButton.isHidden = true
            } else {
                if repliesEnabled {
                    cell.separatorView.isHidden = false
                    cell.commentActionButtons.commentButton.isHidden = false
                } else {
                    cell.separatorView.isHidden = false
                    cell.commentActionButtons.commentButton.isHidden = true
                }
            }
            
            return cell 
        }
    }
}

extension CommentPostRepliesViewController: CommentInputAccessoryViewDelegate {
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        CommentService.uploadPostReplyComment(comment: comment, commentId: self.comment.id, post: post, user: user, type: type) { commentId in
            self.comment.numberOfComments += 1
            
            inputView.clearCommentTextView()
            
            let isAuthor = uid == self.post.ownerUid ? true : false
            
            let addedComment = Comment(dictionary: [
                "comment": comment,
                "uid": self.currentUser.uid as Any,
                "id": commentId as Any,
                "timestamp": "Now" as Any,
                "isTextFromAuthor": false as Bool,
                "isAuthor": isAuthor as Any])
            
            self.comments.append(addedComment)
            
            self.users.append(User(dictionary: [
                "uid": self.currentUser.uid as Any,
                "firstName": self.currentUser.firstName as Any,
                "lastName": self.currentUser.lastName as Any,
                "profileImageUrl": self.currentUser.profileImageUrl as Any,
                "profession": self.currentUser.profession as Any,
                "category": self.currentUser.category.rawValue as Any,
                "speciality": self.currentUser.speciality as Any]))
            //}
            
            let indexPath = IndexPath(item: self.comments.count - 1, section: 1)
            self.collectionView.insertItems(at: [indexPath])
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            self.delegate?.didAddReplyToComment(comment: self.comment)
            //self.delegate?.didCommentPost(post: self.post, user: self.currentUser, comment: addedComment)
            /*
             self.collectionView.insertItems(at: [indexPath])
             let indexPath = IndexPath(item: 1, section: 0)
             self.collectionView.insertItems(at: [indexPath])
             self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
             
             self.delegate?.didCommentPost(post: self.post, user: self.currentUser, comment: addedComment)
             
             NotificationService.uploadNotification(toUid: self.post.ownerUid, fromUser: self.currentUser, type: .commentPost, post: self.post, withCommentId: commentUid)
             */
        }
    }
}

extension CommentPostRepliesViewController: CommentCellDelegate {
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: Comment.CommentOptions) {
        
        #warning("Implement")
    }
    
    func didTapProfile(forUser user: User) {
        /*
        guard let rootController = navigationController?.viewControllers.first as? CommentPostViewController else {
            return
            
        }
        rootController.didTapProfile(forUser: user)
         */
        
    }
    
    func wantsToSeeRepliesFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard repliesEnabled else { return }
        print("1")
        if let indexPath = collectionView.indexPath(for: cell) {
            guard indexPath.section != 0 else { return }
            if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
                print("4")
                let controller = CommentPostRepliesViewController(referenceCommentId: self.comment.id, comment: comment, user: users[userIndex], post: post, type: type, currentUser: currentUser, repliesEnabled: false)
                controller.delegate = self
                let backItem = UIBarButtonItem()
                backItem.tintColor = .label
                backItem.title = ""
                navigationItem.backBarButtonItem = backItem
                
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func didTapLikeActionFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        let currentCell = cell as! CommentCell
        currentCell.viewModel?.comment.didLike.toggle()
        
        
        if indexPath.section == 0 && repliesEnabled {
            // Comment like
            if comment.didLike {
                
                CommentService.unlikePostComment(forPost: post, forType: type, forCommentUid: comment.id) { _ in
                    currentCell.viewModel?.comment.likes = comment.likes - 1
                    self.comment.didLike = false
                    self.comment.likes -= 1
                    self.delegate?.didLikeComment(comment: self.comment)
                }
                
            } else {
                
                CommentService.likePostComment(forPost: post, forType: type, forCommentUid: comment.id) { _ in
                    currentCell.viewModel?.comment.likes = comment.likes + 1
                    self.comment.didLike = true
                    self.comment.likes += 1
                    self.delegate?.didLikeComment(comment: self.comment)
                }
            }
        } else {
            // Reply like
            if comment.didLike {
                
                CommentService.unlikePostReplyComment(forPost: post, forType: type, forCommentUid: repliesEnabled ? self.comment.id : referenceCommentId, forReplyId: repliesEnabled ? comments[indexPath.row].id : self.comment.id) { _ in
                    currentCell.viewModel?.comment.likes = comment.likes - 1
                    if self.repliesEnabled {
                        self.comments[indexPath.row].didLike = false
                        self.comments[indexPath.row].likes -= 1
                        self.delegate?.didLikeComment(comment: self.comments[indexPath.row])
                    } else {
                        self.comment.didLike = false
                        self.comment.likes -= 1
                        self.delegate?.didLikeComment(comment: self.comment)
                    }
                }
            } else {
                CommentService.likePostReplyComment(forPost: post, forType: type, forCommentUid: repliesEnabled ? self.comment.id : referenceCommentId, forReplyId: repliesEnabled ? comments[indexPath.row].id : self.comment.id) { _ in
                    currentCell.viewModel?.comment.likes = comment.likes + 1
                    if self.repliesEnabled {
                        self.comments[indexPath.row].didLike = true
                        self.comments[indexPath.row].likes += 1
                        self.delegate?.didLikeComment(comment: self.comments[indexPath.row])
                    } else {
                        self.comment.didLike = true
                        self.comment.likes += 1
                        self.delegate?.didLikeComment(comment: self.comment)
                    }
                }
            }
        }
    }
}

extension CommentPostRepliesViewController: CommentsRepliesViewControllerDelegate {
    // This will never get called because this call will come from another CommentRepliesViewController on top of it, which is not available to comment there, only like
    func didAddReplyToComment(comment: Comment) { return }
    
    func didLikeComment(comment: Comment) {
        if let commentIndex = comments.firstIndex(where: { $0.id == comment.id }) {
            comments[commentIndex].didLike = comment.didLike
            comments[commentIndex].likes = comment.likes
            collectionView.reloadItems(at: [IndexPath(item: commentIndex, section: 1)])
        }
    }
}
