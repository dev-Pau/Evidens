//
//  DetailsPostViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/7/22.
//

import UIKit
import Firebase
import SafariServices

private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let commentReuseIdentifier = "CommentCellReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"

private let postTextCellReuseIdentifier = "PostTextCellReuseIdentifier"
private let postTextImageCellReuseIdentifier = "PostTextImageCellReuseIdentifier"
private let postLinkCellReuseIdentifier = "PostLinkCellReuseIdentifer"

private let deletedContentCellReuseIdentifier = "DeletedContentCellReuseIdentifier"
private let deletedCellReuseIdentifier = "DeletedCellReuseIdentifier"

private let disabledCellReuseIdentifier = "DisabledCellReuseIdentifier"

class DetailsPostViewController: UIViewController, UINavigationControllerDelegate {
    
    var viewModel: DetailsPostViewModel
    
    private var zoomTransitioning = ZoomTransitioning()
    private let referenceMenu = ReferenceMenu()
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureNotificationObservers()
        configureNavigationBar()
        if let _ = viewModel.postId {
            fetchPost()
        } else {
            fetchComments()
        }
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postVisibleChange(_:)), name: NSNotification.Name(AppPublishers.Names.postVisibility), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.postLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.postBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.postComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postEditChange(_:)), name: NSNotification.Name(AppPublishers.Names.postEdit), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.postCommentLike), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewModel.firstLoad {
            let height = commentInputView.frame.height - 1
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            collectionView.verticalScrollIndicatorInsets.bottom = height
            viewModel.firstLoad = true
        }
    }
    
    init(post: Post, user: User) {
        self.viewModel = DetailsPostViewModel(post: post, user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(postId: String) {
        self.viewModel = DetailsPostViewModel(postId: postId)
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.bottomAnchorConstraint.constant = constant
            strongSelf.view.layoutIfNeeded()
        }
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Content.Post.post
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.leftChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: addLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(SecondaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.register(CommentPostCell.self, forCellWithReuseIdentifier: commentReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(TertiaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.register(DeletedCommentCell.self, forCellWithReuseIdentifier: deletedContentCellReuseIdentifier)
        collectionView.register(DeletedContentCell.self, forCellWithReuseIdentifier: deletedCellReuseIdentifier)
        
        collectionView.register(PostTextExpandedCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        collectionView.register(PostTextImageExpandedCell.self, forCellWithReuseIdentifier: postTextImageCellReuseIdentifier)
        collectionView.register(PostLinkExpandedCell.self, forCellWithReuseIdentifier: postLinkCellReuseIdentifier)
        collectionView.register(PageDisabledCell.self, forCellWithReuseIdentifier: disabledCellReuseIdentifier)
        
        view.addSubview(collectionView)
        
        if viewModel.postId == nil && viewModel.post.visible == .regular {
            configureCommentInputView()
        }
    }
    
    private func addLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(55))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let height: NSCollectionLayoutDimension = UIDevice.isPad ? .estimated(800) : .estimated(500)
            
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: height)
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            if sectionNumber == 0 && !strongSelf.viewModel.postLoaded {
                section.boundarySupplementaryItems = [header]
            } else if sectionNumber == 1 && !strongSelf.viewModel.commentsLoaded {
                section.boundarySupplementaryItems = [header]
            }
            
            return section
        }
        
        return layout
    }
    
    private func configureCommentInputView() {
        guard viewModel.post.visible == .regular else { return }
        
        view.addSubviews(commentInputView)
        
        bottomAnchorConstraint = commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            bottomAnchorConstraint,
            commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        commentInputView.set(placeholder: AppStrings.Content.Comment.voice)
    }
    
    private func fetchPost() {
        
        viewModel.fetchPost { [weak self] error in
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
                strongSelf.fetchComments()
            }
        }
    }
    
    private func fetchComments() {
        viewModel.getComments { [weak self] in
            guard let strongSelf = self else { return }
            guard strongSelf.collectionView.numberOfSections == 2 else { return }
            strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    private func getMoreComments() {
        viewModel.getMoreComments { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreComments()
        }
    }
    
    private func handleLikeUnLike(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        let postId = post.postId
        let didLike = post.didLike
        postDidChangeLike(postId: postId, didLike: didLike)
        
        cell.viewModel?.post.didLike.toggle()
        viewModel.post.didLike.toggle()
        
        cell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        viewModel.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
    }
    
    func handleBookmarkUnbookmark(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        let postId = post.postId
        let didBookmark = post.didBookmark
        postDidChangeBookmark(postId: postId, didBookmark: didBookmark)
        
        cell.viewModel?.post.didBookmark.toggle()
        viewModel.post.didBookmark.toggle()
    }
    
    private func handleLikeUnLike(for cell: CommentPostProtocol, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment else { return }
        
        let postId = viewModel.post.postId
        let commentId = comment.id
        let didLike = comment.didLike
        
        postDidChangeCommentLike(postId: postId, path: [], commentId: commentId, owner: comment.uid, didLike: didLike)
        
        cell.viewModel?.comment.didLike.toggle()
        viewModel.comments[indexPath.row].didLike.toggle()
        
        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        viewModel.comments[indexPath.row].likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
    }
    
    private func deletePost(withId id: String, at indexPath: IndexPath) {
        
        displayAlert(withTitle: AppStrings.Alerts.Title.deletePost, withMessage: AppStrings.Alerts.Subtitle.deletePost, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.deletePost(forId: id) { [weak self] error in
                guard let strongSelf = self else { return }
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.postDidChangeVisible(postId: id)
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    strongSelf.collectionView.verticalScrollIndicatorInsets.bottom = 0
                    strongSelf.commentInputView.removeFromSuperview()
                    
                    let popupView = PopUpBanner(title: AppStrings.PopUp.deletePost, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                    popupView.showTopPopup(inView: strongSelf.view)
                }
            }
        }
    }
}

extension DetailsPostViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.postLoaded ? viewModel.post.visible != .disabled ? 2 : 1 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.postLoaded ? 1 : 0
        } else {
            return viewModel.commentsLoaded ? viewModel.networkFailure ? 1 : viewModel.comments.isEmpty ? 1 : viewModel.comments.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            switch viewModel.post.visible {
                
            case .regular:
                switch viewModel.post.kind {
                    
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextCellReuseIdentifier, for: indexPath) as! PostTextExpandedCell
                    cell.delegate = self
                    cell.viewModel = PostViewModel(post: viewModel.post)
                    cell.set(user: viewModel.user)
                    return cell
                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextImageCellReuseIdentifier, for: indexPath) as! PostTextImageExpandedCell
                    cell.delegate = self
                    cell.viewModel = PostViewModel(post: viewModel.post)
                    cell.set(user: viewModel.user)
                    return cell
                case .link:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postLinkCellReuseIdentifier, for: indexPath) as! PostLinkExpandedCell
                    
                    cell.delegate = self
                    cell.viewModel = PostViewModel(post: viewModel.post)
                    cell.set(user: viewModel.user)
                    
                    return cell
                }
            case .deleted:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedCellReuseIdentifier, for: indexPath) as! DeletedContentCell
                cell.setPost()
                return cell
            case .hidden:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedCellReuseIdentifier, for: indexPath) as! DeletedContentCell
                cell.setHiddenPost()
                return cell
            case .disabled:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: disabledCellReuseIdentifier, for: indexPath) as! PageDisabledCell
                cell.delegate = self
                return cell
            }
        } else {
            if viewModel.networkFailure {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! SecondaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if viewModel.comments.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! TertiaryEmptyCell
                    cell.configure(title: AppStrings.Content.Comment.emptyTitle, description: AppStrings.Content.Comment.emptyPost)
                    return cell
                } else {
                    let comment = viewModel.comments[indexPath.row]
                    
                    switch comment.visible {
                        
                    case .regular:

                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentReuseIdentifier, for: indexPath) as! CommentPostCell
                        cell.delegate = self
                        cell.viewModel = CommentViewModel(comment: comment)

                        if let userIndex = viewModel.users.firstIndex(where: { $0.uid == comment.uid }) {
                            cell.set(user: viewModel.users[userIndex], author: viewModel.user)
                        }
                        
                        return cell

                    case .anonymous:
                        fatalError()
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

extension DetailsPostViewController: PostCellDelegate {
    
    func cell(showURL urlString: String) {
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                presentSafariViewController(withURL: url)
            } else {
                presentWebViewController(withURL: url)
            }
        }
    }
    
    func cell(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(didTapMenuOptionsFor post: Post, option: PostMenu) {
        switch option {
        case .delete:
            deletePost(withId: post.postId, at: IndexPath(item: 0, section: 0))
        case .edit:
            let controller = EditPostViewController(post: post)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            
            present(nav, animated: true)
        case .report:
            let controller = ReportViewController(source: .post, userId: viewModel.user.uid!, contentId: post.postId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
            
        case .reference:
            guard let reference = post.reference else { return }
            referenceMenu.showImageSettings(in: view, forPostId: post.postId, forReferenceKind: reference)
            referenceMenu.delegate = self
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        commentInputView.commentTextView.becomeFirstResponder()
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let currentCell = cell as? HomeCellProtocol else { return }
        handleLikeUnLike(for: currentCell, at: IndexPath(item: 0, section: 0))
    }
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        guard let currentCell = cell as? HomeCellProtocol else { return }
        handleBookmarkUnbookmark(for: currentCell, at: IndexPath(item: 0, section: 0))
    }
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        self.navigationController?.delegate = zoomTransitioning
        viewModel.selectedImage = image[index]
        let controller = ZoomImageViewController(images: map, index: index)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
        guard let currentUid = UserDefaults.getUid(), currentUid == post.uid else { return }
        let controller = LikesViewController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) { return }
}

extension DetailsPostViewController: CommentCellDelegate {
    
    func didTapHashtag(_ hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapLikeActionFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CommentPostProtocol else { return }
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
    
    func wantsToSeeRepliesFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        
        if let userIndex = viewModel.users.firstIndex(where: { $0.uid == comment.uid }) {
            let controller = CommentPostRepliesViewController(path: [comment.id], comment: comment, user: viewModel.users[userIndex], post: viewModel.post)
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: CommentMenu) {
        switch action {
        case .report:
            let controller = ReportViewController(source: .comment, userId: comment.uid, contentId: comment.id)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
            
        case .delete:
            if let indexPath = self.collectionView.indexPath(for: cell) {
                
                displayAlert(withTitle: AppStrings.Alerts.Title.deleteComment, withMessage: AppStrings.Alerts.Subtitle.deleteComment, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.viewModel.deleteComment(forPath: [], forCommentId: comment.id) { [weak self] error in
                        guard let strongSelf = self else { return }
                        if let error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                            strongSelf.collectionView.reloadData()
                            
                            strongSelf.postDidChangeComment(postId: strongSelf.viewModel.post.postId, path: [], comment: comment, action: .remove)
                            
                            let popupView = PopUpBanner(title: AppStrings.Content.Comment.delete, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                            popupView.showTopPopup(inView: strongSelf.view)
                        }
                    }
                }
            }
            
        case .back:
            navigationController?.popViewController(animated: true)
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
    
    func didTapProfile(forUser user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension DetailsPostViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return viewModel.selectedImage
    }
}

extension DetailsPostViewController: ReferenceMenuDelegate {
    func didTapReference(reference: Reference) {
        switch reference.option {
        case .link:
            if let url = URL(string: reference.referenceText) {
                if UIApplication.shared.canOpenURL(url) {
                    presentSafariViewController(withURL: url)
                } else {
                    presentWebViewController(withURL: url)
                }
            }
        case .citation:
            let wordToSearch = reference.referenceText
            if let encodedQuery = wordToSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: AppStrings.URL.googleQuery + encodedQuery) {
                    if UIApplication.shared.canOpenURL(url) {
                        presentSafariViewController(withURL: url)
                    } else {
                        presentWebViewController(withURL: url)
                    }
                }
            }
        }
    }
}

extension DetailsPostViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
    }
}

