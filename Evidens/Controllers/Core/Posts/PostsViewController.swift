//
//  PostsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit
import Firebase

private let emptyPrimaryCellReuseIdentifier = "EmptyPrimaryCellReuseIdentifier"
private let postTextCellReuseIdentifier = "PostTextCellReuseIdentifier"
private let postTextImageCellReuseIdentifier = "PostTextImageCellReuseIdentifier"
private let postLinkCellReuseIdentifier = "PostLinkCellReuseIdentifier"

private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"
private let loadingReuseIdentifier = "LoadingHeaderReuseIdentifier"

class PostsViewController: NavigationBarViewController {
    
    //MARK: - Properties
    
    private var viewModel: HomeViewModel

    private var collectionView: UICollectionView!

    //MARK: - Lifecycle
    
    init(source: PostSource, discipline: Discipline? = nil) {
        self.viewModel = HomeViewModel(source: source, discipline: discipline)
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
    
    //MARK: - Helpers
    
    func configure() {
        view.backgroundColor = .systemBackground
        
        if UIDevice.isPad {
            title = AppStrings.Tab.network
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyPrimaryCellReuseIdentifier)
        collectionView.register(PostTextCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        collectionView.register(PostTextImageCell.self, forCellWithReuseIdentifier: postTextImageCellReuseIdentifier)
        collectionView.register(PostLinkCell.self, forCellWithReuseIdentifier: postLinkCellReuseIdentifier)
        collectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset.bottom = 85
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: UIDevice.isPad ? view.bottomAnchor : view.safeAreaLayoutGuide.bottomAnchor)
        ])

        if viewModel.source == .home {
            let refresher = UIRefreshControl()
            refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
            collectionView.refreshControl = refresher
            
            configureAddButton(primaryAppearance: true)
        }
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
            
            guard let strongSelf = self else { return nil }
            
            let height: NSCollectionLayoutDimension = UIDevice.isPad ? .estimated(800) : .estimated(500)
            
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: height)
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: height), subitems: [item])
            
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.viewModel.loaded {
                section.boundarySupplementaryItems = [header]
            }
          
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        
        return layout
    }
    
    func postsLoaded() -> Bool {
        return viewModel.loaded
    }
    
    //MARK: - Actions
    
    @objc func handleRefresh() {
        guard viewModel.source == .home else { return }
        
        HapticsManager.shared.triggerLightImpact()
        
        if viewModel.postsFirstSnapshot == nil {
            fetchFirstPostsGroup()
        } else {
            checkIfUserHasNewPostsToDisplay()
        }
    }
    
    private func checkIfUserHasNewPostsToDisplay() {

        let cooldownTime: TimeInterval = 20.0
        if let lastRefreshTime = viewModel.lastRefreshTime, Date().timeIntervalSince(lastRefreshTime) < cooldownTime {
            collectionView.refreshControl?.endRefreshing()
            return
        }
        
        viewModel.lastRefreshTime = Date()

        DispatchQueue.main.asyncAfter(deadline: .now() + cooldownTime) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.lastRefreshTime = nil
        }
        
        fetchFirstPostsGroup()
    }

    //MARK: - API

    private func fetchFirstPostsGroup() {
        viewModel.getFirstGroupOfPosts { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.collectionView.refreshControl?.endRefreshing()
            strongSelf.collectionView.reloadData()
        }
    }
}

extension PostsViewController: UICollectionViewDelegate {
    
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

extension PostsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.loaded ? viewModel.networkError ? 1 : viewModel.posts.isEmpty ? 1 : viewModel.posts.count : 0
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.networkError {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
            cell.set(AppStrings.Network.Issues.Post.title)
            cell.delegate = self
            return cell
        } else {
            if viewModel.posts.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyPrimaryCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                cell.set(withTitle: AppStrings.Content.Post.Feed.title, withDescription: AppStrings.Content.Post.Feed.content)
                return cell
            } else {
                let currentPost = viewModel.posts[indexPath.row]
                let kind = currentPost.kind
                
                switch kind {
                    
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextCellReuseIdentifier, for: indexPath) as! PostTextCell
                    
                    cell.delegate = self
                    cell.postTextView.isSelectable = false
                    cell.viewModel = PostViewModel(post: viewModel.posts[indexPath.row])
                    
                    if let userIndex = viewModel.users.firstIndex(where: { $0.uid == currentPost.uid }) {
                        cell.set(user: viewModel.users[userIndex])
                    }
                    
                    return cell
                    
                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextImageCellReuseIdentifier, for: indexPath) as! PostTextImageCell
                    cell.delegate = self
                    cell.postTextView.isSelectable = false
                    cell.viewModel = PostViewModel(post: viewModel.posts[indexPath.row])
                    
                    if let userIndex = viewModel.users.firstIndex(where: { $0.uid == currentPost.uid }) {
                        cell.set(user: viewModel.users[userIndex])
                    }
                    
                    return cell
                    
