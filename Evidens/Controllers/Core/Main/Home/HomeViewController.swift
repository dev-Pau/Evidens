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

protocol HomeViewControllerDelegate: AnyObject {
    func updateAlpha(alpha: CGFloat)
}

class HomeViewController: NavigationBarViewController, UINavigationControllerDelegate {
    
    //MARK: - Properties
    
    weak var scrollDelegate: HomeViewControllerDelegate?
    private let referenceMenu = ReferenceMenu()
    private let source: PostSource

    var user: User?
    
    private var loaded = false

    private var postsLastSnapshot: QueryDocumentSnapshot?
    private var postsFirstSnapshot: QueryDocumentSnapshot?
    
    private var postLastTimestamp: Int64?
    
    private var zoomTransitioning = ZoomTransitioning()
    private var selectedImage: UIImageView!
    
    private var collectionView: UICollectionView!
    
    var users = [User]()
    var posts = [Post]()
    
    private var likeDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var likePostValues: [IndexPath: Bool] = [:]
    private var likePostCount: [IndexPath: Int] = [:]
    
    private let activityIndicator = MEProgressHUD(frame: .zero)
    
    //MARK: - Lifecycle
    
    init(source: PostSource) {
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        if source == .search {
            self.navigationController?.delegate = self
        } else {
            self.navigationController?.delegate = zoomTransitioning
        }
        configureUI()
        configureNavigationItemButtons()
        fetchFirstPostsGroup()
    }
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loaded { collectionView.reloadData() }
        //navigationController?.navigationBar.transform = .init(translationX: 0, y: 0)
        //scrollDelegate?.updateAlpha(alpha: 1)
        //self.navigationController?.hidesBarsOnSwipe = true
    }
     */
    
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
            let view = MENavigationBarTitleView(fullName: name, category: AppStrings.Search.Topics.posts)
            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
            navigationItem.titleView = view
        }
    }

    //MARK: - Helpers
    func configureUI() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.isHidden = true
        collectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyPrimaryCellReuseIdentifier)
        collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        collectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        collectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        collectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        
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
            let view = MENavigationBarTitleView(fullName: name, category: AppStrings.Search.Topics.posts)
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
    
    #warning("pensar si fem fetch de tots un altre cop o no, suposo que si per si s'han actualitzat sisi...")
    private func checkIfUserHasNewPostsToDisplay() {
        PostService.checkIfUserHasNewerPostsToDisplay(snapshot: postsFirstSnapshot) { snapshot in
            if snapshot.isEmpty {
                // Fetch current posts again
                
                
                
                
                self.collectionView.refreshControl?.endRefreshing()
                //self.collectionView.reloadData()
            } else {
                PostService.fetchHomePosts(snapshot: snapshot) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let posts):
                        strongSelf.postsFirstSnapshot = snapshot.documents.last
                        strongSelf.posts.insert(contentsOf: posts, at: 0)
                        
                        let uids = posts.map { $0.uid }
                        let currentUids = strongSelf.users.map { $0.uid }
                        let newUids = uids.filter { !currentUids.contains($0) }
                        
                        UserService.fetchUsers(withUids: newUids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.users.append(contentsOf: users)

                            var newIndexPaths = [IndexPath]()
                            posts.enumerated().forEach { index, post in
                                newIndexPaths.append(IndexPath(item: index, section: 0))
                                if newIndexPaths.count == posts.count {
                                    strongSelf.collectionView.refreshControl?.endRefreshing()
                                    strongSelf.collectionView.isScrollEnabled = false
                                    strongSelf.collectionView.performBatchUpdates {
                                        strongSelf.collectionView.isScrollEnabled = false
                                        strongSelf.collectionView.insertItems(at: newIndexPaths)
                                    }
                                    
                                    DispatchQueue.main.async {
                                        strongSelf.collectionView.isScrollEnabled = true
                                    }
                                }
                            }
                        }
                    case .failure(_):
                        break
                    }
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
                                strongSelf.loaded = true
                                strongSelf.activityIndicator.stop()
                                strongSelf.collectionView.reloadData()
                                strongSelf.collectionView.isHidden = false
                            }
                        case .failure(let error):
                            guard error != .notFound else {
                                return
                            }
                            
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        }
                    }
                  
                case .failure(let error):
                    strongSelf.loaded = true
                    strongSelf.collectionView.refreshControl?.endRefreshing()
                    strongSelf.activityIndicator.stop()
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.isHidden = false

                    guard error != .notFound else {
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
                            strongSelf.loaded = true
                            strongSelf.activityIndicator.stop()
                            strongSelf.collectionView.reloadData()
                            strongSelf.collectionView.isHidden = false
                        case .failure(_):
                            break
                        }
                        
                    }
                case .failure(let error):
                    guard error != .unknown else {
                        return
                    }
                    
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        case .search:
            guard let user = user else { return }
            PostService.fetchSearchDocumentsForProfession(user: user, lastSnapshot: nil) { [weak self] result in
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
                            strongSelf.loaded = true
                            strongSelf.activityIndicator.stop()
                            strongSelf.collectionView.reloadData()
                            strongSelf.collectionView.isHidden = false
                        }
                    }
                case .failure(let error):
                    strongSelf.loaded = true
                    strongSelf.collectionView.refreshControl?.endRefreshing()
                    strongSelf.activityIndicator.stop()
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.isHidden = false
                    
                    guard error != .notFound else {
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
        return posts.isEmpty ? 1 : posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        if let indexPath = collectionView.indexPathForItem(at: point), let userIndex = users.firstIndex(where: { $0.uid! == posts[indexPath.item].uid }) {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 350)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let previewViewController = DetailsPostViewController(post: posts[indexPath.item], user: users[userIndex], type: .regular, collectionViewLayout: layout)
            let previewProvider: () -> DetailsPostViewController? = { previewViewController }
            return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { [weak self] _ in
                guard let strongSelf = self else { return nil }
                var children = [UIMenuElement]()
                
                let action1 = UIAction(title: PostMenu.report.title, image: PostMenu.report.image) { [weak self] _ in
                    guard let strongSelf = self else { return }
                    UIMenuController.shared.hideMenu(from: strongSelf.view)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        guard let strongSelf = self else { return }
                        let controller = ReportViewController(source: .post, contentOwnerUid: strongSelf.users[userIndex].uid!, contentId: strongSelf.posts[indexPath.item].postId)
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
    
    /*
    func handleLikeUnLike(for cell: UICollectionViewCell, at indexPath: IndexPath) {
        var currentCell = cell as! HomeTextCell
        #warning("fer lu del protocol del viewmodel")
        switch cell {
        case is HomeTextCell:
            currentCell = cell as! HomeTextCell
        case is HomeImageTextCell:
            currentCell = cell as! HomeTextCell
        case is HomeTwoImageTextCell:
            currentCell = cell as! HomeTwoImageTextCell
        case is HomeThreeImageTextCell:
            currentCell = cell as! HomeThreeImageTextCell
        case is HomeFourImageTextCell:
            currentCell = cell as! HomeFourImageTextCell
        default:
            return
        }
        
        let post = posts[indexPath.row]
        // Cancel the previous debounce timer for this post, if any
        if let debounceTimer = likeDebounceTimers[indexPath] {
            debounceTimer.cancel()
        }
        
        // Store the initial like state and count
        if likePostValues[indexPath] == nil {
            likePostValues[indexPath] = post.didLike
            likePostCount[indexPath] = post.likes
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            if post.didLike {
                PostService.unlikePost(post: post) { [weak self] _ in
                    guard let strongSelf = self else { return }
                    
                    // Revert to the previous like state and count if there's an error
                    guard let likeValue = strongSelf.likePostValues[indexPath], let countValue = strongSelf.likePostCount[indexPath] else { return }
                    
                    currentCell.viewModel?.post.didLike = likeValue
                    strongSelf.posts[indexPath.row].didLike = likeValue
                    
                    currentCell.viewModel?.post.likes = countValue
                    strongSelf.posts[indexPath.row].likes = countValue
                    
                    // Clean up the dictionaries
                    strongSelf.likePostValues[indexPath] = nil
                    strongSelf.likePostCount[indexPath] = nil
                }
            } else {
                PostService.likePost(post: post) { [weak self] _ in
                    guard let strongSelf = self else { return }
                    
                    // Revert to the previous like state and count if there's an error
                    guard let likeValue = strongSelf.likePostValues[indexPath], let countValue = strongSelf.likePostCount[indexPath] else { return }
                    
                    currentCell.viewModel?.post.didLike = likeValue
                    strongSelf.posts[indexPath.row].didLike = likeValue
                    
                    currentCell.viewModel?.post.likes = countValue
                    strongSelf.posts[indexPath.row].likes = countValue
                    
                    // Clean up the dictionaries
                    strongSelf.likePostValues[indexPath] = nil
                    strongSelf.likePostCount[indexPath] = nil
                }
            }
            
            // Clean up the debounce timer
            strongSelf.likeDebounceTimers[indexPath] = nil
        }
        
        // Save the debounce timer
        likeDebounceTimers[indexPath] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
        
        // Toggle the like state and count
        currentCell.viewModel?.post.didLike.toggle()
        self.posts[indexPath.row].didLike.toggle()
        currentCell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        self.posts[indexPath.row].likes -= post.didLike ? post.likes - 1 : post.likes + 1
    }
     */
}

//MARK: - HomeCellDelegate

extension HomeViewController: HomeCellDelegate {
    func cell(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        controller.postDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didTapMenuOptionsFor post: Post, option: PostMenu) {
        switch option {
        case .delete:
            #warning("Delete Post Logic Here")
        case .edit:
            
            let controller = EditPostViewController(post: post)
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
        case .report:
            let controller = ReportViewController(source: .post, contentOwnerUid: post.uid, contentId: post.postId)
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
        
        let controller = DetailsPostViewController(post: post, user: user, type: .regular, collectionViewLayout: layout)

        controller.delegate = self
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
        
        let controller = DetailsPostViewController(post: post, user: user, type: .regular, collectionViewLayout: layout)

        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell

            if let debounceTimer = likeDebounceTimers[indexPath] {
                debounceTimer.cancel()
            }
            
            if likePostValues[indexPath] == nil {
                likePostValues[indexPath] = post.didLike
                likePostCount[indexPath] = post.likes
            }
            
            let debounceTimer = DispatchWorkItem { [weak self] in
                guard let strongSelf = self else { return }

                if post.didLike {
                    PostService.unlikePost(post: post) { [weak self] error in
                        guard let strongSelf = self else { return }
                        
                        guard let likeValue = strongSelf.likePostValues[indexPath], let countValue = strongSelf.likePostCount[indexPath] else {
                            return
                        }
                        
                        if let _ = error {
                            currentCell.viewModel?.post.didLike = likeValue
                            strongSelf.posts[indexPath.row].didLike = likeValue
                            
                            currentCell.viewModel?.post.likes = countValue
                            strongSelf.posts[indexPath.row].likes = countValue
                        }
                        
                        strongSelf.likePostValues[indexPath] = nil
                        strongSelf.likePostCount[indexPath] = nil
                    }
                } else {
                    PostService.likePost(post: post) { [weak self] error in
                        guard let strongSelf = self else { return }
                        
                        guard let likeValue = strongSelf.likePostValues[indexPath], let countValue = strongSelf.likePostCount[indexPath] else {
                            return
                        }
                        
                        if let _ = error {
                            currentCell.viewModel?.post.didLike = likeValue
                            strongSelf.posts[indexPath.row].didLike = likeValue
                            
                            currentCell.viewModel?.post.likes = countValue
                            strongSelf.posts[indexPath.row].likes = countValue
                        }
                        
                        strongSelf.likePostValues[indexPath] = nil
                        strongSelf.likePostCount[indexPath] = nil
                    }
                }
                
                strongSelf.likeDebounceTimers[indexPath] = nil
            }
            
            likeDebounceTimers[indexPath] = debounceTimer
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
            
            currentCell.viewModel?.post.didLike.toggle()
            self.posts[indexPath.row].didLike.toggle()
            
            currentCell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
            self.posts[indexPath.row].likes -= post.didLike ? post.likes - 1 : post.likes + 1
            
            
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                    
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                }
            }
            
        default:
            break
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        if source == .user { return }
        let controller = UserProfileViewController(user: user)
       //displayState = displaysSinglePost ? .others : .none
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
        
    }
    
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor post: Post, forAuthor user: User) { return }
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                  
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                   
                    self.posts[indexPath.row].didBookmark = true
                }
            }
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                  
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                 
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                   
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                   
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                 
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                   
                    self.posts[indexPath.row].didBookmark = true
                }
            }

        default:
            break
        }
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
            guard let user = user else { return }
            PostService.fetchSearchDocumentsForProfession(user: user, lastSnapshot: postsLastSnapshot) { [weak self] result in
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

extension HomeViewController: DetailsPostViewControllerDelegate {
    func didDeleteComment(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex].numberOfComments -= 1
            
            switch post.kind {
            case .plainText:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithTwoImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeTwoImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithThreeImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeThreeImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithFourImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeFourImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
            }
        }
    }
    
    func didEditPost(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex] = post
            collectionView.reloadItems(at: [IndexPath(item: postIndex, section: 0)])
        }
    }
    
    func didTapLikeAction(forPost post: Post) {
        let index = posts.firstIndex { homePost in
            if homePost.postId == post.postId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                self.cell(cell, didLike: post)
            }
        }
    }
    
    func didTapBookmarkAction(forPost post: Post) {
        if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                self.cell(cell, didBookmark: post)
            }
        }
    }
    
    func didComment(forPost post: Post) {
        if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
            
            posts[index].numberOfComments += 1
            
            switch post.kind {
            case .plainText:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! HomeTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! HomeImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithTwoImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! HomeTwoImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithThreeImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! HomeThreeImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithFourImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! HomeFourImageTextCell
                cell.viewModel?.post.numberOfComments += 1
            }
        }
    }
}

extension HomeViewController: EditPostViewControllerDelegate {
    func didEditPost(post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex] = post
            collectionView.reloadItems(at: [IndexPath(item: postIndex, section: 0)])
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
                if let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
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

