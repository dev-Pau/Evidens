//
//  DetailsCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/8/22.
//

import UIKit
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
    private var user: User?
    private var caseId: String?

    private var commentsLastSnapshot: QueryDocumentSnapshot?
    private var commentsLoaded: Bool = false
    private let activityIndicator = PrimaryLoadingView(frame: .zero)
    private var commentMenu = ContextMenu(display: .comment)
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    private var users = [User]()
    
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!

    weak var delegate: DetailsCaseViewControllerDelegate?
    
    private var comments = [Comment]()
    
    private var likeDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var likeCaseValues: [IndexPath: Bool] = [:]
    private var likeCaseCount: [IndexPath: Int] = [:]
    
    private var bookmarkDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var bookmarkCaseValues: [IndexPath: Bool] = [:]
    
    private var likeCommentDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var likeCommentValues: [IndexPath: Bool] = [:]
    private var likeCommentCount: [IndexPath: Int] = [:]
    
    
    init(clinicalCase: Case, user: User? = nil, collectionViewFlowLayout: UICollectionViewFlowLayout) {
        self.clinicalCase = clinicalCase
        self.user = user
        super.init(collectionViewLayout: collectionViewFlowLayout)
    }
    
    init(caseId: String, collectionViewLayout: UICollectionViewFlowLayout) {
        self.clinicalCase = Case(caseId: "", dictionary: [:])
        self.user = User(dictionary: [:])
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
        if let _ = caseId {
            fetchCase()
        } else {
            configureNavigationBar()
            fetchComments()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureNavigationBar() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        var fullName = ""
        switch clinicalCase.privacy {
            
        case .regular:
            guard let user = user else { return }
            fullName = user.name()
        case .anonymous:
            fullName = AppStrings.Content.Case.Privacy.anonymousTitle
        }

        let view = CompoundNavigationBar(fullName: fullName, category: AppStrings.Title.clinicalCase)
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.leftChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        if clinicalCase.privacy == .anonymous && clinicalCase.uid == uid  {
            commentInputView.profileImageView.image = UIImage(named: AppStrings.Assets.privacyProfile)
        } else {
            guard let imageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, !imageUrl.isEmpty else { return }
            commentInputView.profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        
        commentInputView.set(placeholder: AppStrings.Content.Comment.voice)
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: commentReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.register(DeletedContentCell.self, forCellWithReuseIdentifier: deletedContentCellReuseIdentifier)
        
        switch clinicalCase.kind {
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
    
    private func fetchCase() {
        collectionView.isHidden = true
        commentInputView.isHidden = true
        view.addSubviews(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
        ])
        

        guard let caseId = caseId else { return }
        CaseService.fetchCase(withCaseId: caseId) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let clinicalCase):
                strongSelf.clinicalCase = clinicalCase
                let uid = clinicalCase.uid
                
                UserService.fetchUser(withUid: uid) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                        
                    case .success(let user):
                        strongSelf.user = user
                        strongSelf.configureNavigationBar()
                        strongSelf.collectionView.reloadData()
                        strongSelf.activityIndicator.stop()
                        strongSelf.activityIndicator.removeFromSuperview()
                        strongSelf.collectionView.isHidden = false
                        strongSelf.fetchComments()
                    case .failure(_):
                        break
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    private func fetchComments() {
        CommentService.fetchCaseComments(forCase: clinicalCase, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    strongSelf.commentsLoaded = true
                    strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
                    return
                }
                
                strongSelf.commentsLastSnapshot = snapshot.documents.last
                strongSelf.comments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
                
                CommentService.getCaseCommentValuesFor(forCase: strongSelf.clinicalCase, forComments: strongSelf.comments) { [weak self] fetchedComments in
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
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    private func getMoreComments() {
        guard commentsLastSnapshot != nil else { return }
        CommentService.fetchCaseComments(forCase: clinicalCase, lastSnapshot: commentsLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    return
                }
                
                strongSelf.commentsLastSnapshot = snapshot.documents.last
                var newComments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
                
                CommentService.getCaseCommentValuesFor(forCase: strongSelf.clinicalCase, forComments: newComments) { [weak self] fetchedComments in
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
 
            case .failure(let error):
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    private func handleLikeUnlike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        cell.viewModel?.clinicalCase.didLike.toggle()
        self.clinicalCase.didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        self.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        
        delegate?.didTapLikeAction(forCase: self.clinicalCase)
        
        // Cancel the previous debounce timer for this post, if any
        if let debounceTimer = likeDebounceTimers[indexPath] {
            debounceTimer.cancel()
        }
        
        // Store the initial like state and count
        if likeCaseValues[indexPath] == nil {
            likeCaseValues[indexPath] = clinicalCase.didLike
            likeCaseCount[indexPath] = clinicalCase.likes
        }
        
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            
            guard let likeValue = strongSelf.likeCaseValues[indexPath], let countValue = strongSelf.likeCaseCount[indexPath] else {
                return
            }

            // Prevent any database action if the value remains unchanged
            if cell.viewModel?.clinicalCase.didLike == likeValue {
                strongSelf.likeCaseValues[indexPath] = nil
                strongSelf.likeCaseCount[indexPath] = nil
                return
            }
            
            if clinicalCase.didLike {
                CaseService.unlikeCase(clinicalCase: clinicalCase) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        cell.viewModel?.clinicalCase.didLike = likeValue
                        strongSelf.clinicalCase.didLike = likeValue
                        
                        cell.viewModel?.clinicalCase.likes = countValue
                        strongSelf.clinicalCase.likes = countValue
                        
                        strongSelf.delegate?.didTapLikeAction(forCase: clinicalCase)
                    }
                    
                    strongSelf.likeCaseValues[indexPath] = nil
                    strongSelf.likeCaseCount[indexPath] = nil
                }
            } else {
                CaseService.likeCase(clinicalCase: clinicalCase) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let _ = error {
                        cell.viewModel?.clinicalCase.didLike = likeValue
                        strongSelf.clinicalCase.didLike = likeValue
                        
                        cell.viewModel?.clinicalCase.likes = countValue
                        strongSelf.clinicalCase.likes = countValue
                        
                        strongSelf.delegate?.didTapLikeAction(forCase: clinicalCase)
                    }
                    
                    strongSelf.likeCaseValues[indexPath] = nil
                    strongSelf.likeCaseCount[indexPath] = nil
                }
            }
            
            // Clean up the debounce timer
            strongSelf.likeDebounceTimers[indexPath] = nil
        }
        
        // Save the debounce timer
        likeDebounceTimers[indexPath] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
    
    func handleBookmarkUnbookmark(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        cell.viewModel?.clinicalCase.didBookmark.toggle()
        self.clinicalCase.didBookmark.toggle()
        self.delegate?.didTapBookmarkAction(forCase: self.clinicalCase)
        // Cancel the previous debounce timer for this post, if any
        if let debounceTimer = bookmarkDebounceTimers[indexPath] {
            debounceTimer.cancel()
        }
        
        if bookmarkCaseValues[indexPath] == nil {
            bookmarkCaseValues[indexPath] = clinicalCase.didBookmark
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let bookmarkValue = strongSelf.bookmarkCaseValues[indexPath] else {
                return
            }

            // Prevent any database action if the value remains unchanged
            if cell.viewModel?.clinicalCase.didBookmark == bookmarkValue {
                strongSelf.bookmarkCaseValues[indexPath] = nil
                return
            }

            if clinicalCase.didBookmark {
                CaseService.unbookmarkCase(clinicalCase: clinicalCase) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        cell.viewModel?.clinicalCase.didBookmark = bookmarkValue
                        strongSelf.clinicalCase.didBookmark = bookmarkValue
                    }
                    
                    strongSelf.bookmarkCaseValues[indexPath] = nil
                }
            } else {
                CaseService.bookmarkCase(clinicalCase: clinicalCase) { [weak self] error in
                    guard let strongSelf = self else { return }

                    if let _ = error {
                        cell.viewModel?.clinicalCase.didBookmark = bookmarkValue
                        strongSelf.clinicalCase.didBookmark = bookmarkValue
    
                    }
                    
                    strongSelf.bookmarkCaseValues[indexPath] = nil
                }
            }
            // Clean up the debounce timer
            strongSelf.bookmarkDebounceTimers[indexPath] = nil
        }
        
        // Save the debounce timer
        bookmarkDebounceTimers[indexPath] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
    
    private func handleLikeUnLike(for cell: CommentCell, at indexPath: IndexPath) {
        guard let comment = cell.viewModel?.comment else { return }
        
        // Toggle the like state and count
        cell.viewModel?.comment.didLike.toggle()
        self.comments[indexPath.row].didLike.toggle()

        cell.viewModel?.comment.likes = comment.didLike ? comment.likes - 1 : comment.likes + 1
        self.comments[indexPath.row].likes = comment.didLike ? comment.likes - 1 : comment.likes + 1

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
                        strongSelf.comments[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.comment.likes = countValue
                        strongSelf.comments[indexPath.row].likes = countValue
                    }
                    
                    strongSelf.likeCommentValues[indexPath] = nil
                    strongSelf.likeCommentCount[indexPath] = nil
                }
            } else {
                CommentService.likeComment(forCase: strongSelf.clinicalCase, forCommentId: comment.id) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let _ = error {
                        cell.viewModel?.comment.didLike = likeValue
                        strongSelf.comments[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.comment.likes = countValue
                        strongSelf.comments[indexPath.row].likes = countValue
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
            if clinicalCase.kind == .text {
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
            } else {
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
                    
                case .regular, .anonymous:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentReuseIdentifier, for: indexPath) as! CommentCell
                    cell.commentTextView.isSelectable = false
                    cell.delegate = self
                    cell.viewModel = CommentViewModel(comment: comment)
                    
                    //cell.authorButton.isHidden = true
                    if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
                        cell.set(user: users[userIndex])
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
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
    
    func wantsToSeeRepliesFor(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }

        if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
            let controller = CommentCaseRepliesViewController(comment: comment, user: users[userIndex], clinicalCase: clinicalCase, currentUser: user)
            controller.delegate = self
            
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = CommentCaseRepliesViewController(comment: comment, clinicalCase: clinicalCase, currentUser: user)
            controller.delegate = self
            
            navigationController?.pushViewController(controller, animated: true)
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

                displayAlert(withTitle: AppStrings.Alerts.Title.deleteConversation, withMessage: AppStrings.Alerts.Subtitle.deleteConversation, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                    
                    guard let strongSelf = self else { return }
                    CommentService.deleteComment(forCase: strongSelf.clinicalCase, forCommentId: comment.id) { [weak self] error in
                        guard let strongSelf = self else { return }
                        if let error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                            
                            if comment.visible != .anonymous {
                                DatabaseManager.shared.deleteRecentComment(forCommentId: comment.id)
                            }
                           
                            strongSelf.comments[indexPath.item].visible = .deleted
                            strongSelf.collectionView.reloadItems(at: [indexPath])
                            strongSelf.clinicalCase.numberOfComments -= 1
                            strongSelf.collectionView.reloadSections(IndexSet(integer: 0))
                            strongSelf.delegate?.didDeleteComment(forCase: strongSelf.clinicalCase)
                            
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

extension DetailsCaseViewController: DeletedContentCellDelegate {
    func didTapReplies(_ cell: UICollectionViewCell, forComment comment: Comment) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        guard comment.numberOfComments > 0 else { return }
        if let userIndex = users.firstIndex(where: { $0.uid == comment.uid }) {
            let controller = CommentCaseRepliesViewController(comment: comment, user: users[userIndex], clinicalCase: clinicalCase, currentUser: user)
            controller.delegate = self
            
            navigationController?.pushViewController(controller, animated: true)
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
        controller.caseDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete:
            #warning("Implement Case Deletion")
        case .revision:
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        case .solve:
            let controller = CaseDiagnosisViewController(clinicalCase: clinicalCase)
            controller.delegate = self
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
        
        HapticsManager.shared.vibrate(for: .success)
        handleLikeUnlike(for: currentCell, at: IndexPath(item: 0, section: 0))
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        guard let currentCell = cell as? CaseCellProtocol else {
            return
        }
        
        HapticsManager.shared.vibrate(for: .success)
        handleBookmarkUnbookmark(for: currentCell, at: IndexPath(item: 0, section: 0))
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
        self.clinicalCase.phase = .solved
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
    func didTapContent(_ content: EmptyContent) {
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
        
        CommentService.addComment(comment, for: clinicalCase, from: currentUser) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                
                strongSelf.clinicalCase.numberOfComments += 1
                
                strongSelf.users.append(User(dictionary: [
                    "uid": currentUser.uid as Any,
                    "firstName": currentUser.firstName as Any,
                    "lastName": currentUser.lastName as Any,
                    "imageUrl": currentUser.profileUrl as Any,
                    "discipline": currentUser.discipline as Any,
                    "kind": currentUser.kind.rawValue as Any,
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

extension DetailsCaseViewController: DetailsCaseViewControllerDelegate {
    
    func didTapLikeAction(forCase clinicalCase: Case) {
        if clinicalCase.caseId == self.clinicalCase.caseId {
            guard let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)), let currentCell = cell as? CaseCellProtocol else { return }
            HapticsManager.shared.vibrate(for: .success)
            handleLikeUnlike(for: currentCell, at: IndexPath(item: 0, section: 0))
        }
    }
    
    func didTapBookmarkAction(forCase clinicalCase: Case) {
        if clinicalCase.caseId == self.clinicalCase.caseId {
            guard let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)), let currentCell = cell as? CaseCellProtocol else { return }
            HapticsManager.shared.vibrate(for: .success)
            handleBookmarkUnbookmark(for: currentCell, at: IndexPath(item: 0, section: 0))
        }
    }
    
    func didComment(forCase clinicalCase: Case) {
        if clinicalCase.caseId == self.clinicalCase.caseId {
            fetchComments()
        }
        
        delegate?.didComment(forCase: clinicalCase)
    }
    
    func didAddRevision(forCase clinicalCase: Case) {
        self.clinicalCase.revision = .update
        collectionView.reloadSections(IndexSet(integer: 0))
        delegate?.didAddRevision(forCase: self.clinicalCase)
    }
    
    func didSolveCase(forCase clinicalCase: Case, with diagnosis: CaseRevisionKind?) {
        self.clinicalCase.phase = .solved
        if let diagnosis {
            self.clinicalCase.revision = diagnosis
            delegate?.didSolveCase(forCase: self.clinicalCase, with: .diagnosis)
        } else {
            delegate?.didSolveCase(forCase: self.clinicalCase, with: nil)
        }
        
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func didDeleteComment(forCase clinicalCase: Case) {
        if clinicalCase.caseId == self.clinicalCase.caseId {
            fetchComments()
        }
        
        delegate?.didComment(forCase: clinicalCase)
    }
}
