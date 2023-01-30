//
//  GroupContentManagementViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/1/23.
//

import UIKit
import JGProgressHUD

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let homeTextCellReuseIdentifier = "HomeTextCellReuseIdentifier"
private let homeImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let homeTwoImageTextCellReuseIdentifier = "HomeTwoImageTextCellReuseIdentifier"
private let homeThreeImageTextCellReuseIdentifier = "HomeThreeImageTextCellReuseIdentifier"
private let homeFourImageTextCellReuseIdentifier = "HomeFourImageTextCellReuseIdentifier"
private let emptyPostsCellReuseIdentifier = "EmptyPostsCellReuseIdentifier"
private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"

class GroupContentManagementViewController: UIViewController, UINavigationControllerDelegate {
    
    let group: Group
    
    weak var delegate: GroupBrowserViewControllerDelegate?
    var selectedImage: UIImageView!
    
    weak var scrollDelegate: CollectionViewDidScrollDelegate?
    
    private var zoomTransitioning = ZoomTransitioning()
    
    private lazy var browserSegmentedButtonsView: FollowersFollowingSegmentedButtonsView = {
        let segmentedButtonsView = FollowersFollowingSegmentedButtonsView()
        //segmentedButtonsView.setLabelsTitles(titles: ["Members", "Requests", "Invites", "Blocked"])
        segmentedButtonsView.setLabelsTitles(titles: ["Posts", "Cases"])
        segmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        segmentedButtonsView.backgroundColor = .systemBackground
        return segmentedButtonsView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private var posts = [Post]()
    private var cases = [Case]()
    private var users = [User]()
    
    private let postsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        //layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let casesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        //layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    private var postsLoaded: Bool = false
    private var casesLoaded: Bool = false
    
    private var isFetchingOrDidFetchCases: Bool = false
    
    private var groupNeedsToReviewContent: Bool = false
    
    private let progressIndicator = JGProgressHUD()
    
    init(group: Group) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        postsCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.frame.height)
        casesCollectionView.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: scrollView.frame.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        view.backgroundColor = .systemBackground
        //self.navigationController?.delegate = self
        fetchPendingPosts()
        browserSegmentedButtonsView.segmentedControlDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }
    
    private func configureNavigationBar() {
        title = "Pending content"
    }
    
    private func configureCollectionView() {
        postsCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        postsCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyPostsCellReuseIdentifier)
        postsCollectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: homeTextCellReuseIdentifier)
        postsCollectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        postsCollectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        postsCollectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        postsCollectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        
        casesCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        casesCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyPostsCellReuseIdentifier)
        casesCollectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        casesCollectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        
        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
    }
    
    private func configureUI() {
        browserSegmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(browserSegmentedButtonsView, separatorView, scrollView)
        NSLayoutConstraint.activate([
            browserSegmentedButtonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            browserSegmentedButtonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            browserSegmentedButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            browserSegmentedButtonsView.heightAnchor.constraint(equalToConstant: 51),
            
            separatorView.topAnchor.constraint(equalTo: browserSegmentedButtonsView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.delegate = self
        scrollView.addSubview(postsCollectionView)
        scrollView.addSubview(casesCollectionView)
        scrollView.contentSize.width = view.frame.width * 2
    }
    
    func fetchPendingPosts() {
        if group.permissions == .all || group.permissions == .review {
            groupNeedsToReviewContent = true
            DatabaseManager.shared.fetchPendingPostsForGroup(withGroupId: group.groupId) { pendingPosts in
                let postIds = pendingPosts.map({ $0.id })
                if pendingPosts.isEmpty {
                    self.postsLoaded = true
                    self.postsCollectionView.reloadData()
                    return
                }
                postIds.forEach { id in
                    PostService.fetchGroupPost(withGroupId: self.group.groupId, withPostId: id) { post in
                        self.posts.append(post)
                        if self.posts.count == postIds.count {
                            // Fetch user info
                            self.posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                            let uniqueOwnerUids = Array(Set(self.posts.map({ $0.ownerUid })))
                            UserService.fetchUsers(withUids: uniqueOwnerUids) { users in
                                self.users = users
                                self.postsLoaded = true
                                self.postsCollectionView.reloadData()
                                return
                            }
                        }
                    }
                }
            }
        } else {
            groupNeedsToReviewContent = false
            postsLoaded = true
            postsCollectionView.reloadData()
        }
    }
    
    func fetchPendingCases() {
        isFetchingOrDidFetchCases = true
        if group.permissions == .all || group.permissions == .review {
            groupNeedsToReviewContent = true
            DatabaseManager.shared.fetchPendingCasesForGroup(withGroupId: group.groupId) { pendingCases in
                let postIds = pendingCases.map({ $0.id })
                if pendingCases.isEmpty {
                    self.casesLoaded = true
                    self.casesCollectionView.reloadData()
                    return
                }
                postIds.forEach { id in
                    CaseService.fetchGroupCase(withGroupId: self.group.groupId, withCaseId: id) { clinicalCase in
                        self.cases.append(clinicalCase)
                        if self.cases.count == pendingCases.count {
                            // Fetch user info
                            self.cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                            let uniqueOwnerUids = Array(Set(self.cases.map({ $0.ownerUid })))
                            UserService.fetchUsers(withUids: uniqueOwnerUids) { users in
                                self.users = users
                                self.casesLoaded = true
                                self.casesCollectionView.reloadData()
                                return
                            }
                        }
                    }
                }
            }
        } else {
            groupNeedsToReviewContent = false
            casesLoaded = true
            casesCollectionView.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > scrollView.frame.width * 0.2 &&  !isFetchingOrDidFetchCases { fetchPendingCases() }
        if scrollView.contentOffset.x == 0 { return }
        
        scrollDelegate = browserSegmentedButtonsView
        scrollDelegate?.collectionViewDidScroll(for: scrollView.contentOffset.x / 2)
    }
    
    private func getUserForPost(post: Post) -> User {
        let userIndex = users.firstIndex { user in
            if user.uid == post.ownerUid {
                return true
            }
            
            return false
        }
        
        if let userIndex = userIndex {
            return users[userIndex]
        } else {
            return User(dictionary: [:])
        }
    }
    
    private func getUserForCase(clinicalCase: Case) -> User {
        let userIndex = users.firstIndex { user in
            if user.uid == clinicalCase.ownerUid {
                return true
            }
            
            return false
        }
        
        if let userIndex = userIndex {
            return users[userIndex]
        } else {
            return User(dictionary: [:])
        }
    }
    
    func showAcceptContentPopUp(type: ContentGroup.GroupContentType) {
        let title = type == .post ? "post" : "case"
        
        let approvedPostPopup = METopPopupView(title: "Pending \(title) approved. It may take a few minutes to appear in the group feed.", image: "checkmark.circle.fill", popUpType: .regular)
        approvedPostPopup.showTopPopup(inView: self.view)
    }
    
    func showDeleteAlertController(type: ContentGroup.GroupContentType, contentId: String) {
        let title = type == .post ? "post" : "case"
        //let position = type == .post ? 0 : 1
        
        displayMEDestructiveAlert(withTitle: "Delete \(title)", withMessage: "Are you sure you want to delete this \(title)?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
            switch type {
            case .clinicalCase:
                let caseIndex = self.cases.firstIndex { clinicalCase in
                    if clinicalCase.caseId == contentId {
                        return true
                    }
                    return false
                }
                
                if let caseIndex = caseIndex {
                    self.progressIndicator.show(in: self.view)
                    DatabaseManager.shared.denyGroupCase(withGroupId: self.group.groupId, withCaseId: contentId) { approved in
                        self.progressIndicator.dismiss(animated: true)
                        if approved {
                            self.casesCollectionView.performBatchUpdates {
                                self.cases.remove(at: caseIndex)
                                self.casesCollectionView.deleteItems(at: [IndexPath(item: caseIndex, section: 0)])
                            }
                            self.didCancelContent(type: .clinicalCase)
                        }
                    }
                }
            case .post:
                let postIndex = self.posts.firstIndex { post in
                    if post.postId == contentId {
                        return true
                    }
                    return false
                }
                
                if let postIndex = postIndex {
                    self.progressIndicator.show(in: self.view)
                    DatabaseManager.shared.denyGroupPost(withGroupId: self.group.groupId, withPostId: contentId) { denied in
                        self.progressIndicator.dismiss(animated: true)
                        if denied {
                            self.postsCollectionView.performBatchUpdates {
                                self.posts.remove(at: postIndex)
                                self.postsCollectionView.deleteItems(at: [IndexPath(item: postIndex, section: 0)])
                            }
                            self.didCancelContent(type: .post)
                        }
                    }
                }
            }
        }
    }
    
    func didCancelContent(type: ContentGroup.GroupContentType) {
        let capitalTitle = type == .post ? "Post" : "Case"
        let deletedPostPopup = METopPopupView(title: "\(capitalTitle) successfully deleted", image: "checkmark.circle.fill", popUpType: .regular)
        deletedPostPopup.showTopPopup(inView: self.view)
    }
}

extension GroupContentManagementViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == postsCollectionView {
            return postsLoaded ? groupNeedsToReviewContent ? posts.isEmpty ? 1 : posts.count : 1 : 0
        } else {
            return casesLoaded ? groupNeedsToReviewContent ? cases.isEmpty ? 1 : cases.count : 1 : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == postsCollectionView {
            if !groupNeedsToReviewContent {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyPostsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: nil, title: "Posts don't require admin review", description: "Group owners can activate the ability to review all group posts before they are shared with members.", buttonText: "Go to group")
                cell.delegate = self
                return cell
            } else {
                if posts.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyPostsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    cell.configure(image: nil, title: "No pending posts.", description: "Check back for all the new posts that need review.", buttonText: "Go to group")
                    cell.delegate = self
                    return cell
                } else {
                    let currentPost = posts[indexPath.row].type
                    
                    switch currentPost {
                        
                    case .plainText:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTextCellReuseIdentifier, for: indexPath) as! HomeTextCell
                        cell.delegate = self
                        cell.reviewDelegate = self
                        cell.viewModel = PostViewModel(post: posts[indexPath.row])
                        cell.set(user: getUserForPost(post: posts[indexPath.row]))
                        cell.configureWithReviewOptions()
                        return cell
                    case .textWithImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                        cell.delegate = self
                        cell.reviewDelegate = self
                        cell.viewModel = PostViewModel(post: posts[indexPath.row])
                        cell.set(user: getUserForPost(post: posts[indexPath.row]))
                        cell.configureWithReviewOptions()
                        return cell
                    case .textWithTwoImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                        cell.delegate = self
                        cell.reviewDelegate = self
                        cell.viewModel = PostViewModel(post: posts[indexPath.row])
                        cell.set(user: getUserForPost(post: posts[indexPath.row]))
                        cell.configureWithReviewOptions()
                        return cell
                    case .textWithThreeImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                        cell.delegate = self
                        cell.reviewDelegate = self
                        cell.viewModel = PostViewModel(post: posts[indexPath.row])
                        cell.set(user: getUserForPost(post: posts[indexPath.row]))
                        cell.configureWithReviewOptions()
                        return cell
                    case .textWithFourImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as!  HomeFourImageTextCell
                        cell.delegate = self
                        cell.reviewDelegate = self
                        cell.viewModel = PostViewModel(post: posts[indexPath.row])
                        cell.set(user: getUserForPost(post: posts[indexPath.row]))
                        cell.configureWithReviewOptions()
                        return cell
                    case .document:
                        return UICollectionViewCell()
                    case .poll:
                        return UICollectionViewCell()
                    case .video:
                        return UICollectionViewCell()
                    }
                }
            }
        } else {
            // Cases
            if !groupNeedsToReviewContent {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyPostsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: nil, title: "Cases don't require admin review", description: "Group owners can activate the ability to review all group cases before they are shared with members.", buttonText: "Go to group")
                cell.delegate = self
                return cell
            } else {
                if cases.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyPostsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    cell.configure(image: nil, title: "No pending cases.", description: "Check back for all the new cases that need review.", buttonText: "Go to group")
                    cell.delegate = self
                    return cell
                } else {
                    let currentCase = cases[indexPath.row].type
                    switch currentCase {
                    case .text:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                        cell.reviewDelegate = self
                        cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                        cell.set(user: getUserForCase(clinicalCase: cases[indexPath.row]))
                        cell.configureWithReviewOptions()
                        cell.delegate = self
                        return cell
                    case .textWithImage:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                        cell.reviewDelegate = self
                        cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                        cell.set(user: getUserForCase(clinicalCase: cases[indexPath.row]))
                        cell.configureWithReviewOptions()
                        cell.delegate = self
                        return cell
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == postsCollectionView {
            return postsLoaded ? CGSize.zero : CGSize(width: view.frame.width - 30, height: 50)
        } else {
            return casesLoaded ? CGSize.zero : CGSize(width: view.frame.width - 30, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if collectionView == postsCollectionView {
            let header = postsCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        } else {
            let header = casesCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }
    }
}

extension GroupContentManagementViewController: SegmentedControlDelegate {
    func indexDidChange(from currentIndex: Int, to index: Int) {
        if currentIndex == index { return }

        switch currentIndex {
        case 0:
            let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x + view.frame.width))
            self.moveToFrame(contentOffset: contentOffset)
            
        case 1:
            let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x - view.frame.width))
            self.moveToFrame(contentOffset: contentOffset)
            
        default:
            print("Not found index to change position")
        }
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        UIView.animate(withDuration: 1) {
            self.scrollView.setContentOffset(CGPoint(x: contentOffset, y: self.scrollView.bounds.origin.y), animated: true)
        }
        
    }
}