extension DetailsPostViewController: CommentInputAccessoryViewDelegate {
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToEditComment comment: String, forId id: String) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        
        viewModel.editComment(comment, forId: id, from: currentUser) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                if let index = strongSelf.viewModel.comments.firstIndex(where: { $0.id == id }) {
                    strongSelf.viewModel.comments[index].set(comment: comment)
                    strongSelf.collectionView.reloadData()
                    
                    let popupView = PopUpBanner(title: AppStrings.PopUp.commentModified, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                    popupView.showTopPopup(inView: strongSelf.view)
                    
                    strongSelf.postDidChangeComment(postId: strongSelf.viewModel.post.postId, path: [], comment: strongSelf.viewModel.comments[index], action: .edit)
                }
            }
        }
    }
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        
        viewModel.addComment(comment, from: currentUser) { [weak self] result in
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
                        strongSelf.postDidChangeComment(postId: strongSelf.viewModel.post.postId, path: [], comment: comment, action: .add)
                        
                        if let cell = strongSelf.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? HomeCellProtocol {
                            cell.viewModel?.post.numberOfComments += 1
                        }
                        
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

extension DetailsPostViewController: DeletedCommentCellDelegate {
    func didTapReplies(_ cell: UICollectionViewCell, forComment comment: Comment) {
        
        guard comment.numberOfComments > 0 else { return }
        
        if let userIndex = viewModel.users.firstIndex(where: { $0.uid == comment.uid }) {
            let controller = CommentPostRepliesViewController(path: [comment.id], comment: comment, user: viewModel.users[userIndex], post: viewModel.post)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapLearnMore() { }
}

extension DetailsPostViewController: PostChangesDelegate {
    func postDidChangeVisible(postId: String) {
        viewModel.currentNotification = true
        ContentManager.shared.visiblePostChange(postId: postId)
    }
    
    @objc func postVisibleChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostVisibleChange {
            if viewModel.post.postId == change.postId {
                viewModel.post.visible = .deleted
                collectionView.reloadData()
                collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                collectionView.verticalScrollIndicatorInsets.bottom = 0
                commentInputView.removeFromSuperview()
            }
        }
    }
    
    func postDidChangeComment(postId: String, path: [String], comment: Comment, action: CommentAction) {
        viewModel.currentNotification = true
        ContentManager.shared.commentPostChange(postId: postId, path: path, comment: comment, action: action)
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostCommentChange {
            guard change.postId == viewModel.post.postId else { return }
            
            switch change.action {
                
            case .add:
                // Check if the comment is directly a post reply
                if change.path.isEmpty {
                    guard let tab = tabBarController as? MainTabController, let user = tab.user else { return }
                    viewModel.users.append(user)
                    
                    viewModel.post.numberOfComments += 1
                    viewModel.comments.insert(change.comment, at: 0)
                    collectionView.reloadData()
                    
                } else {
                    if let index = viewModel.comments.firstIndex(where: { $0.id == change.path.last }) {
                        viewModel.comments[index].numberOfComments += 1
                        collectionView.reloadData()
                    }
                }
                
            case .remove:
                // Check if the comment is directly a post reply
                if change.path.isEmpty {
                    if let index = viewModel.comments.firstIndex(where: { $0.id == change.comment.id }) {
                        viewModel.post.numberOfComments -= 1
                        viewModel.comments[index].visible = .deleted
                        collectionView.reloadData()
                    }
                } else {
                    if let index = viewModel.comments.firstIndex(where: { $0.id == change.path.last }) {
                        viewModel.comments[index].numberOfComments -= 1
                        collectionView.reloadData()
                    }
                }
            case .edit:
                if let index = viewModel.comments.firstIndex(where: { $0.id == change.comment.id }) {
                    viewModel.comments[index].set(comment: change.comment.comment)
                    collectionView.reloadData()
                }
            }
        }
    }
    
    func postDidChangeLike(postId: String, didLike: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.likePostChange(postId: postId, didLike: !didLike)
    }
    
    @objc func postLikeChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostLikeChange {
            guard change.postId == viewModel.post.postId else { return }
            let likes = viewModel.post.likes
            
            viewModel.post.likes = change.didLike ? likes + 1 : likes - 1
            viewModel.post.didLike = change.didLike
            collectionView.reloadData()
        }
    }
    
    func postDidChangeBookmark(postId: String, didBookmark: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.bookmarkPostChange(postId: postId, didBookmark: !didBookmark)
    }
    
    
    @objc func postBookmarkChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostBookmarkChange {
            guard change.postId == viewModel.post.postId else { return }
            viewModel.post.didBookmark = change.didBookmark
            collectionView.reloadData()
        }
    }
    
    @objc func postEditChange(_ notification: NSNotification) {
        if let change = notification.object as? PostEditChange {
            let post = change.post
            guard post.postId == viewModel.post.postId else { return }
            viewModel.post = post
            collectionView.reloadData()
        }
    }
}

