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
    private let referenceMenuLauncher = MEReferenceMenuLauncher()
    private let contentSource: Post.ContentSource

    var user: User?
    
    private var loaded = false

    var displaysSinglePost: Bool = false
    private var displayState: DisplayState = .none
    
    private var postsLastSnapshot: QueryDocumentSnapshot?
    private var postsFirstSnapshot: QueryDocumentSnapshot?
    
    private var postLastTimestamp: Int64?
    
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
    
    private var collectionView: UICollectionView!
    
    var users = [User]()
    var posts = [Post]()
    
    private let activityIndicator = MEProgressHUD(frame: .zero)
    //MARK: - Lifecycle
    
    init(contentSource: Post.ContentSource) {
        self.contentSource = contentSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        if contentSource == .search {
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
        if contentSource == .search {
            self.navigationController?.delegate = self
        } else {
            self.navigationController?.delegate = zoomTransitioning
        }

        if displaysSinglePost {
            switch displayState {
            case .none:
                break
            case .photo:
                break
            case .others:
                if contentSource == .search { return }
                guard let firstName = user?.firstName, let lastName = user?.lastName else { return }
                let view = MENavigationBarTitleView(fullName: firstName + " " + lastName, category: "Posts")
                view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
                navigationItem.titleView = view
            }
        }
    }

    //MARK: - Helpers
    func configureUI() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        // Configure UICollectionView
        collectionView.isHidden = true
        //collectionView.register(OnboardingHomeHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: helperHeaderReuseIdentifier)
        collectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyPrimaryCellReuseIdentifier)
        //collectionView.register(OnboardingHomeCell.self, forCellWithReuseIdentifier: helperCellReuseIdentifier)
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
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
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
        if displaysSinglePost {
            if contentSource == .search { return }
            guard let firstName = user?.firstName, let lastName = user?.lastName else { return }
            let view = MENavigationBarTitleView(fullName: firstName + " " + lastName, category: "Posts")
            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
            navigationItem.titleView = view
            let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.systemBackground).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
            
            navigationItem.rightBarButtonItem = rightBarButtonItem
        }
    }
    
    //MARK: - Actions
    
    @objc func handleRefresh() {
        if displaysSinglePost { return }
        HapticsManager.shared.vibrate(for: .success)
        if postsFirstSnapshot == nil {
            fetchFirstPostsGroup()
        } else {
            checkIfUserHasNewPostsToDisplay()
        }
    }
    
    private func checkIfUserHasNewPostsToDisplay() {
        PostService.checkIfUserHasNewerPostsToDisplay(snapshot: postsFirstSnapshot) { snapshot in
            if snapshot.isEmpty {
                // Fetch current posts again
                
                
                
                
                self.collectionView.refreshControl?.endRefreshing()
                //self.collectionView.reloadData()
            } else {
                self.postsFirstSnapshot = snapshot.documents.last
                PostService.fetchHomePosts(snapshot: snapshot, completion: { posts in
                    self.posts.insert(contentsOf: posts, at: 0)
                    UserService.fetchUsers(withUids: posts.map({ $0.ownerUid })) { users in
                        self.users.append(contentsOf: users)

                        var newIndexPaths = [IndexPath]()
                        posts.enumerated().forEach { index, post in
                            newIndexPaths.append(IndexPath(item: index, section: 0))
                            if newIndexPaths.count == posts.count {
                                self.collectionView.refreshControl?.endRefreshing()
                                self.collectionView.isScrollEnabled = false
                                self.collectionView.performBatchUpdates {
                                    self.collectionView.isScrollEnabled = false
                                    self.collectionView.insertItems(at: newIndexPaths)
                                    
                                }
                                
                                DispatchQueue.main.async {
                                    self.collectionView.isScrollEnabled = true
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    //MARK: - API

    func fetchFirstPostsGroup() {
        switch contentSource {
        case .home:
            PostService.fetchHomeDocuments(lastSnapshot: nil) { snapshot in
                // User does not have any type of content to display in home
                if snapshot.isEmpty {
                    self.loaded = true
                    self.collectionView.refreshControl?.endRefreshing()
                    self.activityIndicator.stop()
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                }
                
                PostService.fetchHomePosts(snapshot: snapshot) { fetchedPosts in
                    self.postsFirstSnapshot = snapshot.documents.first
                    self.postsLastSnapshot = snapshot.documents.last
                    self.posts = fetchedPosts
                    //self.checkIfUserLikedPosts()
                    //self.checkIfUserBookmarkedPost()

                    UserService.fetchUsers(withUids: self.posts.map({ $0.ownerUid })) { users in
                        print("got more data completed")
                        self.collectionView.refreshControl?.endRefreshing()
                        self.users = users
                        self.loaded = true
                        self.activityIndicator.stop()
                        self.collectionView.reloadData()
                        self.collectionView.isHidden = false
                    }
                }
            }
 
        case .user:
            guard let uid = user?.uid else { return }
            DatabaseManager.shared.fetchHomeFeedPosts(lastTimestampValue: nil, forUid: uid) { result in
                switch result {
                case .success(let postIds):
                    guard !postIds.isEmpty else {
                        self.loaded = true
                        self.activityIndicator.stop()
                        self.collectionView.reloadData()
                        self.collectionView.isHidden = false
                        return
                    }
                    
                    PostService.fetchPosts(withPostIds: postIds) { posts in
                        self.posts = posts
                        self.postLastTimestamp = self.posts.last?.timestamp.seconds
                        self.loaded = true
                        self.activityIndicator.stop()
                        self.collectionView.reloadData()
                        self.collectionView.isHidden = false
                    }
                case .failure(let error):
                    print(error)
                }
            }
        case .search:
            guard let user = user else { return }
            PostService.fetchSearchDocumentsForProfession(user: user, lastSnapshot: nil) { snapshot in
                if snapshot.isEmpty {
                    self.loaded = true
                    self.activityIndicator.stop()
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                } else {
                    self.postsLastSnapshot = snapshot.documents.last
                    self.posts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
                    
                    PostService.getPostValuesFor(posts: self.posts) { posts in
                        self.posts = posts
                        UserService.fetchUsers(withUids: self.posts.map({ $0.ownerUid })) { users in
                            self.users = users
                            self.loaded = true
                            self.activityIndicator.stop()
                            self.collectionView.reloadData()
                            self.collectionView.isHidden = false
                        }
                    }
                }
            }
        }
        
        /*
        if !displaysSinglePost {
            PostService.fetchHomeDocuments(lastSnapshot: nil) { snapshot in
                PostService.fetchHomePosts(snapshot: snapshot) { fetchedPosts in
                    self.postsLastSnapshot = snapshot.documents.last
                    self.posts = fetchedPosts
                    self.checkIfUserLikedPosts()
                    self.checkIfUserBookmarkedPost()
                    self.collectionView.refreshControl?.endRefreshing()
                    self.posts.forEach { post in
                        UserService.fetchUser(withUid: post.ownerUid) { user in
                            self.users.append(user)
                            self.loaded = true
                            self.activityIndicator.stop()
                            self.collectionView.reloadData()
                            self.collectionView.isHidden = false
                        }
                    }
                }
            } 
        } else {
            guard let uid = user?.uid else { return }
            DatabaseManager.shared.fetchHomeFeedPosts(lastTimestampValue: nil, forUid: uid) { result in
                switch result {
                case .success(let uids):
                    uids.forEach { uid in
                        PostService.fetchPost(withPostId: uid) { fetchedPosts in
                            self.posts.append(fetchedPosts)
                            self.posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                            // Get the last timestamp to create next query for realtime database
                            self.postLastTimestamp = self.posts.last?.timestamp.seconds
                            self.checkIfUserLikedPosts()
                            self.checkIfUserBookmarkedPost()
                            self.activityIndicator.stop()
                            self.loaded = true
                            self.collectionView.isHidden = false
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
         */
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
    
    
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let safeAreaTop = topbarHeight
        let offset = scrollView.contentOffset.y + safeAreaTop
        
  
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        print(translation.y)
        if translation.y > 0 {
            // from top to bottom
            navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -topbarHeight/*min(-topbarHeight, translation.y)*/))
        } else {
            // from bottom to top
            navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, max(-topbarHeight / 2.5, translation.y)))
        }
        
        //navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, max(-topbarHeight / 2.5, -offset)))
        let alpha = 1 - ((scrollView.contentOffset.y + safeAreaTop) / safeAreaTop) * 5
        //scrollDelegate?.updateAlpha(alpha: alpha)
        
    }
     */
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyPrimaryCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
            cell.set(withImage: UIImage(named: "home.empty")!, withTitle: "Welcome to your timeline.", withDescription: "It's empty now, but it won't be for long. Start following people and you'll see all their content show up here.", withButtonText: "    Get started    ")
            cell.delegate = self
            return cell
        } else {
            
            if posts[indexPath.row].type.postType == 0 {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTextCell
                
                cell.delegate = self
                cell.postTextView.isSelectable = false
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
                
                if user != nil {
                    cell.set(user: user!)
                    
                } else {
                    let userIndex = users.firstIndex { user in
                        if user.uid == posts[indexPath.row].ownerUid {
                            return true
                        }
                        return false
                    }
                    
                    if let userIndex = userIndex {
                        cell.set(user: users[userIndex])
                    }
                }
                
                cell.layoutIfNeeded()
                return cell
                
            } else if posts[indexPath.row].type.postType == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                cell.delegate = self
                cell.postTextView.isSelectable = false
                cell.layer.borderWidth = 0
                cell.layoutIfNeeded()
                
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
                
                if user != nil {
                    cell.set(user: user!)
                    
                } else {
                    let userIndex = users.firstIndex { user in
                        if user.uid == posts[indexPath.row].ownerUid {
                            return true
                        }
                        return false
                    }
                    
                    if let userIndex = userIndex {
                        cell.set(user: users[userIndex])
                    }
                }
                
                cell.layoutIfNeeded()
                return cell
                
            } else if posts[indexPath.row].type.postType == 2 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                cell.delegate = self
                cell.postTextView.isSelectable = false
                cell.layer.borderWidth = 0
                
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
                
                if user != nil {
                    cell.set(user: user!)
                    
                } else {
                    let userIndex = users.firstIndex { user in
                        if user.uid == posts[indexPath.row].ownerUid {
                            return true
                        }
                        return false
                    }
                    
                    if let userIndex = userIndex {
                        cell.set(user: users[userIndex])
                    }
                }
                
                cell.layoutIfNeeded()
                return cell
                
            } else if posts[indexPath.row].type.postType == 3 {
                //print("post type 1")
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                cell.delegate = self
                cell.layer.borderWidth = 0
                cell.postTextView.isSelectable = false
                
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
                
                let userIndex = users.firstIndex { user in
                    if user.uid == posts[indexPath.row].ownerUid {
                        return true
                    }
                    return false
                }
                
                if let userIndex = userIndex {
                    cell.set(user: users[userIndex])
                }
                
                cell.layoutIfNeeded()
                
                return cell
                
            } else if posts[indexPath.row].type.postType == 4 {
                //print("post type 1")
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                cell.delegate = self
                cell.layer.borderWidth = 0
                cell.postTextView.isSelectable = false
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
                
                let userIndex = users.firstIndex { user in
                    if user.uid == posts[indexPath.row].ownerUid {
                        return true
                    }
                    return false
                }
                
                if let userIndex = userIndex {
                    cell.set(user: users[userIndex])
                }
                
                cell.layoutIfNeeded()
                
                return cell
                
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                cell.delegate = self
                cell.layer.borderWidth = 0
                cell.postTextView.isSelectable = false
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
                let userIndex = users.firstIndex { user in
                    if user.uid == posts[indexPath.row].ownerUid {
                        return true
                    }
                    return false
                }
                
                if let userIndex = userIndex {
                    cell.set(user: users[userIndex])
                }
                
                cell.layoutIfNeeded()
                
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        if let indexPath = collectionView.indexPathForItem(at: point), let userIndex = users.firstIndex(where: { $0.uid! == posts[indexPath.item].ownerUid }) {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 350)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let previewViewController = DetailsPostViewController(post: posts[indexPath.item], user: users[userIndex], type: .regular, collectionViewLayout: layout)
            let previewProvider: () -> DetailsPostViewController? = { previewViewController }
            return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { _ in
                
                var children = [UIMenuElement]()
                
                let action1 = UIAction(title: Post.PostMenuOptions.report.rawValue, image: Post.PostMenuOptions.report.menuOptionsImage) { action in
                    UIMenuController.shared.hideMenu(from: self.view)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let controller = ReportViewController(source: .post, contentOwnerUid: self.users[userIndex].uid!, contentId: self.posts[indexPath.item].postId)
                        let navVC = UINavigationController(rootViewController: controller)
                        navVC.modalPresentationStyle = .fullScreen
                        self.present(navVC, animated: true)
                    }
                }
                
                children.append(action1)
                
                if self.posts[indexPath.item].reference != nil {
                    let action2 = UIAction(title: Post.PostMenuOptions.reference.rawValue, image: Post.PostMenuOptions.reference.menuOptionsImage, handler: { (_) in
                        let reference = Reference(option: self.posts[indexPath.item].reference, referenceText: self.posts[indexPath.item].referenceText)
                        self.referenceMenuLauncher.reference = reference
                        self.referenceMenuLauncher.delegate = self
                        self.referenceMenuLauncher.showImageSettings(in: self.view)
                    })
                    
                    children.append(action2)
                }
                
                
                
                return UIMenu(children: children)
            }
        }
        
        return nil
    }
    
}

