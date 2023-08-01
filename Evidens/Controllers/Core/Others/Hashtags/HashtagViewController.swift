//
//  HashtagViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/7/23.
//

import UIKit
import Firebase

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"

private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseImageCellReuseIdentifier = "CaseImageCellReuseIdentifier"

private let postTextCellReuseIdentifier = "PostTextCellReuseIdentifier"
private let postImageCellReuseIdentifier = "PostImageCellReuseIdentifier"

private let emptyHashtagCellReuseIdentifier = "EmptyBookmarkCellCaseReuseIdentifier"


class HashtagViewController: UIViewController {
    
    private let hashtag: String
    
    weak var postDelegate: DetailsPostViewControllerDelegate?
    weak var caseDelegate: DetailsCaseViewControllerDelegate?
    
    var lastCaseSnapshot: QueryDocumentSnapshot?
    var lastPostSnapshot: QueryDocumentSnapshot?
    
    private var caseLoaded = false
    private var postLoaded = false
    
    private var cases = [Case]()
    private var caseUsers = [User]()
    
    private var posts = [Post]()
    private var postUsers = [User]()
    
    private var hashtagToolbar = BookmarkToolbar()
    private var spacingView = SpacingView()
    private var isScrollingHorizontally = false
    private var didFetchPosts: Bool = false
    private var scrollIndex: Int = 0
    private var targetOffset: CGFloat = 0.0
    
    private var isFetchingMoreCases: Bool = false
    private var isFetchingMorePosts: Bool = false
    
