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

class CommentCaseRepliesViewController: UICollectionViewController {
    private let clinicalCase: Case
    private var comment: Comment
    private var comments = [Comment]()
    
    private var user: User?
    private var users = [User]()
    
    private var referenceCommentId: String?
    private var commentsLoaded: Bool = false
    private var lastReplySnapshot: QueryDocumentSnapshot?
    private let repliesEnabled: Bool
    private var commentMenuLauncher = ContextMenu(display: .comment)
    private var bottomAnchorConstraint: NSLayoutConstraint!
    private var currentNotification: Bool = false
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    private var bottomSpinner: BottomSpinnerView!
    private var isFetchingMoreReplies: Bool = false

    init(referenceCommentId: String? = nil, comment: Comment, user: User? = nil, clinicalCase: Case, repliesEnabled: Bool? = true) {
        self.comment = comment
        self.user = user
        self.clinicalCase = clinicalCase
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
    
    deinit {
        print("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        configureCollectionView()
        configureNavigationBar()
        configureUI()
        fetchRepliesForComment()
        configureNotificationObservers()
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.replies
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseCommentLike), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(caseReplyLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseReplyLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseReplyChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseReply), object: nil)
     
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
        collectionView.register(DeletedCommentCell.self, forCellWithReuseIdentifier: deletedContentCellReuseIdentifier)
        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        bottomSpinner = BottomSpinnerView(style: .medium)
        
        if repliesEnabled && clinicalCase.visible == .regular {
            view.addSubviews(commentInputView, bottomSpinner)
            bottomAnchorConstraint = commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            NSLayoutConstraint.activate([
                bottomAnchorConstraint,
                commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                bottomSpinner.bottomAnchor.constraint(equalTo: commentInputView.topAnchor),
                bottomSpinner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                bottomSpinner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                bottomSpinner.heightAnchor.constraint(equalToConstant: 50)
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
    
    private func configureUI() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        if clinicalCase.privacy == .anonymous && clinicalCase.uid == uid  {
            commentInputView.profileImageView.image = UIImage(named: AppStrings.Assets.privacyProfile)
        } else {
            guard let imageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, !imageUrl.isEmpty else { return }
            commentInputView.profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
    
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreReplies()
        }
    }
    
    private func getMoreReplies() {

        guard repliesEnabled, lastReplySnapshot != nil, !comments.isEmpty, !isFetchingMoreReplies, comment.numberOfComments > comments.count else {
            return
        }

        showBottomSpinner()
        
        CommentService.fetchRepliesForCaseComment(forClinicalCase: clinicalCase, forCommentId: comment.id, lastSnapshot: lastReplySnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.lastReplySnapshot = snapshot.documents.last
                let comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
                
                let visibleUids = comments.filter { $0.visible == .regular }.map { $0.uid }
                let uniqueUids = Array(Set(visibleUids))

                let currentUserUids = strongSelf.users.map { $0.uid }
                
                let usersToFetch = uniqueUids.filter { !currentUserUids.contains($0) }

                guard !usersToFetch.isEmpty else {
                    strongSelf.collectionView.reloadData()
                    strongSelf.hideBottomSpinner()
                    return
                }

                CommentService.getCaseRepliesCommmentsValuesFor(forCase: strongSelf.clinicalCase, forComment: strongSelf.comment, forReplies: comments) { [weak self] fetchedReplies in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.comments.append(contentsOf: fetchedReplies.sorted { $0.timestamp.seconds > $1.timestamp.seconds })
                    UserService.fetchUsers(withUids: usersToFetch) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users.append(contentsOf: users)
                        strongSelf.hideBottomSpinner()
                        strongSelf.collectionView.reloadData()
                    }
                }
                
            case .failure(_):
                strongSelf.hideBottomSpinner()
            }
        }
    }
    
    func showBottomSpinner() {
        isFetchingMoreReplies = true
        let collectionViewContentHeight = collectionView.contentSize.height
        
        if collectionView.frame.height < collectionViewContentHeight {
            bottomSpinner.startAnimating()
            collectionView.contentInset.bottom += 50
        }
    }
    
    func hideBottomSpinner() {
        isFetchingMoreReplies = false
        bottomSpinner.stopAnimating()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.contentInset.bottom -= 50
        }
    }
    
    private func handleLikeUnLike(for cell: CommentCell, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment else { return }
        
        let caseId = clinicalCase.caseId
        let commentId = comment.id
        let didLike = comment.didLike
        caseDidChangeCommentLike(caseId: caseId, commentId: commentId, didLike: didLike)
   
        // Toggle the like state and count
        cell.viewModel?.comment.didLike.toggle()
        self.comment.didLike.toggle()

        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        self.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1

    }
    
