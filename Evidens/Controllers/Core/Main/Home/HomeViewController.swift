//
//  FeedController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit
import Firebase

private let emptyPrimaryCellReuseIdentifier = "EmptyPrimaryCellReuseIdentifier"
private let reuseIdentifier = "HomeTextCellReuseIdentifier"
private let homeImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let homeTwoImageTextCellReuseIdentifier = "HomeTwoImageTextCellReuseIdentifier"
private let homeThreeImageTextCellReuseIdentifier = "HomeThreeImageTextCellReuseIdentifier"
private let homeFourImageTextCellReuseIdentifier = "HomeFourImageTextCellReuseIdentifier"
private let homeDocumentCellReuseIdentifier = "HomeDocumentCellReuseIdentifier"
private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"

protocol HomeViewControllerDelegate: AnyObject {
    func updateAlpha(alpha: CGFloat)
}

class HomeViewController: NavigationBarViewController, UINavigationControllerDelegate {
    
    //MARK: - Properties
    
    weak var scrollDelegate: HomeViewControllerDelegate?
    private let referenceMenu = ReferenceMenu()
    private let source: PostSource
    
    var user: User?
    var discipline: Discipline?
    
    private var loaded = false
    private var sections = 1

    private var postsLastSnapshot: QueryDocumentSnapshot?
    private var postsFirstSnapshot: QueryDocumentSnapshot?
    
    private var postLastTimestamp: Int64?
    
    private var currentNotification: Bool = false
    
    private var zoomTransitioning = ZoomTransitioning()
    private var selectedImage: UIImageView!
    
    private var collectionView: UICollectionView!
    
    var users = [User]()
    var posts = [Post]()
    
    private var lastRefreshTime: Date?
    
    private var isFetchingMorePosts: Bool = false
    
    private let activityIndicator = PrimaryLoadingView(frame: .zero)
    
    private var networkError: Bool = false
    
    //MARK: - Lifecycle
    
    init(source: PostSource) {
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureNotificationObservers()
        fetchFirstPostsGroup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch source {
            
        case .home:
            self.navigationController?.delegate = zoomTransitioning
        case .search:
            self.navigationController?.delegate = self
        }
    }
    
    //MARK: - Helpers
    
