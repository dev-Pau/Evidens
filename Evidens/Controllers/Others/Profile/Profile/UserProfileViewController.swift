//
//  UserProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/9/23.
//

import UIKit

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"

private let postTextCellReuseIdentifier = "PostTextCellReuseIdentifier"
private let postTextImageCellReuseIdentifier = "PostTextImageCellReuseIdentifier"
private let postLinkCellReuseIdentifier = "PostLinkCellReuseIdentifier"

private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"

private let commentsCellReuseIdentifier = "CommentsCellReuseIdentifier"

private let profileAboutCellReuseIdentifier = "ProfileAboutCellReuseIdentifier"
private let profileHeaderReuseIdentifier = "ProfileHeaderReuseIdentifier"
private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"

class UserProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    private var viewModel: UserProfileViewModel
    
    private var scrollView: UIScrollView!
    private var postsCollectionView: UICollectionView!
    private var casesCollectionView: UICollectionView!
    private var repliesCollectionView: UICollectionView!

    private var topHeaderAnchorConstraint: NSLayoutConstraint!
    private var topToolbarAnchorConstraint: NSLayoutConstraint!
    private var heightToolbarAnchorConstraint: NSLayoutConstraint!
 
    private var profileToolbar: ProfileToolbar!
    private var postsSpacingView = SpacingView()
    private var casesSpacingView = SpacingView()
    
    private var headerTopInset: CGFloat!
    
    private var zoomTransitioning = ZoomTransitioning()

    private var pageView: PageUnavailableView!
    
    private let activityIndicator = LoadingIndicatorView(frame: .zero)

    private let profileNameView = ProfileNameView()
    
    private let padding: CGFloat = 10.0

    private var toolbarHeight = 50.0
    private let padPadding: CGFloat = UIDevice.isPad ? 30 : 0
    
    init(user: User) {
        self.viewModel = UserProfileViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(uid: String) {
        self.viewModel = UserProfileViewModel(uid: uid)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let phase = viewModel.user.phase
        
        switch phase {
            
        case .category, .name, .username:
            break
        case .identity, .pending, .review:
            
            guard viewModel.user.isCurrentUser else {
                return
            }
            
            if !viewModel.collectionsLoaded && viewModel.uid == nil {
                viewModel.collectionsLoaded = true
            }
        case .verified:
            if !viewModel.collectionsLoaded && viewModel.uid == nil {
                viewModel.collectionsLoaded = true
            }
        case .deactivate, .ban, .deleted:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoading()
        configureNotificationObservers()
        getUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }
    
    private func configureLoading() {
        
        let appearance = UINavigationBarAppearance.profileAppearance()
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.standardAppearance = appearance
        
        view.backgroundColor = .systemBackground
        scrollView = UIScrollView()
        scrollView.isHidden = true
        
        view.addSubview(scrollView)

        activityIndicator.frame = view.bounds
        
        view.addSubviews(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: view.frame.height),
            activityIndicator.widthAnchor.constraint(equalToConstant: view.frame.height),
        ])
    }

    private func configureNavigationBar() {
        title = viewModel.user.name()
    }
    
    private func configure() {
        let phase = viewModel.user.phase

        switch phase {
        case .category, .name, .username:
            configurePage()
            
        case .identity, .pending, .review:

            guard viewModel.user.isCurrentUser else {
                configurePage()
                return
            }
            
            configureUI()
            fetchUserContent()
            
        case .verified:
            configureUI()
            fetchUserContent()
        case .deactivate, .ban, .deleted:
            configurePage()
        }
    }
    
    private func configurePage() {
        view.backgroundColor = .systemBackground
        
        activityIndicator.stop()
        activityIndicator.removeFromSuperview()
       
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        scrollView.delegate = self
        
        pageView = PageUnavailableView()
        pageView.delegate = self
        
        scrollView.addSubview(pageView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.frame.width),
            
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
        ])
        
        scrollView.isHidden = false
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false

        scrollView.backgroundColor = .systemBackground
        scrollView.delegate = self
        
        casesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: casesLayout())
        postsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: postsLayout())
        repliesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: commentsLayout())
     
        casesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        postsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        repliesCollectionView.translatesAutoresizingMaskIntoConstraints = false
      
        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
        casesCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        casesCollectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        casesCollectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        casesCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)

        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        postsCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        postsCollectionView.register(PostTextCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        postsCollectionView.register(PostTextImageCell.self, forCellWithReuseIdentifier: postTextImageCellReuseIdentifier)
        postsCollectionView.register(PostLinkCell.self, forCellWithReuseIdentifier: postLinkCellReuseIdentifier)
        postsCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
       
        repliesCollectionView.delegate = self
        repliesCollectionView.dataSource = self
        repliesCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        repliesCollectionView.register(UserProfileCommentCell.self, forCellWithReuseIdentifier: commentsCellReuseIdentifier)
        repliesCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        
        casesSpacingView.translatesAutoresizingMaskIntoConstraints = false
        postsSpacingView.translatesAutoresizingMaskIntoConstraints = false

        profileToolbar = ProfileToolbar()
        profileToolbar.toolbarDelegate = self
        profileNameView.delegate = self
        
        heightToolbarAnchorConstraint = profileToolbar.heightAnchor.constraint(equalToConstant: toolbarHeight)
        
        scrollView.addSubviews(casesCollectionView, postsCollectionView, repliesCollectionView, casesSpacingView, postsSpacingView, profileNameView)

        if UIDevice.isPad {
            let line = UIView()
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = separatorColor
            
            scrollView.addSubviews(line, profileToolbar)

            topToolbarAnchorConstraint = profileToolbar.topAnchor.constraint(equalTo: scrollView.topAnchor)
            topHeaderAnchorConstraint = profileNameView.topAnchor.constraint(equalTo: profileToolbar.bottomAnchor)
            
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                scrollView.widthAnchor.constraint(equalToConstant: view.frame.width + padding),
                
                topHeaderAnchorConstraint,
                profileNameView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                profileNameView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

                topToolbarAnchorConstraint,
                profileToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                profileToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                heightToolbarAnchorConstraint,
                
                line.topAnchor.constraint(equalTo: profileNameView.bottomAnchor, constant: padPadding - 1),
                line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                line.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                line.heightAnchor.constraint(equalToConstant: 0.4),
                
                postsCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                postsCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                postsCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
                postsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                
                postsSpacingView.topAnchor.constraint(equalTo: line.bottomAnchor),
                postsSpacingView.leadingAnchor.constraint(equalTo: postsCollectionView.trailingAnchor),
                postsSpacingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                postsSpacingView.widthAnchor.constraint(equalToConstant: 10),

                casesCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                casesCollectionView.leadingAnchor.constraint(equalTo: postsSpacingView.trailingAnchor),
                casesCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
                casesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                
                casesSpacingView.topAnchor.constraint(equalTo: line.bottomAnchor),
                casesSpacingView.leadingAnchor.constraint(equalTo: casesCollectionView.trailingAnchor),
                casesSpacingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                casesSpacingView.widthAnchor.constraint(equalToConstant: 10),

                repliesCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                repliesCollectionView.leadingAnchor.constraint(equalTo: casesSpacingView.trailingAnchor),
                repliesCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
                repliesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        } else {
            scrollView.addSubview(profileToolbar)

            topHeaderAnchorConstraint = profileNameView.topAnchor.constraint(equalTo: scrollView.topAnchor)
            topToolbarAnchorConstraint = profileToolbar.topAnchor.constraint(equalTo: scrollView.topAnchor)
            
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                scrollView.widthAnchor.constraint(equalToConstant: view.frame.width + padding),
             
                topHeaderAnchorConstraint,
                profileNameView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                profileNameView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

                topToolbarAnchorConstraint,
                profileToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                profileToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                heightToolbarAnchorConstraint,
                
                casesCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                casesCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                casesCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
                casesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                
                casesSpacingView.topAnchor.constraint(equalTo: profileToolbar.bottomAnchor),
                casesSpacingView.leadingAnchor.constraint(equalTo: casesCollectionView.trailingAnchor),
                casesSpacingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                casesSpacingView.widthAnchor.constraint(equalToConstant: 10),

                postsCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                postsCollectionView.leadingAnchor.constraint(equalTo: casesSpacingView.trailingAnchor),
                postsCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
                postsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                
                postsSpacingView.topAnchor.constraint(equalTo: profileToolbar.bottomAnchor),
                postsSpacingView.leadingAnchor.constraint(equalTo: postsCollectionView.trailingAnchor),
                postsSpacingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                postsSpacingView.widthAnchor.constraint(equalToConstant: 10),

                repliesCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                repliesCollectionView.leadingAnchor.constraint(equalTo: postsSpacingView.trailingAnchor),
                repliesCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
                repliesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        }
        
        scrollView.contentSize.width = view.frame.width * 3 + 3 * 10

        casesCollectionView.backgroundColor = .systemBackground
        postsCollectionView.backgroundColor = .systemBackground
        repliesCollectionView.backgroundColor = .systemBackground
    }
    
    private func configureUser(withNewUser user: User? = nil) {
        
        if let user {

            viewModel.set(user: user)
            configureNavigationBar()
            
            let group = DispatchGroup()
            
            viewModel.getWebsite(group)

            viewModel.fetchAboutText(group)
            
            group.notify(queue: .main) { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.casesCollectionView.reloadData()
                strongSelf.postsCollectionView.reloadData()
                strongSelf.repliesCollectionView.reloadData()
 
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.configureViewValues()
                }
            }
        } else {
            configureViewValues()
        }
    }
    
    private func configureViewValues() {
        profileNameView.set(viewModel: viewModel)
        
        let viewModel = ProfileHeaderViewModel(user: viewModel.user)
        profileNameView.configure(viewModel: viewModel)
        profileNameView.configureActionButton(viewModel: viewModel)

        view.layoutIfNeeded()

        toolbarHeight = self.viewModel.user.blockPhase != nil ? 0 : 50.0
        
        heightToolbarAnchorConstraint.constant = toolbarHeight
        profileToolbar.isHidden = self.viewModel.user.blockPhase != nil ? true : false
        scrollView.isScrollEnabled = self.viewModel.user.blockPhase != nil ? false : true
       
        headerTopInset = profileNameView.frame.height
        
        let paddingTop =  headerTopInset + toolbarHeight + padPadding
        
        casesCollectionView.contentInset.top = paddingTop
        casesCollectionView.verticalScrollIndicatorInsets.top = paddingTop
        
        postsCollectionView.contentInset.top = paddingTop
        postsCollectionView.verticalScrollIndicatorInsets.top = paddingTop
        
        repliesCollectionView.contentInset.top = paddingTop
        repliesCollectionView.verticalScrollIndicatorInsets.top = paddingTop

        scrollViewDidScroll(scrollView)
        scrollViewDidScroll(postsCollectionView)
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.postLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postVisibleChange(_:)), name: NSNotification.Name(AppPublishers.Names.postVisibility), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.postBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.postComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postEditChange(_:)), name: NSNotification.Name(AppPublishers.Names.postEdit), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseVisibleChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseVisibility), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseRevisionChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseRevision), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseSolveChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseSolve), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(followDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.followUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectionDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.connectUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(blockDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.blockUser), object: nil)
    }
    
    private func postsLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.posts.isEmpty ? .estimated(200) : .estimated(500))
            
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.viewModel.postsLoaded {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: ElementKind.sectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
            }
            
            return section
        }
        return layout
    }
    
    private func casesLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.cases.isEmpty ? .estimated(200) : .estimated(600))
            
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.viewModel.casesLoaded {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: ElementKind.sectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
            }
            
            return section
        }
        return layout
    }
    
    private func commentsLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.replies.isEmpty ? .estimated(200) : .estimated(300))
            
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.viewModel.repliesLoaded {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: ElementKind.sectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
            }
            
            return section
        }
        return layout
    }
    
    private func getUser() {
        if let _ = viewModel.uid {
            fetchUser()
        } else {
            configure()
        }
    }
   
    private func fetchUser() {
        viewModel.fetchUser { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configure()
        }
    }
    
    private func fetchUserContent() {
        viewModel.fetchUserContent { [weak self] error in
            guard let strongSelf = self else { return }

            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            } else {
                strongSelf.viewModel.collectionsLoaded = true
                strongSelf.dismissProgressIndicator()
                strongSelf.configureUser(withNewUser: nil)
                strongSelf.configureNavigationBar()
                strongSelf.activityIndicator.stop()
                strongSelf.activityIndicator.removeFromSuperview()
                strongSelf.casesCollectionView.reloadData()
                strongSelf.scrollView.isHidden = false
            }
        }
    }
    
    private func fetchPosts() {
        viewModel.fetchPosts { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.postsCollectionView.reloadData()
        }
    }
   
    func fetchComments() {
        viewModel.fetchComments { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.repliesCollectionView.reloadData()
        }
    }
}

