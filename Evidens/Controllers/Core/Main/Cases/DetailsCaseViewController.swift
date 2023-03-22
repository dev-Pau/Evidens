//
//  DetailsCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/8/22.
//

import UIKit
import JGProgressHUD

private let headerReuseIdentifier = "HeaderReuseIdentifier"
private let commentReuseIdentifier = "CommentCellReuseIdentifier"

private let caseImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let caseTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"


protocol DetailsCaseViewControllerDelegate: AnyObject {
    func didTapLikeAction(forCase clinicalCase: Case)
    func didTapBookmarkAction(forCase clinicalCase: Case)
    func didComment(forCase clinicalCase: Case)
    func didAddUpdate(forCase clinicalCase: Case)
    func didAddDiagnosis(forCase clinicalCase: Case)
}

class DetailsCaseViewController: UICollectionViewController, UINavigationControllerDelegate {
    
    private var clinicalCase: Case
    private var user: User
    
    private var displayState: DisplayState = .none
    
    private var ownerComments: [User] = []
    
    private var type: Comment.CommentType
    
    private var commentMenu = CommentsMenuLauncher()
  
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
    
    var isReviewingCase: Bool = false
    var groupId: String?
    
    weak var reviewDelegate: DetailsContentReviewDelegate?
    weak var delegate: DetailsCaseViewControllerDelegate?
    
    private let progressIndicator = JGProgressHUD()
    
    private var comments: [Comment]? {
        didSet {
            collectionView.reloadData()
        }
    }

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
        checkIfUserLikedCase()
        checkIfUserBookmarkedCase()
    }
    
    private func configureNavigationBar() {
        
        let fullName = clinicalCase.privacyOptions == .nonVisible ? "Shared anonymously" : user.firstName! + " " + user.lastName!
        
        let view = MENavigationBarTitleView(fullName: fullName, category: "Case")
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.systemBackground).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    

    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: commentReuseIdentifier)
        collectionView.register(CommentsSectionHeader.self, forCellWithReuseIdentifier: headerReuseIdentifier)
        
        switch clinicalCase.type { 
        case .text:
            collectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        case .textWithImage:
            collectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseImageTextCellReuseIdentifier)
        }
    }
    
    private func fetchComments() {
        CommentService.fetchCaseComments(forCase: clinicalCase, forType: type) { fetchedComments in
            self.comments = fetchedComments
            fetchedComments.forEach { comment in
                UserService.fetchUser(withUid: comment.uid) { user in
                    self.ownerComments.append(user)
                    if self.ownerComments.count == fetchedComments.count {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if let comments = comments {
                if comments.isEmpty { return 0 } else {
                    if section == 1 {
                        return 1
                    } else {
                        return comments.count
                    }
                }
            }
            return 0
        }
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
                if isReviewingCase {
                    cell.reviewDelegate = self
                    cell.configureWithReviewOptions()
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageTextCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                cell.viewModel = CaseViewModel(clinicalCase: clinicalCase)
                cell.set(user: user)
                cell.titleCaseLabel.numberOfLines = 0
                cell.descriptionCaseLabel.numberOfLines = 0
                cell.delegate = self
                if isReviewingCase {
                    cell.reviewDelegate = self
                    cell.configureWithReviewOptions()
                }
                return cell
            }
        } else {
            if let comments = comments {
                if indexPath.section == 1 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! CommentsSectionHeader
                    cell.backgroundColor = .systemBackground
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentReuseIdentifier, for: indexPath) as! CommentCell
                    cell.authorButton.isHidden = true
                    cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
                    cell.delegate = self
                    
                    let userIndex = ownerComments.firstIndex { user in
                        if user.uid == comments[indexPath.row].uid {
                            return true
                        }
                        return false
                    }
                    
                    if let userIndex = userIndex {
                        cell.set(user: ownerComments[userIndex])
                    }

                    cell.backgroundColor = .systemBackground
                    return cell
                }
            } else {
                return UICollectionViewCell()
            }
        }
    }
}

extension DetailsCaseViewController: CommentCellDelegate {

    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment) {
        commentMenu.comment = comment
        commentMenu.showCommentsSettings(in: view)
        
        commentMenu.completion = { delete in
            if let indexPath = self.collectionView.indexPath(for: cell) {
                self.deleteCommentAlert {
                    CommentService.deleteCaseComment(forCase: self.clinicalCase, forCommentUid: comment.id) { deleted in
                        if deleted {
                            DatabaseManager.shared.deleteRecentComment(forCommentId: comment.id)
                            
                            self.collectionView.performBatchUpdates {
                                self.comments!.remove(at: indexPath.item)
                                self.collectionView.deleteItems(at: [indexPath])
                            }
                            let popupView = METopPopupView(title: "Comment deleted", image: "trash", popUpType: .destructive)
                            popupView.showTopPopup(inView: self.view)
                        }
                        else {
                            print("couldnt remove comment")
                        }
                    }
                }
            }
        }
    }
    
    func didTapProfile(forUser user: User) {
        let controller = UserProfileViewController(user: user)
        displayState = .others
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = .label
        self.navigationItem.backBarButtonItem = backButton
        displayState = .others
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func checkIfUserLikedCase() {
        CaseService.checkIfUserLikedCase(clinicalCase: clinicalCase) { didLike in
            self.clinicalCase.didLike = didLike
            self.collectionView.reloadData()

        }
    }
    
    func checkIfUserBookmarkedCase() {
        CaseService.checkIfUserBookmarkedCase(clinicalCase: clinicalCase) { didBookmark in
            self.clinicalCase.didBookmark = didBookmark
            self.collectionView.reloadData()

        }
    }
}