//MARK: - HomeCellDelegate

extension HomeViewController: HomeCellDelegate {
    func cell(_ cell: UICollectionViewCell, wantsToSeeReference reference: Reference) {
        referenceMenuLauncher.reference = reference
        referenceMenuLauncher.delegate = self
        referenceMenuLauncher.showImageSettings(in: view)
    }
    
    func cell(_ cell: UICollectionViewCell, didTapMenuOptionsFor post: Post, option: Post.PostMenuOptions) {
        switch option {
        case .delete:
            print("delete post here")
        case .edit:
            let controller = EditPostViewController(post: post)
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            
            present(nav, animated: true)
        case .report:
            let controller = ReportViewController(source: .post, contentOwnerUid: post.ownerUid, contentId: post.postId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        case .reference:
            let reference = Reference(option: post.reference, referenceText: post.referenceText)
            referenceMenuLauncher.reference = reference
            referenceMenuLauncher.delegate = self
            referenceMenuLauncher.showImageSettings(in: view)
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
        displayState = displaysSinglePost ? .others : .none
        
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        //guard let newImage = image.image else { return }
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        //controller.customDelegate = self
        if contentSource == .search {
            self.navigationController?.delegate = zoomTransitioning
        }
        displayState = .photo
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .clear
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func cell(wantsToSeeLikesFor post: Post) {
        let controller = PostLikesViewController(contentType: post)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        displayState = displaysSinglePost ? .others : .none
        
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
        displayState = displaysSinglePost ? .others : .none
        
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell
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
        if displaysSinglePost { return }
        let controller = UserProfileViewController(user: user)
        displayState = displaysSinglePost ? .others : .none
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
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
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.posts[indexPath.row].didBookmark = true
                }
            }
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
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
        switch contentSource {
        case .home:
            PostService.fetchHomeDocuments(lastSnapshot: postsLastSnapshot) { snapshot in
                if snapshot.isEmpty { return }
                PostService.fetchHomePosts(snapshot: snapshot) { newPosts in
                    self.postsLastSnapshot = snapshot.documents.last
                    self.posts.append(contentsOf: newPosts)
                    UserService.fetchUsers(withUids: newPosts.map({ $0.ownerUid })) { users in
                        self.users.append(contentsOf: users)
                        self.collectionView.reloadData()
                    }
                }
            }
        case .user:
            guard let uid = user?.uid else { return }
            DatabaseManager.shared.fetchHomeFeedPosts(lastTimestampValue: postLastTimestamp, forUid: uid) { result in
                switch result {
                case .success(let postIds):
                    guard !postIds.isEmpty else { return }
                    PostService.fetchPosts(withPostIds: postIds) { newPosts in
                        self.posts.append(contentsOf: newPosts)
                        self.postLastTimestamp = self.posts.last?.timestamp.seconds
                        self.collectionView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        case .search:
            guard let user = user else { return }
            PostService.fetchSearchDocumentsForProfession(user: user, lastSnapshot: postsLastSnapshot) { snapshot in
                if snapshot.isEmpty { return }
                let newPosts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
                self.postsLastSnapshot = snapshot.documents.last
                
                PostService.getPostValuesFor(posts: newPosts, completion: { posts in
                    self.posts.append(contentsOf: posts)
                    UserService.fetchUsers(withUids: newPosts.map({ $0.ownerUid })) { users in
                        self.users.append(contentsOf: users)
                        self.collectionView.reloadData()
                    }
                })
            }
        }
    }
}

extension HomeViewController: DetailsPostViewControllerDelegate {
    func didDeleteComment(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex].numberOfComments -= 1
            
            switch post.type {
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
                
            case .document:
                break
            case .poll:
                break
            case .video:
                break
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
        let index = posts.firstIndex { homePost in
            if homePost.postId == post.postId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                self.cell(cell, didBookmark: post)
            }
        }
    }
    
    func didComment(forPost post: Post) {
        let index = posts.firstIndex { homePost in
            if homePost.postId == post.postId {
                return true
            }
            return false
        }
        
        if let index = index {

            posts[index].numberOfComments += 1
            
            switch post.type {
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
                
            case .document:
                break
            case .poll:
                break
            case .video:
                break
            }

        }
    }
}

/*
extension HomeViewController: CommentPostViewControllerDelegate {
    func didPressUserProfileFor(_ user: User) {
        let controller = UserProfileViewController(user: user)
        displayState = displaysSinglePost ? .others : .none
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    func didDeletePostComment(post: Post, comment: Comment) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex].numberOfComments -= 1
            
            switch post.type {
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
                
            case .document:
                break
            case .poll:
                break
            case .video:
                break
            }
        }
    }
    
    func didCommentPost(post: Post, user: User, comment: Comment) {
        let postIndex = posts.firstIndex { homePost in
            if homePost.postId == post.postId { return true }
            return false
        }
        
        if let index = postIndex {
            posts[index].numberOfComments += 1
            
            switch post.type {
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
                
            case .document:
                break
            case .poll:
                break
            case .video:
                break
            }
        }
    }
}
 */

extension HomeViewController: EditPostViewControllerDelegate {
    func didEditPost(post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex] = post
            collectionView.reloadItems(at: [IndexPath(item: postIndex, section: 0)])
        }
    }
}

extension HomeViewController: EmptyGroupCellDelegate {
    func didTapDiscoverGroup() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        
        let controller = HomeOnboardingViewController(user: user)
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
    
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension HomeViewController: HomeOnboardingViewControllerDelegate {
    func didUpdateUser(user: User) {
        guard let tab = tabBarController as? MainTabController else { return }
        tab.user = user
    }
}

extension HomeViewController: MEReferenceMenuLauncherDelegate {
    func didTapReference(reference: Reference) {
        switch reference.option {
        case .link:
            if let url = URL(string: reference.referenceText) {
                if UIApplication.shared.canOpenURL(url) {
                    let webViewController = WebViewController(url: url)
                    let navVC = UINavigationController(rootViewController: webViewController)
                    present(navVC, animated: true, completion: nil)
                }
            }
        case .citation:
            let wordToSearch = reference.referenceText
            if let encodedQuery = wordToSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
                    let webViewController = WebViewController(url: url)
                    let navVC = UINavigationController(rootViewController: webViewController)
                    present(navVC, animated: true, completion: nil)
                }
            }
        }
    }
}