extension UserProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        
        guard viewModel.collectionsLoaded else { return }
        
        if scrollView == casesCollectionView || scrollView == postsCollectionView || scrollView == repliesCollectionView {
            viewModel.isScrollingHorizontally = false
            
            let minimumContentHeight = visibleScreenHeight - toolbarHeight
            
            if viewModel.collectionsLoaded {
                casesCollectionView.contentInset.bottom = max(0, minimumContentHeight - casesCollectionView.contentSize.height)
                postsCollectionView.contentInset.bottom = max(0, minimumContentHeight - postsCollectionView.contentSize.height)
                repliesCollectionView.contentInset.bottom = max(0, minimumContentHeight - repliesCollectionView.contentSize.height)
            }
            
            if !UIDevice.isPad {
                switch viewModel.index {
                case 0:
                    topToolbarAnchorConstraint.constant = max(0, -(offset.y + postsCollectionView.contentInset.top - headerTopInset))
                    topHeaderAnchorConstraint.constant = -(offset.y + postsCollectionView.contentInset.top - padding)
                case 1:
                    topToolbarAnchorConstraint.constant = max(0, -(offset.y + casesCollectionView.contentInset.top - headerTopInset))
                    topHeaderAnchorConstraint.constant = -(offset.y + casesCollectionView.contentInset.top - padding)
                default:
                    topToolbarAnchorConstraint.constant = max(0, -(offset.y + repliesCollectionView.contentInset.top - headerTopInset))
                    topHeaderAnchorConstraint.constant = -(offset.y + repliesCollectionView.contentInset.top - padding)
                }
            } else {
                switch viewModel.index {
                case 0:
                    topHeaderAnchorConstraint.constant = -(offset.y + casesCollectionView.contentInset.top - padding)
                case 1:
                    topHeaderAnchorConstraint.constant = -(offset.y + postsCollectionView.contentInset.top - padding)
                default:
                    topHeaderAnchorConstraint.constant = -(offset.y + repliesCollectionView.contentInset.top - padding)
                }
            }
            
            if offset.y < -toolbarHeight {
                casesCollectionView.verticalScrollIndicatorInsets.top = -(offset.y)
                casesCollectionView.contentOffset.y = offset.y
                
                postsCollectionView.verticalScrollIndicatorInsets.top = -(offset.y)
                postsCollectionView.contentOffset.y = offset.y
                
                repliesCollectionView.verticalScrollIndicatorInsets.top = -(offset.y)
                repliesCollectionView.contentOffset.y = offset.y
            } else {
                
                switch viewModel.index {
                case 0:
                    postsCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, postsCollectionView.contentOffset.y))
                    repliesCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, repliesCollectionView.contentOffset.y))
                case 1:
                    casesCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, casesCollectionView.contentOffset.y))
                    repliesCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, repliesCollectionView.contentOffset.y))
                default:
                    postsCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, postsCollectionView.contentOffset.y))
                    casesCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, casesCollectionView.contentOffset.y))
                }
                
                switch viewModel.index {
                case 0:
                    casesCollectionView.verticalScrollIndicatorInsets.top = toolbarHeight
                case 1:
                    postsCollectionView.verticalScrollIndicatorInsets.top = toolbarHeight
                default:
                    repliesCollectionView.verticalScrollIndicatorInsets.top = toolbarHeight
                }
            }
        } else if scrollView == self.scrollView {

            viewModel.isScrollingHorizontally = true
            profileToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
            
            if scrollView.contentOffset.x > view.frame.width * 0.2 && !viewModel.isFetchingOrDidFetchPosts {
                fetchPosts()
            }
            
            if scrollView.contentOffset.x > view.frame.width * 1.2 && !viewModel.isFetchingOrDidFetchReplies {
                fetchComments()
            }
            
            switch offset.x {
            case 0 ..< view.frame.width + 10:
                viewModel.index = 0
            case view.frame.width + 10 ..< 2 * (view.frame.width + 10):
                viewModel.index = 1
            default:
                viewModel.index = 2
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        guard !viewModel.isScrollingHorizontally else {
            return
        }
        
        if offsetY > contentHeight - height {
            switch viewModel.index {
            case 0:
                fetchMoreCases()
            case 1:
                fetchMorePosts()
            case 2:
                fetchMoreReplies()
            default:
                break
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollView.isUserInteractionEnabled = true
        postsCollectionView.isScrollEnabled = true
        casesCollectionView.isScrollEnabled = true
        repliesCollectionView.isScrollEnabled = true
    }
    
    private func fetchMorePosts() {
        viewModel.fetchMorePosts { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.postsCollectionView.reloadData()
        }
    }
    
    private func fetchMoreCases() {
        viewModel.fetchMoreCases { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.casesCollectionView.reloadData()
        }
    }
    
    private func fetchMoreReplies() {
        viewModel.fetchMoreReplies { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.repliesCollectionView.reloadData()
        }
    }
}

extension UserProfileViewController: ProfileToolbarDelegate {
    func didTapIndex(_ index: Int) {
        
        switch viewModel.index {
        case 0:
            casesCollectionView.setContentOffset(casesCollectionView.contentOffset, animated: false)
        case 1:
            postsCollectionView.setContentOffset(postsCollectionView.contentOffset, animated: false)
        case 2:
            repliesCollectionView.setContentOffset(repliesCollectionView.contentOffset, animated: false)
        default:
            break
        }

        guard viewModel.isFirstLoad else {
            viewModel.isFirstLoad.toggle()
            scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width) + index * 10, y: 0), animated: true)
            viewModel.index = index
            return
        }
        
        postsCollectionView.isScrollEnabled = false
        casesCollectionView.isScrollEnabled = false
        repliesCollectionView.isScrollEnabled = false
        self.scrollView.isUserInteractionEnabled = false

        scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width) + index * 10, y: 0), animated: true)
        viewModel.index = index
    }
}

extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _ = viewModel.getBlockPhase() {
            return 1
        } else {
            if collectionView == postsCollectionView {
                return viewModel.postsLoaded ? viewModel.posts.isEmpty ? 1 : viewModel.posts.count : 0
            } else if collectionView == casesCollectionView {
                return viewModel.casesLoaded ? viewModel.cases.isEmpty ? 1 : viewModel.cases.count : 0
            } else {
                return viewModel.repliesLoaded ? viewModel.replies.isEmpty ? 1 : viewModel.replies.count : 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let phase = viewModel.getBlockPhase() {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
            
            switch phase {
            case .block:
                cell.set(withTitle: viewModel.user.getUsername() + AppStrings.Characters.space + AppStrings.Content.Block.blockTitle, withDescription: AppStrings.Content.Block.blockContent + AppStrings.Characters.space + viewModel.user.getUsername())
            case .blocked:
                cell.set(withTitle: AppStrings.Content.Block.blockedTitle, withDescription: AppStrings.Content.Block.blockedContent + AppStrings.Characters.space + viewModel.user.getUsername())
            }
            return cell
        } else {
            if collectionView == postsCollectionView {
                if viewModel.posts.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                    cell.set(withTitle: AppStrings.Content.Search.emptyTitle, withDescription: AppStrings.Content.Search.emptyContent)
                    return cell
                } else {
                    let currentPost = viewModel.posts[indexPath.row]
                    let kind = currentPost.kind
                    
                    switch kind {
                        
                    case .text:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextCellReuseIdentifier, for: indexPath) as! PostTextCell
                        cell.delegate = self
                        cell.viewModel = PostViewModel(post: viewModel.posts[indexPath.row])
                        cell.set(user: viewModel.user)
                        return cell
                        
                    case .image:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextImageCellReuseIdentifier, for: indexPath) as! PostTextImageCell
                        cell.delegate = self
                        cell.viewModel = PostViewModel(post: viewModel.posts[indexPath.row])
                        cell.set(user: viewModel.user)
                        return cell
                    case .link:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postLinkCellReuseIdentifier, for: indexPath) as! PostLinkCell
                        cell.delegate = self
                        cell.viewModel = PostViewModel(post: viewModel.posts[indexPath.row])
                        cell.set(user: viewModel.user)
                        return cell
                    }
                }
            } else if collectionView == casesCollectionView {
                if viewModel.cases.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                    cell.set(withTitle: AppStrings.Content.Search.emptyTitle, withDescription: AppStrings.Content.Search.emptyContent)
                    return cell
                } else {
                    let clinicalCase = viewModel.cases[indexPath.row]

                    switch clinicalCase.kind {
                        
                    case .text:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                        cell.delegate = self
                        cell.viewModel = CaseViewModel(clinicalCase: viewModel.cases[indexPath.row])
                        cell.set(user: viewModel.user)
                        return cell
                    case .image:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                        cell.delegate = self
                        cell.viewModel = CaseViewModel(clinicalCase: viewModel.cases[indexPath.row])
                        cell.set(user: viewModel.user)
                        return cell
                    }
                }
            } else {
                if viewModel.replies.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                    cell.set(withTitle: AppStrings.Content.Search.emptyTitle, withDescription: AppStrings.Content.Search.emptyContent)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentsCellReuseIdentifier, for: indexPath) as! UserProfileCommentCell
                    cell.user = viewModel.user
                    cell.configure(recentComment: viewModel.replies[indexPath.row])
                    return cell
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == repliesCollectionView {
            guard !viewModel.replies.isEmpty else { return }
            let reply = viewModel.replies[indexPath.row]
            
            switch reply.source {
                
            case .post:
                
                if reply.path.isEmpty {
                    let controller = DetailsPostViewController(postId: reply.contentId)
                    navigationController?.pushViewController(controller, animated: true)
                } else {
                    let controller = CommentPostRepliesViewController(postId: reply.contentId, uid: reply.uid, path: reply.path)
                    navigationController?.pushViewController(controller, animated: true)
                }
            case .clinicalCase:
              
                if reply.path.isEmpty {
                    let controller = DetailsCaseViewController(caseId: reply.contentId)
                    navigationController?.pushViewController(controller, animated: true)
                } else {
                    let controller = CommentCaseRepliesViewController(caseId: reply.contentId, uid: reply.uid, path: reply.path)
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
}

extension UserProfileViewController: UserProfileAboutCellDelegate {
    func wantsToSeeHashtag(_ hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func showUrl(_ url: String) {
        if let url = URL(string: url) {
            if UIApplication.shared.canOpenURL(url) {
                presentSafariViewController(withURL: url)
            } else {
                presentWebViewController(withURL: url)
            }
        }
    }
}

extension UserProfileViewController: PostCellDelegate {
    
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
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        
        self.navigationController?.delegate = zoomTransitioning
        
        viewModel.selectedImage = image[index]
        let controller = ZoomImageViewController(images: map, index: index)
        navigationController?.pushViewController(controller, animated: true)
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
        guard let indexPath = postsCollectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
    
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        guard let indexPath = postsCollectionView.indexPath(for: cell), let currentCell = cell as? HomeCellProtocol else { return }
        handleBookmarkUnbookmark(for: currentCell, at: indexPath)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        return
    }
    
    private func deletePost(withId id: String, at indexPath: IndexPath) {

        displayAlert(withTitle: AppStrings.Alerts.Title.deletePost, withMessage: AppStrings.Alerts.Subtitle.deletePost, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let _ = self else { return }
            
            PostService.deletePost(withId: id) { [weak self] error in

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

//MARK: - PostChangesDelegate

extension UserProfileViewController: PostChangesDelegate {
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
                postsCollectionView.reloadData()
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
                let likes = viewModel.posts[index].likes
                
                viewModel.posts[index].likes = change.didLike ? likes + 1 : likes - 1
                viewModel.posts[index].didLike = change.didLike
                
                postsCollectionView.reloadData()
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
                
                postsCollectionView.reloadData()
            }
        }
    }
    
    @objc func postEditChange(_ notification: NSNotification) {
        if let change = notification.object as? PostEditChange {
            let post = change.post
            
            if let index = viewModel.posts.firstIndex(where: { $0.postId == post.postId }) {
                viewModel.posts[index] = post
                postsCollectionView.reloadData()
            }
        }
    }
}

extension UserProfileViewController: CaseCellDelegate {
    func clinicalCase(didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete:
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                deleteCase(withId: clinicalCase.caseId, privacy: clinicalCase.privacy, at: IndexPath(item: index , section: 0))
            }

        case .revision:
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: viewModel.user)
            navigationController?.pushViewController(controller, animated: true)
        case .solve:
            let controller = CaseDiagnosisViewController(clinicalCase: clinicalCase)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
        case .report:
            let controller = ReportViewController(source: .clinicalCase, userId: clinicalCase.uid, contentId: clinicalCase.caseId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User?) {
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }

    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        viewModel.selectedImage = image[index]
        navigationController?.delegate = zoomTransitioning
        let controller = ZoomImageViewController(images: map, index: index)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: viewModel.user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) { return }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        guard let indexPath = casesCollectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
        handleBookmarkUnbookmark(for: currentCell, at: indexPath)
        
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let indexPath = casesCollectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        guard let currentUid = UserDefaults.getUid(), currentUid == clinicalCase.uid else { return }
        let controller = LikesViewController(clinicalCase: clinicalCase)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user)

        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func handleLikeUnLike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
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
    
    private func deleteCase(withId id: String, privacy: CasePrivacy, at indexPath: IndexPath) {
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

extension UserProfileViewController: CaseChangesDelegate {

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

    func caseDidChangeLike(caseId: String, didLike: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.likeCaseChange(caseId: caseId, didLike: !didLike)
    }
    
    @objc func caseLikeChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseLikeChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                
                let likes = viewModel.cases[index].likes
                
                viewModel.cases[index].likes = change.didLike ? likes + 1 : likes - 1
                viewModel.cases[index].didLike = change.didLike
                
                casesCollectionView.reloadData()
                
            }
        }
    }
    
    func caseDidChangeBookmark(caseId: String, didBookmark: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.bookmarkCaseChange(caseId: caseId, didBookmark: !didBookmark)
    }
    
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }

        if let change = notification.object as? CaseBookmarkChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? CaseCellProtocol {

                    viewModel.cases[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.clinicalCase.didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.cases[index].revision = .update
                casesCollectionView.reloadData()
            }
        }
    }

    func caseDidChangeComment(caseId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseCommentChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }), change.path.isEmpty {
                let comments = viewModel.cases[index].numberOfComments

                switch change.action {
                    
                case .add:
                    viewModel.cases[index].numberOfComments = comments + 1
                case .remove:
                    viewModel.cases[index].numberOfComments = comments - 1
                case .edit:
                    break
                }
                
                casesCollectionView.reloadData()
            }
        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseSolveChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {

                viewModel.cases[index].phase = .solved
                
                if let diagnosis = change.diagnosis {
                    viewModel.cases[index].revision = diagnosis
                }
                
                casesCollectionView.reloadData()
            }
        }
    }
}

