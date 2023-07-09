//
//  DetailsCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/8/22.
//

import UIKit
import JGProgressHUD
import Firebase

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let commentReuseIdentifier = "CommentCellReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let deletedContentCellReuseIdentifier = "DeletedContentCellReuseIdentifier"

private let caseImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let caseTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"

protocol DetailsCaseViewControllerDelegate: AnyObject {
    func didTapLikeAction(forCase clinicalCase: Case)
    func didTapBookmarkAction(forCase clinicalCase: Case)
    func didComment(forCase clinicalCase: Case)
    func didAddRevision(forCase clinicalCase: Case)
    func didSolveCase(forCase clinicalCase: Case, with diagnosis: CaseRevisionKind?)
    func didDeleteComment(forCase clinicalCase: Case)
}

class DetailsCaseViewController: UICollectionViewController, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    private var clinicalCase: Case
    private var user: User
    private var type: Comment.CommentType

    private var commentsLastSnapshot: QueryDocumentSnapshot?
    private var commentsLoaded: Bool = false
    private var commentMenuLauncher = MEContextMenuLauncher(menuLauncherData: Display(content: .comment))
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    private var users: [User] = []
    
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
    
    var isReviewingCase: Bool = false
    var groupId: String?
    
    weak var reviewDelegate: DetailsContentReviewDelegate?
    weak var delegate: DetailsCaseViewControllerDelegate?
    
    private let progressIndicator = JGProgressHUD()
    
    private var comments = [Comment]()
    
    init(clinicalCase: Case, user: User, type: Comment.CommentType, collectionViewFlowLayout: UICollectionViewFlowLayout) {
        self.clinicalCase = clinicalCase
        self.user = user
        self.type = type
        super.init(collectionViewLayout: collectionViewFlowLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
        let fullName = clinicalCase.privacyOptions == .nonVisible ? "Shared anonymously" : user.firstName! + " " + user.lastName!
        
        let view = MENavigationBarTitleView(fullName: fullName, category: "Case")
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        fetchComments()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
    
    private func configureNavigationBar() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let fullName = clinicalCase.privacyOptions == .nonVisible ? "Shared Anonymously" : user.firstName! + " " + user.lastName!
        let view = MENavigationBarTitleView(fullName: fullName, category: "Case")
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        if clinicalCase.privacyOptions == .nonVisible && clinicalCase.ownerUid == uid  {
            commentInputView.profileImageView.image = UIImage(named: "user.profile.privacy")
        } else {
            guard let imageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String, !imageUrl.isEmpty else { return }
            commentInputView.profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        
        commentInputView.set(placeholder: "Voice your thoughts here...")
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: commentReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.register(DeletedContentCell.self, forCellWithReuseIdentifier: deletedContentCellReuseIdentifier)
        
        switch clinicalCase.type {
        case .text:
            collectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        case .image:
            collectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseImageTextCellReuseIdentifier)
        }
        
        view.addSubview(commentInputView)
        bottomAnchorConstraint = commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            bottomAnchorConstraint,
            commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 47, right: 0)
        collectionView.verticalScrollIndicatorInsets.bottom = 47
    }
    
    private func fetchComments() {
        CommentService.fetchCaseComments(forCase: clinicalCase, forType: type, lastSnapshot: nil) { snapshot in
            guard !snapshot.isEmpty else {
                self.commentsLoaded = true
                self.collectionView.reloadSections(IndexSet(integer: 1))
                return
            }
            
            self.commentsLastSnapshot = snapshot.documents.last
            self.comments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
            
            CommentService.getCaseCommentValuesFor(forCase: self.clinicalCase, forComments: self.comments, forType: self.type) { fetchedComments in
                self.comments = fetchedComments
                
                self.comments.enumerated().forEach { index, comment in
                    self.comments[index].isAuthor = comment.uid == self.clinicalCase.ownerUid
                }
                
                self.comments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                let userUids = self.comments.map { $0.uid }
                UserService.fetchUsers(withUids: userUids) { users in
                    self.users = users
                    self.commentsLoaded = true
                    self.collectionView.reloadSections(IndexSet(integer: 1))
                }
            }
        }
    }
    
    private func getMoreComments() {
        guard commentsLastSnapshot != nil else { return }
        CommentService.fetchCaseComments(forCase: clinicalCase, forType: type, lastSnapshot: commentsLastSnapshot) { snapshot in
            guard !snapshot.isEmpty else {
                return
            }
            
            self.commentsLastSnapshot = snapshot.documents.last
            var newComments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
            CommentService.getCaseCommentValuesFor(forCase: self.clinicalCase, forComments: newComments, forType: self.type) { fetchedComments in
                newComments = fetchedComments
                newComments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                self.comments.append(contentsOf: newComments)
                let newUserUids = newComments.map { $0.uid }
                let currentUserUids = self.users.map { $0.uid }
                let usersToFetch = newUserUids.filter { !currentUserUids.contains($0) }
                
                guard !usersToFetch.isEmpty else {
                    self.collectionView.reloadData()
                    return
                }
                
                UserService.fetchUsers(withUids: usersToFetch) { users in
                    self.users.append(contentsOf: users)
                    self.collectionView.reloadData()
                }
            }
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
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? CGSize.zero : commentsLoaded ? comments.isEmpty ? CGSize.zero : CGSize.zero : CGSize(width: view.frame.width, height: 55)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : commentsLoaded ? comments.isEmpty ? 1 : comments.count : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if clinicalCase.type == .text {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                cell.viewModel = CaseViewModel(clinicalCase: clinicalCase)
                cell.set(user: user)
                cell.delegate = self
                cell.titleCaseLabel.numberOfLines = 0
                cell.descriptionCaseLabel.numberOfLines = 0
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageTextCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                cell.viewModel = CaseViewModel(clinicalCase: clinicalCase)
                cell.set(user: user)
                cell.titleCaseLabel.numberOfLines = 0
                cell.descriptionCaseLabel.numberOfLines = 0
                cell.delegate = self
                return cell
            }
        } else {
            if comments.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.multiplier = 0.5
                cell.configure(image: UIImage(named: "content.empty"), title: "Be the first to comment", description: "This case has no comments, but it won't be that way for long. Take the lead in commenting.", buttonText: .comment)
                cell.delegate = self
                return cell
            } else {
                let comment = comments[indexPath.row]
                
                switch comment.visible {
                    
                case .regular, .anonymous:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentReuseIdentifier, for: indexPath) as! CommentCell
                    cell.commentTextView.isSelectable = false
                    cell.delegate = self
                    cell.viewModel = CommentViewModel(comment: comment)
                    
                    cell.authorButton.isHidden = true
                    if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
                        cell.set(user: users[userIndex])
                    }
                    
                    if comments[indexPath.row].hasCommentFromAuthor {
                        if comments[indexPath.row].visible == .anonymous {
                            cell.ownerPostImageView.image = UIImage(named: "user.profile.privacy")
                        } else {
                            if let image = user.profileImageUrl, !image.isEmpty {
                                cell.ownerPostImageView.sd_setImage(with: URL(string: user.profileImageUrl! ))
                            }
                        }
                        
                    } else {
                        cell.commentActionButtons.ownerPostImageView.image = nil
                    }
                    
                    return cell
                    
                case .deleted:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedContentCellReuseIdentifier, for: indexPath) as! DeletedContentCell
                    cell.delegate = self
                    cell.viewModel = CommentViewModel(comment: comment)
                    return cell
                }
            }
        }
    }
}

