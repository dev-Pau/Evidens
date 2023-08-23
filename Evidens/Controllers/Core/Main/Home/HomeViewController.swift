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
        configureNavigationItemButtons()
        fetchFirstPostsGroup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if source == .search {
            self.navigationController?.delegate = self
        } else {
            self.navigationController?.delegate = zoomTransitioning
        }
        
        if source == .user {
            guard let user = user else { return }
            let name = user.name()
            let view = CompoundNavigationBar(fullName: name, category: AppStrings.Search.Topics.posts)
            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
            navigationItem.titleView = view
        }
    }
    
    //MARK: - Helpers
    func configure() {
        
        view.backgroundColor = .systemBackground
        if source == .search {
            self.navigationController?.delegate = self
        } else {
            self.navigationController?.delegate = zoomTransitioning
        }
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.isHidden = true
        collectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyPrimaryCellReuseIdentifier)
        collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        collectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        collectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        collectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        collectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self

        view.addSubviews(activityIndicator, collectionView)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
        ])
        
        if source != .user {
            let refresher = UIRefreshControl()
            refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
            collectionView.refreshControl = refresher
        }
    }
    
    private func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("UserUpdateIdentifier"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.postLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.postBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.postComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postEditChange(_:)), name: NSNotification.Name(AppPublishers.Names.postEdit), object: nil)
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let _ = self else { return nil }
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        
        return layout
    }
    
    func configureNavigationItemButtons() {
        if source == .user {
            guard let user = user else { return }
            let name = user.name()
            let view = CompoundNavigationBar(fullName: name, category: AppStrings.Search.Topics.posts)
            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
            navigationItem.titleView = view
            let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.leftChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.systemBackground).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
            navigationItem.rightBarButtonItem = rightBarButtonItem
        }
    }
    
    //MARK: - Actions
    
    @objc func handleRefresh() {
        guard source == .home else { return }
        HapticsManager.shared.vibrate(for: .success)
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
 
        case .user:
            guard let uid = user?.uid else { return }
            DatabaseManager.shared.fetchHomeFeedPosts(lastTimestampValue: nil, forUid: uid) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let postIds):
                    guard !postIds.isEmpty else {
                        strongSelf.loaded = true
                        strongSelf.activityIndicator.stop()
                        strongSelf.collectionView.reloadData()
                        strongSelf.collectionView.isHidden = false
                        return
                    }
                    
                    PostService.fetchPosts(withPostIds: postIds) { [weak self] result in
                        guard let strongSelf = self else { return }
                        switch result {
                            
                        case .success(let posts):
                            strongSelf.posts = posts
                            strongSelf.postLastTimestamp = strongSelf.posts.last?.timestamp.seconds
                            strongSelf.networkError = false
                            strongSelf.loaded = true
                            strongSelf.activityIndicator.stop()
                            strongSelf.collectionView.reloadData()
                            strongSelf.collectionView.isHidden = false
                        case .failure(_):
                            break
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
                    
                    guard error != .empty, error != .network else {
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
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return networkError ? 1 : posts.isEmpty ? 1 : posts.count
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        if let indexPath = collectionView.indexPathForItem(at: point), let userIndex = users.firstIndex(where: { $0.uid! == posts[indexPath.item].uid }) {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 350)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let previewViewController = DetailsPostViewController(post: posts[indexPath.item], user: users[userIndex], collectionViewLayout: layout)
            let previewProvider: () -> DetailsPostViewController? = { previewViewController }
            return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { [weak self] _ in
                guard let strongSelf = self else { return nil }
                var children = [UIMenuElement]()
                
                let action1 = UIAction(title: PostMenu.report.title, image: PostMenu.report.image) { [weak self] _ in
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
                
                children.append(action1)
                
                if let reference = strongSelf.posts[indexPath.row].reference {
                    let action2 = UIAction(title: PostMenu.reference.title, image: PostMenu.reference.image, handler: { [weak self] _ in
                        guard let strongSelf = self else { return }
                        strongSelf.referenceMenu.delegate = self
                        strongSelf.referenceMenu.showImageSettings(in: strongSelf.view, forPostId: strongSelf.posts[indexPath.row].postId, forReferenceKind: reference)
                    })
                    
                    children.append(action2)
                }

                return UIMenu(children: children)
            }
        }
        
        return nil
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
}

//MARK: - HomeCellDelegate

extension HomeViewController: HomeCellDelegate {
    func cell(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didTapMenuOptionsFor post: Post, option: PostMenu) {
        switch option {
        case .delete:
            #warning("Delete Post Logic Here")
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
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 350)
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
        if source == .search { self.navigationController?.delegate = zoomTransitioning }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
        let controller = LikesViewController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 350)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.navigationController?.delegate = self
        
        let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
    
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        
        handleBookmarkUnbookmark(for: currentCell, at: indexPath)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        if source == .user { return }
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
        switch source {
        case .home:
            PostService.fetchHomeDocuments(lastSnapshot: postsLastSnapshot) { [weak self] result in
                guard let _ = self else { return }

                switch result {
                case .success(let snapshot):
                    PostService.fetchHomePosts(snapshot: snapshot) { [weak self] result in
                        guard let _ = self else { return }
                        
                        switch result {
                        case .success(let newPosts):
                            guard let strongSelf = self else { return }
                            strongSelf.postsLastSnapshot = snapshot.documents.last
                            
                            strongSelf.posts.append(contentsOf: newPosts)
                            
                            let uids = newPosts.map { $0.uid }
                            let currentUids = strongSelf.users.map { $0.uid }
                            let newUids = uids.filter { !currentUids.contains($0)}
                            
                            UserService.fetchUsers(withUids: newUids) { [weak self] users in
                                guard let strongSelf = self else { return }
                                strongSelf.networkError = false
                                strongSelf.users.append(contentsOf: users)
                                strongSelf.collectionView.reloadData()
                            }
                        case .failure(_):
                            break
                        }
                    }
                case .failure(_):
                    break
                }
            }
        case .user:
            guard let uid = user?.uid else { return }
            DatabaseManager.shared.fetchHomeFeedPosts(lastTimestampValue: postLastTimestamp, forUid: uid) { [weak self] result in
                guard let _ = self else { return }
                switch result {
                case .success(let postIds):
                    guard !postIds.isEmpty else { return }
                    PostService.fetchPosts(withPostIds: postIds) { [weak self] result in
                        guard let strongSelf = self else { return }
                        switch result {
                        case .success(let newPosts):
                            strongSelf.networkError = false
                            strongSelf.posts.append(contentsOf: newPosts)
                            strongSelf.postLastTimestamp = strongSelf.posts.last?.timestamp.seconds
                            strongSelf.collectionView.reloadData()
                        case .failure(_):
                            break
                        } 
                    }
                case .failure(_):
                    break
                }
            }
        case .search:
            guard let discipline = discipline else { return }
            PostService.fetchSearchDocumentsForDiscipline(discipline: discipline, lastSnapshot: postsLastSnapshot) { [weak self] result in
                guard let _ = self else { return }
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
                        }
                        
                    }
                case .failure(_):
                    break
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
            if let index = posts.firstIndex(where: { $0.postId == change.postId }) {
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
    