extension UserProfileViewController: ReferenceMenuViewControllerDelegate {
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

extension UserProfileViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return viewModel.selectedImage
    }
}

extension UserProfileViewController: ProfileNameViewDelegate {
    func didTapAbout() {
        let controller = AboutProfileViewController(viewModel: viewModel)

        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        
        present(controller, animated: true)
    }
    
    func didTapWebsite() {
        if let url = URL(string: viewModel.getFormatUrl()) {
            if UIApplication.shared.canOpenURL(url) {
                presentSafariViewController(withURL: url)
            } else {
                presentWebViewController(withURL: url)
            }
        }
    }
    
    func didTapNetwork() {
        let controller = UserNetworkViewController(user: viewModel.user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapImage(kind: ImageKind) {
        let controller = ProfileImageViewController(kind: kind)
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            switch kind {
            case .profile:
                if strongSelf.viewModel.user.isCurrentUser {
                    controller.profileImageView.addImage(forUrl: strongSelf.viewModel.user.profileUrl, size: strongSelf.view.frame.width * 0.8)
                } else {
                    controller.profileImageView.addImage(forUser: strongSelf.viewModel.user, size: strongSelf.view.frame.width * 0.8)
                }
            case .banner:
                controller.profileImageView.addImage(forUrl: strongSelf.viewModel.user.bannerUrl, size: strongSelf.view.frame.width / 3)
            }

            controller.modalPresentationStyle = .overFullScreen
            strongSelf.present(controller, animated: true)
        }
    }
  
    func didTapActionButton() {
        if viewModel.user.isCurrentUser {
            let controller = EditProfileViewController(user: viewModel.user)
            controller.delegate = self
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        } else {
            if let phase = UserDefaults.getPhase(), phase == .verified {
                
                if let _ = viewModel.getBlockPhase() {
                    
                    let title = AppStrings.Alerts.Actions.unblock + AppStrings.Characters.space + viewModel.user.getUsername()
                    let message = viewModel.user.getUsername() + AppStrings.Characters.space + AppStrings.Block.unblock + AppStrings.Characters.space + viewModel.user.getUsername() + AppStrings.Characters.smallDot
                    
                    displayAlert(withTitle: title, withMessage: message, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.unblock, style: .destructive) { [weak self] in
                        guard let strongSelf = self else { return }

                        strongSelf.showProgressIndicator(in: strongSelf.view)
                        
                        strongSelf.viewModel.unblock { [weak self] error in
                            guard let strongSelf = self else { return }
                            if let error {
                                strongSelf.dismissProgressIndicator()
                                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            } else {

                                strongSelf.viewModel.unblockUser()
                                
                                DispatchQueue.main.async { [weak self] in
                                    guard let strongSelf = self else { return }
                                    strongSelf.postsCollectionView.reloadData()
                                    strongSelf.repliesCollectionView.reloadData()
                                    
                                    strongSelf.fetchUserContent()
                                }
                                
                                strongSelf.userDidChangeBlockPhase(uid: strongSelf.viewModel.user.uid!, phase: nil)
                            }
                        }
                    }
                } else {
                    guard let connection = viewModel.user.connection else { return }
                    
                    switch connection.phase {
                        
                    case .connected, .pending, .received, .rejected, .withdraw, .none, .unconnect:
                        
                        guard let tab = tabBarController as? MainTabController else { return }
                        
                        let controller = ConnectMenuViewController(user: viewModel.user)
                        controller.delegate = self
                        tab.showMenu(controller)
                    }
                }
            } else {
                ContentManager.shared.permissionAlert(kind: .connections)
            }
        }
    }
}

extension UserProfileViewController: ConnectMenuViewControllerDelegate {
    
