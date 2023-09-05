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
    
    private var clinicalCase: Case
    private var comment: Comment
    private var user: User?
    
    private var comments = [Comment]()
    private var users = [User]()
    private let activityIndicator = PrimaryLoadingView(frame: .zero)
    private var currentNotification: Bool = false
    
    private var path: [String]
    
    private var commentsLoaded: Bool = false
    
    private var lastReplySnapshot: QueryDocumentSnapshot?
    
    private let needsToFetch: Bool
    
    private var caseId: String?
    private var uid: String?
    
    private var bottomSpinner: BottomSpinnerView!
    private var isFetchingMoreReplies: Bool = false
    
    private var commentMenuLauncher = ContextMenu(display: .comment)
    private var bottomAnchorConstraint: NSLayoutConstraint!

    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()


    init(path: [String], comment: Comment, user: User? = nil, clinicalCase: Case) {
        self.comment = comment
        self.user = user
        self.clinicalCase = clinicalCase
        self.path = path
        self.needsToFetch = false

        let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
       }

        super.init(collectionViewLayout: compositionalLayout)
    }
    
    init(caseId: String, uid: String, path: [String]) {
        self.caseId = caseId
        self.uid = uid
        self.path = path
        self.needsToFetch = true
        
        self.comment = Comment(dictionary: [:])
        self.clinicalCase = Case(caseId: "", dictionary: [:])
        
        let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)

            return section
       }
        super.init(collectionViewLayout: compositionalLayout)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        configureCollectionView()
        configureNotificationObservers()
        configureNavigationBar()
        if needsToFetch {
            fetchContent()
        } else {
            configureUI()
            fetchRepliesForComment()
        }
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.replies
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseCommentLike), object: nil)

    }
    
    private func fetchRepliesForComment() {
        CommentService.fetchRepliesForCaseComment(forClinicalCase: clinicalCase, forPath: path, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.lastReplySnapshot = snapshot.documents.last
                let comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
                let uids = comments.filter { $0.visible == .regular }.map { $0.uid }
                
                let uniqueUids = Array(Set(uids))
                
                CommentService.getCaseCommentValuesFor(forCase: strongSelf.clinicalCase, forPath: strongSelf.path, forComments: comments) { [weak self] replies in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.comments = replies.sorted { $0.timestamp.seconds > $1.timestamp.seconds }
                    
                    strongSelf.comments.enumerated().forEach { [weak self] index, comment in
                        guard let strongSelf = self else { return }
                        strongSelf.comments[index].isAuthor = comment.uid == strongSelf.clinicalCase.caseId
                    }
                    
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
        view.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: loadingCellReuseIdentifier)
        collectionView.register(CommentCaseCell.self, forCellWithReuseIdentifier: commentCellReuseIdentifier)
        collectionView.register(ReplyCell.self, forCellWithReuseIdentifier: replyCellReuseIdentifier)
        collectionView.register(DeletedCommentCell.self, forCellWithReuseIdentifier: deletedContentCellReuseIdentifier)
        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        if !needsToFetch {
            configureCommentInputView()
        }
    }
    
    private func configureCommentInputView() {
        bottomSpinner = BottomSpinnerView(style: .medium)

        if clinicalCase.visible == .regular  {
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
    
    private func fetchContent() {
        collectionView.isHidden = true
        view.addSubviews(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
        ])
        
        guard let caseId = caseId else { return }
        CaseService.getPlainCase(withCaseId: caseId) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let clinicalCase):
                strongSelf.clinicalCase = clinicalCase
                let group = DispatchGroup()
                
                if let uid = strongSelf.uid, uid != "" {
                    group.enter()
                    UserService.fetchUser(withUid: uid) { [weak self] result in
                        guard let strongSelf = self else { return }
                        switch result {
                        case .success(let user):
                            strongSelf.user = user
                            group.leave()
                            
                        case .failure(_):
                            break
                        }
                    }
                }
                
                group.enter()
                
                CommentService.fetchReply(forCase: clinicalCase, forPath: strongSelf.path) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let comment):
                        strongSelf.comment = comment
                        group.leave()
                        
                    case .failure(_):
                        break
                    }
                }
                
                group.notify(queue: .main) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.collectionView.reloadData()
                    strongSelf.activityIndicator.stop()
                    strongSelf.activityIndicator.removeFromSuperview()
                    strongSelf.configureUI()
                    strongSelf.configureCommentInputView()
                    strongSelf.collectionView.isHidden = false
                    strongSelf.fetchRepliesForComment()
                }
                
            case .failure(_):
                break
            }
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

        guard lastReplySnapshot != nil, !comments.isEmpty, !isFetchingMoreReplies, comment.numberOfComments > comments.count else {
            return
        }

        showBottomSpinner()

        CommentService.fetchRepliesForCaseComment(forClinicalCase: clinicalCase, forPath: path, lastSnapshot: lastReplySnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.lastReplySnapshot = snapshot.documents.last
                var comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
                
                let visibleUids = comments.filter { $0.visible == .regular }.map { $0.uid }
                let uniqueUids = Array(Set(visibleUids))

                let currentUserUids = strongSelf.users.map { $0.uid }
                
                let usersToFetch = uniqueUids.filter { !currentUserUids.contains($0) }
                
                CommentService.getCaseCommentValuesFor(forCase: strongSelf.clinicalCase, forPath: strongSelf.path, forComments: comments) { [weak self] newComments in
                    
                    guard let strongSelf = self else { return }
                    comments = newComments
                    comments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    strongSelf.comments.append(contentsOf: comments)
                    
                    
                    guard !usersToFetch.isEmpty else {
                        strongSelf.collectionView.reloadData()
                        strongSelf.hideBottomSpinner()
                        return
                    }
                    
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
    
    private func handleLikeUnLike(for cell: CommentCaseCell, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let caseId = clinicalCase.caseId
        let commentId = comment.id
        let didLike = comment.didLike
        
        cell.viewModel?.comment.didLike.toggle()
        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        
        if indexPath.section == 0 {
            self.comment.didLike.toggle()
            self.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
            let commentPath = Array(path.dropLast())
            
            let anonymous = (uid == clinicalCase.uid && clinicalCase.privacy == .anonymous) ? true : false
            
            caseDidChangeCommentLike(caseId: caseId, path: commentPath, commentId: commentId, owner: comment.uid, didLike: didLike, anonymous: anonymous)
        } else {
            comments[indexPath.row].didLike.toggle()
            comments[indexPath.row].likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
            
            let anonymous = (uid == clinicalCase.uid && clinicalCase.privacy == .anonymous) ? true : false
            
            caseDidChangeCommentLike(caseId: caseId, path: path, commentId: commentId, owner: comment.uid, didLike: didLike, anonymous: anonymous)
        }
    }
}

extension CommentCaseRepliesViewController: UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : commentsLoaded ? comments.count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            
            switch comment.visible {
                
            case .regular, .anonymous:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! CommentCaseCell
                cell.delegate = self
                cell.viewModel = CommentViewModel(comment: comment)
                cell.setExpanded()
                
                if let user = user {
                    cell.set(user: user)
                } else {
                    cell.anonymize()
                }
                
                return cell
               
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
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! CommentCaseCell
                    cell.delegate = self
                    cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
                    cell.setCompress()
                    
                    if let userIndex = users.firstIndex(where: { $0.uid == comments[indexPath.row].uid }) {
                        cell.set(user: users[userIndex])
                    } else {
                        cell.anonymize()
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
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        
        CommentService.addReply(comment, path: path, clinicalCase: clinicalCase) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                strongSelf.comment.numberOfComments += 1
                
                if comment.visible == .regular {
                    guard let tab = strongSelf.tabBarController as? MainTabController, let user = tab.user else { return }
                    strongSelf.users.append(user)
                }
                
                // If the reply is not from the comment owner, we send a notification to the comment owner
                if strongSelf.comment.uid != comment.uid {
                    
                    var replyPath = strongSelf.path
                    replyPath.append(comment.id)
                    
                    let anonymous = (comment.uid == strongSelf.clinicalCase.uid && strongSelf.clinicalCase.privacy == .anonymous) ? true : false

                    FunctionsManager.shared.addNotificationOnCaseReply(caseId: strongSelf.clinicalCase.caseId, owner: strongSelf.comment.uid, path: replyPath, comment: comment, anonymous: anonymous)
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
                        strongSelf.caseDidChangeComment(caseId: strongSelf.clinicalCase.caseId, path: strongSelf.path, comment: comment, action: .add)
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
                displayAlert(withTitle: AppStrings.Alerts.Title.deleteComment, withMessage: AppStrings.Alerts.Subtitle.deleteComment, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    if indexPath.section == 0 {
                        let commentPath = Array(strongSelf.path.dropLast())
                        
                        CommentService.deleteComment(forCase: strongSelf.clinicalCase, forPath: commentPath, forCommentId: comment.id) { [weak self] error in
                            guard let strongSelf = self else { return }
                            if let error {
                                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            } else {
                                strongSelf.comment.visible = .deleted
                                
                                strongSelf.commentInputView.removeFromSuperview()
                                strongSelf.commentInputView.isHidden = true
                                
                                strongSelf.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                                strongSelf.collectionView.verticalScrollIndicatorInsets.bottom = 0
                                strongSelf.collectionView.reloadData()
                                
                                strongSelf.caseDidChangeComment(caseId: strongSelf.clinicalCase.caseId, path: commentPath, comment: comment, action: .remove)
                                
                                  let popupView = PopUpBanner(title: AppStrings.Content.Comment.delete, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                                  popupView.showTopPopup(inView: strongSelf.view)
                            }
                        }
                    } else {
                        CommentService.deleteComment(forCase: strongSelf.clinicalCase, forPath: strongSelf.path, forCommentId: comment.id) { [weak self] error in
                            guard let strongSelf = self else { return }
                            if let error {
                                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            } else {
                              
                                strongSelf.comments[indexPath.row].visible = .deleted
                                strongSelf.comment.numberOfComments -= 1
                                
                                strongSelf.collectionView.reloadData()
                                
                                strongSelf.caseDidChangeComment(caseId: strongSelf.clinicalCase.caseId, path: strongSelf.path, comment: comment, action: .remove)
                                
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
        if let indexPath = collectionView.indexPath(for: cell) {
            guard indexPath.section != 0 else { return }
            
            var path = self.path
            path.append(comment.id)
            
            if clinicalCase.privacy == .anonymous && comment.uid == clinicalCase.uid {
                let controller = CommentCaseRepliesViewController(path: path, comment: comment, clinicalCase: clinicalCase)
                navigationController?.pushViewController(controller, animated: true)
            } else {
                if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
                    
                    let controller = CommentCaseRepliesViewController(path: path, comment: comment, user: users[userIndex], clinicalCase: clinicalCase)
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
        
    func didTapLikeActionFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CommentCaseCell else { return }
        handleLikeUnLike(for: currentCell, at: indexPath)
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
    func caseDidChangeComment(caseId: String, path: [String], comment: Comment, action: CommentAction) {
        currentNotification = true
        ContentManager.shared.commentCaseChange(caseId: caseId, path: path, comment: comment, action: action)
    }
    
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        // Check if the currentNotification flag is set, and if so, toggle it and return
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        // Check if the notification object is of type PostCommentChange
        if let change = notification.object as? CaseCommentChange {
            
            // Check if the postId in the change object matches the postId of the current post
            guard change.caseId == self.clinicalCase.caseId else { return }
            
            if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CommentCaseCell {
                
                switch change.action {
                    
                case .add:
                    // A new comment was added to the root comment of this view
                    guard let tab = tabBarController as? MainTabController, let user = tab.user else { return }
                    
                    // Append the user to the users array
                    users.append(user)
                    
                    // Increment the number of comments for the current comment and its view model
                    comment.numberOfComments += 1
                    cell.viewModel?.comment.numberOfComments += 1
                    
                    // Insert the new comment at the beginning of the comments array and reload the collectionView
                    comments.insert(change.comment, at: 0)
                    
                    collectionView.reloadData()

                case .remove:
                    // Check if the comment is the root comment or a reply inside this comment
                    if comment.id == change.comment.id {
                        // Set the visibility of the current comment to 'deleted' and reload the collectionView
                        comment.visible = .deleted
                        commentInputView.removeFromSuperview()
                        commentInputView.isHidden = true
                        
                        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                        collectionView.verticalScrollIndicatorInsets.bottom = 0
                        
                        collectionView.reloadData()
                    } else if let index = comments.firstIndex(where: { $0.id == change.comment.id }) {
                        // Decrement the number of comments for the current comment and its view model
                        self.comment.numberOfComments -= 1
                        cell.viewModel?.comment.numberOfComments -= 1
                        // Set the visibility of the comment at the specified index to 'deleted' and reload the collectionView
                        comments[index].visible = .deleted
                        collectionView.reloadData()
                    }
                }
            }
        }
    }

    func caseDidChangeCommentLike(caseId: String, path: [String], commentId: String, owner: String, didLike: Bool, anonymous: Bool) {
        currentNotification = true
        ContentManager.shared.likeCommentCaseChange(caseId: caseId, path: path, commentId: commentId, owner: owner, didLike: !didLike, anonymous: anonymous)
    }
    
    @objc func caseCommentLikeChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseCommentLikeChange {
            guard change.caseId == clinicalCase.caseId else { return }
            
            if change.commentId == comment.id {
                if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CommentCaseCell {
                    
                    let likes = self.comment.likes
                    
                    self.comment.likes = change.didLike ? likes + 1 : likes - 1
                    self.comment.didLike = change.didLike
                    
                    cell.viewModel?.comment.didLike = change.didLike
                    cell.viewModel?.comment.likes = change.didLike ? likes + 1 : likes - 1
                }
            } else if let index = comments.firstIndex(where: { $0.id == change.commentId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) as? CommentCaseCell {
                    let likes = comments[index].likes
                    
                    comments[index].didLike = change.didLike
                    comments[index].likes = change.didLike ? likes + 1 : likes - 1
                    
                    cell.viewModel?.comment.didLike = change.didLike
                    cell.viewModel?.comment.likes = change.didLike ? likes + 1 : likes - 1
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


