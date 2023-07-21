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
private let deletedContentCellReuseIdentifier = "DeletedContentCellReuseIdentifier"

protocol CommentCaseRepliesViewControllerDelegate: AnyObject {
    func didLikeComment(comment: Comment)
    func didAddReplyToComment(comment: Comment)
    func didDeleteReply(withRefComment refComment: Comment, comment: Comment)
    func didDeleteComment(comment: Comment)
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
    private var commentMenuLauncher = MEContextMenuLauncher(menuLauncherData: Display(content: .comment))
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
        collectionView.register(DeletedContentCell.self, forCellWithReuseIdentifier: deletedContentCellReuseIdentifier)
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
            commentInputView.set(placeholder: "Voice your thoughts here...")
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 47, right: 0)
            collectionView.verticalScrollIndicatorInsets.bottom = 47
        }
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
            
            switch comment.visible {
                
            case .regular, .anonymous:
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
                    cell.isAuthor = comment.uid == clinicalCase.uid
                    cell.viewModel = CommentViewModel(comment: comment)
                    cell.set(user: user)
                    return cell
                }
            case .deleted:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedContentCellReuseIdentifier, for: indexPath) as! DeletedContentCell
                cell.delegate = self
                return cell
            }

        } else {
            if !commentsLoaded {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellReuseIdentifier, for: indexPath) as! MELoadingCell
                return cell
                
            } else {
                let comment = comments[indexPath.row]
                switch comment.visible {
                    
                case .regular, .anonymous:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: replyCellReuseIdentifier, for: indexPath) as! ReplyCell
                    cell.delegate = self
                    cell.isExpanded = false
                    cell.isAuthor = comments[indexPath.row].uid == clinicalCase.uid
                    cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
                    cell.commentTextView.isSelectable = false
                    if let userIndex = users.firstIndex(where: { $0.uid == comments[indexPath.row].uid }) {
                        cell.set(user: users[userIndex])
                    }
                    return cell
                case .deleted:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedContentCellReuseIdentifier, for: indexPath) as! DeletedContentCell
                    cell.delegate = self
                    return cell
                }
            }
        }
    }
}

extension CommentCaseRepliesViewController: CommentInputAccessoryViewDelegate {
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        inputView.commentTextView.resignFirstResponder()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        CommentService.addReply(comment, commentId: self.comment.id, clinicalCase: clinicalCase, user: user, type: type) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                strongSelf.comment.numberOfComments += 1
                
