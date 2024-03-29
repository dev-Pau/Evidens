//
//  HashtagViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/7/23.
//

import UIKit

private let loadingHeaderReuseIdentifier = "loadingHeaderReuseIdentifier"

private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseImageCellReuseIdentifier = "CaseImageCellReuseIdentifier"

private let postTextCellReuseIdentifier = "PostTextCellReuseIdentifier"
private let postImageCellReuseIdentifier = "PostImageCellReuseIdentifier"
private let postLinkCellReuseIdentnifier = "PostLinkCellReuseIdentifier"

private let emptyHashtagCellReuseIdentifier = "EmptyBookmarkCellCaseReuseIdentifier"

private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"

class HashtagViewController: UIViewController {
    
    private var viewModel: HashtagViewModel
    private var hashtagToolbar = BookmarkToolbar()
    private var spacingView = SpacingView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .systemBackground
        scrollView.bounces = false
        return scrollView
    }()
    
    private var casesCollectionView: UICollectionView!
    private var postsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureNotificationObservers()
        fetchCases()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewModel.isLayoutFirstLoad {
            configure()
            viewModel.isLayoutFirstLoad = true
        }
    }
    
    init(hashtag: String) {
        self.viewModel = HashtagViewModel(hashtag: hashtag)
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        navigationItem.title = viewModel.title()
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        casesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createCaseLayout())
        postsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createPostLayout())
        
        casesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        postsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        spacingView.translatesAutoresizingMaskIntoConstraints = false

        casesCollectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        casesCollectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        postsCollectionView.register(PostTextCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        postsCollectionView.register(PostTextImageCell.self, forCellWithReuseIdentifier: postImageCellReuseIdentifier)
        postsCollectionView.register(PostLinkCell.self, forCellWithReuseIdentifier: postLinkCellReuseIdentnifier)
        
        casesCollectionView.register(LoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        postsCollectionView.register(LoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        
        postsCollectionView.register(SecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyHashtagCellReuseIdentifier)
        casesCollectionView.register(SecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyHashtagCellReuseIdentifier)
        
        postsCollectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        casesCollectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        
        view.addSubviews(hashtagToolbar, scrollView)
        
        scrollView.addSubviews(casesCollectionView, spacingView, postsCollectionView)
        
        NSLayoutConstraint.activate([
            hashtagToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hashtagToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hashtagToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hashtagToolbar.heightAnchor.constraint(equalToConstant: 50),
            
            scrollView.topAnchor.constraint(equalTo: hashtagToolbar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.frame.width + 10),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            casesCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            casesCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            casesCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            casesCollectionView.bottomAnchor.constraint(equalTo: UIDevice.isPad ? view.bottomAnchor : view.safeAreaLayoutGuide.bottomAnchor),

            spacingView.topAnchor.constraint(equalTo: casesCollectionView.topAnchor),
            spacingView.leadingAnchor.constraint(equalTo: casesCollectionView.trailingAnchor),
            spacingView.widthAnchor.constraint(equalToConstant: 10),
            spacingView.bottomAnchor.constraint(equalTo: casesCollectionView.bottomAnchor),
            
            postsCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            postsCollectionView.leadingAnchor.constraint(equalTo: spacingView.trailingAnchor),
            postsCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            postsCollectionView.bottomAnchor.constraint(equalTo: casesCollectionView.bottomAnchor),
        ])
        
        scrollView.delegate = self

        scrollView.contentSize.width = view.frame.width * 2 + 2 * 10
        
        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
        
        hashtagToolbar.toolbarDelegate = self
        
        casesCollectionView.reloadData()
        postsCollectionView.reloadData()
    }
    
    private func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(postLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.postLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postVisibleChange(_:)), name: NSNotification.Name(AppPublishers.Names.postVisibility), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.postBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.postComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postEditChange(_:)), name: NSNotification.Name(AppPublishers.Names.postEdit), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseVisibleChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseVisibility), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseRevisionChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseRevision), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseSolveChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseSolve), object: nil)
    }
    
    private func createCaseLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            let size: NSCollectionLayoutDimension = UIDevice.isPad ? .estimated(800) : .estimated(500)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: size)
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.viewModel.caseLoaded {
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        
        return layout
    }
    
    private func createPostLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let size: NSCollectionLayoutDimension = UIDevice.isPad ? .estimated(800) : .estimated(500)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: size)
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.viewModel.postLoaded {
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        
        return layout
    }
    
    private func fetchCases() {
        viewModel.getCases { [weak self] in
            guard let strongSelf = self, strongSelf.viewModel.isLayoutFirstLoad else { return }
            strongSelf.casesCollectionView.reloadData()
        }
    }
    
    private func fetchPosts() {
        viewModel.getPosts { [weak self] in
            guard let strongSelf = self, strongSelf.viewModel.isLayoutFirstLoad else { return }
            strongSelf.postsCollectionView.reloadData()
        }
    }
    
    private func fetchMoreCases() {
        viewModel.getMoreCases { [weak self] in
            guard let strongSelf = self, strongSelf.viewModel.isLayoutFirstLoad else { return }
            strongSelf.casesCollectionView.reloadData()
        }
    }
    
    private func fetchMorePosts() {
        viewModel.getMorePosts { [weak self] in
            guard let strongSelf = self, strongSelf.viewModel.isLayoutFirstLoad else { return }
            strongSelf.postsCollectionView.reloadData()
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
                    strongSelf.postsCollectionView.reloadData()
                    
                    let popupView = PopUpBanner(title: AppStrings.PopUp.deletePost, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                    popupView.showTopPopup(inView: strongSelf.view)
                }
            }
        }
    }
    
    private func handleLikeUnlike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didLike = viewModel.cases[indexPath.row].didLike
        
        caseDidChangeLike(caseId: caseId, didLike: didLike)

        cell.viewModel?.clinicalCase.didLike.toggle()
        viewModel.cases[indexPath.row].didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        viewModel.cases[indexPath.row].likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
    }
    
    
    func handleBookmarkUnbookmark(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didBookmark = viewModel.cases[indexPath.row].didBookmark
        caseDidChangeBookmark(caseId: caseId, didBookmark: didBookmark)

        cell.viewModel?.clinicalCase.didBookmark.toggle()
        viewModel.cases[indexPath.row].didBookmark.toggle()
    }
    
    private func deleteCase(withId id: String, at indexPath: IndexPath, privacy: CasePrivacy) {

        displayAlert(withTitle: AppStrings.Alerts.Title.deleteCase, withMessage: AppStrings.Alerts.Subtitle.deleteCase, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let _ = self else { return }
            
            CaseService.deleteCase(withId: id, privacy: privacy) { [weak self] error in

                guard let strongSelf = self else { return }
                if let error {
                    switch error {
                    case .notFound:
                        strongSelf.displayAlert(withTitle: AppStrings.Alerts.Subtitle.deleteError)
                    default:
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    }
                } else {
                    strongSelf.caseDidChangeVisible(caseId: id)
                    
                    strongSelf.viewModel.cases.remove(at: indexPath.item)
                    
                    if strongSelf.viewModel.cases.isEmpty {
                        strongSelf.casesCollectionView.reloadData()
                    } else {
                        strongSelf.casesCollectionView.deleteItems(at: [indexPath])
                    }
                    
                    let popupView = PopUpBanner(title: AppStrings.PopUp.deleteCase, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                    popupView.showTopPopup(inView: strongSelf.view)
                }
            }
        }
    }
}