    func configure() {
        view.backgroundColor = .systemBackground

        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: createLayout())
        collectionView.isHidden = true
        collectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyPrimaryCellReuseIdentifier)
        collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        collectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        collectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        collectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        collectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self

        view.addSubviews(activityIndicator, collectionView)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
        ])
        
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    private func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.postLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postVisibleChange(_:)), name: NSNotification.Name(AppPublishers.Names.postVisibility), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.postBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.postComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postEditChange(_:)), name: NSNotification.Name(AppPublishers.Names.postEdit), object: nil)
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            
            guard let _ = self else { return nil }
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
            
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        
        return layout
    }
    
    //MARK: - Actions
    
    @objc func handleRefresh() {
        guard source == .home else { return }
        
        HapticsManager.shared.triggerLightImpact()
        
        if postsFirstSnapshot == nil {
            fetchFirstPostsGroup()
        } else {
            checkIfUserHasNewPostsToDisplay()
        }
    }
    
    private func checkIfUserHasNewPostsToDisplay() {
        let dispatchGroup = DispatchGroup()
        
        var currentPosts = [Post]()
        var newPosts = [Post]()
        
        var firstSnapshot: QueryDocumentSnapshot?
        var lastSnapshot: QueryDocumentSnapshot?
        
        let cooldownTime: TimeInterval = 20.0
        if let lastRefreshTime = lastRefreshTime, Date().timeIntervalSince(lastRefreshTime) < cooldownTime {
            // Cooldown time hasn't passed, return without performing the refresh
            self.collectionView.refreshControl?.endRefreshing()
            return
        }
        
        lastRefreshTime = Date()
        
        // Schedule a task to set lastRefreshTime to nil after 20 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + cooldownTime) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.lastRefreshTime = nil
        }
        
        PostService.checkIfUserHasNewerPostsToDisplay(snapshot: postsFirstSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):

                let newPostsToFetch = snapshot.documents.count
                let postsToReFetch = 10 - newPostsToFetch
                
                firstSnapshot = snapshot.documents.first
                
                let currentPostIds = strongSelf.posts.map { $0.postId }
               
                dispatchGroup.enter()
                
                // New posts to fetch
                PostService.fetchHomePosts(snapshot: snapshot) { [weak self] result in
                    guard let _ = self else { return }
                    switch result {
                    case .success(let posts):
                        newPosts = posts
                    case .failure(_):
                        return
                    }
                    
                    dispatchGroup.leave()
                }
                
                if postsToReFetch > 0 {
                    dispatchGroup.enter()
                    // Current posts to update
                    PostService.fetchPosts(withPostIds: currentPostIds) { [weak self] result in
                        guard let _ = self else { return }
                        switch result {
                        case .success(let posts):
                            currentPosts = posts
                            guard let lastPost = currentPosts.last else { return }
                            PostService.getSnapshotForLastPost(lastPost) { [weak self] result in
                                guard let _ = self else { return }
                                switch result {
                                case .success(let snapshot):
                                    lastSnapshot = snapshot.documents.last
                                case .failure(_):
                                    return
                                }
                            }
                        case .failure(_):
                            return
                        }
                        
                        dispatchGroup.leave()
                    }
                } else {
                    lastSnapshot = snapshot.documents.last
                }
            
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.posts = newPosts + currentPosts
                strongSelf.posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                
                let uids = Array(Set(strongSelf.posts.map { $0.uid } ))
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.postsFirstSnapshot = firstSnapshot
                    strongSelf.postsLastSnapshot = lastSnapshot
                    strongSelf.networkError = false
                    strongSelf.users = users
                    strongSelf.activityIndicator.stop()
                    strongSelf.collectionView.refreshControl?.endRefreshing()
                    strongSelf.collectionView.reloadData()
                }
            }
                
            case .failure(let error):
                if error == .network {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    guard error != .notFound else {
                        strongSelf.fetchFirstPostsGroup()
                        return
                    }
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        }
    }

    //MARK: - API

    func fetchFirstPostsGroup() {
        switch source {
        case .home:
            PostService.fetchHomeDocuments(lastSnapshot: nil) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):

                    PostService.fetchHomePosts(snapshot: snapshot) { [weak self] result in
                        guard let strongSelf = self else { return }
                        switch result {
                        case .success(let fetchedPosts):
                            guard let strongSelf = self else { return }
                            strongSelf.postsFirstSnapshot = snapshot.documents.first
                            strongSelf.postsLastSnapshot = snapshot.documents.last
                            strongSelf.posts = fetchedPosts
                            let uniqueUids = Array(Set(strongSelf.posts.map { $0.uid }))

                            UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                                guard let strongSelf = self else { return }
                                strongSelf.collectionView.refreshControl?.endRefreshing()
                                strongSelf.users = users
                                strongSelf.networkError = false
                                strongSelf.loaded = true
                                strongSelf.activityIndicator.stop()
                                strongSelf.collectionView.reloadData()
                                strongSelf.collectionView.isHidden = false
                            }
                        case .failure(let error):
                            strongSelf.collectionView.refreshControl?.endRefreshing()
                            guard error != .notFound else {
                                return
                            }
                            
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        }
                    }
                  
                case .failure(let error):
                    
                    if error == .network {
                        strongSelf.networkError = true
                    }
                    
                    if error == .notFound {
                        strongSelf.postsFirstSnapshot = nil
                        strongSelf.postsLastSnapshot = nil
                        strongSelf.posts.removeAll()
                        strongSelf.users.removeAll()
                    }
                    
                    strongSelf.loaded = true
                    strongSelf.collectionView.refreshControl?.endRefreshing()
                    strongSelf.activityIndicator.stop()
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.isHidden = false

                    guard error != .notFound, error != .network else {
                        return
                    }
                    
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }

        case .search:
            guard let discipline = discipline else { return }
            PostService.fetchSearchDocumentsForDiscipline(discipline: discipline, lastSnapshot: nil) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let snapshot):
                    strongSelf.postsLastSnapshot = snapshot.documents.last
                    strongSelf.posts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
                    
                    PostService.getPostValuesFor(posts: strongSelf.posts) { posts in
                        strongSelf.posts = posts
                        
                        let uids = Array(Set(posts.map { $0.uid }))
                        
                        UserService.fetchUsers(withUids: uids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.users = users
                            strongSelf.networkError = false
                            strongSelf.loaded = true
                            strongSelf.activityIndicator.stop()
                            strongSelf.collectionView.reloadData()
                            strongSelf.collectionView.isHidden = false
                        }
                    }
                case .failure(let error):

                    if error == .network {
                        strongSelf.networkError = true
                    }
                    strongSelf.loaded = true
                    strongSelf.collectionView.refreshControl?.endRefreshing()
                    strongSelf.activityIndicator.stop()
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.isHidden = false
                    
                    guard error != .notFound, error != .network else {
                        return
                    }
                    
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMorePosts()
        }
    }
}

//MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return networkError ? 1 : posts.isEmpty ? 1 : posts.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if networkError {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
            cell.delegate = self
            return cell
        } else {
            if posts.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyPrimaryCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                cell.set(withTitle: AppStrings.Content.Post.Feed.title, withDescription: AppStrings.Content.Post.Feed.content, withButtonText: AppStrings.Content.Post.Feed.start)
                cell.delegate = self
                return cell
            } else {
                let currentPost = posts[indexPath.row]
                let kind = currentPost.kind
                
                switch kind {
                    
                case .plainText:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTextCell
                    
                    cell.delegate = self
                    cell.postTextView.isSelectable = false
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                    if let user = user {
                        cell.set(user: user)
                    } else {
                        if let userIndex = users.firstIndex(where: { $0.uid == currentPost.uid }) {
                            cell.set(user: users[userIndex])
                        }
                    }
                    
                    return cell
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                    
                    cell.delegate = self
                    cell.postTextView.isSelectable = false
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                    if user != nil {
                        cell.set(user: user!)
                        
                    } else {
                        if let user = user {
                            cell.set(user: user)
                        } else {
                            if let userIndex = users.firstIndex(where: { $0.uid == currentPost.uid }) {
                                cell.set(user: users[userIndex])
                            }
                        }
                    }
                    
                    return cell
                case .textWithTwoImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                    cell.delegate = self
                    cell.postTextView.isSelectable = false
                   
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                    if let user = user {
                        cell.set(user: user)
                        
                    } else {
                        if let user = user {
                            cell.set(user: user)
                        } else {
                            if let userIndex = users.firstIndex(where: { $0.uid == currentPost.uid }) {
                                cell.set(user: users[userIndex])
                            }
                        }
                    }

                    return cell
                case .textWithThreeImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                    cell.delegate = self
                    cell.postTextView.isSelectable = false
                    
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                    if let user = user {
                        cell.set(user: user)
                    } else {
                        if let user = user {
                            cell.set(user: user)
                        } else {
                            if let userIndex = users.firstIndex(where: { $0.uid == currentPost.uid }) {
                                cell.set(user: users[userIndex])
                            }
                        }
                    }
                    
                    return cell
                case .textWithFourImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                    cell.delegate = self
                    cell.postTextView.isSelectable = false
                    
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                    if let user = user {
                        cell.set(user: user)
                    } else {
                        if let user = user {
                            cell.set(user: user)
                        } else {
                            if let userIndex = users.firstIndex(where: { $0.uid == currentPost.uid }) {
                                cell.set(user: users[userIndex])
                            }
                        }
                    }
                    
                    return cell
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        if let indexPath = collectionView.indexPathForItem(at: point), let userIndex = users.firstIndex(where: { $0.uid! == posts[indexPath.item].uid }) {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 350)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let post = posts[indexPath.item]
            
            let previewViewController = DetailsPostViewController(post: post, user: users[userIndex], collectionViewLayout: layout)
            previewViewController.previewingController = true
            let previewProvider: () -> DetailsPostViewController? = { previewViewController }
            return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { [weak self] _ in
                guard let strongSelf = self else { return nil }
                var children = [UIMenuElement]()

                if strongSelf.users[userIndex].isCurrentUser {

                    let deleteAction = UIAction(title: PostMenu.delete.title, image: PostMenu.delete.image, attributes: .destructive) { [weak self] _ in
                        guard let strongSelf = self else { return }
                        
                        strongSelf.deletePost(withId: post.postId, at: indexPath)
                    }
                    
                    let editAction = UIAction(title: PostMenu.edit.title, image: PostMenu.edit.image) { [weak self] _ in
                        guard let _ = self else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                            guard let strongSelf = self else { return }
                            let controller = EditPostViewController(post: strongSelf.posts[indexPath.item])
                            let nav = UINavigationController(rootViewController: controller)
                            nav.modalPresentationStyle = .fullScreen
                            strongSelf.present(nav, animated: true)
                        }
                    }

                    children.append(deleteAction)
                    children.append(editAction)

                } else {
                    let reportAction = UIAction(title: PostMenu.report.title, image: PostMenu.report.image) { [weak self] _ in
                        guard let strongSelf = self else { return }
                        UIMenuController.shared.hideMenu(from: strongSelf.view)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                            guard let strongSelf = self else { return }
                            let controller = ReportViewController(source: .post, contentUid: strongSelf.users[userIndex].uid!, contentId: strongSelf.posts[indexPath.item].postId)
                            let navVC = UINavigationController(rootViewController: controller)
                            navVC.modalPresentationStyle = .fullScreen
                            strongSelf.present(navVC, animated: true)
                        }
                    }
                    
                    children.append(reportAction)
                }
                
                if let reference = strongSelf.posts[indexPath.row].reference {
                    let action2 = UIAction(title: PostMenu.reference.title, image: PostMenu.reference.image) { [weak self] _ in
                        guard let _ = self else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.referenceMenu.delegate = self
                            strongSelf.referenceMenu.showImageSettings(in: strongSelf.view, forPostId: strongSelf.posts[indexPath.row].postId, forReferenceKind: reference)
                        }
                    }
                    
                    children.append(action2)
                }

                return UIMenu(children: children)
            }

        }
        
        return nil
    }
    
    private func deletePost(withId id: String, at indexPath: IndexPath) {

        displayAlert(withTitle: AppStrings.Alerts.Title.deletePost, withMessage: AppStrings.Alerts.Subtitle.deletePost, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let _ = self else { return }
            
            PostService.deletePost(withId: id) { [weak self] error in

                guard let strongSelf = self else { return }
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.postDidChangeVisible(postId: id)
                    
                    strongSelf.posts.remove(at: indexPath.item)
                    if strongSelf.posts.isEmpty {
                        strongSelf.collectionView.reloadData()
                    } else {
                        strongSelf.collectionView.deleteItems(at: [indexPath])
                    }
                }
            }
        }
    }
    
    private func handleLikeUnLike(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        let postId = post.postId
        let didLike = posts[indexPath.row].didLike
        
        postDidChangeLike(postId: postId, didLike: didLike)

        // Toggle the like state and count
        cell.viewModel?.post.didLike.toggle()
        self.posts[indexPath.row].didLike.toggle()
        
        cell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        self.posts[indexPath.row].likes = post.didLike ? post.likes - 1 : post.likes + 1
        
    }
    
    func handleBookmarkUnbookmark(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        let postId = post.postId
        let didBookmark = posts[indexPath.row].didBookmark
        
        postDidChangeBookmark(postId: postId, didBookmark: didBookmark)
        
        // Toggle the bookmark state
        cell.viewModel?.post.didBookmark.toggle()
        self.posts[indexPath.row].didBookmark.toggle()
        
    }
    
    private func showBottomSpinner() {
        isFetchingMorePosts = true
    }
    
    private func hideBottomSpinner() {
        isFetchingMorePosts = false
    }
}