    func didTapConnectMenu(menu: ConnectMenu) {
        switch menu {
        case .connect:
            guard let connection = viewModel.user.connection else { return }

            switch connection.phase {
                
            case .connected:

                displayAlert(withTitle: AppStrings.Alerts.Title.remove, withMessage: AppStrings.Alerts.Subtitle.remove, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.withdraw, style: .destructive) { [weak self] in
                    guard let strongSelf = self else { return }

                    strongSelf.profileNameView.actionEnabled(false)
                   
                    strongSelf.viewModel.unconnect { [weak self] error in
                        guard let strongSelf = self else { return }
                        if let error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                            
                            let viewModel = ProfileHeaderViewModel(user: strongSelf.viewModel.user)
                            
                            strongSelf.profileNameView.configureActionButton(viewModel: viewModel)
                            strongSelf.profileNameView.configure(viewModel: viewModel)
                           
                            strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .unconnect)
                            
                            let popupView = PopUpBanner(title: strongSelf.viewModel.removeConnectionText(), image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                            popupView.showTopPopup(inView: strongSelf.view)
                        }
                    }
                }
            case .pending:

                displayAlert(withTitle: AppStrings.Alerts.Title.withdraw, withMessage: AppStrings.Alerts.Subtitle.withdraw, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.withdraw, style: .destructive) { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.profileNameView.actionEnabled(false)
                  
                    strongSelf.viewModel.withdraw { [weak self] error in
                        guard let strongSelf = self else { return }
                        if let error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                            let viewModel = ProfileHeaderViewModel(user: strongSelf.viewModel.user)
                            strongSelf.profileNameView.configureActionButton(viewModel: viewModel)
                           
                            strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .withdraw)
                            
                            let popupView = PopUpBanner(title: strongSelf.viewModel.withdrawConnectionText(), image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                            popupView.showTopPopup(inView: strongSelf.view)
                        }
                    }
                }
            case .received:

                guard let tab = self.tabBarController as? MainTabController, let currentUser = tab.user else { return }
                profileNameView.actionEnabled(false)
               
                viewModel.accept(currentUser: currentUser) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        let viewModel = ProfileHeaderViewModel(user: strongSelf.viewModel.user)
                        strongSelf.profileNameView.configureActionButton(viewModel: viewModel)
                        strongSelf.viewModel.set(isFollowed: true)
            
                        strongSelf.profileNameView.configure(viewModel: viewModel)

                        strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .connected)
                        
