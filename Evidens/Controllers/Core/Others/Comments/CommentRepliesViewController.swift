//
//  CommentRepliesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/4/23.
//

import UIKit
import Firebase

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let commentCellReuseIdentifier = "CommentCellReuseIdentifier"

class CommentsRepliesViewController: UICollectionViewController {
    private let currentUser: User
    private let type: Comment.CommentType
    private let post: Post
    private var comment: Comment
    private var comments = [Comment]()
    private let user: User
    private var users = [User]()
    private var commentsLoaded: Bool = false
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    init(comment: Comment, user: User, post: Post, type: Comment.CommentType, currentUser: User) {
        self.comment = comment
        self.user = user
        self.post = post
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
        configureCollectionView()
        configureNavigationBar()
        configureUI()
        fetchRepliesForComment()
    }
    
    override var inputAccessoryView: UIView? {
        get { return commentInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    private func configureNavigationBar() {
        title = "Replies"
    }
    
    private func fetchRepliesForComment() {
        commentsLoaded = true
        collectionView.reloadData()
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
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

extension CommentsRepliesViewController: UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : commentsLoaded ? comments.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? CGSize.zero : commentsLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! CommentCell
        //cell.delegate = self
        cell.showingRepliesForComment = indexPath.section == 0 ? true : false
        cell.viewModel = CommentViewModel(comment: indexPath.section == 0 ? comment : comments[indexPath.row])
        if indexPath.section == 0 {
            cell.set(user: user)
        } else {
            let userIndex = users.firstIndex { user in
                return user.uid == comments[indexPath.row].uid
            }!
            
            cell.set(user: users[userIndex])
        }


        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            return UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets.zero
        }
    }
}

extension CommentsRepliesViewController: CommentInputAccessoryViewDelegate {
    func didTapAddReference() {
        
    }
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //CommentService.uploadPostReplyComment(comment: comment, commentId: self.comment.id, post: post, user: user, type: type) { commentId in
        let commentId = "OMEGAKEK"
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
        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        
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