                case .link:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postLinkCellReuseIdentifier, for: indexPath) as! PostLinkCell
                    
                    cell.delegate = self
                    cell.postTextView.isSelectable = false
                    cell.viewModel = PostViewModel(post: viewModel.posts[indexPath.row])
                    
                    if let userIndex = viewModel.users.firstIndex(where: { $0.uid == currentPost.uid }) {
                        cell.set(user: viewModel.users[userIndex])
                    }
                    
                    return cell
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    private func deletePost(withId id: String, at indexPath: IndexPath) {

        displayAlert(withTitle: AppStrings.Alerts.Title.deletePost, withMessage: AppStrings.Alerts.Subtitle.deletePost, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.deletePost(forId: id) { [weak self] error in
                guard let strongSelf = self else { return }
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.postDidChangeVisible(postId: id)
                    
                    strongSelf.viewModel.posts.remove(at: indexPath.item)
                    strongSelf.collectionView.reloadData()
                    
                    let popupView = PopUpBanner(title: AppStrings.PopUp.deletePost, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                    popupView.showTopPopup(inView: strongSelf.view)
                }
            }
        }
    }
    
    private func handleLikeUnLike(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        let postId = post.postId
        let didLike = viewModel.posts[indexPath.row].didLike
        
        postDidChangeLike(postId: postId, didLike: didLike)

        cell.viewModel?.post.didLike.toggle()
        viewModel.posts[indexPath.row].didLike.toggle()
        
        cell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        viewModel.posts[indexPath.row].likes = post.didLike ? post.likes - 1 : post.likes + 1
    }
    
    func handleBookmarkUnbookmark(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        let postId = post.postId
        let didBookmark = viewModel.posts[indexPath.row].didBookmark
        
        postDidChangeBookmark(postId: postId, didBookmark: didBookmark)

        cell.viewModel?.post.didBookmark.toggle()
        viewModel.posts[indexPath.row].didBookmark.toggle()
    }
}

//MARK: - HomeCellDelegate

extension PostsViewController: PostCellDelegate {
    
    func cell(showURL urlString: String) {
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                presentSafariViewController(withURL: url)
            } else {
                presentWebViewController(withURL: url)
            }
        }
    }
    
    func cell(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(didTapMenuOptionsFor post: Post, option: PostMenu) {
        switch option {
        case .delete:
            if let index = viewModel.posts.firstIndex(where: { $0.postId == post.postId }) {
                deletePost(withId: post.postId, at: IndexPath(item: index, section: 0))
            }
        case .edit:
            let controller = EditPostViewController(post: post)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
        case .report:
            let controller = ReportViewController(source: .post, userId: post.uid, contentId: post.postId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
            
        case .reference:
            guard let referenceKind = post.reference, let tab = tabBarController as? MainTabController else { return }
            let controller = ReferenceMenuViewController(postId: post.postId, kind: referenceKind)
            controller.delegate = self
            controller.modalPresentationStyle = .overCurrentContext
            tab.showMenu(controller)
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) {
        let controller = DetailsPostViewController(post: post, user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: UIImageView) {
        guard let img = image.image else { return }
        let controller = ContentImageViewController(image: img, navVC: navigationController)
        let navVC = UINavigationController(rootViewController: controller)
        navVC.setNavigationBarHidden(true, animated: false)
        navVC.modalPresentationStyle = .overFullScreen
        present(navVC, animated: true)
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
        guard let currentUid = UserDefaults.getUid(), currentUid == post.uid else { return }
        let controller = LikesViewController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        let controller = DetailsPostViewController(post: post, user: user)
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
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func scrollCollectionViewToTop() {
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

extension PostsViewController {
    func getMorePosts() {
        viewModel.getMorePosts { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
}

extension PostsViewController: ReferenceMenuViewControllerDelegate {
    
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

extension PostsViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        viewModel.networkError = false
        viewModel.loaded = false
        
        collectionView.reloadData()
        
        fetchFirstPostsGroup()
    }
}

//MARK: - PostChangesDelegate

extension PostsViewController: PostChangesDelegate {
    func postDidChangeComment(postId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }
    
    func postDidChangeVisible(postId: String) {
        viewModel.currentNotification = true
        ContentManager.shared.visiblePostChange(postId: postId)
    }
    
    @objc func postVisibleChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostVisibleChange {
            if let index = viewModel.posts.firstIndex(where: { $0.postId == change.postId }) {
                viewModel.posts.remove(at: index)
                collectionView.reloadData()
            }
        }
    }
    
    func postDidChangeComment(postId: String, comment: Comment, action: CommentAction) {
        fatalError()
    }
    
    func postDidChangeBookmark(postId: String, didBookmark: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.bookmarkPostChange(postId: postId, didBookmark: !didBookmark)
    }
    
    func postDidChangeLike(postId: String, didLike: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.likePostChange(postId: postId, didLike: !didLike)
    }
    
    @objc func postBookmarkChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostBookmarkChange {
            if let index = viewModel.posts.firstIndex(where: { $0.postId == change.postId }) {
                viewModel.posts[index].didBookmark = change.didBookmark
                collectionView.reloadData()
            }
        }
    }
    
    @objc func postLikeChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostLikeChange {
            if let index = viewModel.posts.firstIndex(where: { $0.postId == change.postId }) {
                let likes = viewModel.posts[index].likes
                viewModel.posts[index].likes = change.didLike ? likes + 1 : likes - 1
                viewModel.posts[index].didLike = change.didLike
                collectionView.reloadData()
            }
        }
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? PostCommentChange {
            if let index = viewModel.posts.firstIndex(where: { $0.postId == change.postId }), change.path.isEmpty {
                let comments = viewModel.posts[index].numberOfComments
                
                switch change.action {
                case .add:
                    viewModel.posts[index].numberOfComments = comments + 1
                case .remove:
                    viewModel.posts[index].numberOfComments = comments - 1
                case .edit:
                    break
                }
                
                collectionView.reloadData()
            }
        }
    }
    
    @objc func postEditChange(_ notification: NSNotification) {
        if let change = notification.object as? PostEditChange {
            let post = change.post
            if let index = viewModel.posts.firstIndex(where: { $0.postId == post.postId }) {
                viewModel.posts[index] = post
                collectionView.reloadData()
            }
        }
    }
}

// MARK: - User Changes

extension PostsViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            if let index = viewModel.users.firstIndex(where: { $0.uid! == user.uid! }) {
                viewModel.users[index] = user
                collectionView.reloadData()
            }
        }
    }
}


    
