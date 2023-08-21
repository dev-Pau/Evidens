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
    private let clinicalCase: Case
    private var comment: Comment
    private var comments = [Comment]()
    private let user: User?
    private var users = [User]()
    private var referenceCommentId: String?
    private var commentsLoaded: Bool = false
    private var lastReplySnapshot: QueryDocumentSnapshot?
    private let repliesEnabled: Bool
    weak var delegate: CommentCaseRepliesViewControllerDelegate?
    private var commentMenuLauncher = ContextMenu(display: .comment)
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    private var likeCommentDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var likeCommentValues: [IndexPath: Bool] = [:]
    private var likeCommentCount: [IndexPath: Int] = [:]
    
    private var likeReplyDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var likeReplyValues: [IndexPath: Bool] = [:]
    private var likeReplyCount: [IndexPath: Int] = [:]
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    init(referenceCommentId: String? = nil, comment: Comment, user: User? = nil, clinicalCase: Case, currentUser: User, repliesEnabled: Bool? = true) {
        self.comment = comment
        self.user = user
        self.clinicalCase = clinicalCase
        self.currentUser = currentUser
        self.repliesEnabled = repliesEnabled ?? true
        self.referenceCommentId = referenceCommentId
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
        title = AppStrings.Title.replies
    }
    
    private func fetchRepliesForComment() {
        guard repliesEnabled else {
            commentsLoaded = true
            return
        }
        
        CommentService.fetchRepliesForCaseComment(forClinicalCase: clinicalCase, forCommentId: comment.id, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.lastReplySnapshot = snapshot.documents.last
                let comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
                let uids = comments.filter { $0.visible == .regular }.map { $0.uid }
                
                let uniqueUids = Array(Set(uids))
                
                CommentService.getCaseRepliesCommmentsValuesFor(forCase: strongSelf.clinicalCase, forComment: strongSelf.comment, forReplies: comments) { [weak self] replies in
                    guard let strongSelf = self else { return }
                    strongSelf.comments = replies.sorted { $0.timestamp.seconds < $1.timestamp.seconds }
                    
                    guard !uniqueUids.isEmpty else {
                        strongSelf.commentsLoaded = true
                        strongSelf.collectionView.reloadData()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users = users
                        strongSelf.commentsLoaded = true
                        strongSelf.collectionView.reloadData()
                    }
                }
                
            case .failure(let error):
                strongSelf.commentsLoaded = true
                strongSelf.collectionView.reloadData()
                
                guard error != .notFound else {
                    return
                }
                
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: loadingCellReuseIdentifier)
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
            commentInputView.set(placeholder: AppStrings.Content.Comment.voice)
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
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        if clinicalCase.privacy == .anonymous && clinicalCase.uid == uid  {
            commentInputView.profileImageView.image = UIImage(named: AppStrings.Assets.privacyProfile)
        } else {
            guard let imageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, !imageUrl.isEmpty else { return }
            commentInputView.profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
    
    private func handleLikeUnLike(for cell: CommentCell, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment else { return }
        
        // Toggle the like state and count
        cell.viewModel?.comment.didLike.toggle()
        self.comment.didLike.toggle()

        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        self.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1

        self.delegate?.didLikeComment(comment: self.comment)

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
                CommentService.unlikeComment(forCase: strongSelf.clinicalCase, forCommentId: comment.id) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let _ = error {
                        cell.viewModel?.comment.didLike = likeValue
                        strongSelf.comment.didLike = likeValue
                        
                        cell.viewModel?.comment.likes = countValue
                        strongSelf.comment.likes = countValue
                        
                        strongSelf.delegate?.didLikeComment(comment: strongSelf.comment)
                    }
                    
                    strongSelf.likeCommentValues[indexPath] = nil
                    strongSelf.likeCommentCount[indexPath] = nil
                }
            } else {
                CommentService.likeComment(forCase: strongSelf.clinicalCase, forCommentId: comment.id) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let _ = error {
                        cell.viewModel?.comment.didLike = likeValue
                        strongSelf.comment.didLike = likeValue
                        
                        cell.viewModel?.comment.likes = countValue
                        strongSelf.comment.likes = countValue
                        
                        strongSelf.delegate?.didLikeComment(comment: strongSelf.comment)
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
    
    private func handleLikeUnLike(for cell: ReplyCell, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment else { return }
        
        // Toggle the like state and count
        cell.viewModel?.comment.didLike.toggle()
        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        
        if repliesEnabled {
            comments[indexPath.row].didLike.toggle()
            comments[indexPath.row].likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
            
            delegate?.didLikeComment(comment: comments[indexPath.row])
        } else {
            self.comment.didLike.toggle()
            self.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
            
            delegate?.didLikeComment(comment: self.comment)
        }
    
        // Cancel the previous debounce timer for this comment, if any
        if let debounceTimer = likeReplyDebounceTimers[indexPath] {
            debounceTimer.cancel()
        }
        
        // Store the initial like state and count
        if likeReplyValues[indexPath] == nil {
            likeReplyValues[indexPath] = comment.didLike
            likeReplyCount[indexPath] = comment.likes
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let likeValue = strongSelf.likeReplyValues[indexPath], let countValue = strongSelf.likeReplyCount[indexPath] else {
                return
            }

            // Prevent any database action if the value remains unchanged
            if cell.viewModel?.comment.didLike == likeValue {
                strongSelf.likeReplyValues[indexPath] = nil
                strongSelf.likeReplyCount[indexPath] = nil
                return
            }

            if comment.didLike {
                CommentService.unlikeReply(forCase: strongSelf.clinicalCase, forCommentId: strongSelf.repliesEnabled ? strongSelf.comment.id : strongSelf.referenceCommentId!, forReplyId: strongSelf.repliesEnabled ? strongSelf.comments[indexPath.row].id : strongSelf.comment.id) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        if strongSelf.repliesEnabled {
                            
                            cell.viewModel?.comment.didLike = likeValue
                            strongSelf.comments[indexPath.row].didLike = likeValue
                            
                            cell.viewModel?.comment.likes = countValue
                            strongSelf.comments[indexPath.row].likes = countValue
                            
                            strongSelf.delegate?.didLikeComment(comment: strongSelf.comments[indexPath.row])
                            
                        } else {

                            cell.viewModel?.comment.didLike = likeValue
                            strongSelf.comment.didLike = likeValue
                            
                            cell.viewModel?.comment.likes = countValue
                            strongSelf.comment.likes = countValue
                            
                            strongSelf.delegate?.didLikeComment(comment: strongSelf.comment)
                        }
                        
                    }
                    
                    strongSelf.likeReplyValues[indexPath] = nil
                    strongSelf.likeReplyCount[indexPath] = nil
                }
            } else {
                CommentService.likeReply(forCase: strongSelf.clinicalCase, forCommentId: strongSelf.repliesEnabled ? strongSelf.comment.id : strongSelf.referenceCommentId!, forReplyId: strongSelf.repliesEnabled ? strongSelf.comments[indexPath.row].id : strongSelf.comment.id) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        if strongSelf.repliesEnabled {
                            
                            cell.viewModel?.comment.didLike = likeValue
                            strongSelf.comments[indexPath.row].didLike = likeValue
                            
                            cell.viewModel?.comment.likes = countValue
                            strongSelf.comments[indexPath.row].likes = countValue
                            
                            strongSelf.delegate?.didLikeComment(comment: strongSelf.comments[indexPath.row])
                            
                        } else {

                            cell.viewModel?.comment.didLike = likeValue
                            strongSelf.comment.didLike = likeValue
                            
                            cell.viewModel?.comment.likes = countValue
                            strongSelf.comment.likes = countValue
                            
                            strongSelf.delegate?.didLikeComment(comment: strongSelf.comment)
                        }
                        
                    }
                    
                    strongSelf.likeReplyValues[indexPath] = nil
                    strongSelf.likeReplyCount[indexPath] = nil
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
                    
                    if let user = user {
                        cell.set(user: user)
                    }

                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: replyCellReuseIdentifier, for: indexPath) as! ReplyCell
                    cell.delegate = self
                    cell.isExpanded = true
                    cell.set(isAuthor: comment.uid == clinicalCase.uid)
                    cell.viewModel = CommentViewModel(comment: comment)
                    
                    if let user = user {
                        cell.set(user: user)
                    }
                    
                    return cell
                }
            case .deleted:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedContentCellReuseIdentifier, for: indexPath) as! DeletedContentCell
                cell.delegate = self
                return cell
            }

        } else {
            if !commentsLoaded {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellReuseIdentifier, for: indexPath) as! LoadingCell
                return cell
                
            } else {
                let comment = comments[indexPath.row]
                switch comment.visible {
                    
                case .regular, .anonymous:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: replyCellReuseIdentifier, for: indexPath) as! ReplyCell
                    cell.delegate = self
                    cell.isExpanded = false
                    cell.set(isAuthor: comments[indexPath.row].uid == clinicalCase.uid)
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
        CommentService.addReply(comment, commentId: self.comment.id, clinicalCase: clinicalCase) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                strongSelf.comment.numberOfComments += 1
                
                if comment.visible == .regular {
                    strongSelf.users.append(User(dictionary: [
                        "uid": strongSelf.currentUser.uid as Any,
                        "firstName": strongSelf.currentUser.firstName as Any,
                        "lastName": strongSelf.currentUser.lastName as Any,
                        "imageUrl": strongSelf.currentUser.profileUrl as Any,
                        "discipline": strongSelf.currentUser.discipline as Any,
                        "kind": strongSelf.currentUser.kind.rawValue as Any,
                        "speciality": strongSelf.currentUser.speciality as Any]))
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.collectionView.performBatchUpdates { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.comments.insert(comment, at: 0)
                        
                        if strongSelf.comments.count == 1 {
                            strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
                        } else {
                            strongSelf.collectionView.insertItems(at: [IndexPath(item: 0, section: 1)])
                        }
                         
                    } completion: { [weak self] _ in
                        guard let strongSelf = self else { return }
                        strongSelf.collectionView.reloadSections(IndexSet(integer: 0))
                        strongSelf.delegate?.didAddReplyToComment(comment: strongSelf.comment)
                    }
                }
            case .failure(let error):
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
}