    private let referenceMenuLauncher = ReferenceMenu()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .systemBackground
        scrollView.bounces = false
        return scrollView
    }()
    
    private var casesCollectionView: UICollectionView!
    private var postsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
        fetchCases()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        casesCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.frame.height)
        spacingView.frame = CGRect(x: view.frame.width, y: 0, width: 10, height: scrollView.frame.height)
        postsCollectionView.frame = CGRect(x: view.frame.width + 10, y: 0, width: view.frame.width, height: scrollView.frame.height)
    }

    init(hashtag: String) {
        self.hashtag = hashtag
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        navigationItem.title = hashtag.replacingOccurrences(of: "hash:", with: "#")
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        casesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createCaseLayout())
        postsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createPostLayout())
        
        view.addSubviews(hashtagToolbar, scrollView)
        
        NSLayoutConstraint.activate([
            hashtagToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hashtagToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hashtagToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hashtagToolbar.heightAnchor.constraint(equalToConstant: 50),
            
            scrollView.topAnchor.constraint(equalTo: hashtagToolbar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.delegate = self
        scrollView.addSubview(casesCollectionView)
        scrollView.addSubview(postsCollectionView)
        scrollView.addSubview(spacingView)
        scrollView.contentSize.width = view.frame.width * 2 + 10
        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        
        casesCollectionView.register(BookmarksCaseCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        casesCollectionView.register(BookmarksCaseImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        postsCollectionView.register(BookmarkPostCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        postsCollectionView.register(BookmarksPostImageCell.self, forCellWithReuseIdentifier: postImageCellReuseIdentifier)
        casesCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        postsCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        postsCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyHashtagCellReuseIdentifier)
        casesCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyHashtagCellReuseIdentifier)
        
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
        
        hashtagToolbar.toolbarDelegate = self
    }
    
    private func createCaseLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.caseLoaded {
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        
        return layout
    }
    
    private func createPostLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.postLoaded {
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        
        return layout
    }
    
    private func fetchCases() {
        CaseService.fetchCasesWithHashtag(hashtag.replacingOccurrences(of: "hash:", with: ""), lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                CaseService.fetchCases(snapshot: snapshot) { [weak self] cases in
                    guard let strongSelf = self else { return }
                    strongSelf.lastCaseSnapshot = snapshot.documents.last
                    strongSelf.cases = cases
                    
                    let ownerUids = cases.filter {$0.privacy == .regular }.map { $0.uid }
                    let uniqueUids = Array(Set(ownerUids))

                    guard !uniqueUids.isEmpty else {
                        strongSelf.caseLoaded = true
                        strongSelf.casesCollectionView.reloadData()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.caseUsers = users
                        strongSelf.caseLoaded = true
                        strongSelf.casesCollectionView.reloadData()
                    }
                }
            case .failure(let error):
                strongSelf.caseLoaded = true
                strongSelf.casesCollectionView.reloadData()
                
                guard error != .notFound else {
                    return
                }
                
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    private func fetchPosts() {
        didFetchPosts = true
        PostService.fetchPostsWithHashtag(hashtag.replacingOccurrences(of: "hash:", with: ""), lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):
                PostService.fetchHomePosts(snapshot: snapshot) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                        
                    case .success(let posts):
                        strongSelf.lastPostSnapshot = snapshot.documents.last
                        strongSelf.posts = posts
                        
                        let ownerUids = Array(Set(posts.map { $0.uid }))
                        
                        UserService.fetchUsers(withUids: ownerUids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.postUsers = users
                            strongSelf.postLoaded = true

                            strongSelf.postsCollectionView.reloadData()
                        }
                    case .failure(_):
                        break
                    }
                    
                }
            case .failure(let error):
                strongSelf.postLoaded = true
                strongSelf.postsCollectionView.reloadData()
                guard error != .notFound else {
                    return
                }
                
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                
            }
        }
    }
    
    private func fetchMoreCases() {
        guard !isFetchingMoreCases else { return }
        CaseService.fetchCasesWithHashtag(hashtag.replacingOccurrences(of: "hash:", with: ""), lastSnapshot: lastCaseSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                CaseService.fetchCases(snapshot: snapshot) { [weak self] newCases in
                    guard let strongSelf = self else { return }
                    strongSelf.lastCaseSnapshot = snapshot.documents.last
                    strongSelf.cases.append(contentsOf: newCases)
                    
                    let ownerUids = newCases.map { $0.uid }
                    let currentOwnerUids = strongSelf.caseUsers.map { $0.uid }
                    let newOwnerUids = ownerUids.filter { !currentOwnerUids.contains($0) }
                    
                    UserService.fetchUsers(withUids: newOwnerUids) { [weak self] newUsers in
                        guard let strongSelf = self else { return }
                        strongSelf.caseUsers.append(contentsOf: newUsers)
                        strongSelf.casesCollectionView.reloadData()
                        strongSelf.isFetchingMoreCases = false
                    }
                    
                }
            case .failure(let error):
                strongSelf.caseLoaded = true
                strongSelf.isFetchingMoreCases = false
                
                guard error != .notFound else {
                    return
                }
                
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    private func fetchMorePosts() {
        guard !isFetchingMorePosts else { return }
        PostService.fetchPostsWithHashtag(hashtag.replacingOccurrences(of: "hash:", with: ""), lastSnapshot: lastPostSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                PostService.fetchHomePosts(snapshot: snapshot) { [weak self] result in
                    guard let strongSelf = self else { return }
                    
                    switch result {
                    case .success(let newPosts):
                        strongSelf.lastPostSnapshot = snapshot.documents.last
                        strongSelf.posts.append(contentsOf: newPosts)
                        
                        let ownerUids = newPosts.map { $0.uid }
                        let currentOwnerUids = strongSelf.postUsers.map { $0.uid }
                        let newOwnerUids = ownerUids.filter { !currentOwnerUids.contains($0) }
                        
                        UserService.fetchUsers(withUids: newOwnerUids) { [weak self] newUsers in
                            guard let strongSelf = self else { return }
                            strongSelf.postUsers.append(contentsOf: newUsers)
                            strongSelf.postsCollectionView.reloadData()
                            strongSelf.isFetchingMorePosts = false
                        }
                    case .failure(_):
                        break
                    }
                    
                }
            case .failure(let error):
                print(error)
                strongSelf.postLoaded = true
                strongSelf.isFetchingMorePosts = false
                
                guard error != .notFound else {
                    return
                }
                
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
}

extension HashtagViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == casesCollectionView {
            if cases.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyHashtagCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell

                cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Case.Empty.emptyCaseTitle, description: AppStrings.Content.Case.Empty.hashtag(hashtag), content: .dismiss)
                cell.delegate = self
                return cell
            } else {
                let currentCase = cases[indexPath.row]
                switch currentCase.kind {
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! BookmarksCaseCell
                    cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                    cell.delegate = self
                    
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
                    cell.delegate = self
                    
                    guard currentCase.privacy != .anonymous else {
                        return cell
                    }
                    
                    if let user = caseUsers.first(where: { $0.uid! == currentCase.uid }) {
                        cell.set(user: user)
                    }
                    return cell
                }
                
            }
        } else {
            if posts.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyHashtagCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Post.Empty.emptyPostTitle, description: AppStrings.Content.Post.Empty.hashtag(hashtag), content: .dismiss)
                cell.delegate = self
                return cell
            } else {
                let currentPost = posts[indexPath.row]
                
                if currentPost.kind == .plainText {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextCellReuseIdentifier, for: indexPath) as! BookmarkPostCell
                    cell.delegate = self
                    cell.viewModel = PostViewModel(post: currentPost)
                    if let user = postUsers.first(where: { $0.uid! == currentPost.uid }) {
                        cell.set(user: user)
                    }
                    
                    return cell
                    
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postImageCellReuseIdentifier, for: indexPath) as! BookmarksPostImageCell
                    cell.delegate = self
                    cell.viewModel = PostViewModel(post: currentPost)
                    if let user = postUsers.first(where: { $0.uid! == currentPost.uid }) {
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
        
        if collectionView == casesCollectionView {
            if let user = caseUsers.first(where: { $0.uid! == cases[indexPath.row].uid }) {
                let controller = DetailsCaseViewController(clinicalCase: cases[indexPath.row], user: user, collectionViewFlowLayout: layout)
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


extension HashtagViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > view.frame.width {
            hashtagToolbar.test()
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
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee.x
        self.targetOffset = targetOffset
        if targetOffset == view.frame.width {
            let desiredOffset = CGPoint(x: targetOffset + 10, y: 0)
            scrollView.setContentOffset(desiredOffset, animated: true)
            targetContentOffset.pointee = scrollView.contentOffset
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y != 0 {
            isScrollingHorizontally = false
        }
        
        if scrollView.contentOffset.y == 0 && isScrollingHorizontally {
            hashtagToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
        }
        
        if scrollView.contentOffset.y == 0 && !isScrollingHorizontally {
            isScrollingHorizontally = true
            return
        }
        
        if scrollView.contentOffset.x > view.frame.width * 0.2 && !didFetchPosts {
            fetchPosts()
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
}

extension HashtagViewController: BookmarkToolbarDelegate {
    func didTapIndex(_ index: Int) {
        scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width) + index * 10, y: 0), animated: true)
    }
}


extension HashtagViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        navigationController?.popViewController(animated: true)
    }
}

extension HashtagViewController: DetailsPostViewControllerDelegate {
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
        
        postDelegate?.didDeleteComment(forPost: post)
    }
    
    func didEditPost(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex].postText = post.postText
            posts[postIndex].edited = true
            postsCollectionView.reloadData()
        }
        
        postDelegate?.didEditPost(forPost: post)
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
        
        postDelegate?.didTapLikeAction(forPost: post)
    }
    
    func didTapBookmarkAction(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            postsCollectionView.performBatchUpdates {
                posts.remove(at: postIndex)
                postsCollectionView.deleteItems(at: [IndexPath(item: postIndex, section: 0)])
            }
        }
        
        postDelegate?.didTapBookmarkAction(forPost: post)
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
        
        postDelegate?.didComment(forPost: post)
    }
}