                        let popupView = PopUpBanner(title: strongSelf.viewModel.acceptConnectionText(), image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                        popupView.showTopPopup(inView: strongSelf.view)
                    }
                }
                
            case .none:
                profileNameView.actionEnabled(false)
               
                viewModel.connect { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        let viewModel = ProfileHeaderViewModel(user: strongSelf.viewModel.user)
                        strongSelf.profileNameView.configureActionButton(viewModel: viewModel)
                        strongSelf.viewModel.set(isFollowed: true)
                       
                        strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .pending)
                        
                        let popupView = PopUpBanner(title: strongSelf.viewModel.sendConnectionText(), image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                        popupView.showTopPopup(inView: strongSelf.view)
                        
                        
                    }
                }
            case .rejected:

                guard viewModel.hasWeeksPassedSince(forWeeks: 5, timestamp: connection.timestamp) else {
                    displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.connectionDeny)
                    return
                }
                
                profileNameView.actionEnabled(false)

                viewModel.connect { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        let viewModel = ProfileHeaderViewModel(user: strongSelf.viewModel.user)
                        strongSelf.profileNameView.configureActionButton(viewModel: viewModel)
                        strongSelf.viewModel.set(isFollowed: true)
                      
                        strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .pending)
                        
                        let popupView = PopUpBanner(title: strongSelf.viewModel.sendConnectionText(), image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                        popupView.showTopPopup(inView: strongSelf.view)
                    }
                }
                
            case .withdraw:
                // The owner withdrawed the request and can send a request again.
                guard viewModel.hasWeeksPassedSince(forWeeks: 3, timestamp: connection.timestamp) else {
                    displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.connection)
                    return
                }
                
                profileNameView.actionEnabled(false)

                viewModel.connect { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        let viewModel = ProfileHeaderViewModel(user: strongSelf.viewModel.user)
                        strongSelf.profileNameView.configureActionButton(viewModel: viewModel)
                        strongSelf.viewModel.set(isFollowed: true)
                      
                        strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .pending)
                        
                        let popupView = PopUpBanner(title: strongSelf.viewModel.sendConnectionText(), image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                        popupView.showTopPopup(inView: strongSelf.view)
                    }
                }
            case .unconnect:
                // Connection was removed by one of the users so connection can be sent again
                guard viewModel.hasWeeksPassedSince(forWeeks: 5, timestamp: connection.timestamp) else {
                    displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.connection5)
                    return
                }
                
                profileNameView.actionEnabled(false)
    
                viewModel.connect { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        let viewModel = ProfileHeaderViewModel(user: strongSelf.viewModel.user)
                        strongSelf.profileNameView.configureActionButton(viewModel: viewModel)
                       
                        strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .pending)
                        
                        let popupView = PopUpBanner(title: strongSelf.viewModel.sendConnectionText(), image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                        popupView.showTopPopup(inView: strongSelf.view)
                    }
                }
            }
        case .follow:
            if viewModel.user.isFollowed {

                let name = viewModel.user.firstName!
                let baseAlert = AppStrings.Alerts.Subtitle.unfollowPre + " " + name + " "
                let postAlert = AppStrings.Alerts.Subtitle.unfollowPost + " " + name + " " + AppStrings.Alerts.Subtitle.unfollowAction
                
                displayAlert(withTitle: AppStrings.Alerts.Actions.unfollow, withMessage: baseAlert + postAlert, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.unfollow, style: .destructive) { [weak self] in
                    
                    guard let strongSelf = self else { return }
                    
                    strongSelf.profileNameView.actionEnabled(false)
                  
                    strongSelf.viewModel.unfollow { [weak self] error in
                        guard let strongSelf = self else { return }
                        
                        if let error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                            strongSelf.profileNameView.actionEnabled(true)
                            strongSelf.userDidChangeFollow(uid: strongSelf.viewModel.user.uid!, didFollow: false)
                            
                            let popupView = PopUpBanner(title: strongSelf.viewModel.unfollowText(), image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                            popupView.showTopPopup(inView: strongSelf.view)
                        }
                    }
                }
            } else {
                
                profileNameView.actionEnabled(false)
             
                viewModel.follow { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        strongSelf.profileNameView.actionEnabled(true)
                        strongSelf.userDidChangeFollow(uid: strongSelf.viewModel.user.uid!, didFollow: true)
                        
                        let popupView = PopUpBanner(title: strongSelf.viewModel.followText(), image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                        popupView.showTopPopup(inView: strongSelf.view)
                    }
                }
            }
        case .report:
            let controller = ReportViewController(source: .user, userId: viewModel.user.uid!, contentId: "")
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        case .block:
            let title = AppStrings.Alerts.Actions.block + AppStrings.Characters.space + viewModel.user.getUsername()
            let message = viewModel.user.getUsername() + AppStrings.Characters.space + AppStrings.Block.message + AppStrings.Characters.space + viewModel.user.getUsername() + AppStrings.Characters.smallDot

            displayAlert(withTitle: title, withMessage: message, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.block, style: .destructive) { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.viewModel.block { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        
                        strongSelf.viewModel.blockUser()
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.casesCollectionView.reloadData()
                            strongSelf.postsCollectionView.reloadData()
                            strongSelf.repliesCollectionView.reloadData()
                            
                            strongSelf.configureViewValues()
                        }

                        strongSelf.userDidChangeBlockPhase(uid: strongSelf.viewModel.user.uid!, phase: .block)
                        
                        let popUpTitle = strongSelf.viewModel.user.getUsername() + AppStrings.Characters.space + AppStrings.PopUp.block
                        let popupView = PopUpBanner(title: popUpTitle, image: AppStrings.Icons.exclamationmarkCircleFill, popUpKind: .regular)
                        popupView.showTopPopup(inView: strongSelf.view)
                    }
                }
            }
        }
    }
}

