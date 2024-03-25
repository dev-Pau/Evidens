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
private let commentCaseExtendedCellReuseIdentifier = "CommentCaseExtendedCellReuseIdentifier"
private let commentCaseCellReuseIdentifier = "CommentCaseCellReuseIdentifier"
private let deletedContentCellReuseIdentifier = "DeletedContentCellReuseIdentifier"

class CommentCaseRepliesViewController: UIViewController {
    private var viewModel: CommentCaseRepliesViewModel

    private var bottomAnchorConstraint: NSLayoutConstraint!

    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    private var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = K.Colors.primaryColor
        tabBarController?.tabBar.standardAppearance = appearance
        tabBarController?.tabBar.scrollEdgeAppearance = appearance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = K.Colors.separatorColor
        appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = K.Colors.primaryColor
        tabBarController?.tabBar.standardAppearance = appearance
        tabBarController?.tabBar.scrollEdgeAppearance = appearance
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewModel.firstLoad {
            let height = commentInputView.frame.height - 1
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            collectionView.verticalScrollIndicatorInsets.bottom = height
            viewModel.firstLoad = true
        }
    }

    init(path: [String], comment: Comment, user: User? = nil, clinicalCase: Case) {
        self.viewModel = CommentCaseRepliesViewModel(path: path, comment: comment, user: user, clinicalCase: clinicalCase)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(caseId: String, uid: String, path: [String]) {
        self.viewModel = CommentCaseRepliesViewModel(caseId: caseId, uid: uid, path: path)
        super.init(nibName: nil, bundle: nil)
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
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: addLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .systemBackground
        collectionView.register(SecondaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: loadingCellReuseIdentifier)
        collectionView.register(CommentCaseCell.self, forCellWithReuseIdentifier: commentCaseCellReuseIdentifier)
        collectionView.register(CommentCaseExpandedCell.self, forCellWithReuseIdentifier: commentCaseExtendedCellReuseIdentifier)
        collectionView.register(DeletedCommentCell.self, forCellWithReuseIdentifier: deletedContentCellReuseIdentifier)
        
        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        if !viewModel.needsToFetch {
            configureCommentInputView()
        }
    }
    
    private func addLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
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
        }
    }
    
    private func fetchContent() {
       
        viewModel.getContent { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            } else {
                strongSelf.viewModel.firstLoad = false
                strongSelf.collectionView.reloadData()
                strongSelf.configureCommentInputView()
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
        
        let tabBarHeight = UIDevice.isPad ? view.safeAreaInsets.bottom : (tabBarController?.tabBar.frame.height ?? 0)
        
        let constant = -(keyboardHeight - tabBarHeight)
        
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.bottomAnchorConstraint.constant = constant
            strongSelf.view.layoutIfNeeded()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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
    
    private func handleLikeUnLike(for cell: CommentCaseProtocol, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment, let uid = UserDefaults.getUid() else { return }
        
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

extension CommentCaseRepliesViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.commentLoaded ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return viewModel.commentsLoaded ? viewModel.networkFailure ? 1 : viewModel.comments.isEmpty ? 0 : viewModel.comments.count : 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if !viewModel.commentLoaded {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellReuseIdentifier, for: indexPath) as! LoadingCell
                return cell
            } else {
                switch viewModel.comment.visible {
                    
                case .regular, .anonymous:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCaseExtendedCellReuseIdentifier, for: indexPath) as! CommentCaseExpandedCell
                    cell.delegate = self
                    cell.viewModel = CommentViewModel(comment: viewModel.comment)
                    
                    switch viewModel.comment.visible {
                        
                    case .regular:
                        if let user = viewModel.user {
                            cell.set(user: user)
                        }
                    case .anonymous:
                        cell.set()
                    case .deleted:
                        fatalError()
                    }
                    
                    return cell
                   
                case .deleted:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedContentCellReuseIdentifier, for: indexPath) as! DeletedCommentCell
                    cell.delegate = self
                    return cell
                }

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
                        
                    case .regular:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCaseCellReuseIdentifier, for: indexPath) as! CommentCaseCell
                        cell.delegate = self
                        cell.viewModel = CommentViewModel(comment: comment)

                        if let userIndex = viewModel.users.firstIndex(where: { $0.uid == viewModel.comments[indexPath.row].uid }) {
                            cell.set(user: viewModel.users[userIndex], author: viewModel.user)
                        }
                        
                        return cell
                    case .anonymous:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCaseCellReuseIdentifier, for: indexPath) as! CommentCaseCell
                        cell.delegate = self
                        cell.viewModel = CommentViewModel(comment: comment)
                        cell.set()
                        return cell
                        
                    case .deleted:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedContentCellReuseIdentifier, for: indexPath) as! DeletedCommentCell
                        cell.delegate = self
                        cell.viewModel = CommentViewModel(comment: comment)
                        return cell
                    }
                }
            }
        }
    }
}