                strongSelf.users.append(User(dictionary: [
                    "uid": strongSelf.currentUser.uid as Any,
                    "firstName": strongSelf.currentUser.firstName as Any,
                    "lastName": strongSelf.currentUser.lastName as Any,
                    "imageUrl": strongSelf.currentUser.profileUrl as Any,
                    "profession": strongSelf.currentUser.discipline as Any,
                    "category": strongSelf.currentUser.kind.rawValue as Any,
                    "speciality": strongSelf.currentUser.speciality as Any]))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    strongSelf.collectionView.performBatchUpdates {
                        strongSelf.comments.insert(comment, at: 0)
                        strongSelf.collectionView.insertItems(at: [IndexPath(item: 0, section: 1)])
                    } completion: { _ in
                        strongSelf.collectionView.reloadSections(IndexSet(integer: 0))
                        strongSelf.delegate?.didAddReplyToComment(comment: strongSelf.comment)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension CommentCaseRepliesViewController: CommentCellDelegate {
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: Comment.CommentOptions) {
        if let indexPath = collectionView.indexPath(for: cell) {
            switch action {
            case .back:
                navigationController?.popViewController(animated: true)
            case .report:
                let controller = ReportViewController(source: .comment, contentOwnerUid: comment.uid, contentId: comment.id)
                let navVC = UINavigationController(rootViewController: controller)
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true)
            case .delete:
                if repliesEnabled {
                    if indexPath.section == 0 {
                        // Is the Original Comment
                        deleteCommentAlert {
                            CommentService.deleteCaseComment(forCase: self.clinicalCase, forCommentUid: self.comment.id) { error in
                                if let error {
                                    print(error.localizedDescription)
                                } else {
                                    self.comment.visible = .deleted
                                    self.collectionView.reloadItems(at: [indexPath])
                                    
                                    DatabaseManager.shared.deleteRecentComment(forCommentId: comment.id)
                                    
                                    self.delegate?.didDeleteComment(comment: self.comment)
                                    
                                    let popupView = METopPopupView(title: "Comment deleted", image: "checkmark.circle.fill", popUpType: .regular)
                                    popupView.showTopPopup(inView: self.view)
                                }
                            }
                        }
                    } else {
                        // Is a reply of a comment
                        deleteCommentAlert {
                            CommentService.deleteCaseReply(forCase: self.clinicalCase, forCommentUid: self.comment.id, forReplyId: comment.id) { error in
                                if let error {
                                    print(error.localizedDescription)
                                } else {
                                    DatabaseManager.shared.deleteRecentComment(forCommentId: comment.id)

                                    self.comments[indexPath.row].visible = .deleted
                                    self.comment.numberOfComments -= 1
                                    self.collectionView.reloadData()
                                    self.delegate?.didDeleteReply(withRefComment: self.comment, comment: comment)
                                    let popupView = METopPopupView(title: "Reply deleted", image: "checkmark.circle.fill", popUpType: .regular)
                                    popupView.showTopPopup(inView: self.view)
                                }
                            }
                        }
                    }
                } else {
                    // Is a reply
                    deleteCommentAlert {
                        CommentService.deleteCaseReply(forCase: self.clinicalCase, forCommentUid: self.referenceCommentId, forReplyId: comment.id) { error in
                            if let error {
                                print(error.localizedDescription)
                            } else {
                                DatabaseManager.shared.deleteRecentComment(forCommentId: comment.id)

                                self.comment.visible = .deleted
                                self.collectionView.reloadData()
                                self.delegate?.didDeleteReply(withRefComment: comment, comment: comment)
                                let popupView = METopPopupView(title: "Reply deleted", image: "checkmark.circle.fill", popUpType: .regular)
                                popupView.showTopPopup(inView: self.view)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func didTapProfile(forUser user: User) {
        let controller = UserProfileViewController(user: user)
        self.navigationController?.pushViewController(controller, animated: true)
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

        if indexPath.section == 0 && repliesEnabled {
            let currentCell = cell as! CommentCell
            currentCell.viewModel?.comment.didLike.toggle()
            
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
            let currentCell = cell as! ReplyCell
            currentCell.viewModel?.comment.didLike.toggle()
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

extension CommentCaseRepliesViewController: CommentPostRepliesViewControllerDelegate, CommentCaseRepliesViewControllerDelegate {
    func didDeleteComment(comment: Comment) { return }
    
    func didDeleteReply(withRefComment refComment: Comment, comment: Comment) {
        if let commentIndex = comments.firstIndex(where: { $0.id == comment.id }) {
            comments[commentIndex].visible = .deleted
            self.comment.numberOfComments -= 1
            collectionView.reloadData()
            //collectionView.reloadItems(at: [IndexPath(item: commentIndex, section: 1)])
            delegate?.didDeleteReply(withRefComment: self.comment, comment: comment)
        }
    }
    
    func didAddReplyToComment(comment: Comment) { return }
    
    func didLikeComment(comment: Comment) {
        if let commentIndex = comments.firstIndex(where: { $0.id == comment.id }) {
            comments[commentIndex].didLike = comment.didLike
            comments[commentIndex].likes = comment.likes
            collectionView.reloadItems(at: [IndexPath(item: commentIndex, section: 1)])
        }
    }
}

extension CommentCaseRepliesViewController: DeletedContentCellDelegate {
    func didTapReplies(_ cell: UICollectionViewCell, forComment comment: Comment) { return }
    
    func didTapLearnMore() {
        commentInputView.resignFirstResponder()
        commentMenuLauncher.showImageSettings(in: view)
    }
}