extension UserProfileViewController: EditProfileViewControllerDelegate {
   
    func didUpdateProfile(user: User) {
        viewModel.set(user: user)
        setUserDefaults(for: user)
        
        configureNavigationBar()

        configureUser(withNewUser: user)

        postsCollectionView.reloadData()
        casesCollectionView.reloadData()
        repliesCollectionView.reloadData()

        viewModel.currentNotification = true

        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil, userInfo: ["user": user])
        
        guard let tab = self.tabBarController as? MainTabController else { return }
        tab.updateUser(user: user)
    }
    
    func fetchNewWebsiteValues() {

        viewModel.getWebsite { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.configureUser(withNewUser: nil)

            strongSelf.viewModel.currentNotification = true
            NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil, userInfo: ["user": strongSelf.viewModel.user])
        }
    }

    func fetchNewAboutValues(withUid uid: String) {
        viewModel.fetchAboutText { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.configureUser(withNewUser: nil)
            
            strongSelf.viewModel.currentNotification = true
            NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil, userInfo: ["user": strongSelf.viewModel.user])
        }
    }
}

//MARK: - User Changes

extension UserProfileViewController: UserFollowDelegate {
    
    @objc func userDidChange(_ notification: NSNotification) {
        
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }

        if let user = notification.userInfo!["user"] as? User {
            guard viewModel.user.isCurrentUser, viewModel.user.uid == user.uid else { return }
            configureUser(withNewUser: user)
        }
    }
    
    @objc func followDidChange(_ notification: NSNotification) {
    
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? UserFollowChange {
            if viewModel.user.uid == change.uid, !viewModel.user.isCurrentUser {
                viewModel.set(isFollowed: change.isFollowed)
            }
        }
    }
    
    func userDidChangeFollow(uid: String, didFollow: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.userFollowChange(uid: uid, isFollowed: didFollow)
    }
}