extension GroupContentManagementViewController: DetailsContentReviewDelegate {
    func didTapAcceptContent(type: ContentGroup.GroupContentType, contentId: String) {
        switch type {
        case .clinicalCase:
            let caseIndex = cases.firstIndex { clinicalCase in
                if clinicalCase.caseId == contentId {
                    return true
                }
                return false
            }
            if let caseIndex = caseIndex {
                self.casesCollectionView.performBatchUpdates {
                    self.cases.remove(at: caseIndex)
                    self.casesCollectionView.deleteItems(at: [IndexPath(item: caseIndex, section: 0)])
                }
                self.showAcceptContentPopUp(type: .clinicalCase)
            }
            
        case .post:
            let postIndex = posts.firstIndex { post in
                if post.postId == contentId {
                    return true
                }
                return false
            }
            if let postIndex = postIndex {
                self.postsCollectionView.performBatchUpdates {
                    self.posts.remove(at: postIndex)
                    self.postsCollectionView.deleteItems(at: [IndexPath(item: postIndex, section: 0)])
                }
                self.showAcceptContentPopUp(type: .post)
            }
        }
        
        
        //didTapAcceptContent(contentId: contentId, type: type)
    }
    
    func didTapCancelContent(type: ContentGroup.GroupContentType, contentId: String) {
        switch type {
        case .clinicalCase:
            let caseIndex = self.cases.firstIndex { clinicalCase in
                if clinicalCase.caseId == contentId {
                    return true
                }
                return false
            }
            
            if let caseIndex = caseIndex {
                
                self.casesCollectionView.performBatchUpdates {
                    self.cases.remove(at: caseIndex)
                    self.casesCollectionView.deleteItems(at: [IndexPath(item: caseIndex, section: 0)])
                    
                    self.didCancelContent(type: .clinicalCase)
                }
            }
            
        case .post:
            let postIndex = self.posts.firstIndex { post in
                if post.postId == contentId {
                    return true
                }
                return false
            }
            
            if let postIndex = postIndex {
                
                self.postsCollectionView.performBatchUpdates {
                    self.posts.remove(at: postIndex)
                    self.postsCollectionView.deleteItems(at: [IndexPath(item: postIndex, section: 0)])
                }
                self.didCancelContent(type: .post)
            }
        }
    }
}

