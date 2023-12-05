//
//  DetailsCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/8/22.
//

import UIKit
import Firebase

private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let commentReuseIdentifier = "CommentCellReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let deletedContentCellReuseIdentifier = "DeletedContentCellReuseIdentifier"
private let caseImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let caseTextCellReuseIdentifier = "HomeTextCellReuseIdentifier"
private let deletedCellReuseIdentifier = "DeletedCellReuseIdentifier"

class DetailsCaseViewController: UICollectionViewController, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    var viewModel: DetailsCaseViewModel
    
    private var zoomTransitioning = ZoomTransitioning()

    private var commentMenu = ContextMenu(display: .comment)

    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()

    private var bottomAnchorConstraint: NSLayoutConstraint!

    init(clinicalCase: Case, user: User? = nil) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 600)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.viewModel = DetailsCaseViewModel(clinicalCase: clinicalCase, user: user)
        super.init(collectionViewLayout: layout)
    }
    
    init(caseId: String) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 600)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.viewModel = DetailsCaseViewModel(caseId: caseId)
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let height = commentInputView.frame.height - 1
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
        collectionView.verticalScrollIndicatorInsets.bottom = height
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNotificationObservers()
        configureNavigationBar()
        if let _ = viewModel.caseId {
            fetchCase()
        } else {
            fetchComments()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseVisibleChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseVisibility), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseRevisionChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseRevision), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseSolveChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseSolve), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseCommentLike), object: nil)
    }
    
    private func configureNavigationBar() {

        title = AppStrings.Title.clinicalCase
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.leftChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(SecondaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.register(CommentCaseCell.self, forCellWithReuseIdentifier: commentReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.register(DeletedCommentCell.self, forCellWithReuseIdentifier: deletedContentCellReuseIdentifier)
        collectionView.register(DeletedContentCell.self, forCellWithReuseIdentifier: deletedCellReuseIdentifier)
        collectionView.register(CaseTextExpandedCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(CaseTextImageExpandedCell.self, forCellWithReuseIdentifier: caseImageTextCellReuseIdentifier)
        
        if viewModel.caseId == nil {
            configureCommentInputView()
        }
    }
    
    private func configureCommentInputView() {
        guard !viewModel.previewingController else { return }
      
        guard viewModel.clinicalCase.visible == .regular else { return }
      
        view.addSubviews(commentInputView)

        bottomAnchorConstraint = commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            bottomAnchorConstraint,
            commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        commentInputView.set(placeholder: AppStrings.Content.Comment.voice)
    }
    
    private func fetchCase() {
        viewModel.getCase { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                strongSelf.collectionView.reloadData()
                strongSelf.collectionView.isHidden = false
                strongSelf.configureCommentInputView()
                strongSelf.fetchComments()
            }
        }
    }
    
    private func fetchComments() {
        viewModel.getComments { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    private func getMoreComments() {
        viewModel.getMoreComments { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
    
    private func handleLikeUnlike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didLike = viewModel.clinicalCase.didLike
        caseDidChangeLike(caseId: caseId, didLike: didLike)
        
        cell.viewModel?.clinicalCase.didLike.toggle()
        viewModel.clinicalCase.didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        viewModel.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
    }
    
    func handleBookmarkUnbookmark(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didBookmark = viewModel.clinicalCase.didBookmark
        caseDidChangeBookmark(caseId: caseId, didBookmark: didBookmark)
        
        cell.viewModel?.clinicalCase.didBookmark.toggle()
        viewModel.clinicalCase.didBookmark.toggle()
    }
    
    private func handleLikeUnLike(for cell: CommentCaseCell, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let caseId = viewModel.clinicalCase.caseId
        let commentId = comment.id
        let didLike = comment.didLike
        
        let anonymous = (uid == viewModel.clinicalCase.uid && viewModel.clinicalCase.privacy == .anonymous) ? true : false
        
        caseDidChangeCommentLike(caseId: caseId, path: [], commentId: commentId, owner: comment.uid, didLike: didLike, anonymous: anonymous)

        cell.viewModel?.comment.didLike.toggle()
        viewModel.comments[indexPath.row].didLike.toggle()

        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        viewModel.comments[indexPath.row].likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
    }
    
    private func deleteCase(withId id: String, privacy: CasePrivacy, at indexPath: IndexPath) {

        displayAlert(withTitle: AppStrings.Alerts.Title.deleteCase, withMessage: AppStrings.Alerts.Subtitle.deleteCase, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            
            guard let strongSelf = self else { return }

            strongSelf.viewModel.deleteCase { [weak self] error in
                guard let strongSelf = self else { return }
            
                if let error {
                    switch error {
                    case .notFound:
                        strongSelf.displayAlert(withTitle: AppStrings.Alerts.Subtitle.deleteError)
                    default:
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    }
                } else {
                    strongSelf.caseDidChangeVisible(caseId: id)
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    strongSelf.collectionView.verticalScrollIndicatorInsets.bottom = 0
                    strongSelf.commentInputView.removeFromSuperview()
                }
            }
        }
    }

    @objc func handleKeyboardFrameChange(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval, !viewModel.previewingController else {
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
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreComments()
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.caseLoaded ? 2 : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? viewModel.caseLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55) : viewModel.commentsLoaded ? viewModel.comments.isEmpty ? CGSize.zero : CGSize.zero : CGSize(width: view.frame.width, height: 55)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.caseLoaded ? 1 : 0
        } else {
            return viewModel.commentsLoaded ? viewModel.networkFailure ? 1 : viewModel.comments.isEmpty ? 1 : viewModel.comments.count : 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            switch viewModel.clinicalCase.visible {
            case .regular:
                switch viewModel.clinicalCase.kind {
                    
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextExpandedCell
                    cell.delegate = self
                    cell.viewModel = CaseViewModel(clinicalCase: viewModel.clinicalCase)
                    
                    if let user = viewModel.user {
                        cell.set(user: user)
                    } else {
                        cell.anonymize()
                    }

                    return cell
                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageTextCellReuseIdentifier, for: indexPath) as! CaseTextImageExpandedCell
                    cell.delegate = self
                    cell.viewModel = CaseViewModel(clinicalCase: viewModel.clinicalCase)
                    
                    if let user = viewModel.user {
                        cell.set(user: user)
                    } else {
                        cell.anonymize()
                    }
                    
                    return cell
                }
               
            case .deleted:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedCellReuseIdentifier, for: indexPath) as! DeletedContentCell
                cell.setCase()
                return cell
            }
        } else {
            if viewModel.networkFailure {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! SecondaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if viewModel.comments.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    cell.multiplier = 0.5
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Comment.emptyTitle, description: AppStrings.Content.Comment.emptyCase, content: .comment)
                    cell.delegate = self
                    return cell
                } else {
                    let comment = viewModel.comments[indexPath.row]
                    
                    switch comment.visible {
                        
                    
                    case .regular:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentReuseIdentifier, for: indexPath) as! CommentCaseCell
                        cell.delegate = self
                        cell.viewModel = CommentViewModel(comment: comment)
                        cell.setCompress()
                        
                        if let userIndex = viewModel.users.firstIndex(where: { $0.uid == comment.uid }) {
                            cell.set(user: viewModel.users[userIndex], author: viewModel.user)
                        }
                        
                        return cell
                        
                    case .anonymous:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentReuseIdentifier, for: indexPath) as! CommentCaseCell
                        cell.delegate = self
                        cell.viewModel = CommentViewModel(comment: comment)
                        cell.setCompress()
                        cell.anonymize()
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

extension DetailsCaseViewController: CommentCellDelegate {
    func didTapLikeActionFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let currentCell = cell as! CommentCaseCell
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
    
    func wantsToSeeRepliesFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        
        if viewModel.clinicalCase.privacy == .anonymous && comment.uid == viewModel.clinicalCase.uid {
            let controller = CommentCaseRepliesViewController(path: [comment.id], comment: comment, clinicalCase: viewModel.clinicalCase)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            if let userIndex = viewModel.users.firstIndex(where: { $0.uid == comment.uid }) {
                let controller = CommentCaseRepliesViewController(path: [comment.id], comment: comment, user: viewModel.users[userIndex], clinicalCase: viewModel.clinicalCase)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: CommentMenu) {
        switch action {
        case .report:
            let controller = ReportViewController(source: .comment, contentUid: comment.uid, contentId: comment.id)
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

                            strongSelf.collectionView.reloadItems(at: [indexPath])
                            strongSelf.collectionView.reloadSections(IndexSet(integer: 0))
                            
                            strongSelf.caseDidChangeComment(caseId: strongSelf.viewModel.clinicalCase.caseId, path: [], comment: comment, action: .remove)

                            let popupView = PopUpBanner(title: AppStrings.PopUp.deleteComment, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                            popupView.showTopPopup(inView: strongSelf.view)
                        }
                    }
                }
            }
        case .back:
            navigationController?.popViewController(animated: true)
        }
    }
    
    func didTapProfile(forUser user: User) {
        let controller = UserProfileViewController(user: user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension DetailsCaseViewController: DeletedCommentCellDelegate {
    func didTapReplies(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard comment.numberOfComments > 0 else { return }
        if viewModel.clinicalCase.privacy == .anonymous && comment.uid == viewModel.clinicalCase.uid {
            let controller = CommentCaseRepliesViewController(path: [comment.id], comment: comment, clinicalCase: viewModel.clinicalCase)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            if let userIndex = viewModel.users.firstIndex(where: { $0.uid == comment.uid }) {
                let controller = CommentCaseRepliesViewController(path: [comment.id], comment: comment, user: viewModel.users[userIndex], clinicalCase: viewModel.clinicalCase)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func didTapLearnMore() {
        commentInputView.resignFirstResponder()
        commentMenu.showImageSettings(in: view)
    }
}

extension DetailsCaseViewController: CaseCellDelegate {
    func clinicalCase(didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete:
            deleteCase(withId: clinicalCase.caseId, privacy: clinicalCase.privacy, at: IndexPath(item: 0, section: 0))
        case .revision:
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: viewModel.user)
            navigationController?.pushViewController(controller, animated: true)
        case .solve:
            let controller = CaseDiagnosisViewController(clinicalCase: clinicalCase)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        case .report:
            let controller = ReportViewController(source: .clinicalCase, contentUid: clinicalCase.uid, contentId: clinicalCase.caseId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User?) { return }
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        let controller = LikesViewController(clinicalCase: clinicalCase)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        commentInputView.commentTextView.becomeFirstResponder()
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let currentCell = cell as? CaseCellProtocol else {
            return
        }

        handleLikeUnlike(for: currentCell, at: IndexPath(item: 0, section: 0))
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        guard let currentCell = cell as? CaseCellProtocol else {
            return
        }

        handleBookmarkUnbookmark(for: currentCell, at: IndexPath(item: 0, section: 0))
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: viewModel.user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        self.navigationController?.delegate = zoomTransitioning
        viewModel.selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension DetailsCaseViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return viewModel.selectedImage
    }
}

extension DetailsCaseViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        commentInputView.commentTextView.becomeFirstResponder()
    }
}


extension DetailsCaseViewController: CommentInputAccessoryViewDelegate {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        inputView.commentTextView.resignFirstResponder()
        
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
                        strongSelf.caseDidChangeComment(caseId: strongSelf.viewModel.clinicalCase.caseId, path: [], comment: comment, action: .add)
                        
                        if let cell = strongSelf.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CaseCellProtocol {
                            cell.viewModel?.clinicalCase.numberOfComments += 1
                        }
                    }
                }
            case .failure(let error):
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    func textDidChange(_ inputView: CommentInputAccessoryView) {
        collectionView.contentInset.bottom = inputView.frame.height - 3
        collectionView.verticalScrollIndicatorInsets.bottom = inputView.frame.height
        view.layoutIfNeeded()
    }
    
    func textDidBeginEditing() {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
}



extension DetailsCaseViewController: CaseChangesDelegate {
    func caseDidChangeComment(caseId: String, path: [String], comment: Comment, action: CommentAction) {
        viewModel.currentNotification = true
        ContentManager.shared.commentCaseChange(caseId: caseId, path: path, comment: comment, action: action)
    }

    func caseDidChangeVisible(caseId: String) {
        viewModel.currentNotification = true
        ContentManager.shared.visibleCaseChange(caseId: caseId)
    }
    
    
    @objc func caseVisibleChange(_ notification: NSNotification) {

        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseVisibleChange {
            if viewModel.clinicalCase.caseId == change.caseId {
                viewModel.clinicalCase.visible = .deleted
                collectionView.reloadData()
                collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                collectionView.verticalScrollIndicatorInsets.bottom = 0
                commentInputView.removeFromSuperview()
            }
        }
    }
    
    
    func caseDidChangeLike(caseId: String, didLike: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.likeCaseChange(caseId: caseId, didLike: !didLike)
    }

    @objc func caseLikeChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseLikeChange {
            guard change.caseId == viewModel.clinicalCase.caseId else { return }
            let likes = viewModel.clinicalCase.likes
            
            viewModel.clinicalCase.didLike = change.didLike
            viewModel.clinicalCase.likes = change.didLike ? likes + 1 : likes - 1
            
            collectionView.reloadData()
        }
    }
    
    func caseDidChangeBookmark(caseId: String, didBookmark: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.bookmarkCaseChange(caseId: caseId, didBookmark: !didBookmark)
    }
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseBookmarkChange {
            guard change.caseId == viewModel.clinicalCase.caseId else { return }
            viewModel.clinicalCase.didBookmark = change.didBookmark
            collectionView.reloadData()
        }
    }
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseCommentChange {
            guard change.caseId == viewModel.clinicalCase.caseId else { return }
            
            switch change.action {

            case .add:
                if change.path.isEmpty {
                    guard let tab = tabBarController as? MainTabController, let user = tab.user else { return }
                    viewModel.users.append(user)
                    
                    viewModel.clinicalCase.numberOfComments += 1
                 
                    viewModel.comments.insert(change.comment, at: 0)
                    collectionView.reloadData()
                } else {
                    if let index = viewModel.comments.firstIndex(where: { $0.id == change.path.last }) {
                        viewModel.comments[index].numberOfComments += 11
                        collectionView.reloadData()
                    }
                }
                
            case .remove:
                
                if change.path.isEmpty {
                    if let index = viewModel.comments.firstIndex(where: { $0.id == change.comment.id }) {
                        viewModel.clinicalCase.numberOfComments -= 1
                        
                        viewModel.comments[index].visible = .deleted
                        collectionView.reloadData()
                    }
                } else {
                    if let index = viewModel.comments.firstIndex(where: { $0.id == change.path.last }) {
                        viewModel.comments[index].numberOfComments -= 1
                        collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            guard change.caseId == viewModel.clinicalCase.caseId else { return }
            viewModel.clinicalCase.revision = .update
            collectionView.reloadData()

        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseSolveChange {
            guard change.caseId == viewModel.clinicalCase.caseId else { return }

            viewModel.clinicalCase.phase = .solved
            
            if let diagnosis = change.diagnosis {
                viewModel.clinicalCase.revision = diagnosis
            }
            collectionView.reloadData()
        }
    }
}

extension DetailsCaseViewController: CaseDetailedChangesDelegate {
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
            if let index = viewModel.comments.firstIndex(where: { $0.id == change.commentId }) {
                
                let likes = viewModel.comments[index].likes
                
                viewModel.comments[index].likes = change.didLike ? likes + 1 : likes - 1
                viewModel.comments[index].didLike = change.didLike
                collectionView.reloadData()
            }
        }
    }
}


extension DetailsCaseViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            
            if let currentUser = viewModel.user, currentUser.isCurrentUser {
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

extension DetailsCaseViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        viewModel.networkFailure = false
        viewModel.commentsLoaded = false
        collectionView.reloadData()
        fetchComments()
    }
}