    private func handleLikeUnLike(for cell: ReplyCell, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment else { return }
        
        let caseId = clinicalCase.caseId
        let replyId = comment.id
        let commentId = referenceCommentId != nil ? referenceCommentId : self.comment.id
        let didLike = comment.didLike
       
        caseDidChangeReplyLike(caseId: caseId, commentId: commentId!, replyId: replyId, didLike: didLike)
      
        // Toggle the like state and count
        cell.viewModel?.comment.didLike.toggle()
        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        
        if repliesEnabled {
            comments[indexPath.row].didLike.toggle()
            comments[indexPath.row].likes = comment.didLike ? comment.likes - 1 : comment.likes + 1

        } else {
            self.comment.didLike.toggle()
            self.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1

        }
    
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
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedContentCellReuseIdentifier, for: indexPath) as! DeletedCommentCell
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
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedContentCellReuseIdentifier, for: indexPath) as! DeletedCommentCell
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
                    guard let tab = strongSelf.tabBarController as? MainTabController, let user = tab.user else { return }
                    strongSelf.users.append(user)
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
                        strongSelf.caseDidChangeReply(caseId: strongSelf.clinicalCase.caseId, commentId: strongSelf.comment.id, reply: comment, action: .add)
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
                        displayAlert(withTitle: AppStrings.Alerts.Title.deleteComment, withMessage: AppStrings.Alerts.Subtitle.deleteComment, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                            
                            guard let strongSelf = self else { return }
                            CommentService.deleteComment(forCase: strongSelf.clinicalCase, forCommentId: strongSelf.comment.id) { error in
                                if let error {
                                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                                } else {
                                    strongSelf.comment.visible = .deleted
                                    strongSelf.collectionView.reloadItems(at: [indexPath])

                                    strongSelf.caseDidChangeComment(caseId: strongSelf.clinicalCase.caseId, comment: comment, action: .remove)
                                    
                                    let popupView = PopUpBanner(title: AppStrings.Content.Comment.delete, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                                    popupView.showTopPopup(inView: strongSelf.view)
                                }
                            }
                        }
                    } else {
                        // Is a reply of a comment
                        displayAlert(withTitle: AppStrings.Alerts.Title.deleteComment, withMessage: AppStrings.Alerts.Subtitle.deleteComment, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                            
                            guard let strongSelf = self else { return }
                            CommentService.deleteReply(forCase: strongSelf.clinicalCase, forCommentId: strongSelf.comment.id, forReplyId: comment.id) { [weak self] error in
                                guard let strongSelf = self else { return }
                                if let error {
                                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                                } else {
                                   
                                    strongSelf.comments[indexPath.row].visible = .deleted
                                    strongSelf.comment.numberOfComments -= 1
                                    strongSelf.collectionView.reloadData()
                                    
                                     strongSelf.caseDidChangeReply(caseId: strongSelf.clinicalCase.caseId, commentId: strongSelf.comment.id, reply: comment, action: .remove)

                                    let popupView = PopUpBanner(title: AppStrings.Content.Reply.delete, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                                    popupView.showTopPopup(inView: strongSelf.view)
                                }
                            }
                        }
                    }
                } else {
                    // Is a reply
                    displayAlert(withTitle: AppStrings.Alerts.Title.deleteComment, withMessage: AppStrings.Alerts.Subtitle.deleteComment, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                        
                        guard let strongSelf = self, let referenceCommentId = strongSelf.referenceCommentId else { return }
                        CommentService.deleteReply(forCase: strongSelf.clinicalCase, forCommentId: referenceCommentId, forReplyId: comment.id) { error in
                            if let error {
                                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            } else {
                            
                                strongSelf.comment.visible = .deleted
                                strongSelf.collectionView.reloadData()
                                
                                
                                strongSelf.caseDidChangeReply(caseId: strongSelf.clinicalCase.caseId, commentId: referenceCommentId, reply: comment, action: .remove)
                                
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
                let controller = CommentCaseRepliesViewController(referenceCommentId: self.comment.id, comment: comment, user: users[userIndex], clinicalCase: clinicalCase, repliesEnabled: false)
               
                navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller = CommentCaseRepliesViewController(referenceCommentId: self.comment.id, comment: comment, clinicalCase: clinicalCase, repliesEnabled: false)

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

extension CommentCaseRepliesViewController: DeletedCommentCellDelegate {
    func didTapReplies(_ cell: UICollectionViewCell, forComment comment: Comment) { return }
    
    func didTapLearnMore() {
        commentInputView.resignFirstResponder()
        commentMenuLauncher.showImageSettings(in: view)
    }
}


extension CommentCaseRepliesViewController: CaseDetailedChangesDelegate {
    func caseDidChangeComment(caseId: String, comment: Comment, action: CommentAction) {
        currentNotification = true
        ContentManager.shared.commentCaseChange(caseId: caseId, comment: comment, action: action)
    }
    
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseCommentChange {
            guard change.caseId == self.clinicalCase.caseId, change.comment.id == comment.id else { return }
            
            switch change.action {
                
            case .add:
                break
            case .remove:
                comment.visible = .deleted
                collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
            }
        }
    }

    func caseDidChangeCommentLike(caseId: String, commentId: String, didLike: Bool) {
        currentNotification = true
        ContentManager.shared.likeCommentCaseChange(caseId: caseId, commentId: commentId, didLike: !didLike)
    }
    
    func caseDidChangeReplyLike(caseId: String, commentId: String, replyId: String, didLike: Bool) {
        currentNotification = true
        ContentManager.shared.likeReplyCaseChange(caseId: caseId, commentId: commentId, replyId: replyId, didLike: !didLike)
    }
    
    func caseDidChangeReply(caseId: String, commentId: String, reply: Comment, action: CommentAction) {
        currentNotification = true
        ContentManager.shared.replyCaseChange(caseId: caseId, commentId: commentId, reply: reply, action: action)
    }

    @objc func caseCommentLikeChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseCommentLikeChange {
            
            guard change.caseId == self.clinicalCase.caseId, change.commentId == self.comment.id else { return }
            if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CommentCell {
                
                let likes = self.comment.likes
                
                self.comment.likes = change.didLike ? likes + 1 : likes - 1
                self.comment.didLike = change.didLike
                
                cell.viewModel?.comment.didLike = change.didLike
                cell.viewModel?.comment.likes = change.didLike ? likes + 1 : likes - 1
            }
        }
    }
    
    @objc func caseReplyLikeChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseReplyLikeChange {
            guard change.caseId == self.clinicalCase.caseId else { return }
            if repliesEnabled {

                if let index = comments.firstIndex(where: { $0.id == change.replyId }) {
                    if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) as? ReplyCell {
                        
                        let likes = comments[index].likes
                        
                        comments[index].didLike = change.didLike
                        comments[index].likes = change.didLike ? likes + 1 : likes - 1
                        
                        cell.viewModel?.comment.didLike = change.didLike
                        cell.viewModel?.comment.likes = change.didLike ? likes + 1 : likes - 1
                    }
                }
            } else {
                // Reply at first position

                guard let commentId = referenceCommentId, commentId == change.commentId, change.replyId == self.comment.id else { return }
                if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? ReplyCell {
                    
                    let likes = comment.likes
                    
                    self.comment.didLike = change.didLike
                    self.comment.likes = change.didLike ? likes + 1 : likes - 1
                    
                    cell.viewModel?.comment.didLike = change.didLike
                    cell.viewModel?.comment.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
    
    @objc func caseReplyChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        if let change = notification.object as? CaseReplyChange {
            guard change.caseId == self.clinicalCase.caseId else { return }
            if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CommentCell {
                switch change.action {
                    
                case .add:

                    guard let tab = tabBarController as? MainTabController, let user = tab.user else { return }
                    
                    if clinicalCase.privacy == .anonymous && user.uid == clinicalCase.uid {
                        
                    } else {
                        users.append(user)
                        
                    }

                    self.comment.numberOfComments += 1
                    cell.viewModel?.comment.numberOfComments += 1
                    
                    self.comments.insert(change.reply, at: 0)
                    
                    if self.comments.count == 1 {
                        collectionView.reloadSections(IndexSet(integer: 1))
                    } else {
                        collectionView.insertItems(at: [IndexPath(item: 0, section: 1)])
                    }
                    
                case .remove:
                    if let index = comments.firstIndex(where: { $0.id == change.reply.id }) {
                        self.comment.numberOfComments -= 1
                        cell.viewModel?.comment.numberOfComments -= 1
                        self.comments[index].visible = .deleted
                        collectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension CommentCaseRepliesViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            if let currentUser = self.user, currentUser.isCurrentUser {
                self.user = user
                collectionView.reloadData()
            }
            
            if let index = users.firstIndex(where: { $0.uid == user.uid }) {
                users[index] = user
                collectionView.reloadData()
            }
        }
    }
}