extension DetailsCaseViewController: CaseCellDelegate {
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: Case.CaseMenuOptions) {
        switch option {
        case .delete:
            #warning("Implement delete")
            print("delete")
        case .update:
            let controller = CaseUpdatesViewController(clinicalCase: clinicalCase, user: user)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            controller.controllerIsPushed = true
            controller.delegate = self
            controller.groupId = groupId
            
            navigationController?.pushViewController(controller, animated: true)
        case .solved:
            let controller = CaseDiagnosisViewController(diagnosisText: "")
            controller.stageIsUpdating = true
            controller.delegate = self
            controller.caseId = clinicalCase.caseId
            controller.groupId = groupId
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        case .report:
            let reportPopup = METopPopupView(title: "Case successfully reported", image: "checkmark.circle.fill", popUpType: .regular)
            reportPopup.showTopPopup(inView: self.view)
        case .edit:
            let controller = CaseDiagnosisViewController(diagnosisText: clinicalCase.diagnosis)
            controller.diagnosisIsUpdating = true
            controller.delegate = self
            controller.caseId = clinicalCase.caseId
            controller.groupId = groupId
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    

    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        
        let controller = PostLikesViewController(contentType: clinicalCase)
        displayState = .others
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        
        let controller = CommentCaseViewController(clinicalCase: clinicalCase, user: user, type: type)
        controller.delegate = self
        controller.hidesBottomBarWhenPushed = true
        displayState = .others
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is CaseTextCell:
            let currentCell = cell as! CaseTextCell
            currentCell.viewModel?.clinicalCase.didLike.toggle()
            if clinicalCase.didLike {
                //Unlike post here
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
                        NotificationService.uploadNotification(toUid: clinicalCase.ownerUid, fromUser: user, type: .likeCase, clinicalCase: clinicalCase)
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
                        NotificationService.uploadNotification(toUid: clinicalCase.ownerUid, fromUser: user, type: .likeCase, clinicalCase: clinicalCase)
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
                        //NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                    }
                    
                case .group:
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    self.delegate?.didTapBookmarkAction(forCase: clinicalCase)
                }
                //Like post here
                
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
                        //NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                    }
                    
                case .group:
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    self.delegate?.didTapBookmarkAction(forCase: clinicalCase)
                }
                //Like post here
                
            }
        default:
            print("Cell not registered")
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didPressThreeDotsFor clinicalCase: Case) { return }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {

        let controller = UserProfileViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        displayState = .others
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        let controller = CaseUpdatesViewController(clinicalCase: clinicalCase, user: user)
        controller.delegate = self
        controller.controllerIsPushed = true
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        displayState = .others
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        self.navigationController?.delegate = zoomTransitioning
        selectedImage = image[index]
        displayState = .photo
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        //controller.customDelegate = self

        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .clear
        navigationItem.backBarButtonItem = backItem

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User) {
        return
    }
}

extension DetailsCaseViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension DetailsCaseViewController: CommentCaseViewControllerDelegate {
    func didCommentCase(clinicalCase: Case, user: User, comment: Comment) {
        comments?.append(comment)
        self.clinicalCase.numberOfComments += 1
        collectionView.reloadData()
        delegate?.didComment(forCase: clinicalCase)
    }
}

extension DetailsCaseViewController: CaseUpdatesViewControllerDelegate {
    func didAddUpdateToCase(withUpdates updates: [String], caseId: String) {
        self.clinicalCase.caseUpdates = updates
        collectionView.reloadData()
        delegate?.didAddUpdate(forCase: self.clinicalCase)
    }
}

extension DetailsCaseViewController: CaseDiagnosisViewControllerDelegate {
    func handleAddDiagnosis(_ text: String, caseId: String) {
        clinicalCase.stage = .resolved
        clinicalCase.diagnosis = text
        collectionView.reloadData()
        delegate?.didAddDiagnosis(forCase: clinicalCase)
    }
}

extension DetailsCaseViewController: ReviewContentGroupDelegate {
    func didTapAcceptContent(contentId: String, type: ContentGroup.GroupContentType) {
        guard let groupId = groupId else { return }
        progressIndicator.show(in: view)
        DatabaseManager.shared.approveGroupCase(withGroupId: groupId, withCaseId: contentId) { approved in
            self.progressIndicator.dismiss(animated: true)
            if approved {
                self.reviewDelegate?.didTapAcceptContent(type: .clinicalCase, contentId: contentId)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func didTapCancelContent(contentId: String, type: ContentGroup.GroupContentType) {
        guard let groupId = groupId else { return }
        displayMEDestructiveAlert(withTitle: "Delete case", withMessage: "Are you sure you want to delete this case?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
            self.progressIndicator.show(in: self.view)
            DatabaseManager.shared.denyGroupCase(withGroupId: groupId, withCaseId: contentId) { denied in
                self.progressIndicator.dismiss(animated: true)
                if denied {
                    self.reviewDelegate?.didTapCancelContent(type: .clinicalCase, contentId: contentId)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