extension CommentCaseRepliesViewController: CommentCellDelegate {
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: CommentMenu) {
        if let indexPath = collectionView.indexPath(for: cell) {
            switch action {
            case .back:
                navigationController?.popViewController(animated: true)
            case .report:
                let controller = ReportViewController(source: .comment, contentUid: comment.uid, contentId: comment.id)
                let navVC = UINavigationController(rootViewController: controller)
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true)
            case .delete:
                if repliesEnabled {
                    if indexPath.section == 0 {
                        // Is the Original Comment
                        displayAlert(withTitle: AppStrings.Alerts.Title.deleteConversation, withMessage: AppStrings.Alerts.Subtitle.deleteConversation, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                            
                            guard let strongSelf = self else { return }
                            CommentService.deleteComment(forCase: strongSelf.clinicalCase, forCommentId: strongSelf.comment.id) { error in
                                if let error {
                                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                                } else {
                                    strongSelf.comment.visible = .deleted
                                    strongSelf.collectionView.reloadItems(at: [indexPath])
                                    
                                    strongSelf.delegate?.didDeleteComment(comment: strongSelf.comment)
                                    
                                    let popupView = PopUpBanner(title: AppStrings.Content.Comment.delete, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                                    popupView.showTopPopup(inView: strongSelf.view)
                                }
                            }
                        }
                    } else {
                        // Is a reply of a comment
                        displayAlert(withTitle: AppStrings.Alerts.Title.deleteConversation, withMessage: AppStrings.Alerts.Subtitle.deleteConversation, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                            
                            guard let strongSelf = self else { return }
                            CommentService.deleteReply(forCase: strongSelf.clinicalCase, forCommentId: strongSelf.comment.id, forReplyId: comment.id) { [weak self] error in
                                guard let strongSelf = self else { return }
                                if let error {
                                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                                } else {
                                   
                                    strongSelf.comments[indexPath.row].visible = .deleted
                                    strongSelf.comment.numberOfComments -= 1
                                    strongSelf.collectionView.reloadData()
                                    
                                    let popupView = PopUpBanner(title: AppStrings.Content.Reply.delete, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                                    popupView.showTopPopup(inView: strongSelf.view)
                                }
                            }
                        }
                    }
                } else {
                    // Is a reply
                    displayAlert(withTitle: AppStrings.Alerts.Title.deleteConversation, withMessage: AppStrings.Alerts.Subtitle.deleteConversation, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                        
                        guard let strongSelf = self, let referenceCommentId = strongSelf.referenceCommentId else { return }
                        CommentService.deleteReply(forCase: strongSelf.clinicalCase, forCommentId: referenceCommentId, forReplyId: comment.id) { error in
                            if let error {
                                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            } else {
                            
                                strongSelf.comment.visible = .deleted
                                strongSelf.collectionView.reloadData()
                                
                                strongSelf.delegate?.didDeleteReply(withRefComment: comment, comment: comment)
                                
                                let popupView = PopUpBanner(title: AppStrings.Content.Reply.delete, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                                popupView.showTopPopup(inView: strongSelf.view)
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
                let controller = CommentCaseRepliesViewController(referenceCommentId: self.comment.id, comment: comment, user: users[userIndex], clinicalCase: clinicalCase, currentUser: currentUser, repliesEnabled: false)
                controller.delegate = self
                navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller = CommentCaseRepliesViewController(referenceCommentId: self.comment.id, comment: comment, clinicalCase: clinicalCase, currentUser: currentUser, repliesEnabled: false)
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
            handleLikeUnLike(for: currentCell, at: indexPath)
        } else {
            let currentCell = cell as! ReplyCell
            handleLikeUnLike(for: currentCell, at: indexPath)
        }

    }
}

extension CommentCaseRepliesViewController: CommentCaseRepliesViewControllerDelegate {
    func didDeleteComment(comment: Comment) { return }
    
    func didDeleteReply(withRefComment refComment: Comment, comment: Comment) {
        if let commentIndex = comments.firstIndex(where: { $0.id == comment.id }) {
            comments[commentIndex].visible = .deleted
            self.comment.numberOfComments -= 1
            collectionView.reloadData()
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
