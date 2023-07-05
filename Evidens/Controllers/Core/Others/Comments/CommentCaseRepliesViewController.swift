//
//  CommentCaseRepliesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/5/23.
//

import UIKit


import UIKit
import Firebase

private let loadingCellReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let commentCellReuseIdentifier = "CommentCellReuseIdentifier"
private let replyCellReuseIdentifier = "ReplyCellReuseIdentifier"

protocol CommentCaseRepliesViewControllerDelegate: AnyObject {
    func didLikeComment(comment: Comment)
    func didAddReplyToComment(comment: Comment)
}

class CommentCaseRepliesViewController: UICollectionViewController {
    private let currentUser: User
    private let type: Comment.CommentType
    private let clinicalCase: Case
    private var comment: Comment
    private var comments = [Comment]()
    private let user: User
    private var users = [User]()
    private var referenceCommentId: String
    private var commentsLoaded: Bool = false
    private var lastReplySnapshot: QueryDocumentSnapshot?
    private let repliesEnabled: Bool
    weak var delegate: CommentCaseRepliesViewControllerDelegate?
    private var bottomAnchorConstraint: NSLayoutConstraint!

    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    init(referenceCommentId: String? = nil, comment: Comment, user: User, clinicalCase: Case, type: Comment.CommentType, currentUser: User, repliesEnabled: Bool? = true) {
        self.comment = comment
        self.user = user
        self.clinicalCase = clinicalCase
        self.type = type
        self.currentUser = currentUser
        self.repliesEnabled = repliesEnabled ?? true
        self.referenceCommentId = referenceCommentId ?? ""
        let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
       }

        print(self.comment)
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
    }
    
    private func configureNavigationBar() {
        title = "Replies"
    }
    
    private func fetchRepliesForComment() {
        guard repliesEnabled else {
            commentsLoaded = true
            return
        }
        
        CommentService.fetchRepliesForCaseComment(forClinicalCase: clinicalCase, type: type, forCommentId: comment.id, lastSnapshot: nil) { snapshot in
            guard !snapshot.isEmpty else {
                self.commentsLoaded = true
                self.collectionView.reloadData()
                return
            }
            
            self.lastReplySnapshot = snapshot.documents.last
            let comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
            
            let replyUids = comments.map { $0.uid }

            CommentService.getCaseRepliesCommmentsValuesFor(forCase: self.clinicalCase, forComment: self.comment, forReplies: comments, forType: self.type) { fetchedReplies in
                UserService.fetchUsers(withUids: replyUids) { users in
                    self.users = users
                    print(self.users)
                    self.comments = fetchedReplies.sorted { $0.timestamp.seconds < $1.timestamp.seconds }
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
        collectionView.register(ReplyCell.self, forCellWithReuseIdentifier: replyCellReuseIdentifier)
        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        if repliesEnabled {
            view.addSubview(commentInputView)
            bottomAnchorConstraint = commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            NSLayoutConstraint.activate([
                bottomAnchorConstraint,
                commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            collectionView.verticalScrollIndicatorInsets.bottom = 50
        }

    }
    
    private func configureUI() {
        guard let imageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String, imageUrl != "" else { return }
        commentInputView.profileImageView.sd_setImage(with: URL(string: imageUrl))
    }
}

extension CommentCaseRepliesViewController: UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return repliesEnabled ? 2 : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : commentsLoaded ? comments.count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if repliesEnabled {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! CommentCell
                cell.delegate = self
                cell.showingRepliesForComment = true
                cell.isReply = false
                cell.viewModel = CommentViewModel(comment: comment)
                cell.set(user: user)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: replyCellReuseIdentifier, for: indexPath) as! ReplyCell
                cell.delegate = self
                cell.isExpanded = true
                cell.viewModel = CommentViewModel(comment: comment)
                cell.set(user: user)
                return cell
            }
        } else {
            if !commentsLoaded {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellReuseIdentifier, for: indexPath) as! MELoadingCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: replyCellReuseIdentifier, for: indexPath) as! ReplyCell
                cell.delegate = self
                cell.isExpanded = false
                cell.isAuthor = comments[indexPath.row].uid == clinicalCase.ownerUid
                cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
                cell.commentTextView.isSelectable = false
                if let userIndex = users.firstIndex(where: { $0.uid == comments[indexPath.row].uid }) {
                    cell.set(user: users[userIndex])
                }
                return cell
            }
        }
    }
}

extension CommentCaseRepliesViewController: CommentInputAccessoryViewDelegate {
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        CommentService.uploadCaseReplyComment(comment: comment, commentId: self.comment.id, clinicalCase: clinicalCase, user: user, type: type) { [self] commentId in
            self.comment.numberOfComments += 1
            
            inputView.clearCommentTextView()
            
            let isAuthor = uid == self.clinicalCase.ownerUid ? true : false
            
            let addedComment = Comment(dictionary: [
                "comment": comment,
                "uid": self.currentUser.uid as Any,
                "id": commentId as Any,
                "timestamp": "Now" as Any,
                "isTextFromAuthor": false as Bool,
                "anonymous": (isAuthor && clinicalCase.privacyOptions == .nonVisible) ? true : false,
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

            let indexPath = IndexPath(item: self.comments.count - 1, section: 1)
            self.collectionView.insertItems(at: [indexPath])
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            self.delegate?.didAddReplyToComment(comment: self.comment)
        }
    }
}

extension CommentCaseRepliesViewController: CommentCellDelegate {
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: Comment.CommentOptions) {
        print("did tap comment")
        #warning("Implement")
    }
    
    func didTapProfile(forUser user: User) {
        guard let rootController = navigationController?.viewControllers.first as? CommentPostViewController else {
            return
            
        }
        
        rootController.didTapProfile(forUser: user)
        
    }
    
    func wantsToSeeRepliesFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard repliesEnabled else { return }
        if let indexPath = collectionView.indexPath(for: cell) {
            guard indexPath.section != 0 else { return }
            if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {

                let controller = CommentCaseRepliesViewController(referenceCommentId: self.comment.id, comment: comment, user: users[userIndex], clinicalCase: clinicalCase, type: type, currentUser: currentUser, repliesEnabled: false)
                controller.delegate = self
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
                
                CommentService.unlikeCaseComment(forCase: clinicalCase, forType: type, forCommentUid: comment.id) { _ in
                    currentCell.viewModel?.comment.likes = comment.likes - 1
                    self.comment.didLike = false
                    self.comment.likes -= 1
                    self.delegate?.didLikeComment(comment: self.comment)
                }
                
            } else {
                
                CommentService.likeCaseComment(forCase: clinicalCase, forType: type, forCommentUid: comment.id) { _ in
                    currentCell.viewModel?.comment.likes = comment.likes + 1
                    self.comment.didLike = true
                    self.comment.likes += 1
                    self.delegate?.didLikeComment(comment: self.comment)
                }
            }
        } else {
            // Reply like
            if comment.didLike {
                
                CommentService.unlikeCaseReplyComment(forCase: clinicalCase, forType: type, forCommentUid: repliesEnabled ? self.comment.id : referenceCommentId, forReplyId: repliesEnabled ? comments[indexPath.row].id : self.comment.id) { _ in
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
                CommentService.likeCaseReplyComment(forCase: clinicalCase, forType: type, forCommentUid: repliesEnabled ? self.comment.id : referenceCommentId, forReplyId: repliesEnabled ? comments[indexPath.row].id : self.comment.id) { _ in
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

extension CommentCaseRepliesViewController: CommentsRepliesViewControllerDelegate {
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

extension CommentCaseRepliesViewController: CommentCaseRepliesViewControllerDelegate {
    
}