extension HashtagViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == casesCollectionView {
            return viewModel.caseLoaded ? viewModel.cases.isEmpty ? 1 : viewModel.cases.count : 0
        } else {
            return viewModel.postLoaded ? viewModel.posts.isEmpty ? 1 : viewModel.posts.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! LoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == casesCollectionView {
            if viewModel.networkFailure {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.set(AppStrings.Network.Issues.Case.title)
                cell.delegate = self
                return cell
            } else {
                if viewModel.cases.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyHashtagCellReuseIdentifier, for: indexPath) as! SecondaryEmptyCell
                    
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Case.Empty.emptyCaseTitle, description: AppStrings.Content.Case.Empty.hashtag(viewModel.hashtag), content: .dismiss)
                    cell.delegate = self
                    return cell
                } else {
                    let currentCase = viewModel.cases[indexPath.row]
                    
                    switch currentCase.kind {
                    case .text:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                        cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                        cell.delegate = self
                        
                        guard currentCase.privacy != .anonymous else {
                            return cell
                        }
                        
                        if let user = viewModel.caseUsers.first(where: { $0.uid! == currentCase.uid }) {
                            cell.set(user: user)
                        }
                        return cell
                        
                    case .image:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                        cell.delegate = self
                        cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                        
                        guard currentCase.privacy != .anonymous else {
                            return cell
                        }
                        
                        if let user = viewModel.caseUsers.first(where: { $0.uid! == currentCase.uid }) {
                            cell.set(user: user)
                        }
                        return cell
                    }
                }
            }
        } else {
            if viewModel.networkFailure {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.set(AppStrings.Network.Issues.Post.title)
                cell.delegate = self
                return cell
            } else {
                if viewModel.posts.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyHashtagCellReuseIdentifier, for: indexPath) as! SecondaryEmptyCell
                    cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Post.Empty.emptyPostTitle, description: AppStrings.Content.Post.Empty.hashtag(viewModel.hashtag), content: .dismiss)
                    cell.delegate = self
                    return cell
                } else {
                    let currentPost = viewModel.posts[indexPath.row]
                    
                    switch currentPost.kind {
                        
                    case .text:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextCellReuseIdentifier, for: indexPath) as! PostTextCell
                        cell.delegate = self
                        cell.viewModel = PostViewModel(post: currentPost)
                        
                        if let user = viewModel.postUsers.first(where: { $0.uid! == currentPost.uid }) {
                            cell.set(user: user)
                        }
                        
                        return cell
                    case .image:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postImageCellReuseIdentifier, for: indexPath) as! PostTextImageCell
                        cell.delegate = self
                        cell.viewModel = PostViewModel(post: currentPost)
                        if let user = viewModel.postUsers.first(where: { $0.uid! == currentPost.uid }) {
                            cell.set(user: user)
                        }
                        
                        return cell
                    case .link:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postLinkCellReuseIdentnifier, for: indexPath) as! PostLinkCell
                    cell.delegate = self
                    cell.viewModel = PostViewModel(post: currentPost)
                    if let user = viewModel.postUsers.first(where: { $0.uid! == currentPost.uid }) {
                        cell.set(user: user)
                    }
                    
                    return cell
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == casesCollectionView {
            guard !viewModel.cases.isEmpty else { return }
            if let user = viewModel.caseUsers.first(where: { $0.uid! == viewModel.cases[indexPath.row].uid }) {
                let controller = DetailsCaseViewController(clinicalCase: viewModel.cases[indexPath.row], user: user)
                navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            guard !viewModel.posts.isEmpty else { return }
            if let user = viewModel.postUsers.first(where: { $0.uid! == viewModel.posts[indexPath.row].uid }) {
                let controller = DetailsPostViewController(post: viewModel.posts[indexPath.row], user: user)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension HashtagViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        guard !viewModel.isScrollingHorizontally else {
            return
        }
        
        if offsetY > contentHeight - height {
            switch viewModel.scrollIndex {
            case 0:
                fetchMoreCases()
            case 1:
                fetchMorePosts()
            default:
                break
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        if scrollView == casesCollectionView || scrollView == postsCollectionView {
            viewModel.isScrollingHorizontally = false
            
        } else if scrollView == self.scrollView {
            viewModel.isScrollingHorizontally = true
            hashtagToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
            
            if scrollView.contentOffset.x > view.frame.width * 0.2 && !viewModel.didFetchPosts {
                fetchPosts()
            }
            
            switch scrollView.contentOffset.x {
            case 0 ..< view.frame.width + 10:
                viewModel.scrollIndex = 0
            case view.frame.width + 10 ..< 2 * (view.frame.width + 10):
                viewModel.scrollIndex = 1
            default:
                break
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollView.isUserInteractionEnabled = true
        casesCollectionView.isScrollEnabled = true
        postsCollectionView.isScrollEnabled = true
    }
}

extension HashtagViewController: BookmarkToolbarDelegate {
    func didTapIndex(_ index: Int) {
        
        switch viewModel.scrollIndex {
        case 0:
            casesCollectionView.setContentOffset(casesCollectionView.contentOffset, animated: false)
        case 1:
            postsCollectionView.setContentOffset(postsCollectionView.contentOffset, animated: false)
        default:
            break
        }

        let scrollX = index == 0 ? 0 : scrollView.contentSize.width / CGFloat(2) * CGFloat(index)
        
        guard viewModel.isFirstLoad else {
            viewModel.isFirstLoad.toggle()
            scrollView.setContentOffset(CGPoint(x: scrollX, y: 0), animated: true)
            viewModel.scrollIndex = index
            return
        }

        casesCollectionView.isScrollEnabled = false
        postsCollectionView.isScrollEnabled = false
        self.scrollView.isUserInteractionEnabled = false
        
        scrollView.setContentOffset(CGPoint(x: scrollX, y: 0), animated: true)
        viewModel.scrollIndex = index
    }
}


extension HashtagViewController: SecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        navigationController?.popViewController(animated: true)
    }
}

extension HashtagViewController: PostCellDelegate {
    
    func cell(showURL urlString: String) {
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                presentSafariViewController(withURL: url)
            }
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        let controller = DetailsPostViewController(post: post, user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let indexPath = postsCollectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
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
            nav.modalPresentationStyle = UIModalPresentationStyle.getBasePresentationStyle()
            present(nav, animated: true)
            
        case .report:
            let controller = ReportViewController(source: .post, userId: post.uid, contentId: post.postId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = UIModalPresentationStyle.getBasePresentationStyle()
            self.present(navVC, animated: true)
            
        case .reference:
            guard let referenceKind = post.reference, let tab = tabBarController as? MainTabController else { return }
            let controller = ReferenceMenuViewController(postId: post.postId, kind: referenceKind)
            controller.delegate = self
            tab.showMenu(controller)
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        guard let indexPath = postsCollectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
        handleBookmarkUnbookmark(for: currentCell, at: indexPath)
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
    
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) {
        let controller = DetailsPostViewController(post: post, user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension HashtagViewController: CaseCellDelegate {
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        guard let currentUid = UserDefaults.getUid(), currentUid == clinicalCase.uid else { return }
        let controller = LikesViewController(clinicalCase: clinicalCase)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let indexPath = casesCollectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
        handleLikeUnlike(for: currentCell, at: indexPath)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        guard let indexPath = casesCollectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
        handleBookmarkUnbookmark(for: currentCell, at: indexPath)
    }
    
    func clinicalCase(didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete:
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                deleteCase(withId: clinicalCase.caseId, at: IndexPath(item: index , section: 0), privacy: clinicalCase.privacy)
            }

        case .revision:
            guard let tab = tabBarController as? MainTabController else { return }
            guard let currentUser = tab.user else { return }
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: currentUser)
            navigationController?.pushViewController(controller, animated: true)
        case .solve:
            let controller = CaseDiagnosisViewController(clinicalCase: clinicalCase)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = UIModalPresentationStyle.getBasePresentationStyle()
            present(nav, animated: true)
            
        case .report:
            let controller = ReportViewController(source: .clinicalCase, userId: clinicalCase.uid, contentId: clinicalCase.caseId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = UIModalPresentationStyle.getBasePresentationStyle()
            self.present(navVC, animated: true)
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        if let userIndex = viewModel.caseUsers.firstIndex(where: { $0.uid == clinicalCase.uid }) {
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: viewModel.caseUsers[userIndex])
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: UIImageView) {
        guard let img = image.image else { return }
        let controller = ContentImageViewController(image: img, navVC: navigationController)
        let navVC = UINavigationController(rootViewController: controller)
        navVC.setNavigationBarHidden(true, animated: false)
        navVC.modalPresentationStyle = .overFullScreen
        present(navVC, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User?) {
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - Content Changes

extension HashtagViewController {
    
    func postDidChangeLike(postId: String, didLike: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.likePostChange(postId: postId, didLike: !didLike)
    }
    
    func postDidChangeBookmark(postId: String, didBookmark: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.bookmarkPostChange(postId: postId, didBookmark: !didBookmark)
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
                postsCollectionView.reloadData()
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
                if let cell = postsCollectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? HomeCellProtocol {

                    let likes = viewModel.posts[index].likes
                    
                    viewModel.posts[index].likes = change.didLike ? likes + 1 : likes - 1
                    viewModel.posts[index].didLike = change.didLike
                    
                    currentCell.viewModel?.post.didLike = change.didLike
                    currentCell.viewModel?.post.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
    
    @objc func postBookmarkChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostBookmarkChange {
            if let index = viewModel.posts.firstIndex(where: { $0.postId == change.postId }) {
                if let cell = postsCollectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? HomeCellProtocol {
                    viewModel.posts[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.post.didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostCommentChange {
            if let index = viewModel.posts.firstIndex(where: { $0.postId == change.postId }), change.path.isEmpty {
                if let cell = postsCollectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? HomeCellProtocol {
                    
                    let comments = viewModel.posts[index].numberOfComments

                    switch change.action {
                        
                    case .add:
                        viewModel.posts[index].numberOfComments = comments + 1
                        currentCell.viewModel?.post.numberOfComments = comments + 1
                    case .remove:
                        viewModel.posts[index].numberOfComments = comments - 1
                        currentCell.viewModel?.post.numberOfComments = comments - 1
                    case .edit:
                        break
                    }
                }
            }
        }
    }
    
    
    @objc func postEditChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostEditChange {
            let post = change.post
            if let index = viewModel.posts.firstIndex(where: { $0.postId == post.postId }) {
                viewModel.posts[index] = post
                postsCollectionView.reloadData()
            }
        } 
    }
}

//MARK: - Case Changes

extension HashtagViewController {
    
    func caseDidChangeLike(caseId: String, didLike: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.likeCaseChange(caseId: caseId, didLike: !didLike)
    }
    
    func caseDidChangeBookmark(caseId: String, didBookmark: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.bookmarkCaseChange(caseId: caseId, didBookmark: !didBookmark)
    }
    
    func caseDidChangeVisible(caseId: String) {
        viewModel.currentNotification = true
        ContentManager.shared.visibleCaseChange(caseId: caseId)
    }
    
    @objc func caseVisibleChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseVisibleChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.cases.remove(at: index)
                casesCollectionView.reloadData()
            }
        }
    }
    
    @objc func caseLikeChange(_ notification: NSNotification) {
        
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseLikeChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    let likes = viewModel.cases[index].likes
                    
                    viewModel.cases[index].didLike = change.didLike
                    viewModel.cases[index].likes = change.didLike ? likes + 1 : likes - 1
                    
                    cell.viewModel?.clinicalCase.didLike = change.didLike
                    cell.viewModel?.clinicalCase.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseBookmarkChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.didBookmark = change.didBookmark
                    viewModel.cases[index].didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseCommentChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    let comments = viewModel.cases[index].numberOfComments
                    
                    switch change.action {
                        
                    case .add:
                        viewModel.cases[index].numberOfComments = comments + 1
                        cell.viewModel?.clinicalCase.numberOfComments = comments + 1
                    case .remove:
                        viewModel.cases[index].numberOfComments = comments - 1
                        cell.viewModel?.clinicalCase.numberOfComments = comments - 1
                    case .edit:
                        break
                    }
                }
            }
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseRevisionChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.revision = .update
                    viewModel.cases[index].revision = .update
                    casesCollectionView.reloadData()
                }
            }
        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseSolveChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.phase = .solved
                    viewModel.cases[index].phase = .solved
                    
                    if let diagnosis = change.diagnosis {
                        viewModel.cases[index].revision = diagnosis
                        cell.viewModel?.clinicalCase.revision = diagnosis
                    }
                    
                    casesCollectionView.reloadData()
                }
            }
        }
    }
}

extension HashtagViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {

        if let user = notification.userInfo!["user"] as? User {
            
            if let postIndex = viewModel.postUsers.firstIndex(where: { $0.uid! == user.uid! }) {
                viewModel.postUsers[postIndex] = user
                postsCollectionView.reloadData()
            }
            
            if let caseIndex = viewModel.caseUsers.firstIndex(where: { $0.uid! == user.uid!}) {
                viewModel.caseUsers[caseIndex] = user
                casesCollectionView.reloadData()
            }
        }
    }
}

extension HashtagViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        viewModel.networkFailure = false
        
        switch viewModel.scrollIndex {
        case 0:
            viewModel.caseLoaded = false
            casesCollectionView.reloadData()
            fetchCases()
        case 1:
            viewModel.postLoaded = false
            postsCollectionView.reloadData()
            fetchPosts()
        default:
            break
        }
    }
}

extension HashtagViewController: ReferenceMenuViewControllerDelegate {
    func didTapReference(reference: Reference) {
        switch reference.option {
        case .link:
            if let url = URL(string: reference.referenceText) {
                if UIApplication.shared.canOpenURL(url) {
                    presentSafariViewController(withURL: url)
                }
            }
        case .citation:
            let wordToSearch = reference.referenceText
            if let encodedQuery = wordToSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: AppStrings.URL.googleQuery + encodedQuery) {
                    if UIApplication.shared.canOpenURL(url) {
                        presentSafariViewController(withURL: url)
                    }
                }
            }
        }
    }
}
