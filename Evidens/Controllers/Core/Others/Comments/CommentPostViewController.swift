//
//  CommentViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/11/21.
//

import UIKit
import Firebase

private let commentCellReuseIdentifier = "CommentCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"

protocol CommentPostViewControllerDelegate: AnyObject {
    func didCommentPost(post: Post, user: User, comment: Comment)
    func didDeletePostComment(post: Post, comment: Comment)
}

class CommentPostViewController: UICollectionViewController {
    
    //MARK: - Properties
    weak var delegate: CommentPostViewControllerDelegate?
    
    private var post: Post
    private var user: User
    private var currentUser: User
    private var type: Comment.CommentType
    private var reference: Reference?
    private var commentsLoaded: Bool = false
    private var lastCommentSnapshot: QueryDocumentSnapshot?
    
    private var comments = [Comment]()
    private var users = [User]()
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    //MARK: - Lifecycle
    
    init(post: Post, user: User, type: Comment.CommentType, currentUser: User) {
        self.post = post
        self.user = user
        self.type = type
        self.currentUser = currentUser
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        fetchComments()
    }
    
    override var inputAccessoryView: UIView? {
        get { return commentInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK: - API
    
    func fetchComments() {
        // If user post has text, append it as first element of the comment list with the owner user information
        if !post.postText.isEmpty {
            comments.append(Comment(dictionary: [
                "comment": post.postText,
                "uid": user.uid as Any,
                "timestamp": post.timestamp,
                "isAuthor": true as Bool,
                "isTextFromAuthor": true as Bool as Any]))
            
            users.append(User(dictionary: [
                "uid": user.uid as Any,
                "firstName": user.firstName as Any,
                "lastName": user.lastName as Any,
                "profileImageUrl": user.profileImageUrl as Any,
                "profession": user.profession as Any,
                "category": user.category.rawValue as Any,
                "speciality": user.speciality as Any]))
        }

        CommentService.fetchComments(forPost: post, forType: type, lastSnapshot: nil) { snapshot in
            if snapshot.isEmpty {
                // No comments uploaded
                self.commentsLoaded = true
                self.collectionView.reloadData()
                
            } else {
                // Found comments
                self.lastCommentSnapshot = snapshot.documents.last
                let comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
                
                // Get comment post values
                CommentService.getPostCommmentsValuesFor(forPost: self.post, forComments: comments, forType: self.type) { fetchedComments in
                    self.comments.append(contentsOf: fetchedComments)
                    let uids = comments.map { $0.uid }
                    UserService.fetchUsers(withUids: uids) { users in
                        self.users.append(contentsOf: users)
                        self.commentsLoaded = true
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: - Helpers
    
    func configureCollectionView() {
        navigationItem.title = "Comments"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: commentCellReuseIdentifier)
        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
     
    }
    
    private func configureUI() {
        guard let imageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String, imageUrl != "" else { return }
        commentInputView.profileImageView.sd_setImage(with: URL(string: imageUrl))
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreComments()
        }
    }
    
    private func getMoreComments() {
        CommentService.fetchComments(forPost: post, forType: type, lastSnapshot: lastCommentSnapshot) { snapshot in
            guard !snapshot.isEmpty else { return }
            self.lastCommentSnapshot = snapshot.documents.last
            let newComments = snapshot.documents.map( { Comment(dictionary: $0.data()) })
            let newOwnerUids = newComments.map({ $0.uid })
            CommentService.getPostCommmentsValuesFor(forPost: self.post, forComments: newComments, forType: self.type) { newCommentsFetched in
                self.comments.append(contentsOf: newCommentsFetched)
                UserService.fetchUsers(withUids: newOwnerUids) { newUsers in
                    self.users.append(contentsOf: newUsers)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}


//MARK: - UICollectionViewDataSource

extension CommentPostViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commentsLoaded ? comments.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return commentsLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! CommentCell
        cell.delegate = self
        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
        
        let userIndex = users.firstIndex { user in
            return user.uid == comments[indexPath.row].uid
        }!
        
        cell.set(user: users[userIndex])
        
        if comments[indexPath.row].hasCommentFromAuthor {
            cell.commentActionButtons.ownerPostImageView.sd_setImage(with: URL(string: user.profileImageUrl! ))
        } else {
            cell.commentActionButtons.ownerPostImageView.image = nil
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
}

extension CommentPostViewController: CommentCellDelegate {
    func didTapLikeActionFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        let currentCell = cell as! CommentCell
        currentCell.viewModel?.comment.didLike.toggle()

        if comment.didLike {
            switch type {
            case .regular:
                CommentService.unlikePostComment(forPost: post, forType: type, forCommentUid: comment.id) { _ in
                    currentCell.viewModel?.comment.likes = comment.likes - 1
                    self.comments[indexPath.row].didLike = false
                    self.comments[indexPath.row].likes -= 1
                }
            case .group:
                print("group unlike")
                #warning("implement group like")
            }
        } else {
            switch type {
                
            case .regular:
                CommentService.likePostComment(forPost: post, forType: type, forCommentUid: comment.id) { _ in
                    currentCell.viewModel?.comment.likes = comment.likes + 1
                    self.comments[indexPath.row].didLike = true
                    self.comments[indexPath.row].likes += 1
                }
            case .group:
                print("group like")
                #warning("implement group like")
            }
        }
    }
    
    func wantsToSeeRepliesFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        if comment.isTextFromAuthor { return }
        if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
            let controller = CommentsRepliesViewController(comment: comment, user: users[userIndex], post: post, type: type, currentUser: currentUser)
            let backItem = UIBarButtonItem()
            backItem.tintColor = .label
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: Comment.CommentOptions) {
        switch action {
        case .report:
            reportCommentAlert {
                DatabaseManager.shared.reportPostComment(forCommentId: comment.id) { reported in
                    if reported {
                        let popupView = METopPopupView(title: "Comment reported", image: "checkmark.circle.fill", popUpType: .regular)
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
                            
                            self.collectionView.performBatchUpdates {
                                self.comments.remove(at: indexPath.item)
                                self.users.remove(at: indexPath.item)
                                self.collectionView.deleteItems(at: [indexPath])
                            }
                            
                            self.delegate?.didDeletePostComment(post: self.post, comment: comment)
                            let popupView = METopPopupView(title: "Comment deleted", image: "checkmark.circle.fill", popUpType: .regular)
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
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = .label
        navigationItem.backBarButtonItem = backButton
        
        navigationController?.pushViewController(controller, animated: true)
    }
    

    
}

extension CommentPostViewController: AddWebLinkReferenceDelegate {
    
    func didTapEditReference(_ reference: Reference) {
        switch reference.option {
        case .link:
            let controller = AddWebLinkReferenceViewController(reference: reference)
            controller.delegate = self
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        case .reference:
            let controller = AddAuthorReferenceViewController(reference: reference)
            controller.delegate = self
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("PostReference"), object: nil)
    }
    
    func didTapDeleteReference() {
        reference = nil
        commentInputView.updateReferenceButton(reference: nil)
    }
}

//MARK: - CommentInputAccesoryViewDelegate

extension CommentPostViewController: CommentInputAccessoryViewDelegate {
    func didTapAddReference() {
        if let reference = reference {
            didTapEditReference(reference)
        } else {
            let controller = ReferencesViewController()
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("PostReference"), object: nil)
            present(navVC, animated: true)
        }
    }
    
    @objc func didReceiveNotification(notification: NSNotification) {
        if let reference = notification.userInfo, let selectedReference = reference["reference"] as? Reference {
            self.reference = selectedReference
            let reportPopup = METopPopupView(title: "Reference added to your comment", image: "checkmark.circle.fill", popUpType: .regular)
            reportPopup.showTopPopup(inView: self.view)
            
            commentInputView.updateReferenceButton(reference: selectedReference)
            
        }
    }
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        
        //Get user from MainTabController
        //guard let tab = self.tabBarController as? MainTabController else { return }
        //guard let currentUser = tab.user else { return }

        //Upload commento to Firebase
        CommentService.uploadPostComment(comment: comment, post: post, user: currentUser, type: type) { ids in
            let commentUid = ids[0]
            let postUid = ids[1]
            
            if self.type == .regular {
                DatabaseManager.shared.uploadRecentComments(withCommentUid: commentUid, withRefUid: postUid, title: "", comment: comment, type: .post, withTimestamp: Date()) { uploaded in
                }
            }

            self.post.numberOfComments += 1
            inputView.clearCommentTextView()
            
            let isAuthor = self.currentUser.uid == self.post.ownerUid ? true : false
            
            let addedComment = Comment(dictionary: [
                "comment": comment,
                "uid": self.currentUser.uid as Any,
                "id": commentUid as Any,
                "timestamp": "Now" as Any,
                "isTextFromAuthor": false as Bool,
                "isAuthor": isAuthor as Any])
            
            self.comments.insert(addedComment, at: 1)
            
            self.users.append(User(dictionary: [
                "uid": self.currentUser.uid as Any,
                "firstName": self.currentUser.firstName as Any,
                "lastName": self.currentUser.lastName as Any,
                "profileImageUrl": self.currentUser.profileImageUrl as Any,
                "profession": self.currentUser.profession as Any,
                "category": self.currentUser.category.rawValue as Any,
                "speciality": self.currentUser.speciality as Any]))
            
            let indexPath = IndexPath(item: 1, section: 0)
            self.collectionView.insertItems(at: [indexPath])
            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            
            self.delegate?.didCommentPost(post: self.post, user: self.currentUser, comment: addedComment)
            
            NotificationService.uploadNotification(toUid: self.post.ownerUid, fromUser: self.currentUser, type: .commentPost, post: self.post, withCommentId: commentUid)
        }
    }
}
