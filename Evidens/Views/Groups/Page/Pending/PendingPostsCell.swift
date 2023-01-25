//
//  PendingPostsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/1/23.
//

import UIKit

private let homeTextCellReuseIdentifier = "HomeTextCellReuseIdentifier"
private let homeImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let homeTwoImageTextCellReuseIdentifier = "HomeTwoImageTextCellReuseIdentifier"
private let homeThreeImageTextCellReuseIdentifier = "HomeThreeImageTextCellReuseIdentifier"
private let homeFourImageTextCellReuseIdentifier = "HomeFourImageTextCellReuseIdentifier"

private let emptyPostsCellReuseIdentifier = "EmptyPostsCellReuseIdentifier"

class PendingPostsCell: UICollectionViewCell {
    
    private var posts = [Post]()
    private var users = [User]()
    
    var groupId: String?
    
    weak var reviewPostCellDelegate: PresentReviewAlertContentGroupDelegate?
    
    private var loaded: Bool = false
    private var groupNeedsToReviewContent: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.isScrollEnabled = false
        collectionView.isHidden = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(collectionView, activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        collectionView.frame = bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyPostsCellReuseIdentifier)
        
        collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: homeTextCellReuseIdentifier)
        collectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        collectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        collectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        collectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        
        
        activityIndicator.startAnimating()
    }
    
    func fetchPendingPosts(group: Group) {
        if group.permissions == .all || group.permissions == .review {
            groupNeedsToReviewContent = true
            DatabaseManager.shared.fetchPendingPostsForGroup(withGroupId: group.groupId) { pendingPosts in
                print(pendingPosts)
                let postIds = pendingPosts.map({ $0.id })
                if pendingPosts.isEmpty {
                    self.activityIndicator.stopAnimating()
                    self.collectionView.isHidden = false
                    self.collectionView.isScrollEnabled = true
                    self.collectionView.reloadData()
                    return
                }
                postIds.forEach { id in
                    PostService.fetchGroupPost(withGroupId: group.groupId, withPostId: id) { post in
                        self.posts.append(post)
                        if self.posts.count == postIds.count {
                            // Fetch user info
                            self.posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                            let uniqueOwnerUids = Array(Set(self.posts.map({ $0.ownerUid })))
                            UserService.fetchUsers(withUids: uniqueOwnerUids) { users in
                                self.users = users
                                self.activityIndicator.stopAnimating()
                                self.collectionView.isHidden = false
                                self.collectionView.isScrollEnabled = true
                                self.collectionView.reloadData()
                                return
                            }
                        }
                    }
                }
            }
        } else {
            groupNeedsToReviewContent = false
            activityIndicator.stopAnimating()
            collectionView.isHidden = false
            collectionView.isScrollEnabled = true
            collectionView.reloadData()
        }
    }
    
    private func getUserForPost(post: Post) -> User {
        let userIndex = users.firstIndex { user in
            if user.uid == post.ownerUid {
                return true
            }
            
            return false
        }
        
        if let userIndex = userIndex {
            return users[userIndex]
        } else {
            return User(dictionary: [:])
        }
    }
    /*
    func configureContextMenu() -> UIContextMenuConfiguration{
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                print("edit button clicked")
            }
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil,attributes: .destructive, state: .off) { (_) in
                print("delete button clicked")
            }
            
            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [edit,delete])
            
        }
        return context
    }
     */
}

extension PendingPostsCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  groupNeedsToReviewContent ? (posts.isEmpty ? 1 : posts.count) : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if !groupNeedsToReviewContent {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyPostsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: nil, title: "Posts don't require admin review", description: "Group owners can activate the ability to review all group posts before they are shared with members.", buttonText: "Learn more")
            return cell
        }
        
        if posts.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyPostsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: nil, title: "No pending posts.", description: "Check back for all the new posts that need review.", buttonText: "Go to group")
            return cell
        }
        // Dequeue posts
        if posts[indexPath.row].type.postType == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTextCellReuseIdentifier, for: indexPath) as! HomeTextCell
            
            //cell.delegate = self
            cell.reviewDelegate = self
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
            cell.set(user: getUserForPost(post: posts[indexPath.row]))
            cell.configureWithReviewOptions()
            return cell
            
        } else if posts[indexPath.row].type.postType == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
           
            //cell.delegate = self
            cell.reviewDelegate = self
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
            cell.set(user: getUserForPost(post: posts[indexPath.row]))
            cell.configureWithReviewOptions()
            return cell
            
        } else if posts[indexPath.row].type.postType == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
            /*
            cell.delegate = self
            cell.layer.borderWidth = 0
            */
            cell.reviewDelegate = self
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
            cell.set(user: getUserForPost(post: posts[indexPath.row]))
            cell.configureWithReviewOptions()
            return cell
            
        } else if posts[indexPath.row].type.postType == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
           /*
            cell.delegate = self
            cell.layer.borderWidth = 0
            */
            cell.reviewDelegate = self
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
            cell.set(user: getUserForPost(post: posts[indexPath.row]))
            cell.configureWithReviewOptions()
            return cell
            
        } else if posts[indexPath.row].type.postType == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as!  HomeFourImageTextCell
            /*
            cell.delegate = self
            */
            cell.reviewDelegate = self
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
            cell.set(user: getUserForPost(post: posts[indexPath.row]))
            cell.configureWithReviewOptions()
            return cell
            
        }
        else {
            return UICollectionViewCell()
        }
    }
    /*
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        configureContextMenu()
    }
     */
}

extension PendingPostsCell: ReviewContentGroupDelegate {
    
    func didTapAcceptContent(contentId: String) {
        guard let groupId = groupId else { return }
        let postIndex = posts.firstIndex { post in
            if post.postId == contentId {
                return true
            }
            return false
        }
        
        if let postIndex = postIndex {
            DatabaseManager.shared.approveGroupPost(withGroupId: groupId, withPostId: contentId) { approved in
                if approved {
                    self.collectionView.performBatchUpdates {
                        self.posts.remove(at: postIndex)
                        self.collectionView.deleteItems(at: [IndexPath(item: postIndex, section: 0)])
                    }
                    self.reviewPostCellDelegate?.didAcceptContent(type: .post)
                }
            }
        }
    }
    
    func didTapCancelContent(contentId: String) {
        reviewPostCellDelegate?.didCancelContent(type: .post)
    }
    
}