extension DetailsPostViewController: PostDetailedChangesDelegate {
    
    func postDidChangeCommentLike(postId: String, path: [String], commentId: String, owner: String, didLike: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.likeCommentPostChange(postId: postId, path: path, commentId: commentId, owner: owner, didLike: !didLike)
    }
    
    @objc func postCommentLikeChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostCommentLikeChange {
            guard change.postId == viewModel.post.postId else { return }
            if let index = viewModel.comments.firstIndex(where: { $0.id == change.commentId }) {
                
                let likes = viewModel.comments[index].likes
                
                viewModel.comments[index].likes = change.didLike ? likes + 1 : likes - 1
                viewModel.comments[index].didLike = change.didLike
                collectionView.reloadData()
            }
        }
    }
}

extension DetailsPostViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            
            if viewModel.user.isCurrentUser {
                viewModel.user = user
                configureNavigationBar()
                collectionView.reloadData()
            }
            
            if let index = viewModel.users.firstIndex(where: { $0.uid! == user.uid! }) {
                viewModel.users[index] = user
                collectionView.reloadData()
            }
        }
    }
}

extension DetailsPostViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        viewModel.networkFailure = false
        viewModel.commentsLoaded = false
        collectionView.reloadData()
        fetchComments()
    }
}


extension DetailsPostViewController: PageUnavailableViewDelegate {
    func didTapPageButton() {
        navigationController?.popViewController(animated: true)
    }
}
