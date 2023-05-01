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

class CommentsRepliesViewController: UICollectionViewController {
    private let currentUser: User
    private let type: Comment.CommentType
    private let post: Post
    private var comment: Comment
    private var comments = [Comment]()
    private let user: User
    private var users = [User]()
    private var commentsLoaded: Bool = false
    private var lastReplySnapshot: QueryDocumentSnapshot?
    
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
        let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            //if self.commentsLoaded { section.boundarySupplementaryItems = [header] }
            section.contentInsets.leading = sectionIndex == 0 ? .zero : 50
            return section
       }

        super.init(collectionViewLayout: compositionalLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     private func createLayout() -> UICollectionViewCompositionalLayout {

         let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)))
         let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .absolute(30)), subitems: [item])
         let section = NSCollectionLayoutSection(group: group)
         section.orthogonalScrollingBehavior = .continuous
         section.interGroupSpacing = 10
         section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)

         let config = UICollectionViewCompositionalLayoutConfiguration()
         config.interSectionSpacing = 10
         config.scrollDirection = .horizontal
         
         return UICollectionViewCompositionalLayout(section: section)
     }
     */
    
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
        CommentService.fetchRepliesForPostComment(forPost: post, type: type, forCommentId: comment.id, lastSnapshot: nil) { snapshot in
            guard !snapshot.isEmpty else {
                self.commentsLoaded = true
                self.collectionView.reloadData()
                return
            }
            
            self.lastReplySnapshot = snapshot.documents.last
            let comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
            let replyUids = comments.map { $0.uid }
            
            UserService.fetchUsers(withUids: replyUids) { users in
                self.users = users
                self.comments = comments
                self.commentsLoaded = true
                self.collectionView.reloadData()
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

extension CommentsRepliesViewController: UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : commentsLoaded ? comments.count : 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! CommentCell
        
        if indexPath.section == 1 && !commentsLoaded {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellReuseIdentifier, for: indexPath) as! MELoadingCell
            return cell
        } else {
            //cell.delegate = self
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
                cell.separatorView.isHidden = false
                cell.commentActionButtons.commentButton.isHidden = false
            }
            
            return cell
        }
    }
}

extension CommentsRepliesViewController: CommentInputAccessoryViewDelegate {
    func didTapAddReference() {
        
    }
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        CommentService.uploadPostReplyComment(comment: comment, commentId: self.comment.id, post: post, user: user, type: type) { commentId in
            //let commentId = "OMEGAKEK"
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