extension GroupContentManagementViewController: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension GroupContentManagementViewController: ReviewContentGroupDelegate {
    func didTapAcceptContent(contentId: String, type: ContentGroup.GroupContentType) {
        
        switch type {
        case .clinicalCase:
            let caseIndex = cases.firstIndex { clinicalCase in
                if clinicalCase.caseId == contentId {
                    return true
                }
                return false
            }
            
            if let caseIndex = caseIndex {
                progressIndicator.show(in: view)
                DatabaseManager.shared.approveGroupCase(withGroupId: group.groupId, withCaseId: contentId) { approved in
                    self.progressIndicator.dismiss(animated: true)
                    if approved {
                        self.casesCollectionView.performBatchUpdates {
                            self.cases.remove(at: caseIndex)
                            self.casesCollectionView.deleteItems(at: [IndexPath(item: caseIndex, section: 0)])
                        }
                        self.showAcceptContentPopUp(type: .clinicalCase)
                    }
                }
            }
        case .post:
            let postIndex = posts.firstIndex { post in
                if post.postId == contentId {
                    return true
                }
                return false
            }
            
            if let postIndex = postIndex {
                progressIndicator.show(in: view)
                DatabaseManager.shared.approveGroupPost(withGroupId: group.groupId, withPostId: contentId) { approved in
                    self.progressIndicator.dismiss(animated: true)
                    if approved {
                        self.postsCollectionView.performBatchUpdates {
                            self.posts.remove(at: postIndex)
                            self.postsCollectionView.deleteItems(at: [IndexPath(item: postIndex, section: 0)])
                        }
                        self.showAcceptContentPopUp(type: .post)
                    }
                }
            }
        }
    }
    
