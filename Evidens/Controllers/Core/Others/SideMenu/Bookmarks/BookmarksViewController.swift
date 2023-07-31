//
//  BookmarksViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/9/22.
//

import UIKit
import Firebase

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"

private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseImageCellReuseIdentifier = "CaseImageCellReuseIdentifier"

private let postTextCellReuseIdentifier = "PostTextCellReuseIdentifier"
private let postImageCellReuseIdentifier = "PostImageCellReuseIdentifier"

private let emptyBookmarkCellCaseReuseIdentifier = "EmptyBookmarkCellCaseReuseIdentifier"

private let networkCellReuseIdentifier = "NetworkCellReuseIdentifer"

class BookmarksViewController: UIViewController {
    
    var lastCaseSnapshot: QueryDocumentSnapshot?
    var lastPostSnapshot: QueryDocumentSnapshot?
    
    private var caseLoaded = false
    private var postLoaded = false
    private var networkError = false
    
    private var cases = [Case]()
    private var caseUsers = [User]()
    
    private var posts = [Post]()
    private var postUsers = [User]()
    
    private var bookmarkToolbar = BookmarkToolbar()
    private var spacingView = SpacingView()
    
    private var isScrollingHorizontally = false
    private var didFetchPosts: Bool = false
    private var scrollIndex: Int = 0
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .systemBackground
        scrollView.bounces = false
        return scrollView
    }()
    
    private let casesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = true
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let postsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = true
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureCollectionViews()
        fetchBookmarkedClinicalCases()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        casesCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.frame.height)
        spacingView.frame = CGRect(x: view.frame.width, y: 0, width: 10, height: scrollView.frame.height)
        postsCollectionView.frame = CGRect(x: view.frame.width + 10, y: 0, width: view.frame.width, height: scrollView.frame.height)
    }
    
    private func fetchBookmarkedClinicalCases() {
        CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):
                CaseService.fetchCases(snapshot: snapshot) { clinicalCases in
                    strongSelf.lastCaseSnapshot = snapshot.documents.last
                    strongSelf.cases = clinicalCases
                    let ownerUids = clinicalCases.filter({ $0.privacy == .regular }).map({ $0.uid })
                    
                    guard !ownerUids.isEmpty else {
                        strongSelf.caseLoaded = true
                        strongSelf.casesCollectionView.reloadData()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: ownerUids) { users in
                        strongSelf.caseUsers = users
                        strongSelf.caseLoaded = true
                        strongSelf.casesCollectionView.reloadData()
                    }
                }
            case .failure(let error):
                switch error {
                case .network:
                    strongSelf.caseLoaded = true
                    strongSelf.networkError = true
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                case .notFound:
                    strongSelf.caseLoaded = true
                    strongSelf.casesCollectionView.reloadData()
                case .unknown:
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        }
    }
    
    private func fetchBookmarkedPosts() {
        PostService.fetchPostBookmarkDocuments(lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):
                PostService.fetchHomePosts(snapshot: snapshot) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let posts):
                        strongSelf.lastPostSnapshot = snapshot.documents.last
                        strongSelf.posts = posts
                        let ownerUids = posts.map({ $0.uid })
                        UserService.fetchUsers(withUids: ownerUids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.postLoaded = true
                            strongSelf.postUsers = users
                            strongSelf.didFetchPosts = true
                            strongSelf.postsCollectionView.reloadData()
                        }
                    case .failure(_):
                        break
                    }
                }
            case .failure(let error):
                switch error {
                case .network:
                    strongSelf.postLoaded = true
                    strongSelf.networkError = true
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    strongSelf.didFetchPosts = true
                    strongSelf.postsCollectionView.reloadData()
                case .notFound:
                    strongSelf.postLoaded = true
                    strongSelf.postsCollectionView.reloadData()
                    strongSelf.didFetchPosts = true
                case .unknown:
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        }
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.bookmark
    }
    
    private func configureCollectionViews() {
        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        
        casesCollectionView.register(BookmarksCaseCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        casesCollectionView.register(BookmarksCaseImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        postsCollectionView.register(BookmarkPostCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        postsCollectionView.register(BookmarksPostImageCell.self, forCellWithReuseIdentifier: postImageCellReuseIdentifier)
        casesCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        postsCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        postsCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyBookmarkCellCaseReuseIdentifier)
        casesCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyBookmarkCellCaseReuseIdentifier)
        
        postsCollectionView.register(NetworkFailureCell.self, forCellWithReuseIdentifier: networkCellReuseIdentifier)
        casesCollectionView.register(NetworkFailureCell.self, forCellWithReuseIdentifier: networkCellReuseIdentifier)
        
        view.addSubviews(bookmarkToolbar, scrollView)
        
        NSLayoutConstraint.activate([
            bookmarkToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bookmarkToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bookmarkToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bookmarkToolbar.heightAnchor.constraint(equalToConstant: 50),
            
            scrollView.topAnchor.constraint(equalTo: bookmarkToolbar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        bookmarkToolbar.toolbarDelegate = self
        scrollView.delegate = self
        scrollView.addSubview(casesCollectionView)
        scrollView.addSubview(postsCollectionView)
        scrollView.addSubview(spacingView)
        scrollView.contentSize.width = view.frame.width * 2 + 10
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y != 0 {
            isScrollingHorizontally = false
        }
        
        if scrollView.contentOffset.y == 0 && isScrollingHorizontally {
            bookmarkToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x - 10)
        }
        
        if scrollView.contentOffset.y == 0 && !isScrollingHorizontally {
            isScrollingHorizontally = true
            return
        }
        
        if scrollView.contentOffset.x > view.frame.width * 0.2 && !didFetchPosts {
            fetchBookmarkedPosts()
        }
        
        let spacingWidth = spacingView.frame.width / 2
        
        switch scrollView.contentOffset.x {
        case 0 ..< view.frame.width:
            if isScrollingHorizontally { scrollIndex = 0 }
        case view.frame.width + spacingWidth ..< 2 * view.frame.width + spacingWidth:
            if isScrollingHorizontally { scrollIndex = 1 }
        default:
            break
        }
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee.x
        print(targetOffset)
        if targetOffset == view.frame.width {
            let desiredOffset = CGPoint(x: targetOffset + 10, y: 0)
            scrollView.setContentOffset(desiredOffset, animated: true)
            targetContentOffset.pointee = scrollView.contentOffset
        }
    }

    func fetchMorePosts() {
        PostService.fetchPostBookmarkDocuments(lastSnapshot: lastPostSnapshot) { [weak self] result in
            guard let _ = self else { return }
            switch result {
                
            case .success(let snapshot):
                PostService.fetchHomePosts(snapshot: snapshot) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let posts):
                        strongSelf.lastPostSnapshot = snapshot.documents.last
                        
                        let uids = posts.filter { $0.privacy == .regular}.map { $0.uid }
                        let currentUids = strongSelf.postUsers.map { $0.uid }
                        
                        let newUids = uids.filter { !currentUids.contains($0) }
                        
                        UserService.fetchUsers(withUids: newUids) { [weak self] newUsers in
                            guard let strongSelf = self else { return }
                            strongSelf.postUsers.append(contentsOf: newUsers)
                            strongSelf.postsCollectionView.reloadData()
                        }
                    case .failure(_):
                        break
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    func fetchMoreCases() {
        CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: lastCaseSnapshot) { [weak self] result in
            guard let _ = self else { return }
            switch result {
                
            case .success(let snapshot):
                CaseService.fetchCases(snapshot: snapshot) { [weak self] cases in
                    guard let strongSelf = self else { return }
                    strongSelf.lastCaseSnapshot = snapshot.documents.last
                    
                    let uids = cases.filter { $0.privacy == .regular }.map { $0.uid }
                    let currentUids = strongSelf.caseUsers.map { $0.uid }
                    
                    let newUids = uids.filter { !currentUids.contains($0) }
                    
                    guard !newUids.isEmpty else {
                        strongSelf.caseLoaded = true
                        strongSelf.casesCollectionView.reloadData()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: newUids) { [weak self] newUsers in
                        guard let strongSelf = self else { return }
                        strongSelf.caseUsers.append(contentsOf: newUsers)
                        strongSelf.casesCollectionView.reloadData()
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            switch scrollIndex {
            case 0:
                fetchMoreCases()
            case 1:
                fetchMorePosts()
            default:
                break
            }
        }
    }
}

extension BookmarksViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == casesCollectionView {
            return caseLoaded ? cases.isEmpty ? 1 : cases.count : 0
        } else {
            return postLoaded ? posts.isEmpty ? 1 : posts.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == casesCollectionView {
            return caseLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 65)
        } else {
            return postLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 65)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == casesCollectionView {
            if networkError {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkCellReuseIdentifier, for: indexPath) as! NetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if cases.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyBookmarkCellCaseReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Case.Empty.emptyRevisionTitle, description: AppStrings.Content.Case.Empty.emptyRevisionContent, content: .dismiss)
                    cell.delegate = self
                    return cell
                } else {
                    let currentCase = cases[indexPath.row]
                    switch currentCase.kind {
                    case .text:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! BookmarksCaseCell
                        cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                        guard currentCase.privacy != .anonymous else {
                            return cell
                        }
                        
                        if let user = caseUsers.first(where: { $0.uid! == currentCase.uid }) {
                            cell.set(user: user)
                        }
                        return cell
                        
                    case .image:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath) as! BookmarksCaseImageCell
                        cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                        guard currentCase.privacy != .anonymous else {
                            return cell
                        }
                        
                        if let user = caseUsers.first(where: { $0.uid! == currentCase.uid }) {
                            cell.set(user: user)
                        }
                        return cell
                    }
                    
                }
            }
        } else {
            if networkError {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkCellReuseIdentifier, for: indexPath) as! NetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if posts.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyBookmarkCellCaseReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Bookmark.emptyPostTitle, description: AppStrings.Content.Bookmark.emptyPostContent, content: .dismiss)
                    cell.delegate = self
                    return cell
                } else {
                    let currentPost = posts[indexPath.row]
                    
                    if currentPost.kind == .plainText {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextCellReuseIdentifier, for: indexPath) as! BookmarkPostCell
                        cell.viewModel = PostViewModel(post: currentPost)
                        if let user = postUsers.first(where: { $0.uid! == currentPost.uid }) {
                            cell.set(user: user)
                        }
                        
                        return cell
                        
                    } else {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postImageCellReuseIdentifier, for: indexPath) as! BookmarksPostImageCell
                        
                        cell.viewModel = PostViewModel(post: currentPost)
                        if let user = postUsers.first(where: { $0.uid! == currentPost.uid }) {
                            cell.set(user: user)
                        }
                        
                        return cell
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        if collectionView == casesCollectionView {
            let clinicalCase = cases[indexPath.row]
            switch clinicalCase.privacy {
                
            case .regular:
                if let user = caseUsers.first(where: { $0.uid! == cases[indexPath.row].uid }) {
                    let controller = DetailsCaseViewController(clinicalCase: cases[indexPath.row], user: user, collectionViewFlowLayout: layout)
                    controller.delegate = self
                    navigationController?.pushViewController(controller, animated: true)
                }
            case .anonymous:
                let controller = DetailsCaseViewController(clinicalCase: cases[indexPath.row], collectionViewFlowLayout: layout)
                controller.delegate = self
                navigationController?.pushViewController(controller, animated: true)
            }
            
        } else {
            if let user = postUsers.first(where: { $0.uid! == posts[indexPath.row].uid }) {
                let controller = DetailsPostViewController(post: posts[indexPath.row], user: user, collectionViewLayout: layout)
                controller.delegate = self
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension BookmarksViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        navigationController?.popViewController(animated: true)
    }
}

extension BookmarksViewController: DetailsPostViewControllerDelegate {
    func didDeleteComment(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            let cell = postsCollectionView.cellForItem(at: IndexPath(item: postIndex, section: 0))
            switch cell {
            case is BookmarkPostCell:
                let currentCell = cell as! BookmarkPostCell
                currentCell.viewModel?.post.numberOfComments -= 1
                posts[postIndex].numberOfComments = post.numberOfComments
            case is BookmarksPostImageCell:
                let currentCell = cell as! BookmarksPostImageCell
                currentCell.viewModel?.post.numberOfComments -= 1
                posts[postIndex].numberOfComments = post.numberOfComments
            default:
                return
            }
        }
    }
    
    func didEditPost(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex].postText = post.postText
            posts[postIndex].edited = true
            postsCollectionView.reloadData()
        }
    }
    
    func didTapLikeAction(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            let cell = postsCollectionView.cellForItem(at: IndexPath(item: postIndex, section: 0))
            switch cell {
            case is BookmarkPostCell:
                let currentCell = cell as! BookmarkPostCell
                currentCell.viewModel?.post.didLike.toggle()
                if post.didLike {
                    currentCell.viewModel?.post.likes = post.likes - 1
                    posts[postIndex].didLike = false
                    posts[postIndex].likes -= 1
                } else {
                    currentCell.viewModel?.post.likes = post.likes + 1
                    posts[postIndex].didLike = true
                    posts[postIndex].likes += 1
                }
            case is BookmarksPostImageCell:
                let currentCell = cell as! BookmarksPostImageCell
                currentCell.viewModel?.post.didLike.toggle()
                if post.didLike {
                    currentCell.viewModel?.post.likes = post.likes - 1
                    posts[postIndex].didLike = false
                    posts[postIndex].likes -= 1
                } else {
                    currentCell.viewModel?.post.likes = post.likes + 1
                    posts[postIndex].didLike = true
                    posts[postIndex].likes += 1
                }
                
            default:
                return
            }
        }
    }
    
    func didTapBookmarkAction(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            postsCollectionView.performBatchUpdates {
                posts.remove(at: postIndex)
                postsCollectionView.deleteItems(at: [IndexPath(item: postIndex, section: 0)])
            }
        }
    }
    
    func didComment(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            let cell = postsCollectionView.cellForItem(at: IndexPath(item: postIndex, section: 0))
            switch cell {
            case is BookmarkPostCell:
                let currentCell = cell as! BookmarkPostCell
                currentCell.viewModel?.post.numberOfComments += 1
                posts[postIndex].numberOfComments = post.numberOfComments
            case is BookmarksPostImageCell:
                let currentCell = cell as! BookmarksPostImageCell
                currentCell.viewModel?.post.numberOfComments += 1
                posts[postIndex].numberOfComments = post.numberOfComments
            default:
                return
            }
        }
    }
}