extension CommentCaseRepliesViewController: CommentInputAccessoryViewDelegate {
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToEditComment comment: String, forId id: String) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        
        viewModel.editReply(comment, withId: id, withCurrentUser: currentUser) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {

                if id == strongSelf.viewModel.comment.id {
                    strongSelf.viewModel.comment.set(comment: comment)
                    strongSelf.caseDidChangeComment(caseId: strongSelf.viewModel.clinicalCase.caseId, path: strongSelf.viewModel.path, comment: strongSelf.viewModel.comment, action: .edit)
                } else if let index = strongSelf.viewModel.comments.firstIndex(where: { $0.id == id}) {
                    strongSelf.viewModel.comments[index].set(comment: comment)
                    strongSelf.caseDidChangeComment(caseId: strongSelf.viewModel.clinicalCase.caseId, path: strongSelf.viewModel.path, comment: strongSelf.viewModel.comments[index], action: .edit)
                }
                
                let popupView = PopUpBanner(title: AppStrings.PopUp.commentModified, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                popupView.showTopPopup(inView: strongSelf.view)
                
                strongSelf.collectionView.reloadData()
            }
        }
    }
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }

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
                        
                        let popupView = PopUpBanner(title: AppStrings.PopUp.commentAdded, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                        popupView.showTopPopup(inView: strongSelf.view)
                    }
                }
            case .failure(let error):
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    func textDidChange(_ inputView: CommentInputAccessoryView) {
        collectionView.contentInset.bottom = inputView.frame.height - 1
        collectionView.verticalScrollIndicatorInsets.bottom = inputView.frame.height
        view.layoutIfNeeded()
    }
    
    func textDidBeginEditing() {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
}

extension CommentCaseRepliesViewController: CommentCellDelegate {
    
    func didTapHashtag(_ hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: CommentMenu) {
        if let indexPath = collectionView.indexPath(for: cell) {
            switch action {
            case .back:
                navigationController?.popViewController(animated: true)
            case .report:
                let controller = ReportViewController(source: .comment, userId: comment.uid, contentId: comment.id)
                let navVC = UINavigationController(rootViewController: controller)
                navVC.modalPresentationStyle = UIModalPresentationStyle.getBasePresentationStyle()
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
                                
                                let popupView = PopUpBanner(title: AppStrings.Content.Reply.delete, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                                popupView.showTopPopup(inView: strongSelf.view)
                            }
                        }
                    }
                }
            case .edit:
                guard commentInputView.commentId == nil else {
                    displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.editComment) {
                        [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.commentInputView.commentTextView.becomeFirstResponder()
                    }
                    return
                }
                
                commentInputView.set(edit: true, text: comment.comment, commentId: comment.id)
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
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CommentCaseProtocol else { return }
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
}

extension CommentCaseRepliesViewController: DeletedCommentCellDelegate {
    
    func didTapReplies(_ cell: UICollectionViewCell, forComment comment: Comment) {

        if let userIndex = viewModel.users.firstIndex(where: { $0.uid == comment.uid }) {
            
            var path = viewModel.path
            path.append(comment.id)
            
            let controller = CommentCaseRepliesViewController(path: path, comment: comment, user: viewModel.users[userIndex], clinicalCase: viewModel.clinicalCase)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapLearnMore() { }
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
                let commentId = change.path.last
                
                if viewModel.comment.id == commentId {
                    // A new comment was added to the root comment of this view
                    guard let tab = tabBarController as? MainTabController, let user = tab.user else { return }
                    
                    // Append the user to the users array
                    viewModel.users.append(user)
                    
                    // Increment the number of comments for the current comment and its view model
                    viewModel.comment.numberOfComments += 1

                    // Insert the new comment at the beginning of the comments array and reload the collectionView
                    viewModel.comments.insert(change.comment, at: 0)
                    
                    collectionView.reloadData()

                } else if let index = viewModel.comments.firstIndex(where: { $0.id == change.path.last }) {
                    viewModel.comments[index].numberOfComments += 1
                    collectionView.reloadData()
                }
                
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
                } else if let index = viewModel.comments.firstIndex(where: { $0.id == change.path.last }) {
                    
                    viewModel.comments[index].numberOfComments -= 1
                    collectionView.reloadData()
                }
            case .edit:
                if viewModel.comment.id == change.comment.id {
                    viewModel.comment.set(comment: change.comment.comment)
                    collectionView.reloadData()
                } else if let index = viewModel.comments.firstIndex(where: { $0.id == change.comment.id }) {
                    viewModel.comments[index].set(comment: change.comment.comment)
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


