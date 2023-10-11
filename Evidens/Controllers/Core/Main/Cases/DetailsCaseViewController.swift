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
    
    private var zoomTransitioning = ZoomTransitioning()
    private var selectedImage: UIImageView!
    private let activityIndicator = PrimaryLoadingView(frame: .zero)
    private var commentMenu = ContextMenu(display: .comment)
    
    var previewingController: Bool = false
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    private var commentsLastSnapshot: QueryDocumentSnapshot?
    private var commentsLoaded: Bool = false
   
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    private var clinicalCase: Case
    private var user: User?
    private var caseId: String?

    private var networkFailure: Bool = false
    
    private var currentNotification: Bool = false
    
    private var isFetchingMoreComments: Bool = false

    private var comments = [Comment]()
    private var users = [User]()
    
    init(clinicalCase: Case, user: User? = nil, collectionViewFlowLayout: UICollectionViewFlowLayout) {
        self.clinicalCase = clinicalCase
        self.user = user
        super.init(collectionViewLayout: collectionViewFlowLayout)
    }
    
    init(caseId: String, collectionViewLayout: UICollectionViewFlowLayout) {
        self.clinicalCase = Case(caseId: "", dictionary: [:])
        self.caseId = caseId
        super.init(collectionViewLayout: collectionViewLayout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNotificationObservers()
        configureNavigationBar()
        if let _ = caseId {
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
        collectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseImageTextCellReuseIdentifier)
        
        if caseId == nil {
            configureCommentInputView()
        }
    }
    
    private func configureCommentInputView() {
        guard !previewingController else { return }
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        guard clinicalCase.visible == .regular else { return }
      
        view.addSubviews(commentInputView)
        
        view.addSubview(commentInputView)
        
        bottomAnchorConstraint = commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            bottomAnchorConstraint,
            commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 47, right: 0)
        collectionView.verticalScrollIndicatorInsets.bottom = 47

        commentInputView.set(placeholder: AppStrings.Content.Comment.voice)
        
        
        if clinicalCase.privacy == .anonymous && clinicalCase.uid == uid  {
            commentInputView.profileImageView.image = UIImage(named: AppStrings.Assets.privacyProfile)
        } else {
            guard let imageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, !imageUrl.isEmpty else { return }
            commentInputView.profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        
        commentInputView.set(placeholder: AppStrings.Content.Comment.voice)
    }
    
    private func fetchCase() {
        collectionView.isHidden = true

        view.addSubviews(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
        ])

        guard NetworkMonitor.shared.isConnected else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.network)
            return
        }
        
        guard let caseId = caseId else { return }
        CaseService.fetchCase(withCaseId: caseId) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let clinicalCase):
                strongSelf.clinicalCase = clinicalCase
                let uid = clinicalCase.uid
                
                if clinicalCase.privacy == .anonymous {
                    strongSelf.collectionView.reloadData()
                    strongSelf.activityIndicator.stop()
                    strongSelf.activityIndicator.removeFromSuperview()
                    strongSelf.configureCommentInputView()
                    strongSelf.collectionView.isHidden = false

                    strongSelf.fetchComments()
                } else {
                    UserService.fetchUser(withUid: uid) { [weak self] result in
                        guard let strongSelf = self else { return }
                        switch result {
                            
                        case .success(let user):
                            strongSelf.user = user
                            strongSelf.collectionView.reloadData()
                            strongSelf.activityIndicator.stop()
                            strongSelf.activityIndicator.removeFromSuperview()
                            strongSelf.collectionView.isHidden = false
                            strongSelf.configureCommentInputView()
                            strongSelf.fetchComments()
                        case .failure(_):
                            break
                        }
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    private func fetchComments() {
        CommentService.fetchCaseComments(forCase: clinicalCase, forPath: [], lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
               
                strongSelf.commentsLastSnapshot = snapshot.documents.last
                strongSelf.comments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
                
                CommentService.getCaseCommentValuesFor(forCase: strongSelf.clinicalCase, forPath: [], forComments: strongSelf.comments) { [weak self] fetchedComments in
                    guard let strongSelf = self else { return }
                    strongSelf.comments = fetchedComments

                    strongSelf.comments.enumerated().forEach { [weak self] index, comment in
                        guard let strongSelf = self else { return }
                        strongSelf.comments[index].isAuthor = comment.uid == strongSelf.clinicalCase.uid
                    }
                    
                    strongSelf.comments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    
                    let userUids = strongSelf.comments.filter { $0.visible == .regular }.map { $0.uid }
                    
                    let uniqueUids = Array(Set(userUids))
                    
                    guard !uniqueUids.isEmpty else {
                        strongSelf.commentsLoaded = true
                        strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
                        return
                    }
                    
                    UserService.fetchUsers(withUids: userUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users = users
                        strongSelf.commentsLoaded = true
                        strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
                    }
                }
                
            case .failure(let error):
                if error == .network {
                    strongSelf.networkFailure = true
                }
                
                strongSelf.commentsLoaded = true
                
                strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
            }
        }
    }
    
    private func getMoreComments() {
        
        guard commentsLastSnapshot != nil, !comments.isEmpty, !isFetchingMoreComments, commentsLoaded else { return }

        CommentService.fetchCaseComments(forCase: clinicalCase, forPath: [], lastSnapshot: commentsLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):

                strongSelf.commentsLastSnapshot = snapshot.documents.last
                var newComments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
                
                CommentService.getCaseCommentValuesFor(forCase: strongSelf.clinicalCase, forPath: [], forComments: newComments) { [weak self] fetchedComments in
                    guard let strongSelf = self else { return }
                    
                    newComments = fetchedComments
                    newComments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    strongSelf.comments.append(contentsOf: newComments)
                    let newUserUids = newComments.map { $0.uid }
                    let currentUserUids = strongSelf.users.map { $0.uid }
                    let usersToFetch = newUserUids.filter { !currentUserUids.contains($0) }
                    
                    guard !usersToFetch.isEmpty else {
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.collectionView.reloadData()
                        }
                        
                        return
                    }
                    
                    UserService.fetchUsers(withUids: usersToFetch) { [weak self] users in
                        guard let _ = self else { return }
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.users.append(contentsOf: users)
                            strongSelf.collectionView.reloadData()
                        }
                    }
                }
 
            case .failure(_):
                break
            }
        }
    }
    
    private func handleLikeUnlike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didLike = self.clinicalCase.didLike
        caseDidChangeLike(caseId: caseId, didLike: didLike)
        
        cell.viewModel?.clinicalCase.didLike.toggle()
        self.clinicalCase.didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        self.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
    }
    
    func handleBookmarkUnbookmark(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didBookmark = self.clinicalCase.didBookmark
        caseDidChangeBookmark(caseId: caseId, didBookmark: didBookmark)
        
        cell.viewModel?.clinicalCase.didBookmark.toggle()
        self.clinicalCase.didBookmark.toggle()

    }
    
    private func handleLikeUnLike(for cell: CommentCaseCell, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let caseId = clinicalCase.caseId
        let commentId = comment.id
        let didLike = comment.didLike
        
        let anonymous = (uid == clinicalCase.uid && clinicalCase.privacy == .anonymous) ? true : false
        
        caseDidChangeCommentLike(caseId: caseId, path: [], commentId: commentId, owner: comment.uid, didLike: didLike, anonymous: anonymous)
       
        // Toggle the like state and count
        cell.viewModel?.comment.didLike.toggle()
        self.comments[indexPath.row].didLike.toggle()

        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        self.comments[indexPath.row].likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
    }
    
    private func deleteCase(withId id: String, privacy: CasePrivacy, at indexPath: IndexPath) {
        displayAlert(withTitle: AppStrings.Alerts.Title.deleteCase, withMessage: AppStrings.Alerts.Subtitle.deleteCase, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            
            guard let _ = self else { return }
            
            CaseService.deleteCase(withId: id, privacy: privacy) { [weak self] error in
                guard let strongSelf = self else { return }
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.caseDidChangeVisible(caseId: id)
                    strongSelf.clinicalCase.visible = .deleted
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    strongSelf.collectionView.verticalScrollIndicatorInsets.bottom = 0
                    strongSelf.commentInputView.removeFromSuperview()
                }
            }
        }
    }

    @objc func handleKeyboardFrameChange(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval, !previewingController else {
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
        if section == 0 {
            return 1
        } else {
            return commentsLoaded ? networkFailure ? 1 : comments.isEmpty ? 1 : comments.count : 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            switch clinicalCase.visible {
            case .regular:
                switch clinicalCase.kind {
                    
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                    cell.descriptionTextView.textContainer.maximumNumberOfLines = 0
                    cell.viewModel = CaseViewModel(clinicalCase: clinicalCase)
                    
                    if let user = user {
                        cell.set(user: user)
                    } else {
                        cell.anonymize()
                    }

                    cell.delegate = self
                    cell.titleCaseLabel.numberOfLines = 0

                    return cell
                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageTextCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                    cell.descriptionTextView.textContainer.maximumNumberOfLines = 0
                    cell.viewModel = CaseViewModel(clinicalCase: clinicalCase)
                    
                    if let user = user {
                        cell.set(user: user)
                    } else {
                        cell.anonymize()
                    }
                    
                    cell.titleCaseLabel.numberOfLines = 0
                    cell.delegate = self
                    return cell
                }
               
            case .deleted:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deletedCellReuseIdentifier, for: indexPath) as! DeletedContentCell
                cell.setCase()
                return cell
            }
        } else {
            if networkFailure {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! SecondaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if comments.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    cell.multiplier = 0.5
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Comment.emptyTitle, description: AppStrings.Content.Comment.emptyCase, content: .comment)
                    cell.delegate = self
                    return cell
                } else {
                    let comment = comments[indexPath.row]
                    
                    switch comment.visible {
                        
                    
                    case .regular:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentReuseIdentifier, for: indexPath) as! CommentCaseCell
                        cell.delegate = self
                        cell.viewModel = CommentViewModel(comment: comment)
                        cell.setCompress()
                        
                        if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
                            cell.set(user: users[userIndex], author: user)
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
        
        if clinicalCase.privacy == .anonymous && comment.uid == clinicalCase.uid {
            let controller = CommentCaseRepliesViewController(path: [comment.id], comment: comment, clinicalCase: clinicalCase)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
                let controller = CommentCaseRepliesViewController(path: [comment.id], comment: comment, user: users[userIndex], clinicalCase: clinicalCase)
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
                    CommentService.deleteComment(forCase: strongSelf.clinicalCase, forPath: [], forCommentId: comment.id) { [weak self] error in
                        guard let strongSelf = self else { return }
                        if let error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                            
                            strongSelf.comments[indexPath.item].visible = .deleted
                            strongSelf.collectionView.reloadItems(at: [indexPath])
                            strongSelf.clinicalCase.numberOfComments -= 1
                            strongSelf.collectionView.reloadSections(IndexSet(integer: 0))
                            
                            strongSelf.caseDidChangeComment(caseId: strongSelf.clinicalCase.caseId, path: [], comment: comment, action: .remove)

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
        if clinicalCase.privacy == .anonymous && comment.uid == clinicalCase.uid {
            let controller = CommentCaseRepliesViewController(path: [comment.id], comment: comment, clinicalCase: clinicalCase)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
                let controller = CommentCaseRepliesViewController(path: [comment.id], comment: comment, user: users[userIndex], clinicalCase: clinicalCase)
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
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User?) { return }
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete:
            deleteCase(withId: clinicalCase.caseId, privacy: clinicalCase.privacy, at: IndexPath(item: 0, section: 0))
        case .revision:
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)
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
        let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        self.navigationController?.delegate = zoomTransitioning
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension DetailsCaseViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
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
        
        CommentService.addComment(comment, for: clinicalCase) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                
                strongSelf.clinicalCase.numberOfComments += 1
                
                strongSelf.users.append(currentUser)
                
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
                        strongSelf.caseDidChangeComment(caseId: strongSelf.clinicalCase.caseId, path: [], comment: comment, action: .add)

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
        currentNotification = true
        ContentManager.shared.commentCaseChange(caseId: caseId, path: path, comment: comment, action: action)
    }

    func caseDidChangeVisible(caseId: String) {
        currentNotification = true
        ContentManager.shared.visibleCaseChange(caseId: caseId)
    }
    
    
    @objc func caseVisibleChange(_ notification: NSNotification) {

        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseVisibleChange {
            if clinicalCase.caseId == change.caseId {
                clinicalCase.visible = .deleted
                collectionView.reloadData()
                collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                collectionView.verticalScrollIndicatorInsets.bottom = 0
                commentInputView.removeFromSuperview()
            }
        }
    }
    
    
    func caseDidChangeLike(caseId: String, didLike: Bool) {
        currentNotification = true
        ContentManager.shared.likeCaseChange(caseId: caseId, didLike: !didLike)
    }

    @objc func caseLikeChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseLikeChange {
            guard change.caseId == clinicalCase.caseId else { return }
            if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CaseCellProtocol {
                
                let likes = clinicalCase.likes
                
                clinicalCase.didLike = change.didLike
                clinicalCase.likes = change.didLike ? likes + 1 : likes - 1
                
                cell.viewModel?.clinicalCase.didLike = change.didLike
                cell.viewModel?.clinicalCase.likes = change.didLike ? likes + 1 : likes - 1
            }
        }
    }
    
    func caseDidChangeBookmark(caseId: String, didBookmark: Bool) {
        currentNotification = true
        ContentManager.shared.bookmarkCaseChange(caseId: caseId, didBookmark: !didBookmark)
    }
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseBookmarkChange {
            guard change.caseId == clinicalCase.caseId else { return }
            if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CaseCellProtocol {
                
                cell.viewModel?.clinicalCase.didBookmark = change.didBookmark
                clinicalCase.didBookmark = change.didBookmark
            }
        }
    }
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseCommentChange {
            guard change.caseId == self.clinicalCase.caseId else { return }
            
            switch change.action {

            case .add:
                if change.path.isEmpty {
                    if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CaseCellProtocol {
                        
                        guard let tab = tabBarController as? MainTabController, let user = tab.user else { return }
                        users.append(user)
                        
                        self.clinicalCase.numberOfComments += 1
                        cell.viewModel?.clinicalCase.numberOfComments += 1
                        
                        self.comments.insert(change.comment, at: 0)
                        collectionView.reloadData()
                    }
                } else {
                    if let index = comments.firstIndex(where: { $0.id == change.path.last }) {
                        if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) as? CommentCaseCell {
                            comments[index].numberOfComments += 1
                            cell.viewModel?.comment.numberOfComments += 1
                            collectionView.reloadData()
                        }
                    }
                }
                
            case .remove:
                
                if change.path.isEmpty {
                    if let index = comments.firstIndex(where: { $0.id == change.comment.id }) {
                        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CaseCellProtocol {
                            cell.viewModel?.clinicalCase.numberOfComments -= 1
                            clinicalCase.numberOfComments -= 1
                            
                            comments[index].visible = .deleted
                            collectionView.reloadData()
                        }
                    }
                } else {
                    if let index = comments.firstIndex(where: { $0.id == change.path.last }) {
                        if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) as? CommentCaseCell {
                            comments[index].numberOfComments -= 1
                            cell.viewModel?.comment.numberOfComments -= 1
                            collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            guard change.caseId == clinicalCase.caseId else { return }
            if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CaseCellProtocol {
                self.clinicalCase.revision = .update
                cell.viewModel?.clinicalCase.revision = .update
                collectionView.reloadData()
            }

        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseSolveChange {
            guard change.caseId == clinicalCase.caseId else { return }
            if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CaseCellProtocol {
                cell.viewModel?.clinicalCase.phase = .solved
                self.clinicalCase.phase = .solved
                
                if let diagnosis = change.diagnosis {
                    self.clinicalCase.revision = diagnosis
                    cell.viewModel?.clinicalCase.revision = diagnosis
                }
                collectionView.reloadData()
            }
        }
    }
}

extension DetailsCaseViewController: CaseDetailedChangesDelegate {
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
            guard change.caseId == self.clinicalCase.caseId else { return }
            if let index = comments.firstIndex(where: { $0.id == change.commentId }), let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) as? CommentCaseCell {
                
                let likes = self.comments[index].likes
                
                self.comments[index].likes = change.didLike ? likes + 1 : likes - 1
                self.comments[index].didLike = change.didLike
                
                cell.viewModel?.comment.didLike = change.didLike
                cell.viewModel?.comment.likes = change.didLike ? likes + 1 : likes - 1
            }
        }
    }
}


extension DetailsCaseViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            
            if let currentUser = self.user, currentUser.isCurrentUser {
                self.user = user
                configureNavigationBar()
                collectionView.reloadData()
            }
            
            if let index = users.firstIndex(where: { $0.uid! == user.uid! }) {
                users[index] = user
                collectionView.reloadData()
            }
        }
    }
}

extension DetailsCaseViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        networkFailure = false
        commentsLoaded = false
        collectionView.reloadData()
        fetchComments()
    }
}

