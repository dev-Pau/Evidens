//
//  FeedController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

private let reuseIdentifier = "Cell"
private let homeImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let homeTwoImageTextCellReuseIdentifier = "HomeTwoImageTextCellReuseIdentifier"


class HomeViewController: UICollectionViewController {
    
    //MARK: - Properties
    
    
    //weak var delegate: FeedControllerDelegate?
    
    var user: User?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.setDimensions(height: 35, width: 35)
        iv.layer.cornerRadius = 35/2
        
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
        return searchBar
    }()

    private var posts = [Post]() {
        didSet { collectionView.reloadData() }
    }
    
    var post: Post? {
        didSet { collectionView.reloadData() }
    }

    //MARK: - Lifecycle
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        fetchPosts()
        configureUI()
        configureNavigationItemButtons()
        searchBar.delegate = self

        if post != nil {
            checkIfUserLikedPosts()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        // To resign first responder
        searchBar.resignFirstResponder()
    }
    
    
    //MARK: - Helpers
    func configureUI() {
        // Configure UICollectionView
        collectionView.backgroundColor = lightColor
        collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        collectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        //Configure UIRefreshControl
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    func configureNavigationItemButtons() {

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "messages"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapChat))
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        let profileImageItem = UIBarButtonItem(customView: profileImageView)
        profileImageView.sd_setImage(with: URL(string: UserDefaults.standard.value(forKey: "userProfileImageUrl") as! String))
        navigationItem.leftBarButtonItem = profileImageItem
        
        navigationItem.titleView = searchBar
        
    }
    
    //MARK: - Actions
    
    @objc func handleRefresh() {
        HapticsManager.shared.vibrate(for: .success)
        posts.removeAll()
        fetchPosts()
    }
    
    @objc func didTapProfile() {
        guard let user = user else { return }
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        backItem.tintColor = blackColor
        
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
        
    }

    @objc func didTapChat() {
        let controller = ConversationViewController()
        
        //let backItem = UIBarButtonItem()
        //backItem.title = ""
        //navigationItem.backBarButtonItem = backItem
        //navigationItem.backBarButtonItem?.tintColor = .black
        
        controller.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(controller, animated: false)
    }

    
    //MARK: - API
    func fetchUser() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        UserService.fetchUser(withUid: uid) { user in
            self.user = user
        }
    }
    
    
    func fetchPosts() {
        guard post == nil else {
            //self.collectionView.refreshControl?.endRefreshing()
            return
        }
        //PostService.fetchPosts { posts in

        //}
        
        PostService.fetchFeedPosts { posts in
            self.posts = posts
            self.checkIfUserLikedPosts()
            self.checkIfUserBookmarkedPost()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func checkIfUserLikedPosts() {
        if let post = post {
            PostService.checkIfUserLikedPost(post: post) { didLike in
                self.post?.didLike = didLike
            }
        } else {
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
    }
    
    func checkIfUserBookmarkedPost() {
        if let post = post {
            PostService.checkIfUserBookmarkedPost(post: post) { didBookmark in
                self.post?.didBookmark = didBookmark
            }
        } else {
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
}

//MARK: - UICollectionViewDataSource

extension HomeViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post == nil ? posts.count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if posts[indexPath.row].type.postType == 0 {
            //print("post type 0")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeTextCell
            
            cell.delegate = self
            
            cell.layer.borderWidth = 0
            //cell.layer.borderColor = UIColor.lightGray.cgColor
            
            if let post = post {
                cell.viewModel = PostViewModel(post: post)
            } else {
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
            }
            return cell

        } else if posts[indexPath.row].type.postType == 1 {
            //print("post type 1")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
            cell.delegate = self
            cell.layer.borderWidth = 0
            cell.postImageView.image = nil
            //cell.layer.borderColor = UIColor.lightGray.cgColor
            if let post = post {
                cell.viewModel = PostViewModel(post: post)
            } else {
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
                
            }
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
            cell.delegate = self
            cell.layer.borderWidth = 0
            cell.postImageView.image = nil
            //cell.layer.borderColor = UIColor.lightGray.cgColor
            if let post = post {
                cell.viewModel = PostViewModel(post: post)
            } else {
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
                
            }
            return cell
        }
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if post != nil {
            //Single cell display
            return CGSize(width: view.frame.width, height: 300)
        } else {
            if posts[indexPath.row].type.postType == 1 {
                let viewModel = PostViewModel(post: posts[indexPath.row])
                let height = viewModel.size(forWidth: view.frame.width).height + 900
                return CGSize(width: view.frame.width, height: height)
                
            } else if posts[indexPath.row].type.postType == 2  {
                
                let viewModel = PostViewModel(post: posts[indexPath.row])
                
                

                let height = viewModel.size(forWidth: view.frame.width).height + 700
                return CGSize(width: view.frame.width, height: height)
                
            } else {
                //Array of posts
                let viewModel = PostViewModel(post: posts[indexPath.row])
                let height = viewModel.size(forWidth: view.frame.width).height + 200
                return CGSize(width: view.frame.width, height: height)
            }
        }
    }
     
    
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
    
    func cell(wantsToSeePostsFor topic: String) {
        // Preset new VC with topic title to fetch Posts & Clinical cases regarding the topic
    }
    

    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post) {
        let controller = CommentViewController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell
            currentCell.viewModel?.post.didLike.toggle()
            if post.didLike {
                //Unlike post here
                PostService.unlikePost(post: post) { _ in
                    currentCell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    currentCell.likeButton.tintColor = UIColor(rgb: 0x79CBBF)
                    currentCell.viewModel?.post.likes = post.likes - 1
                }
            } else {
                //Like post here
                PostService.likePost(post: post) { _ in
                    currentCell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    currentCell.likeButton.tintColor = UIColor(rgb: 0x79CBBF)
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
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor post: Post, withAction action: String) {
        print("Action received in HomeViewController for \(action) with post text \(post.postText)")
        //print(action)
    }
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            if post.didBookmark {
                //Unbookmark post here
                PostService.unbookmarkPost(post: post) { _ in
                    currentCell.bookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                }
            } else {
                //Bookmark post here
                PostService.bookmarkPost(post: post) { _ in
                    currentCell.bookmarkButton.setImage(UIImage(named: "bookmark.fill"), for: .normal)
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
        print("User pressed SearchBar")
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        backItem.tintColor = blackColor
        
        let controller = SearchViewController()
        navigationController?.pushViewController(controller, animated: true)

        return true
    }
}