    func didTapCancelContent(contentId: String, type: ContentGroup.GroupContentType) {
        showDeleteAlertController(type: type, contentId: contentId)
    }
}

extension GroupContentManagementViewController: HomeCellDelegate {
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor post: Post, forAuthor user: User) { return }
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) { return }
    func cell(wantsToSeeLikesFor post: Post) { return }
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor: User) { return }
    func cell(_ cell: UICollectionViewCell, didLike post: Post) { return }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }

    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        navigationController?.delegate = self
        
        let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)
        //controller.displaysta
        controller.isReviewingPost = true
        controller.reviewDelegate = self
        controller.groupId = group.groupId
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        self.navigationController?.delegate = zoomTransitioning
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        //controller.customDelegate = self
        //displayState = .photo
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .clear
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension GroupContentManagementViewController: CaseCellDelegate {
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) { return }
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) { return }
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) { return }
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) { return }
    func clinicalCase(_ cell: UICollectionViewCell, didPressThreeDotsFor clinicalCase: Case) { return }
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) { return }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }

    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        self.navigationController?.delegate = zoomTransitioning
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        //controller.customDelegate = self

        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .clear
        navigationItem.backBarButtonItem = backItem

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        navigationController?.delegate = self
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)
        //controller.displaysta
        controller.isReviewingCase = true
        controller.reviewDelegate = self
        controller.groupId = group.groupId
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension GroupContentManagementViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