//MARK: - HomeCellDelegate

extension HomeViewController: HomeCellDelegate {
    func cell(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(didTapMenuOptionsFor post: Post, option: PostMenu) {
        switch option {
        case .delete:
            if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                deletePost(withId: post.postId, at: IndexPath(item: index, section: 0))
            }
        case .edit:
            let controller = EditPostViewController(post: post)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
        case .report:
            let controller = ReportViewController(source: .post, contentUid: post.uid, contentId: post.postId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
            
        case .reference:
            guard let reference = post.reference else { return }
            referenceMenu.showImageSettings(in: view, forPostId: post.postId, forReferenceKind: reference)
            referenceMenu.delegate = self
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.navigationController?.delegate = self
        
        let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        
        switch source {
            
        case .home:
            break
        case .search:
            self.navigationController?.delegate = zoomTransitioning
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
        let controller = LikesViewController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.navigationController?.delegate = self
        
        let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
    
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
        handleBookmarkUnbookmark(for: currentCell, at: indexPath)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        self.navigationController?.delegate = self
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func scrollCollectionViewToTop() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

extension HomeViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension HomeViewController {
    func getMorePosts() {

        guard !isFetchingMorePosts, !posts.isEmpty else {
            return
        }
        
        showBottomSpinner()

        switch source {
        case .home:
            PostService.fetchHomeDocuments(lastSnapshot: postsLastSnapshot) { [weak self] result in
                guard let strongSelf = self else { return }

                switch result {
                case .success(let snapshot):
                    PostService.fetchHomePosts(snapshot: snapshot) { [weak self] result in
                        guard let strongSelf = self else { return }
                        
                        switch result {
                        case .success(let newPosts):
                            guard let strongSelf = self else { return }
                            strongSelf.postsLastSnapshot = snapshot.documents.last
                            
                            strongSelf.posts.append(contentsOf: newPosts)
                            
                            let uids = newPosts.map { $0.uid }
                            let currentUids = strongSelf.users.map { $0.uid }
                            let newUids = uids.filter { !currentUids.contains($0) }
                            
                            if newUids.isEmpty {
                                strongSelf.networkError = false
                                strongSelf.collectionView.reloadData()
                                strongSelf.hideBottomSpinner()
                                return
                            }
                            
                            UserService.fetchUsers(withUids: newUids) { [weak self] users in
                                guard let strongSelf = self else { return }
                                strongSelf.networkError = false
                                strongSelf.users.append(contentsOf: users)
                                strongSelf.collectionView.reloadData()
                                strongSelf.hideBottomSpinner()
                            }
                        case .failure(_):
                            strongSelf.hideBottomSpinner()
                        }
                    }
                case .failure(_):
                    strongSelf.hideBottomSpinner()
                }
            }
        
        case .search:
            guard let discipline = discipline else { return }
            PostService.fetchSearchDocumentsForDiscipline(discipline: discipline, lastSnapshot: postsLastSnapshot) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let snapshot):
                    let newPosts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
                    
                    PostService.getPostValuesFor(posts: newPosts) { [weak self] posts in
                        guard let strongSelf = self else { return }
                        strongSelf.posts.append(contentsOf: newPosts)
                        let uids = newPosts.map { $0.uid }
                        let currentUids = strongSelf.users.map { $0.uid }
                        let uniqueUids = uids.filter { !currentUids.contains($0) }
                        
                        UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.networkError = false
                            strongSelf.users.append(contentsOf: users)
                            strongSelf.collectionView.reloadData()
                            strongSelf.hideBottomSpinner()
                        }
                        
                    }
                case .failure(_):
                    strongSelf.hideBottomSpinner()
                }
            }
        }
    }
}

extension HomeViewController: PrimaryEmptyCellDelegate {
    func didTapEmptyAction() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let controller = HomeOnboardingViewController(user: user)
        controller.delegate = self
       
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension HomeViewController: HomeOnboardingViewControllerDelegate {
    func didUpdateUser(user: User) {
        guard let tab = tabBarController as? MainTabController else { return }
        tab.user = user
    }
}

extension HomeViewController: ReferenceMenuDelegate {
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

extension HomeViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        networkError = false
        activityIndicator.start()
        collectionView.isHidden = true
        fetchFirstPostsGroup()
        
    }
}

//MARK: - PostChangesDelegate

extension HomeViewController: PostChangesDelegate {
    func postDidChangeComment(postId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }
    
