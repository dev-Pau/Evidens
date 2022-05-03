//
//  FeedController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

private let reuseIdentifier = "Cell"

class FeedViewController: UICollectionViewController {
    
    //MARK: - Properties
    
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

        return searchBar
    }()
    
    var feedDelegate: FeedViewControllerDelegate?
    
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
    
    
    //MARK: - Helpers
    func configureUI() {

        collectionView.backgroundColor = UIColor(rgb: 0xF1F4F7)
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
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

    @objc func didTapFilter() {
        print("DEBUG: did tap filter")
    }
    
    @objc func didTapProfile() {
        print("DEBUG: did tap profile")
        guard let user = user else { return }
        let controller = ProfileViewController(user: user)
        
        //let backItem = UIBarButtonItem()
        //backItem.title = ""
        //navigationItem.backBarButtonItem = backItem
        //navigationItem.backBarButtonItem?.tintColor = .black
        
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
}

//MARK: - UICollectionViewDataSource

extension FeedViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post == nil ? posts.count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        
        cell.delegate = self
        
        cell.layer.borderWidth = 0
        //cell.layer.borderColor = UIColor.lightGray.cgColor
        
        if let post = post {
            cell.viewModel = PostViewModel(post: post)
        } else {
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
        }
        return cell
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 7.0
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

//MARK: - FeedCellDelegate

extension FeedViewController: FeedCellDelegate {
    
    func cell(_ cell: FeedCell, didPressThreeDotsFor post: Post, withAction action: String) {
        print(action)
    }
    
    func cell(_ cell: FeedCell, wantsToShowProfileFor uid: String) {
        UserService.fetchUser(withUid: uid) { user in
            let controller = ProfileViewController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post) {
        let controller = CommentViewController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: FeedCell, didLike post: Post) {
        //Grab the current user that sends the notification
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        cell.viewModel?.post.didLike.toggle()
        if post.didLike {
            //Unlike post here
            PostService.unlikePost(post: post) { _ in
                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                cell.likeButton.tintColor = UIColor(rgb: 0x79CBBF)
                cell.viewModel?.post.likes = post.likes - 1
            }
        } else {
            //Like post here
            PostService.likePost(post: post) { _ in
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                cell.likeButton.tintColor = UIColor(rgb: 0x79CBBF)
                cell.viewModel?.post.likes = post.likes + 1
                
                NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            }
    }
}

extension FeedViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        print("User pressed SearchBar")
        
        let controller = SearchViewController()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
        searchBar.resignFirstResponder()
        
        return true
    }
}
    