extension HashtagViewController: DetailsCaseViewControllerDelegate {
    func didSolveCase(forCase clinicalCase: Case, with diagnosis: CaseRevisionKind?) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[caseIndex].phase = .solved
            if let diagnosis {
                cases[caseIndex].revision = diagnosis
            }

            casesCollectionView.reloadData()
        }
        
        caseDelegate?.didSolveCase(forCase: clinicalCase, with: diagnosis)
    }
    
    func didAddRevision(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[caseIndex].revision = clinicalCase.revision
            casesCollectionView.reloadData()
        }
        
        caseDelegate?.didAddRevision(forCase: clinicalCase)
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
        
        caseDelegate?.didDeleteComment(forCase: clinicalCase)
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
        
        caseDelegate?.didTapLikeAction(forCase: clinicalCase)
    }
    
    func didTapBookmarkAction(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            casesCollectionView.performBatchUpdates {
                cases.remove(at: caseIndex)
                casesCollectionView.deleteItems(at: [IndexPath(item: caseIndex, section: 0)])
            }
        }
        
        caseDelegate?.didTapBookmarkAction(forCase: clinicalCase)
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
        
        caseDelegate?.didComment(forCase: clinicalCase)
    }
}

extension HashtagViewController: BookmarksCellDelegate {
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
}

