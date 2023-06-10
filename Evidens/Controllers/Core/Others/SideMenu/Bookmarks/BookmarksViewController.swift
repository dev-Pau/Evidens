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

class BookmarksViewController: UIViewController {
    
    var lastCaseSnapshot: QueryDocumentSnapshot?
    var lastPostSnapshot: QueryDocumentSnapshot?
    
    private var caseLoaded = false
    private var postLoaded = false
    
    private var cases = [Case]()
    private var caseUsers = [User]()
    
    private var posts = [Post]()
    private var postUsers = [User]()
    
    private var bookmarkToolbar = BookmarkToolbar()
    private var isScrollingHorizontally = false
    private var didFetchPosts: Bool = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .systemBackground
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
        postsCollectionView.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: scrollView.frame.height)
    }
    
    private func fetchBookmarkedClinicalCases() {
        CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: nil) { snapshot in
            if snapshot.isEmpty {
                self.caseLoaded = true
                self.casesCollectionView.reloadData()
                return
            }
            
            CaseService.fetchCases(snapshot: snapshot) { clinicalCases in
                self.lastCaseSnapshot = snapshot.documents.last
                self.cases = clinicalCases
                let ownerUids = clinicalCases.filter({ $0.privacyOptions == .visible }).map({ $0.ownerUid })
                UserService.fetchUsers(withUids: ownerUids) { users in
                    self.caseUsers = users
                    self.caseLoaded = true
                    self.casesCollectionView.reloadData()
                }
            }
        }
    }
    
    private func fetchBookmarkedPosts() {
        PostService.fetchBookmarkedPostDocuments(lastSnapshot: nil) { snapshot in
            if snapshot.isEmpty {
                self.postLoaded = true
                self.postsCollectionView.reloadData()
                self.didFetchPosts = true
                return
            }
            
            PostService.fetchHomePosts(snapshot: snapshot) { posts in
                self.lastPostSnapshot = snapshot.documents.last
                self.posts = posts
                let ownerUids = posts.map({ $0.ownerUid })
                UserService.fetchUsers(withUids: ownerUids) { users in
                    self.postLoaded = true
                    self.postUsers = users
                    self.didFetchPosts = true
                    self.postsCollectionView.reloadData()
                    print("posts fetched")
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
        scrollView.contentSize.width = view.frame.width * 2
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            isScrollingHorizontally = false
        }
        
        if scrollView.contentOffset.y == 0 && isScrollingHorizontally {
            bookmarkToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
        }
        
        if scrollView.contentOffset.y == 0 && !isScrollingHorizontally {
            isScrollingHorizontally = true
        }
        
        if scrollView.contentOffset.x > view.frame.width * 0.2 && !didFetchPosts {
            print("start fetch now")
            fetchBookmarkedPosts()
        }
    }
    /*
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreBookmarksContent()
        }
    }
    
    private func getMoreBookmarksContent() {
        switch selectedCategory {
        case .cases:
            CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: lastCaseSnapshot) { snapshot in
                guard !snapshot.isEmpty else { return }
                CaseService.fetchCases(snapshot: snapshot) { newClinicalCases in
                    self.lastCaseSnapshot = snapshot.documents.last
                    self.cases.append(contentsOf: newClinicalCases)
                    let newOwnerUids = newClinicalCases.filter({ $0.privacyOptions == .visible }).map({ $0.ownerUid })
                    UserService.fetchUsers(withUids: newOwnerUids) { newUsers in
                        self.caseUsers.append(contentsOf: newUsers)
                        self.contentCollectionView.reloadData()
                    }
                }
            }
        case .posts:
            PostService.fetchBookmarkedPostDocuments(lastSnapshot: lastPostSnapshot) { snapshot in
                guard !snapshot.isEmpty else { return }
                PostService.fetchHomePosts(snapshot: snapshot) { newPosts in
                    self.lastPostSnapshot = snapshot.documents.last
                    self.posts.append(contentsOf: newPosts)
                    let newOwnerUids = newPosts.map({ $0.ownerUid })
                    UserService.fetchUsers(withUids: newOwnerUids) { newUsers in
                        self.postUsers.append(contentsOf: newUsers)
                        self.contentCollectionView.reloadData()
                    }
                }
            }
        }
    }
     */
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
            if cases.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyBookmarkCellCaseReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: "No saved cases yet.", description: "Cases you save will show up here.", buttonText: EmptyCellButtonOptions.dismiss)
                cell.delegate = self
                return cell
            } else {
                let currentCase = cases[indexPath.row]
                switch currentCase.type {
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! BookmarksCaseCell
                    cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                    guard currentCase.privacyOptions != .nonVisible else {
                        return cell
                    }
                    
                    if let user = caseUsers.first(where: { $0.uid! == currentCase.ownerUid }) {
                        cell.set(user: user)
                    }
                    return cell
                    
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath) as! BookmarksCaseImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                    guard currentCase.privacyOptions != .nonVisible else {
                        return cell
                    }
                    
                    if let user = caseUsers.first(where: { $0.uid! == currentCase.ownerUid }) {
                        cell.set(user: user)
                    }
                    return cell
                }
                
            }
        } else {
            if posts.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyBookmarkCellCaseReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: "No saved posts yet.", description: "Posts you save will show up here.", buttonText: EmptyCellButtonOptions.dismiss)
                cell.delegate = self
                return cell
            } else {
                let currentPost = posts[indexPath.row]
                
                if currentPost.type == .plainText {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextCellReuseIdentifier, for: indexPath) as! BookmarkPostCell
                    cell.viewModel = PostViewModel(post: currentPost)
                    if let user = postUsers.first(where: { $0.uid! == currentPost.ownerUid }) {
                        cell.set(user: user)
                    }
                    
                    return cell
                    
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postImageCellReuseIdentifier, for: indexPath) as! BookmarksPostImageCell
                    
                    cell.viewModel = PostViewModel(post: currentPost)
                    if let user = postUsers.first(where: { $0.uid! == currentPost.ownerUid }) {
                        cell.set(user: user)
                    }
                    
                    return cell
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
        
        let backItem = UIBarButtonItem()
        //backItem.title = ""
        backItem.tintColor = .label
        backItem.image = UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        navigationItem.leftItemsSupplementBackButton = false
        navigationItem.backBarButtonItem = backItem
        
        if collectionView == casesCollectionView {
            if let user = caseUsers.first(where: { $0.uid! == cases[indexPath.row].ownerUid }) {
                if let _ = cases[indexPath.row].groupId {
                    let controller = DetailsCaseViewController(clinicalCase: cases[indexPath.row], user: user, type: .group, collectionViewFlowLayout: layout)
                    controller.delegate = self
                    navigationController?.pushViewController(controller, animated: true)
                } else {
                    let controller = DetailsCaseViewController(clinicalCase: cases[indexPath.row], user: user, type: .regular, collectionViewFlowLayout: layout)
                    controller.delegate = self
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
        } else {
            if let user = postUsers.first(where: { $0.uid! == posts[indexPath.row].ownerUid }) {
                
                if let _ = posts[indexPath.row].groupId {
                    let controller = DetailsPostViewController(post: posts[indexPath.row], user: user, type: .group, collectionViewLayout: layout)
                    controller.delegate = self
                    navigationController?.pushViewController(controller, animated: true)
                } else {
                    let controller = DetailsPostViewController(post: posts[indexPath.row], user: user, type: .regular, collectionViewLayout: layout)
                    controller.delegate = self
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
}

extension BookmarksViewController: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton(option: EmptyCellButtonOptions) {
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
    
    func didAddUpdate(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[caseIndex].caseUpdates = clinicalCase.caseUpdates
            casesCollectionView.reloadData()
        }
    }
    
    func didAddDiagnosis(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[caseIndex].diagnosis = clinicalCase.diagnosis
            casesCollectionView.reloadData()
        }
    }
}

extension BookmarksViewController: BookmarkToolbarDelegate {
    func didTapIndex(_ index: Int) {
        scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width), y: 0), animated: true)
    }
}
