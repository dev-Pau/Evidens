//
//  CommentCaseRepliesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/5/23.
//

import UIKit


import UIKit
import Firebase

private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"
private let loadingCellReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let commentCellReuseIdentifier = "CommentCellReuseIdentifier"
private let deletedContentCellReuseIdentifier = "DeletedContentCellReuseIdentifier"

class CommentCaseRepliesViewController: UICollectionViewController {
    private var viewModel: CommentCaseRepliesViewModel
    private let activityIndicator = PrimaryLoadingView(frame: .zero)
  
    private var commentMenuLauncher = ContextMenu(display: .comment)
    private var bottomAnchorConstraint: NSLayoutConstraint!

    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        tabBarController?.tabBar.standardAppearance = appearance
        tabBarController?.tabBar.scrollEdgeAppearance = appearance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = separatorColor
        tabBarController?.tabBar.standardAppearance = appearance
        tabBarController?.tabBar.scrollEdgeAppearance = appearance
    }


    init(path: [String], comment: Comment, user: User? = nil, clinicalCase: Case) {
        self.viewModel = CommentCaseRepliesViewModel(path: path, comment: comment, user: user, clinicalCase: clinicalCase)
        
        let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
       }

        super.init(collectionViewLayout: compositionalLayout)
    }
    
    init(caseId: String, uid: String, path: [String]) {
        self.viewModel = CommentCaseRepliesViewModel(caseId: caseId, uid: uid, path: path)
        
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
        if viewModel.needsToFetch {
            fetchContent()
        } else {
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
        viewModel.getReplies { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(SecondaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: loadingCellReuseIdentifier)
        collectionView.register(CommentCaseCell.self, forCellWithReuseIdentifier: commentCellReuseIdentifier)
        collectionView.register(DeletedCommentCell.self, forCellWithReuseIdentifier: deletedContentCellReuseIdentifier)
        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        if !viewModel.needsToFetch {
            configureCommentInputView()
        }
    }
    
    private func configureCommentInputView() {
        if viewModel.clinicalCase.visible == .regular  {
            view.addSubviews(commentInputView)
            
            bottomAnchorConstraint = commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            NSLayoutConstraint.activate([
                bottomAnchorConstraint,
                commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
        
        viewModel.getContent { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                strongSelf.collectionView.reloadData()
                strongSelf.activityIndicator.stop()
                strongSelf.activityIndicator.removeFromSuperview()
                strongSelf.configureCommentInputView()
                strongSelf.collectionView.isHidden = false
                strongSelf.fetchRepliesForComment()
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
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreReplies()
        }
    }
    
    private func getMoreReplies() {
        viewModel.getMoreReplies { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
    
    private func handleLikeUnLike(for cell: CommentCaseCell, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let caseId = viewModel.clinicalCase.caseId
        let commentId = comment.id
        let didLike = comment.didLike
        
        cell.viewModel?.comment.didLike.toggle()
        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        
        if indexPath.section == 0 {
            viewModel.comment.didLike.toggle()
            viewModel.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
            let commentPath = Array(viewModel.path.dropLast())
            
            let anonymous = (uid == viewModel.clinicalCase.uid && viewModel.clinicalCase.privacy == .anonymous) ? true : false
            
            caseDidChangeCommentLike(caseId: caseId, path: commentPath, commentId: commentId, owner: comment.uid, didLike: didLike, anonymous: anonymous)
        } else {
            viewModel.comments[indexPath.row].didLike.toggle()
            viewModel.comments[indexPath.row].likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
            
            let anonymous = (uid == viewModel.clinicalCase.uid && viewModel.clinicalCase.privacy == .anonymous) ? true : false
            
            caseDidChangeCommentLike(caseId: caseId, path: viewModel.path, commentId: commentId, owner: comment.uid, didLike: didLike, anonymous: anonymous)
        }
    }
}

extension CommentCaseRepliesViewController: UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return viewModel.commentsLoaded ? viewModel.networkFailure ? 1 : viewModel.comments.isEmpty ? 0 : viewModel.comments.count : 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            
            switch viewModel.comment.visible {
                
            case .regular, .anonymous:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! CommentCaseCell
                cell.delegate = self
                cell.viewModel = CommentViewModel(comment: viewModel.comment)
                cell.setExpanded()
                
                if let user = viewModel.user {
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
            if !viewModel.commentsLoaded {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellReuseIdentifier, for: indexPath) as! LoadingCell
                return cell
                
            } else {
                if viewModel.networkFailure {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! SecondaryNetworkFailureCell
                    cell.delegate = self
                    return cell
                }  else {
                    let comment = viewModel.comments[indexPath.row]
                    switch comment.visible {
                        
                    case .regular, .anonymous:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! CommentCaseCell
                        cell.delegate = self
                        cell.viewModel = CommentViewModel(comment: viewModel.comments[indexPath.row])
                        cell.setCompress()
                        
                        if let userIndex = viewModel.users.firstIndex(where: { $0.uid == viewModel.comments[indexPath.row].uid }) {
                            cell.set(user: viewModel.users[userIndex])
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
}

extension CommentCaseRepliesViewController: CommentInputAccessoryViewDelegate {
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        inputView.commentTextView.resignFirstResponder()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        
        viewModel.addReply(comment, withCurrentUser: currentUser) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.collectionView.performBatchUpdates { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.viewModel.comments.insert(comment, at: 0)
                        
                        if strongSelf.viewModel.comments.count == 1 {
                            strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
                        } else {
                            strongSelf.collectionView.insertItems(at: [IndexPath(item: 0, section: 1)])
                        }
                         
                    } completion: { [weak self] _ in
                        guard let strongSelf = self else { return }
                        strongSelf.collectionView.reloadSections(IndexSet(integer: 0))
                        strongSelf.caseDidChangeComment(caseId: strongSelf.viewModel.clinicalCase.caseId, path: strongSelf.viewModel.path, comment: comment, action: .add)
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
                        let commentPath = Array(strongSelf.viewModel.path.dropLast())
                        
                        strongSelf.viewModel.deleteComment(forId: comment.id, forPath: commentPath) { [weak self] error in
                            guard let strongSelf = self else { return }
                            if let error {
                                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            } else {
                                strongSelf.viewModel.comment.visible = .deleted
                                
                                strongSelf.commentInputView.removeFromSuperview()
                                strongSelf.commentInputView.isHidden = true
                                
                                strongSelf.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                                strongSelf.collectionView.verticalScrollIndicatorInsets.bottom = 0
                                strongSelf.collectionView.reloadData()
                                
                                strongSelf.caseDidChangeComment(caseId: strongSelf.viewModel.clinicalCase.caseId, path: commentPath, comment: comment, action: .remove)
                                
                                  let popupView = PopUpBanner(title: AppStrings.Content.Comment.delete, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                                  popupView.showTopPopup(inView: strongSelf.view)
                            }
                        }
                    } else {
                        strongSelf.viewModel.deleteComment(forId: comment.id, forPath: strongSelf.viewModel.path) { [weak self] error in
                            guard let strongSelf = self else { return }
                            if let error {
                                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            } else {
                                strongSelf.viewModel.comments[indexPath.row].visible = .deleted
                                strongSelf.viewModel.comment.numberOfComments -= 1
                                
                                strongSelf.collectionView.reloadData()
                                
                                strongSelf.caseDidChangeComment(caseId: strongSelf.viewModel.clinicalCase.caseId, path: strongSelf.viewModel.path, comment: comment, action: .remove)
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
            
            var path = viewModel.path
            path.append(comment.id)
            
            if viewModel.clinicalCase.privacy == .anonymous && comment.uid == viewModel.clinicalCase.uid {
                let controller = CommentCaseRepliesViewController(path: path, comment: comment, clinicalCase: viewModel.clinicalCase)
                navigationController?.pushViewController(controller, animated: true)
            } else {
                if let userIndex = viewModel.users.firstIndex(where: { $0.uid == comment.uid }) {
                    
                    let controller = CommentCaseRepliesViewController(path: path, comment: comment, user: viewModel.users[userIndex], clinicalCase: viewModel.clinicalCase)
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
        viewModel.currentNotification = true
        ContentManager.shared.commentCaseChange(caseId: caseId, path: path, comment: comment, action: action)
    }
    
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        // Check if the currentNotification flag is set, and if so, toggle it and return
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        // Check if the notification object is of type PostCommentChange
        if let change = notification.object as? CaseCommentChange {
            
            // Check if the postId in the change object matches the postId of the current post
            guard change.caseId == viewModel.clinicalCase.caseId else { return }
            
            switch change.action {
                
            case .add:
                // A new comment was added to the root comment of this view
                guard let tab = tabBarController as? MainTabController, let user = tab.user else { return }
                
                // Append the user to the users array
                viewModel.users.append(user)
                
                // Increment the number of comments for the current comment and its view model
                viewModel.comment.numberOfComments += 1

                // Insert the new comment at the beginning of the comments array and reload the collectionView
                viewModel.comments.insert(change.comment, at: 0)
                
                collectionView.reloadData()

            case .remove:
                // Check if the comment is the root comment or a reply inside this comment
                if viewModel.comment.id == change.comment.id {
                    // Set the visibility of the current comment to 'deleted' and reload the collectionView
                    viewModel.comment.visible = .deleted
                    commentInputView.removeFromSuperview()
                    commentInputView.isHidden = true
                    
                    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    collectionView.verticalScrollIndicatorInsets.bottom = 0
                    
                    collectionView.reloadData()
                } else if let index = viewModel.comments.firstIndex(where: { $0.id == change.comment.id }) {
                    // Decrement the number of comments for the current comment and its view model
                    viewModel.comment.numberOfComments -= 1

                    // Set the visibility of the comment at the specified index to 'deleted' and reload the collectionView
                    viewModel.comments[index].visible = .deleted
                    collectionView.reloadData()
                }
            }
        }
    }

    func caseDidChangeCommentLike(caseId: String, path: [String], commentId: String, owner: String, didLike: Bool, anonymous: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.likeCommentCaseChange(caseId: caseId, path: path, commentId: commentId, owner: owner, didLike: !didLike, anonymous: anonymous)
    }
    
    @objc func caseCommentLikeChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseCommentLikeChange {
            guard change.caseId == viewModel.clinicalCase.caseId else { return }
            
            if change.commentId == viewModel.comment.id {
                let likes = viewModel.comment.likes
                
                viewModel.comment.likes = change.didLike ? likes + 1 : likes - 1
                viewModel.comment.didLike = change.didLike
                collectionView.reloadData()
            } else if let index = viewModel.comments.firstIndex(where: { $0.id == change.commentId }) {
                let likes = viewModel.comments[index].likes
                
                viewModel.comments[index].didLike = change.didLike
                viewModel.comments[index].likes = change.didLike ? likes + 1 : likes - 1

                collectionView.reloadData()
            }
        }
    }
}

extension CommentCaseRepliesViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            if let currentUser = viewModel.user, currentUser.isCurrentUser {
                viewModel.user = user
                collectionView.reloadData()
            }
            
            if let index = viewModel.users.firstIndex(where: { $0.uid == user.uid }) {
                viewModel.users[index] = user
                collectionView.reloadData()
            }
        }
    }
}

extension CommentCaseRepliesViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        viewModel.networkFailure = false
        viewModel.commentsLoaded = false
        collectionView.reloadData()
        fetchRepliesForComment()
    }
}