extension UserProfileViewController: UserConnectDelegate {
    
    @objc func connectionDidChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? UserConnectionChange {
            if viewModel.user.uid == change.uid, !viewModel.user.isCurrentUser {
                viewModel.set(phase: change.phase)
                
                let viewModel = ProfileHeaderViewModel(user: viewModel.user)
                profileNameView.configureActionButton(viewModel: viewModel)
            }
        }
    }
    
    func userDidChangeConnection(uid: String, phase: ConnectPhase) {
        viewModel.currentNotification = true
        ContentManager.shared.userConnectionChange(uid: uid, phase: phase)
    }
}

extension UserProfileViewController: UserBlockDelegate {

    @objc func blockDidChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? UserBlockChange {
            if viewModel.user.uid == change.uid, !viewModel.user.isCurrentUser {
                
                if let _ = change.phase {
                    // User has been blocked
                    viewModel.blockUser()
                } else {
                    // User has been unblocked
                    viewModel.unblockUser()
                }

                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.postsCollectionView.reloadData()
                    strongSelf.repliesCollectionView.reloadData()
                    strongSelf.fetchUserContent()
                }
            }
        }
    }
    
    func userDidChangeBlockPhase(uid: String, phase: BlockPhase?) {
        viewModel.currentNotification = true
        ContentManager.shared.userBlockChange(uid: uid, phase: phase)
    }
}

extension UserProfileViewController: PageUnavailableViewDelegate {
    func didTapPageButton() {
        navigationController?.popViewController(animated: true)
    }
}