    func postDidChangeVisible(postId: String) {
        currentNotification = true
        ContentManager.shared.visiblePostChange(postId: postId)
    }
    
    @objc func postVisibleChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostVisibleChange {
            if let index = posts.firstIndex(where: { $0.postId == change.postId }) {
                posts.remove(at: index)
                if posts.isEmpty {
                    collectionView.reloadData()
                } else {
                    collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
    }
    
    func postDidChangeComment(postId: String, comment: Comment, action: CommentAction) {
        fatalError()
    }
    
    func postDidChangeBookmark(postId: String, didBookmark: Bool) {
        currentNotification = true
        ContentManager.shared.bookmarkPostChange(postId: postId, didBookmark: !didBookmark)
    }
    
    func postDidChangeLike(postId: String, didLike: Bool) {
        currentNotification = true
        ContentManager.shared.likePostChange(postId: postId, didLike: !didLike)
    }
    
    @objc func postBookmarkChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostBookmarkChange {
            if let index = posts.firstIndex(where: { $0.postId == change.postId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? HomeCellProtocol {
                    self.posts[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.post.didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func postLikeChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostLikeChange {
            if let index = posts.firstIndex(where: { $0.postId == change.postId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? HomeCellProtocol {
                    
                    let likes = self.posts[index].likes
                    
                    self.posts[index].likes = change.didLike ? likes + 1 : likes - 1
                    self.posts[index].didLike = change.didLike
                    
                    currentCell.viewModel?.post.didLike = change.didLike
                    currentCell.viewModel?.post.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? PostCommentChange {
            if let index = posts.firstIndex(where: { $0.postId == change.postId }), change.path.isEmpty {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? HomeCellProtocol {
                    
                    let comments = self.posts[index].numberOfComments
                    
                    switch change.action {
                    case .add:
                        self.posts[index].numberOfComments = comments + 1
                        currentCell.viewModel?.post.numberOfComments = comments + 1
                    case .remove:
                        self.posts[index].numberOfComments = comments - 1
                        currentCell.viewModel?.post.numberOfComments = comments - 1
                    }
                }
            }
        }
    }
    
    @objc func postEditChange(_ notification: NSNotification) {
        if let change = notification.object as? PostEditChange {
            let post = change.post
            if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                posts[index] = post
                collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }
}

// MARK: - User Changes

extension HomeViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            if let index = users.firstIndex(where: { $0.uid! == user.uid! }) {
                users[index] = user
                collectionView.reloadData()
            }
            
            if let currentUser = self.user, currentUser.isCurrentUser {
                self.user = user
                collectionView.reloadData()
            }
        }
    }
}


    