extension DetailsCaseViewController: CommentCellDelegate {
    func didTapLikeActionFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        let currentCell = cell as! CommentCell
        currentCell.viewModel?.comment.didLike.toggle()
        
        if comment.didLike {
            CommentService.unlikeCaseComment(forCase: clinicalCase, forType: type, forCommentUid: comment.id) { _ in
                currentCell.viewModel?.comment.likes = comment.likes - 1
                self.comments[indexPath.row].didLike = false
                self.comments[indexPath.row].likes -= 1
            }
        } else {
            
            CommentService.likeCaseComment(forCase: clinicalCase, forType: type, forCommentUid: comment.id) { _ in
                currentCell.viewModel?.comment.likes = comment.likes + 1
                self.comments[indexPath.row].didLike = true
                self.comments[indexPath.row].likes += 1
            }
        }
    }
    
    func wantsToSeeRepliesFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
            let controller = CommentCaseRepliesViewController(comment: comment, user: users[userIndex], clinicalCase: clinicalCase, type: type, currentUser: user)
            controller.delegate = self
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: Comment.CommentOptions) {
        switch action {
        case .report:
            let controller = ReportViewController(source: .comment, contentOwnerUid: comment.uid, contentId: comment.id)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        case .delete:
            if let indexPath = self.collectionView.indexPath(for: cell) {
                self.deleteCommentAlert {
                    CommentService.deleteCaseComment(forCase: self.clinicalCase, forCommentUid: comment.id) { error in
                        if let error {
                            print(error.localizedDescription)
                        } else {
                            DatabaseManager.shared.deleteRecentComment(forCommentId: comment.id)
                            self.comments[indexPath.item].visible = .deleted
                            self.collectionView.reloadItems(at: [indexPath])
                            self.clinicalCase.numberOfComments -= 1
                            self.collectionView.reloadSections(IndexSet(integer: 0))
                            self.delegate?.didDeleteComment(forCase: self.clinicalCase)
                            
                            let popupView = METopPopupView(title: "Comment deleted", image: "checkmark.circle.fill", popUpType: .regular)
                            popupView.showTopPopup(inView: self.view)
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

extension DetailsCaseViewController: DeletedContentCellDelegate {
    func didTapReplies(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        guard comment.numberOfComments > 0 else { return }
        if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
            let controller = CommentCaseRepliesViewController(comment: comment, user: users[userIndex], clinicalCase: clinicalCase, type: type, currentUser: user)
            controller.delegate = self
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapLearnMore() {
        commentInputView.resignFirstResponder()
        commentMenuLauncher.showImageSettings(in: view)
    }
}

extension DetailsCaseViewController: CaseCellDelegate {
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: Case.CaseMenuOptions) {
        switch option {
        case .delete:
            #warning("Implement Case Deletion")
        case .update:
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)
            controller.delegate = self
            controller.groupId = groupId
            navigationController?.pushViewController(controller, animated: true)
        case .solved:
            let controller = CaseDiagnosisViewController(clinicalCase: clinicalCase)
            controller.stageIsUpdating = true
            controller.delegate = self
            controller.caseId = clinicalCase.caseId
            controller.groupId = groupId
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        case .report:
            let controller = ReportViewController(source: .clinicalCase, contentOwnerUid: user.uid!, contentId: clinicalCase.caseId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        }
    }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        let controller = PostLikesViewController(contentType: clinicalCase)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        commentInputView.commentTextView.becomeFirstResponder()
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is CaseTextCell:
            let currentCell = cell as! CaseTextCell
            currentCell.viewModel?.clinicalCase.didLike.toggle()
            if clinicalCase.didLike {
                switch type {
                case .regular:
                    CaseService.unlikeCase(clinicalCase: clinicalCase) { _ in
                        currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                        self.delegate?.didTapLikeAction(forCase: clinicalCase)
                    }
                case .group:
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                    self.delegate?.didTapLikeAction(forCase: clinicalCase)
                }
            } else {
                switch type {
                case .regular:
                    CaseService.likeCase(clinicalCase: clinicalCase) { _ in
                        currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                        self.delegate?.didTapLikeAction(forCase: clinicalCase)
                    }
                case .group:
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    self.delegate?.didTapLikeAction(forCase: clinicalCase)
                }
            }
            
        case is CaseTextImageCell:
            let currentCell = cell as! CaseTextImageCell
            currentCell.viewModel?.clinicalCase.didLike.toggle()
            if clinicalCase.didLike {
                switch type {
                case .regular:
                    CaseService.unlikeCase(clinicalCase: clinicalCase) { _ in
                        currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                        self.delegate?.didTapLikeAction(forCase: clinicalCase)
                    }
                case .group:
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                    self.delegate?.didTapLikeAction(forCase: clinicalCase)
                }
            } else {
                //Like post here
                switch type {
                case .regular:
                    CaseService.likeCase(clinicalCase: clinicalCase) { _ in
                        currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                        self.delegate?.didTapLikeAction(forCase: clinicalCase)
                    }
                case .group:
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    self.delegate?.didTapLikeAction(forCase: clinicalCase)
                }
            }
        default:
            print("Cell not registered")
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is CaseTextCell:
            let currentCell = cell as! CaseTextCell
            currentCell.viewModel?.clinicalCase.didBookmark.toggle()
            if clinicalCase.didBookmark {
                switch type {
                case .regular:
                    CaseService.unbookmarkCase(clinicalCase: clinicalCase) { _ in
                        currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks - 1
                        self.delegate?.didTapBookmarkAction(forCase: clinicalCase)
                    }
                case .group:
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks - 1
                    self.delegate?.didTapBookmarkAction(forCase: clinicalCase)
                }
                
            } else {
                switch type {
                case .regular:
                    CaseService.bookmarkCase(clinicalCase: clinicalCase) { _ in
                        currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                        self.delegate?.didTapBookmarkAction(forCase: clinicalCase)
                    }
                    
                case .group:
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    self.delegate?.didTapBookmarkAction(forCase: clinicalCase)
                }
            }
            
        case is CaseTextImageCell:
            let currentCell = cell as! CaseTextImageCell
            currentCell.viewModel?.clinicalCase.didBookmark.toggle()
            if clinicalCase.didBookmark {
                switch type {
                case .regular:
                    CaseService.unbookmarkCase(clinicalCase: clinicalCase) { _ in
                        currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks - 1
                        self.delegate?.didTapBookmarkAction(forCase: clinicalCase)
                    }
                case .group:
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks - 1
                    self.delegate?.didTapBookmarkAction(forCase: clinicalCase)
                }
                
            } else {
                switch type {
                case .regular:
                    CaseService.bookmarkCase(clinicalCase: clinicalCase) { _ in
                        currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                        self.delegate?.didTapBookmarkAction(forCase: clinicalCase)
                    }
                    
                case .group:
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    self.delegate?.didTapBookmarkAction(forCase: clinicalCase)
                }
            }
        default:
            print("Cell not registered")
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didPressThreeDotsFor clinicalCase: Case) { return }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        self.navigationController?.delegate = zoomTransitioning
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User) { return }
}

extension DetailsCaseViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension DetailsCaseViewController: CaseUpdatesViewControllerDelegate {
    func didAddRevision(to clinicalCase: Case, _ revision: CaseRevision) {
        self.clinicalCase.revision = revision.kind
        collectionView.reloadSections(IndexSet(integer: 0))
        delegate?.didAddRevision(forCase: self.clinicalCase)
    }
}

extension DetailsCaseViewController: CaseDiagnosisViewControllerDelegate {
    func handleSolveCase(diagnosis: CaseRevision?, clinicalCase: Case?) {
        self.clinicalCase.stage = .resolved
        if let diagnosis {
            self.clinicalCase.revision = diagnosis.kind
            delegate?.didSolveCase(forCase: self.clinicalCase, with: .diagnosis)
        } else {
            delegate?.didSolveCase(forCase: self.clinicalCase, with: nil)
        }
        
        collectionView.reloadSections(IndexSet(integer: 0))
    }
}

extension DetailsCaseViewController: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton(option: EmptyCellButtonOptions) {
        commentInputView.commentTextView.becomeFirstResponder()
    }
}

extension DetailsCaseViewController: CommentCaseRepliesViewControllerDelegate {
    func didDeleteComment(comment: Comment) {
        if let commentIndex = comments.firstIndex(where: { $0.id == comment.id }) {
            self.comments[commentIndex].visible = .deleted
            self.clinicalCase.numberOfComments -= 1
            self.collectionView.reloadItems(at: [IndexPath(item: commentIndex, section: 1)])
            self.collectionView.reloadSections(IndexSet(integer: 0))
            self.delegate?.didDeleteComment(forCase: self.clinicalCase)
        }
    }
    
    func didDeleteReply(withRefComment refComment: Comment, comment: Comment) {
        if let commentIndex = comments.firstIndex(where: { $0.id == refComment.id }) {
            comments[commentIndex].numberOfComments -= 1
            collectionView.reloadItems(at: [IndexPath(item: commentIndex, section: 1)])
        }
    }
    
    func didLikeComment(comment: Comment) {
        if let commentIndex = comments.firstIndex(where: { $0.id == comment.id }) {
            comments[commentIndex].didLike = comment.didLike
            comments[commentIndex].likes = comment.likes
            collectionView.reloadItems(at: [IndexPath(item: commentIndex, section: 1)])
        }
    }
    
    func didAddReplyToComment(comment: Comment) {
        if let commentIndex = comments.firstIndex(where: { $0.id == comment.id }) {
            self.comments[commentIndex].numberOfComments += 1
            
            let hasCommentFromAuthor = self.comments[commentIndex].hasCommentFromAuthor
            
            if !hasCommentFromAuthor {
                self.comments[commentIndex].hasCommentFromAuthor = comment.uid == self.comments[commentIndex].uid
            }
            
            collectionView.reloadItems(at: [IndexPath(item: commentIndex, section: 1)])
        }
    }
}

extension DetailsCaseViewController: CommentInputAccessoryViewDelegate {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        inputView.commentTextView.resignFirstResponder()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        
        CommentService.addComment(comment, for: clinicalCase, from: currentUser, kind: type) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                
                strongSelf.clinicalCase.numberOfComments += 1
                
                strongSelf.users.append(User(dictionary: [
                    "uid": currentUser.uid as Any,
                    "firstName": currentUser.firstName as Any,
                    "lastName": currentUser.lastName as Any,
                    "profileImageUrl": currentUser.profileImageUrl as Any,
                    "profession": currentUser.profession as Any,
                    "category": currentUser.category.rawValue as Any,
                    "speciality": currentUser.speciality as Any]))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    strongSelf.collectionView.performBatchUpdates {
                        strongSelf.comments.insert(comment, at: 0)
                        strongSelf.collectionView.insertItems(at: [IndexPath(item: 0, section: 1)])
                    } completion: { _ in
                        strongSelf.delegate?.didComment(forCase: strongSelf.clinicalCase)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
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
