//
//  FeedController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit
import Firebase

private let reuseIdentifier = "HomeTextCellReuseIdentifier"
private let homeImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let homeTwoImageTextCellReuseIdentifier = "HomeTwoImageTextCellReuseIdentifier"
private let homeThreeImageTextCellReuseIdentifier = "HomeThreeImageTextCellReuseIdentifier"
private let homeFourImageTextCellReuseIdentifier = "HomeFourImageTextCellReuseIdentifier"
private let homeDocumentCellReuseIdentifier = "HomeDocumentCellReuseIdentifier"


class HomeViewController: NavigationBarViewController {
    
    //MARK: - Properties
    
    enum Section {
        case main
    }
    
    var user: User?
    var selectedImage: UIImageView!
    var homeMenuLauncher = HomeOptionsMenuLauncher()
    
    private var singleUpdate: Bool = false
    
    var displaysSinglePost: Bool = false
    
    private var postsLastSnapshot: QueryDocumentSnapshot?
    private var postLastTimestamp: Int64?
    
    private var zoomTransitioning = ZoomTransitioning()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing  = 10
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .zero)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = lightColor
        
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var users = [User]() {
        didSet {
            //collectionView.reloadData()
        }
    }
   
    var posts = [Post]() {
        didSet {
            if !singleUpdate {
                print("Reload all")
                //collectionView.reloadData()
            }
        }
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = zoomTransitioning
        fetchUser()
        fetchFirstPostsGroup()
        //configureDataSource()
        configureUI()
        configureNavigationItemButtons()
    }

    //MARK: - Helpers
    func configureUI() {
        // Configure UICollectionView
        collectionView.backgroundColor = lightColor
        collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        collectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        collectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        collectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        //collectionView.register(HomeDocumentCell.self, forCellWithReuseIdentifier: homeDocumentCellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(collectionView)
        //Configure UIRefreshControl
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
        
        homeMenuLauncher.delegate = self
    }
    
    func configureNavigationItemButtons() {
        if displaysSinglePost {
            guard let firstName = user?.firstName, let lastName = user?.lastName else { return }
            let view = MENavigationBarTitleView(fullName: firstName + " " + lastName, category: "Posts")
            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
            navigationItem.titleView = view

            let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
            
            navigationItem.rightBarButtonItem = rightBarButtonItem
        }
    }
    
    //MARK: - Actions
    
    @objc func handleRefresh() {
        HapticsManager.shared.vibrate(for: .success)
        posts.removeAll()
        fetchFirstPostsGroup()
    }
    
    //MARK: - API
    func fetchUser() {
        if !displaysSinglePost {
            guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            UserService.fetchUser(withUid: uid) { user in
                self.user = user
            }
        }
    }

    func fetchFirstPostsGroup() {
        if !displaysSinglePost {
            PostService.fetchHomeDocuments(lastSnapshot: nil) { snapshot in
                PostService.fetchHomePosts(snapshot: snapshot) { fetchedPosts in
                    self.postsLastSnapshot = snapshot.documents.last
                    self.posts = fetchedPosts
                    self.checkIfUserLikedPosts()
                    self.checkIfUserBookmarkedPost()
                    
                    self.posts.forEach { post in
                        UserService.fetchUser(withUid: post.ownerUid) { user in
                            self.users.append(user)
                            if self.users.count == self.posts.count {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                    
                    self.collectionView.refreshControl?.endRefreshing()
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
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func checkIfUserLikedPosts() {
            //For every post in array fetched
            self.posts.forEach { post in
                //Check if user did like
                PostService.checkIfUserLikedPost(post: post) { didLike in
                    //Check the postId of the current post looping
                    if let index = self.posts.firstIndex(where: {$0.postId == post.postId}) {
                        //Change the didLike according if user did like post
                        self.posts[index].didLike = didLike
                        //self.updateData(on: self.posts)
                    }
            }
        }
    }
    
    func checkIfUserBookmarkedPost() {
        //For every post in array fetched
        self.posts.forEach { post in
            PostService.checkIfUserBookmarkedPost(post: post) { didBookmark in
                if let index = self.posts.firstIndex(where: { $0.postId == post.postId}) {
                    self.posts[index].didBookmark = didBookmark
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if posts[indexPath.row].type.postType == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTextCell
            
            cell.delegate = self
            
            cell.layer.borderWidth = 0
            
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
            
            
            let userIndex = users.firstIndex { user in
                return user.uid == posts[indexPath.row].ownerUid
            }!
            
            
            cell.userPostView.profileImageView.sd_setImage(with: URL(string: users[userIndex].profileImageUrl!))
            
            return cell
            
        } else if posts[indexPath.row].type.postType == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
            cell.delegate = self
            cell.layer.borderWidth = 0
            cell.layoutIfNeeded()
            
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
            cell.layoutIfNeeded()
            
            return cell
            
        } else if posts[indexPath.row].type.postType == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
            cell.delegate = self
            cell.layer.borderWidth = 0
            cell.layoutIfNeeded()
            
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
            
            
            return cell
            
        } else if posts[indexPath.row].type.postType == 3 {
            //print("post type 1")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
            cell.delegate = self
            cell.layer.borderWidth = 0

            
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
            cell.layoutIfNeeded()
            
            return cell
            
        } else if posts[indexPath.row].type.postType == 4 {
            //print("post type 1")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
            cell.delegate = self
            cell.layer.borderWidth = 0
            cell.layoutIfNeeded()
            
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
            
            
            return cell
            
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
            cell.delegate = self
            cell.layer.borderWidth = 0
            
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
            cell.layoutIfNeeded()
            return cell
        }
        
    }
}

//MARK: - HomeCellDelegate

extension HomeViewController: HomeCellDelegate {
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post) {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsPostViewController(post: post, collectionViewLayout: layout)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        //guard let newImage = image.image else { return }
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        //controller.customDelegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .clear
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func cell(wantsToSeeLikesFor post: Post) {
        PostService.getAllLikesFor(post: post) { uids in
            let controller = PostLikesViewController(uid: uids)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post) {
        let controller = CommentPostViewController(post: post)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        
        if post.didLike {
            PostService.unlikePost(post: post) { _ in
                //self.singleUpdate = true
                self.posts[indexPath.row].didLike = false
                self.posts[indexPath.row].likes -= 1
                //self.singleUpdate = false
            }
        } else {
            PostService.likePost(post: post) { _ in
                //self.singleUpdate = true
                self.posts[indexPath.row].didLike = true
                self.posts[indexPath.row].likes += 1
                //self.singleUpdate = false
                NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
            }
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor uid: String) {
        UserService.fetchUser(withUid: uid) { user in
            let controller = UserProfileViewController(user: user)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .black
            self.navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(controller, animated: true)
            DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor post: Post) {
        homeMenuLauncher.post = post
        homeMenuLauncher.showImageSettings(in: view)
    }
    
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        if post.didBookmark {
            PostService.unbookmarkPost(post: post) { _ in
                self.posts[indexPath.row].didBookmark = false
                self.posts[indexPath.row].numberOfBookmarks -= 1
                
            }
        } else {
            PostService.bookmarkPost(post: post) { _ in
                self.posts[indexPath.row].didBookmark = true
                self.posts[indexPath.row].numberOfBookmarks += 1
            }
        }
    }
}

extension HomeViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension HomeViewController: HomeOptionsMenuLauncherDelegate {
    func didTapFollowAction(forUid uid: String, isFollowing follow: Bool, forUserFirstName firstName: String) {
        if follow {
            // Unfollow user
            UserService.unfollow(uid: uid) { _ in
                let reportPopup = METopPopupView(title: "You unfollowed \(firstName)", image: "xmark.circle.fill")
                reportPopup.showTopPopup(inView: self.view)
                PostService.updateUserFeedAfterFollowing(userUid: uid, didFollow: false)
            }
        } else {
            // Follow user
            UserService.follow(uid: uid) { _ in
                let reportPopup = METopPopupView(title: "You followed \(firstName)", image: "plus.circle.fill")
                reportPopup.showTopPopup(inView: self.view)
                PostService.updateUserFeedAfterFollowing(userUid: uid, didFollow: true)
            }
        }
    }
    
    func didTapReportPost(forPostUid uid: String) {
        reportPostAlert {
            DatabaseManager.shared.reportPost(forUid: uid) { reported in
                if reported {
                    let reportPopup = METopPopupView(title: "Post reported", image: "flag.fill")
                    reportPopup.showTopPopup(inView: self.view)
                }
            }
        }
    }
    
    func didTapDeletePost(forPostUid uid: String) {
        deletePostAlert {
            print("Delete post here")
        }
    }
    
    func didTapEditPost(forPost post: Post) {
        let controller = EditPostViewController(post: post)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
}

extension HomeViewController {
    func getMorePosts() {
        if !displaysSinglePost {
            print(collectionView.contentSize.height)
            PostService.fetchHomeDocuments(lastSnapshot: postsLastSnapshot) { snapshot in
                PostService.fetchHomePosts(snapshot: snapshot) { newPosts in
                    self.postsLastSnapshot = snapshot.documents.last
                    self.posts.append(contentsOf: newPosts)
                    self.checkIfUserLikedPosts()
                    self.checkIfUserBookmarkedPost()
                    
                    newPosts.forEach { post in
                        UserService.fetchUser(withUid: post.ownerUid) { user in
                            self.users.append(user)
                            if self.users.count == self.posts.count {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        } else {
            guard let uid = user?.uid else { return }
            DatabaseManager.shared.fetchHomeFeedPosts(lastTimestampValue: postLastTimestamp, forUid: uid) { result in
                switch result {
                case .success(let uids):
                    uids.forEach { uid in
                        PostService.fetchPost(withPostId: uid) { newPost in
                            self.posts.append(newPost)
                            self.posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                            self.postLastTimestamp = self.posts.last?.timestamp.seconds
                        }
                    }
                case .failure(let error):
                    print(error)
                    
                }
            }
        }
    }
}