extension BookmarksViewController: DetailsCaseViewControllerDelegate {
    func didSolveCase(forCase clinicalCase: Case, with diagnosis: CaseRevisionKind?) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[caseIndex].phase = .solved
            if let diagnosis {
                cases[caseIndex].revision = diagnosis
            }

            casesCollectionView.reloadData()
        }
    }
    
    func didAddRevision(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[caseIndex].revision = clinicalCase.revision
            casesCollectionView.reloadData()
        }
    }
    
    func didDeleteComment(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            let cell = casesCollectionView.cellForItem(at: IndexPath(item: caseIndex, section: 0))
            switch cell {
            case is BookmarkPostCell:
                let currentCell = cell as! BookmarksCaseCell
                currentCell.viewModel?.clinicalCase.numberOfComments -= 1
                cases[caseIndex].numberOfComments = clinicalCase.numberOfComments
            case is BookmarksPostImageCell:
                let currentCell = cell as! BookmarksCaseImageCell
                currentCell.viewModel?.clinicalCase.numberOfComments -= 1
                cases[caseIndex].numberOfComments = clinicalCase.numberOfComments
            default:
                return
            }
        }
    }
    
    func didTapLikeAction(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            let cell = casesCollectionView.cellForItem(at: IndexPath(item: caseIndex, section: 0))
            switch cell {
            case is BookmarksCaseCell:
                let currentCell = cell as! BookmarksCaseCell
                if clinicalCase.didLike {
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                    cases[caseIndex].didLike = false
                    cases[caseIndex].likes -= 1
                } else {
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    cases[caseIndex].didLike = true
                    cases[caseIndex].likes += 1
                }
            case is BookmarksCaseImageCell:
                let currentCell = cell as! BookmarksCaseImageCell
                if clinicalCase.didLike {
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                    cases[caseIndex].didLike = false
                    cases[caseIndex].likes -= 1
                } else {
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    cases[caseIndex].didLike = true
                    cases[caseIndex].likes += 1
                }
            default:
                return
            }
        }
    }
    
    func didTapBookmarkAction(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            casesCollectionView.performBatchUpdates {
                cases.remove(at: caseIndex)
                casesCollectionView.deleteItems(at: [IndexPath(item: caseIndex, section: 0)])
            }
        }
    }
    
    func didComment(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            let cell = casesCollectionView.cellForItem(at: IndexPath(item: caseIndex, section: 0))
            switch cell {
            case is BookmarkPostCell:
                let currentCell = cell as! BookmarksCaseCell
                currentCell.viewModel?.clinicalCase.numberOfComments += 1
                cases[caseIndex].numberOfComments = clinicalCase.numberOfComments
            case is BookmarksPostImageCell:
                let currentCell = cell as! BookmarksCaseImageCell
                currentCell.viewModel?.clinicalCase.numberOfComments += 1
                cases[caseIndex].numberOfComments = clinicalCase.numberOfComments
            default:
                return
            }
        }
    }
}

extension BookmarksViewController: BookmarkToolbarDelegate {
    func didTapIndex(_ index: Int) {
        scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width) + index * 10, y: 0), animated: true)
    }
}

extension BookmarksViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        networkError = false
        switch scrollIndex {
        case 0:
            fetchBookmarkedClinicalCases()
        case 1:
            fetchBookmarkedPosts()
        default:
            break
        }
    }
}
