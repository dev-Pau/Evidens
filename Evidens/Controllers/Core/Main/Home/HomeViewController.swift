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


class HomeViewController: UICollectionViewController {
    
    //MARK: - Properties
    
    var user: User?
    var selectedImage: UIImageView!
    var homeMenuLauncher = HomeOptionsMenuLauncher()
    var controllerIsBeeingPushed: Bool = false
    
    private var postsLastSnapshot: QueryDocumentSnapshot?
    
    private var zoomTransitioning = ZoomTransitioning()
        
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.setDimensions(height: 35, width: 35)
        iv.layer.cornerRadius = 35/2
        iv.contentMode = .scaleAspectFill
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        let atrString = NSAttributedString(string: "Search", attributes: [.font: UIFont.systemFont(ofSize: 15)])
        searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.backgroundColor = lightColor
        searchBar.searchTextField.tintColor = primaryColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    var posts = [Post]() {
        didSet { collectionView.reloadData() }
    }
    
    //MARK: - Lifecycle
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = zoomTransitioning
        fetchUser()
        fetchFirstPostsGroup()
        configureUI()
        configureNavigationItemButtons()
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        // To resign first responder
        //navigationController?.navigationBar.isHidden = false
        searchBar.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //navigationController?.navigationBar.isHidden = false
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
        //Configure UIRefreshControl
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
        
        homeMenuLauncher.delegate = self
    }
    
    func configureNavigationItemButtons() {
        if !controllerIsBeeingPushed {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane",
                                                                               withConfiguration: UIImage.SymbolConfiguration(weight: .medium)),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(didTapChat))
            navigationItem.rightBarButtonItem?.tintColor = .black
            let profileImageItem = UIBarButtonItem(customView: profileImageView)
            profileImageView.sd_setImage(with: URL(string: UserDefaults.standard.value(forKey: "userProfileImageUrl") as! String))
            navigationItem.leftBarButtonItem = profileImageItem
            navigationItem.titleView = searchBar
        } else {
            navigationItem.titleView = searchBar
            navigationItem.titleView?.isHidden = true
            navigationItem.titleView?.isUserInteractionEnabled = false
        }
    }
    
    //MARK: - Actions
    
    @objc func handleRefresh() {
        HapticsManager.shared.vibrate(for: .success)
        posts.removeAll()
        fetchFirstPostsGroup()
    }
    
    @objc func didTapProfile() {
        guard let user = user else { return }
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        backItem.tintColor = .black
        
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
        
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
        
    }

    @objc func didTapChat() {
        let controller = ConversationViewController()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem

        controller.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(controller, animated: true)
    }

    
    //MARK: - API
    func fetchUser() {
        if !controllerIsBeeingPushed {
            guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            UserService.fetchUser(withUid: uid) { user in
                self.user = user
            }
        }
    }
    
    
    func fetchFirstPostsGroup() {
        if !controllerIsBeeingPushed {
            PostService.fetchHomeDocuments(lastSnapshot: nil) { snapshot in
                PostService.fetchHomePosts(snapshot: snapshot) { posts in
                    self.postsLastSnapshot = snapshot.documents.last
                    self.posts = posts
                    self.checkIfUserLikedPosts()
                    self.checkIfUserBookmarkedPost()
                    self.collectionView.refreshControl?.endRefreshing()
                }
            }

        } else {
            guard let uid = user?.uid else { return }
            PostService.fetchPosts(forUser: uid) { posts in
                self.posts = posts
                self.checkIfUserLikedPosts()
                self.checkIfUserBookmarkedPost()
                self.collectionView.refreshControl?.endRefreshing()
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

extension HomeViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
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

        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell
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
            
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            
            currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    //currentCell.actionButtonsView.likeButton.setImage(UIImage(named: "heart"), for: .normal)
                    //currentCell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    //currentCell.likeButton.tintColor = UIColor(rgb: 0x79CBBF)
                    
                    currentCell.viewModel?.post.likes = post.likes - 1
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

