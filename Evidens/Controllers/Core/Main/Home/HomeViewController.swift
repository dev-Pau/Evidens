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
    
    var user: User?
    var selectedImage: UIImageView!
    var homeMenuLauncher = HomeOptionsMenuLauncher()
    
    var displaysSinglePost: Bool = false
    
    private var postsLastSnapshot: QueryDocumentSnapshot?
    private var postLastTimestamp: Int64?
    
    private var zoomTransitioning = ZoomTransitioning()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing  = 10
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 600)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = lightColor
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    
    var posts = [Post]() {
        didSet {
            collectionView.reloadData()
            
        }
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        fetchFirstPostsGroup()
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
        /*
        if controllerIsBeeingPushed {
            navigationItem.titleView?.isHidden = true
            navigationItem.titleView?.isUserInteractionEnabled = false
            navigationItem.leftBarButtonItem?.customView?.isHidden = true
            navigationItem.rightBarButtonItem?.tintColor = .white
        }
         */
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
                PostService.fetchHomePosts(snapshot: snapshot) { posts in
                    self.postsLastSnapshot = snapshot.documents.last
                    self.posts = posts
                    self.checkIfUserLikedPosts()
                    self.checkIfUserBookmarkedPost()
                    //self.collectionView.reloadData()
                    self.collectionView.refreshControl?.endRefreshing()
                }
            }
            
        } else {
            guard let uid = user?.uid else { return }
            DatabaseManager.shared.fetchHomeFeedPosts(lastTimestampValue: nil, forUid: uid) { result in
                switch result {
                    
                case .success(let uids):
                    uids.forEach { uid in
                        PostService.fetchPost(withPostId: uid) { post in
                            self.posts.append(post)
                            
                            self.posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                            // Get the last timestamp to create next query for realtime database
                            self.postLastTimestamp = self.posts.last?.timestamp.seconds
    
                            self.checkIfUserLikedPosts()
                            self.checkIfUserBookmarkedPost()
                            //self.collectionView.reloadData()
                            
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
            /*
             PostService.fetchPosts(forUser: uid) { posts in
             self.posts = posts
             self.checkIfUserLikedPosts()
                self.checkIfUserBookmarkedPost()
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()
            }
             */
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
                
                return cell
                
            } else if posts[indexPath.row].type.postType == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                cell.delegate = self
                cell.layer.borderWidth = 0
                
                
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                
                return cell
                
            } else if posts[indexPath.row].type.postType == 2 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                cell.delegate = self
                cell.layer.borderWidth = 0
                
                
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                
                return cell
                
            } else if posts[indexPath.row].type.postType == 3 {
                //print("post type 1")
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                cell.delegate = self
                cell.layer.borderWidth = 0
                
    
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                
                return cell
                
            } else if posts[indexPath.row].type.postType == 4 {
                //print("post type 1")
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                cell.delegate = self
                cell.layer.borderWidth = 0
                
                
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                
                return cell
                
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                cell.delegate = self
                cell.layer.borderWidth = 0
               
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                
                return cell
            }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            print("Get more Posts")
            getMorePosts()
        }
    }
    
    /*
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
            collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
            
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
     */
}


//MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if post != nil {
            //Single cell display
            return CGSize(width: view.frame.width, height: 300)
        } else {
            if posts[indexPath.row].type.postType == 1 {
                let viewModel = PostViewModel(post: posts[indexPath.row])
                let height = viewModel.size(forWidth: view.frame.width).height + viewModel.sizeOfImage + 205
                return CGSize(width: view.frame.width, height: height)
                
            } else if posts[indexPath.row].type.postType == 2  {
                let viewModel = PostViewModel(post: posts[indexPath.row])
                let height = viewModel.size(forWidth: view.frame.width).height + 350 + 215
                
                return CGSize(width: view.frame.width, height: height)
                
            } else if posts[indexPath.row].type.postType == 3  {
                let viewModel = PostViewModel(post: posts[indexPath.row])
                let height = viewModel.size(forWidth: view.frame.width).height + 350 + 215
                
                return CGSize(width: view.frame.width, height: height)
                
            } else if posts[indexPath.row].type.postType == 4  {
                let viewModel = PostViewModel(post: posts[indexPath.row])
                let height = viewModel.size(forWidth: view.frame.width).height + 350 + 215
                
                return CGSize(width: view.frame.width, height: height)
            } else if posts[indexPath.row].type.postType == 5  {
                let viewModel = DocumentPostViewModel(post: posts[indexPath.row])
                let height = viewModel.size(forWidth: view.frame.width).height + 450 + 215
                
                return CGSize(width: view.frame.width, height: height)
            }
            else {
                //Array of posts
                let viewModel = PostViewModel(post: posts[indexPath.row])
                let height = viewModel.size(forWidth: view.frame.width).height + viewModel.additionalPostHeight + 155
                return CGSize(width: view.frame.width, height: height)
            }
        }
         
    }
     */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 14.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    /*
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                return UIMenu(title: "", subtitle: nil, image: nil, identifier: nil, options: .displayInline, children: [
                    UIAction(title: "Report Post", image: UIImage(systemName: "flag"), handler: { (_) in
                        print("Report post pressed")
                    })
                ])
            }
            return config
        }
     */
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
        controller.customDelegate = self

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
                //currentCell.viewModel?.post.likes = post.likes - 1
                self.posts[indexPath.row].didLike = false
                self.posts[indexPath.row].likes -= 1
            }
        } else {
            PostService.likePost(post: post) { _ in
                //currentCell.viewModel?.post.likes = post.likes + 1
                self.posts[indexPath.row].didLike = true
                self.posts[indexPath.row].likes += 1
                NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
            }
        }
      
        
        /*
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell
            //currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    //currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                    
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    //currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            }
            
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            
            //currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    //currentCell.actionButtonsView.likeButton.setImage(UIImage(named: "heart"), for: .normal)
                    //currentCell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    //currentCell.likeButton.tintColor = UIColor(rgb: 0x79CBBF)
                    
                    //currentCell.viewModel?.post.likes = post.likes - 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in

                    currentCell.viewModel?.post.likes = post.likes + 1
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                    }
                }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            
            currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            
            currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            
            currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            }
            
            
        default:
            print("No cell registered")
        }
         */
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
        /*
         guard let tab = tabBarController as? MainTabController else { return }
         guard let user = tab.user else { return }
         guard let indexPath = collectionView.indexPath(for: cell) else { return }

         HapticsManager.shared.vibrate(for: .success)
         
         if post.didLike {
             PostService.unlikePost(post: post) { _ in
                 //currentCell.viewModel?.post.likes = post.likes - 1
                 self.posts[indexPath.row].didLike = false
                 self.posts[indexPath.row].likes -= 1
             }
         } else {
             PostService.likePost(post: post) { _ in
                 //currentCell.viewModel?.post.likes = post.likes + 1
                 self.posts[indexPath.row].didLike = true
                 self.posts[indexPath.row].likes += 1
                 NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
             }
         }
       
         */
        if post.didBookmark {
            
        }
        
        
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                //Unbookmark post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                }
            } else {
                //Bookmark post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                }
            }
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                //Unbookmark post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                }
            } else {
                //Bookmark post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                //Unbookmark post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                }
            } else {
                //Bookmark post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                //Unbookmark post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                }
            } else {
                //Bookmark post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                //Unbookmark post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                }
            } else {
                //Bookmark post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                }
            }
        default:
            print("No cell registered")
        }
    }
}
/*
extension HomeViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        backItem.tintColor = .black
        
        let controller = SearchViewController()
        navigationController?.pushViewController(controller, animated: true)

        return true
    }
}
 */


extension HomeViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension HomeViewController: HomeImageViewControllerDelegate {
    func updateVisibleImageInScrollView(_ image: UIImageView) {
        selectedImage = image
    }
}

extension HomeViewController: HomeOptionsMenuLauncherDelegate {
    func didTapFollowAction(forUid uid: String, isFollowing follow: Bool, forUserFirstName firstName: String) {
        if follow {
            // Unfollow user
            UserService.unfollow(uid: uid) { _ in
                let reportPopup = METopPopupView(title: "You unfollowed \(firstName)", image: "xmark.circle.fill")
                reportPopup.showTopPopup(inView: self.view)
            }
        } else {
            // Follow user
            UserService.follow(uid: uid) { _ in
                let reportPopup = METopPopupView(title: "You followed \(firstName)", image: "plus.circle.fill")
                reportPopup.showTopPopup(inView: self.view)
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
            //let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: true)
            //timer.fire()        }
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
            PostService.fetchHomeDocuments(lastSnapshot: postsLastSnapshot) { snapshot in
                PostService.fetchHomePosts(snapshot: snapshot) { posts in
                    self.postsLastSnapshot = snapshot.documents.last

                    self.posts.append(contentsOf: posts)
                    self.collectionView.reloadData()
                    self.checkIfUserLikedPosts()
                    self.checkIfUserBookmarkedPost()
                    //self.collectionView.reloadItems(at: [IndexPath(index: posts.count - 1)])
                }
            }
        } else {
            guard let uid = user?.uid else { return }
            DatabaseManager.shared.fetchHomeFeedPosts(lastTimestampValue: postLastTimestamp, forUid: uid) { result in
                switch result {
                case .success(let uids):
                    uids.forEach { uid in
                        PostService.fetchPost(withPostId: uid) { post in
                            self.posts.append(post)

                            
                            self.posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })

                            // Get the last timestamp to create next query for realtime database
                            self.postLastTimestamp = self.posts.last?.timestamp.seconds
                            self.checkIfUserLikedPosts()
                            self.checkIfUserBookmarkedPost()
                            self.collectionView.reloadData()
                            
                        }
                    }
                case .failure(let error):
                    print(error)
                    
                }
            }
        }
    }
}
