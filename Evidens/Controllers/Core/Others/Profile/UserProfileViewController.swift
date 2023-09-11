//
//  UserProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/9/23.
//

import UIKit

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let homeTextCellReuseIdentifier = "ReuseIdentifier"
private let homeImageTextCellReuseIdentifier = "HomeImageTextCellReuseIdentifier"
private let homeTwoImageTextCellReuseIdentifier = "HomeTwoImageTextCellReuseIdentifier"
private let homeThreeImageTextCellReuseIdentifier = "HomeThreeImageTextCellReuseIdentifier"
private let homeFourImageTextCellReuseIdentifier = "HomeFourImageTextCellReuseIdentifier"

private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"

private let commentsCellReuseIdentifier = "CommentsCellReuseIdentifier"

private let profileAboutCellReuseIdentifier = "ProfileAboutCellReuseIdentifier"
private let experienceCellReuseIdentifier = "ExperienceCellReuseIdentifier"
private let educationCellReuseIdentifier = "EducationCellReuseIdentifier"
private let patentCellReuseIdentifier = "PatentCellReuseIdentifier"
private let publicationsCellReuseIdentifier = "PublicationsCellReuseIdentifier"
private let languageCellReuseIdentifier = "LanguageCellReuseIdentifier"
private let profileHeaderReuseIdentifier = "ProfileHeaderReuseIdentifier"
private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"

class UserProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    private var user: User
    private var uid: String?
    
    private var scrollView: UIScrollView!
    private var postsCollectionView: UICollectionView!
    private var casesCollectionView: UICollectionView!
    private var repliesCollectionView: UICollectionView!
    private var aboutCollectionView: UICollectionView!
    
    private var postsLoaded: Bool = false
    private var casesLoaded: Bool = false
    private var repliesLoaded: Bool = false
    private var aboutLoaded: Bool = false
    
    private var networkFailure: Bool = false
    
    private var topHeaderAnchorConstraint: NSLayoutConstraint!
    private var topProfileAnchorConstraint: NSLayoutConstraint!
    private var topToolbarAnchorConstraint: NSLayoutConstraint!
    
    private var profileToolbar: ProfileToolbar!
    private var postsSpacingView = SpacingView()
    private var casesSpacingView = SpacingView()
    private var repliesSpacingView = SpacingView()
    private var headerTopInset: CGFloat!
    
    private var postLastTimestamp: Int64?
    private var caseLastTimestamp: Int64?
    private var replyLastTimestamp: Int64?
    
    private var zoomTransitioning = ZoomTransitioning()
    private let referenceMenu = ReferenceMenu()
    
    private var selectedImage: UIImageView!
 
    private let activityIndicator = PrimaryLoadingView(frame: .zero)

    private let bannerImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = primaryColor.withAlphaComponent(0.8)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var profileImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .quaternarySystemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
        iv.image = UIImage(named: AppStrings.Assets.profile)
        return iv
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
        configuration.cornerStyle = .capsule
        button.configuration = configuration
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        return button
    }()
    
    private let name: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        return label
    }()
    
    private let discipline: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var followers: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowFollowers)))
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let padding: CGFloat = 10.0
    private let profileImageHeight: CGFloat = 70.0
    private var bannerHeight = 0.0
    private let buttonHeight = 40.0
    private let toolbarHeight = 50.0
    
    private var index = 0
    
    private var posts = [Post]()
    private var cases = [Case]()
    private var replies = [RawComment]()
    
    private var experiences = [Experience]()
    private var languages = [Language]()
    private var education = [Education]()
    private var publications = [Publication]()
    private var patents = [Patent]()
    private var about = String()

    private var isFetchingOrDidFetchCases: Bool = false
    private var isFetchingOrDidFetchReplies: Bool = false
    private var isFetchingOrDidFetchAbout: Bool = false
    
    private var isFetchingMorePosts: Bool = false
    private var isFetchingMoreCases: Bool = false
    private var isFetchingMoreReplies: Bool = false
    
    private var isScrollingHorizontally = false
    private var collectionsLoaded: Bool = false
    
    private var currentNotification: Bool = false
    
    private var fetchPostLimit: Bool = false
    private var fetchCaseLimit: Bool = false
    private var fetchReplyLimit: Bool = false
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !collectionsLoaded {
            collectionsLoaded = true
        }
    }
    
    init(uid: String) {
        self.user = User(dictionary: [:])
        self.uid = uid
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
        configureLoading()
        configureNotificationObservers()
        if let _ = uid {
            fetchUser()
        } else {
            configure()
            fetchUserContent()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }
    
    private func configureLoading() {
        view.backgroundColor = .systemBackground
        scrollView = UIScrollView()
        scrollView.isHidden = true
        
        view.addSubview(scrollView)
        
        
        let appearance = UINavigationBarAppearance.profileAppearance()
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.standardAppearance = appearance
        
        view.addSubviews(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
        ])
    }

    private func configureNavigationBar() {
        title = user.name()
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        //scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = .systemBackground
        scrollView.delegate = self

        postsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: postsLayout())
        casesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: casesLayout())
        repliesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: commentsLayout())
        aboutCollectionView = UICollectionView(frame: .zero, collectionViewLayout: aboutLayout())
        
        postsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        casesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        repliesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        aboutCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        postsCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        postsCollectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: homeTextCellReuseIdentifier)
        postsCollectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCellReuseIdentifier)
        postsCollectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCellReuseIdentifier)
        postsCollectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCellReuseIdentifier)
        postsCollectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCellReuseIdentifier)
        postsCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
       
        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
        casesCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        casesCollectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        casesCollectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        casesCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        
        repliesCollectionView.delegate = self
        repliesCollectionView.dataSource = self
        repliesCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        repliesCollectionView.register(UserProfileCommentCell.self, forCellWithReuseIdentifier: commentsCellReuseIdentifier)
        repliesCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        
        aboutCollectionView.delegate = self
        aboutCollectionView.dataSource = self
        aboutCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        aboutCollectionView.register(UserProfileAboutCell.self, forCellWithReuseIdentifier: profileAboutCellReuseIdentifier)
        aboutCollectionView.register(UserProfileAboutCell.self, forCellWithReuseIdentifier: profileAboutCellReuseIdentifier)
        aboutCollectionView.register(ProfileExperienceCell.self, forCellWithReuseIdentifier: experienceCellReuseIdentifier)
        aboutCollectionView.register(ProfileEducationCell.self, forCellWithReuseIdentifier: educationCellReuseIdentifier)
        aboutCollectionView.register(ProfilePatentCell.self, forCellWithReuseIdentifier: patentCellReuseIdentifier)
        aboutCollectionView.register(ProfilePublicationCell.self, forCellWithReuseIdentifier: publicationsCellReuseIdentifier)
        aboutCollectionView.register(ProfileLanguageCell.self, forCellWithReuseIdentifier: languageCellReuseIdentifier)
        aboutCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        aboutCollectionView.register(PrimaryProfileHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: profileHeaderReuseIdentifier)
        
        postsSpacingView.translatesAutoresizingMaskIntoConstraints = false
        casesSpacingView.translatesAutoresizingMaskIntoConstraints = false
        repliesSpacingView.translatesAutoresizingMaskIntoConstraints = false

        profileToolbar = ProfileToolbar()
        profileToolbar.toolbarDelegate = self
        
        if let banner = user.bannerUrl, !banner.isEmpty {
            topHeaderAnchorConstraint = bannerImage.topAnchor.constraint(equalTo: scrollView.topAnchor)
            bannerHeight = (view.frame.width - 20.0) / 3
            headerTopInset = 4 * padding + bannerHeight + profileImageHeight + buttonHeight + padding / 2
            topProfileAnchorConstraint = profileImage.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: padding + padding / 2)
        } else {
            headerTopInset = 4 * padding + profileImageHeight + buttonHeight
            topHeaderAnchorConstraint = bannerImage.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0)
            bannerHeight = 0
            topProfileAnchorConstraint = profileImage.topAnchor.constraint(equalTo: bannerImage.bottomAnchor)
        }
        
        topToolbarAnchorConstraint = profileToolbar.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: headerTopInset)
    
        scrollView.addSubviews(postsCollectionView, casesCollectionView, repliesCollectionView, aboutCollectionView, profileToolbar, postsSpacingView, casesSpacingView, repliesSpacingView, bannerImage, profileImage, actionButton, name, discipline, followers)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.frame.width + padding),
            
            topHeaderAnchorConstraint,
            bannerImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            bannerImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            bannerImage.heightAnchor.constraint(equalToConstant: bannerHeight),
            
            topProfileAnchorConstraint,
            profileImage.leadingAnchor.constraint(equalTo: bannerImage.leadingAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: profileImageHeight),
            profileImage.heightAnchor.constraint(equalToConstant: profileImageHeight),
            
            name.topAnchor.constraint(equalTo: profileImage.topAnchor),
            name.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 10),
            name.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            discipline.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 5),
            discipline.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            discipline.trailingAnchor.constraint(equalTo: name.trailingAnchor),
            
            followers.topAnchor.constraint(equalTo: discipline.bottomAnchor),
            followers.leadingAnchor.constraint(equalTo: discipline.leadingAnchor),
            followers.trailingAnchor.constraint(equalTo: discipline.trailingAnchor),
            
            actionButton.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 2 * padding),
            actionButton.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: bannerImage.trailingAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            topToolbarAnchorConstraint,
            profileToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileToolbar.heightAnchor.constraint(equalToConstant: toolbarHeight),
            
            postsCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            postsCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            postsCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            postsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            postsSpacingView.topAnchor.constraint(equalTo: profileToolbar.bottomAnchor),
            postsSpacingView.leadingAnchor.constraint(equalTo: postsCollectionView.trailingAnchor),
            postsSpacingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            postsSpacingView.widthAnchor.constraint(equalToConstant: 10),

            casesCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            casesCollectionView.leadingAnchor.constraint(equalTo: postsSpacingView.trailingAnchor),
            casesCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            casesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            casesSpacingView.topAnchor.constraint(equalTo: profileToolbar.bottomAnchor),
            casesSpacingView.leadingAnchor.constraint(equalTo: casesCollectionView.trailingAnchor),
            casesSpacingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            casesSpacingView.widthAnchor.constraint(equalToConstant: 10),

            repliesCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            repliesCollectionView.leadingAnchor.constraint(equalTo: casesSpacingView.trailingAnchor),
            repliesCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            repliesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            repliesSpacingView.topAnchor.constraint(equalTo: profileToolbar.bottomAnchor),
            repliesSpacingView.leadingAnchor.constraint(equalTo: repliesCollectionView.trailingAnchor),
            repliesSpacingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            repliesSpacingView.widthAnchor.constraint(equalToConstant: 10),

            aboutCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            aboutCollectionView.leadingAnchor.constraint(equalTo: repliesSpacingView.trailingAnchor),
            aboutCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            aboutCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        scrollView.contentSize.width = view.frame.width * 4 + 4 * 10
        bannerImage.layer.cornerRadius = 10
        profileImage.layer.cornerRadius = profileImageHeight / 2
        
        postsCollectionView.backgroundColor = .systemBackground
        casesCollectionView.backgroundColor = .systemBackground
        repliesCollectionView.backgroundColor = .systemBackground
        aboutCollectionView.backgroundColor = .systemBackground
        
        postsCollectionView.contentInset.top = headerTopInset + toolbarHeight
        postsCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
        
        casesCollectionView.contentInset.top = headerTopInset + toolbarHeight
        casesCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
        
        repliesCollectionView.contentInset.top = headerTopInset + toolbarHeight
        repliesCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
        
        aboutCollectionView.contentInset.top = headerTopInset + toolbarHeight
        aboutCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
        
    }
    
    private func configureUser() {
        if let url = user.profileUrl, url != "" {
            profileImage.sd_setImage(with: URL(string: url))
        }
        
        if let banner = user.bannerUrl, banner != "" {
            bannerImage.sd_setImage(with: URL(string: banner))
        } else {
            
        }
        
        name.text = user.name()
        discipline.text = user.details()
        
        let viewModel = ProfileHeaderViewModel(user: user)
        followers.attributedText = viewModel.followingFollowersText
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
    }
    
    
    private func postsLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.posts.isEmpty ? .absolute(strongSelf.visibleScreenHeight - 50) : .estimated(300))
            
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.postsLoaded {
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
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.cases.isEmpty ? .absolute(strongSelf.visibleScreenHeight - 50) : .estimated(300))
            
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.casesLoaded {
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
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.replies.isEmpty ? .absolute(strongSelf.visibleScreenHeight - 50) : .estimated(300))
            
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.repliesLoaded {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: ElementKind.sectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
            }
            
            return section
        }
        return layout
    }
    
    private func aboutLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
            
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.aboutLoaded || sectionNumber == 0 && !strongSelf.about.isEmpty || sectionNumber == 1 && !strongSelf.experiences.isEmpty || sectionNumber == 2 && !strongSelf.education.isEmpty || sectionNumber == 3 && !strongSelf.patents.isEmpty || sectionNumber == 4 && !strongSelf.publications.isEmpty || sectionNumber == 5 && !strongSelf.languages.isEmpty {
                 
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: ElementKind.sectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
            }
            
            return section
        }
        return layout
    }
    
    private func configureActionButton() {
        let viewModel = ProfileHeaderViewModel(user: user)
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        actionButton.configuration?.attributedTitle = AttributedString(viewModel.followText, attributes: container)
        actionButton.configuration?.baseBackgroundColor = viewModel.followBackgroundColor
        actionButton.configuration?.baseForegroundColor = viewModel.followTextColor
        actionButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
        if user.isFollowed {
            actionButton.showsMenuAsPrimaryAction = true
            actionButton.menu = addUnfollowMenu()
        }
    }
    
    private func fetchUser() {
        guard let uid = uid else { return }
        UserService.fetchUser(withUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let user):
                strongSelf.user = user
                strongSelf.configure()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    strongSelf.fetchUserContent()
                }

            case .failure(_):
                break
            }
        }
    }
    
    private func fetchUserContent() {
        guard NetworkMonitor.shared.isConnected else {
            networkFailure = true
            return
        }
        
        let group = DispatchGroup()
        
        checkIfUserIsFollowed(group)
        fetchStats(group)
        fetchPosts(group)
        
        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configureNavigationBar()
            strongSelf.activityIndicator.stop()
            strongSelf.activityIndicator.removeFromSuperview()
            strongSelf.scrollView.isHidden = false
        }
    }
    
    private func checkIfUserIsFollowed(_ group: DispatchGroup? = nil) {
        
        if let group {
            group.enter()
        }
        
        UserService.checkIfUserIsFollowed(uid: user.uid!) { [weak self] isFollowed in
            guard let strongSelf = self else { return }
            strongSelf.user.set(isFollowed: isFollowed)
            strongSelf.configureActionButton()
            
            if let group {
                group.leave()
            }
        }
    }
    
    private func fetchStats(_ group: DispatchGroup? = nil) {
        
        if let group {
            group.enter()
        }
        
        UserService.fetchUserStats(uid: user.uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let stats):
                strongSelf.user.stats = stats
                strongSelf.configureUser()
            case .failure(let error):
                switch error {
                case .network:
                    break
                default:
                    break
                }
            }
            
            if let group {
                group.leave()
            }
        }
    }
    
    func fetchPosts(_ group: DispatchGroup? = nil) {
        guard let uid = user.uid else { return }
        
        if let group {
            group.enter()
        }
        
        DatabaseManager.shared.fetchHomeFeedPosts(lastTimestampValue: nil, forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let postIds):
                
                if postIds.count < 10 {
                    strongSelf.fetchPostLimit = true
                }
                
                PostService.fetchPosts(withPostIds: postIds) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let posts):
                        strongSelf.posts = posts
                        strongSelf.postLastTimestamp = strongSelf.posts.last?.timestamp.seconds
                    case .failure(_):
                        strongSelf.posts.removeAll()
                        break
                    }

                    strongSelf.postsLoaded = true
                    strongSelf.postsCollectionView.reloadData()
                    
                    if let group {
                        group.leave()
                    }
                }
            case .failure(_):
                strongSelf.posts.removeAll()
                strongSelf.postsLoaded = true
                strongSelf.postsCollectionView.reloadData()
                strongSelf.fetchPostLimit = true
                
                if let group {
                    group.leave()
                }
            }
        }
    }
    
    private func fetchCases() {
        guard let uid = user.uid else { return }
        isFetchingOrDidFetchCases = true
        
        DatabaseManager.shared.getRecentCaseIds(lastTimestampValue: nil, forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let caseIds):
                
                if caseIds.count < 10 {
                    strongSelf.fetchCaseLimit = true
                }
                
                CaseService.fetchCases(withCaseIds: caseIds) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let cases):
                        strongSelf.cases = cases
                        strongSelf.caseLastTimestamp = strongSelf.cases.last?.timestamp.seconds
                    case .failure(_):
                        strongSelf.cases.removeAll()
                        break
                    }
                    
                    strongSelf.casesLoaded = true
                    strongSelf.casesCollectionView.reloadData()
                }
                
            case .failure(_):
                strongSelf.cases.removeAll()
                strongSelf.fetchCaseLimit = true
                strongSelf.casesLoaded = true
                strongSelf.casesCollectionView.reloadData()
            }
        }
    }
    
    func fetchComments() {
        guard let uid = user.uid else { return }
        isFetchingOrDidFetchReplies = true
        DatabaseManager.shared.fetchRecentComments(lastTimestampValue: nil, forUid: uid) { [weak self] result in
            
            guard let strongSelf = self else { return }
            switch result {
            case .success(let replies):
                strongSelf.replies = replies
                strongSelf.replyLastTimestamp = Int64(strongSelf.replies.last?.timestamp ?? 0)
            case .failure(_):
                strongSelf.replies.removeAll()
            }
            
            if strongSelf.replies.count < 10 {
                strongSelf.fetchReplyLimit = true
            }
            
            strongSelf.repliesLoaded = true
            strongSelf.repliesCollectionView.reloadData()
            
        }
    }
    
    private func fetchAbout() {
        let group = DispatchGroup()
        isFetchingOrDidFetchAbout = true
        fetchExperience(group)
        fetchLanguages(group)
        fetchPatents(group)
        fetchEducation(group)
        fetchPublications(group)
        fetchAbout(group)
        
        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.aboutLoaded = true
            strongSelf.aboutCollectionView.reloadData()
        }
    }
    
    private func fetchExperience(_ group: DispatchGroup? = nil) {
        guard let uid = user.uid else { return }
        
        if let group {
            group.enter()
        }
        
        DatabaseManager.shared.fetchExperience(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let experiences):
                strongSelf.experiences = experiences
            case .failure(_):
                strongSelf.experiences.removeAll()
            }
            
            if let group {
                group.leave()
            } else {
                strongSelf.aboutCollectionView.reloadData()
            }
        }
    }
    
    private func fetchLanguages(_ group: DispatchGroup? = nil) {
        guard let uid = user.uid else { return }
        
        if let group {
            group.enter()
        }
        
        DatabaseManager.shared.fetchLanguages(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let languages):
                strongSelf.languages = languages

            case .failure(_):
                strongSelf.languages.removeAll()
            }
            
            if let group {
                group.leave()
            } else {
                strongSelf.aboutCollectionView.reloadData()
            }
        }
    }
    
    private func fetchPatents(_ group: DispatchGroup? = nil) {
        guard let uid = user.uid else { return }
        
        if let group {
            group.enter()
        }
        
        DatabaseManager.shared.fetchPatents(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let patents):
                strongSelf.patents = patents
            case .failure(_):
                strongSelf.patents.removeAll()
            }
            
            if let group {
                group.leave()
            } else {
                strongSelf.aboutCollectionView.reloadData()
            }
        }
    }
    
    private func fetchEducation(_ group: DispatchGroup? = nil) {
        guard let uid = user.uid else { return }
        
        if let group {
            group.enter()
        }

        DatabaseManager.shared.fetchEducation(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {

            case .success(let education):
                strongSelf.education = education
            case .failure(_):
                strongSelf.education.removeAll()
            }
            
            if let group {
                group.leave()
            } else {
                strongSelf.aboutCollectionView.reloadData()
            }
        }
    }
    
    private func fetchPublications(_ group: DispatchGroup? = nil) {
        guard let uid = user.uid else { return }
        
        if let group {
            group.enter()
        }
        
        DatabaseManager.shared.fetchPublications(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let publications):
                strongSelf.publications = publications
            case .failure(_):
                strongSelf.publications.removeAll()
            }
            
            if let group {
                group.leave()
            } else {
                strongSelf.aboutCollectionView.reloadData()
            }
        }
    }
    
    private func fetchAbout(_ group: DispatchGroup? = nil) {
        guard let uid = user.uid else { return }
        
        if let group {
            group.enter()
        }
        
        DatabaseManager.shared.fetchAboutUs(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let about):
                strongSelf.about = about
            case .failure(_):
                strongSelf.about = ""
            }
            
            if let group {
                group.leave()
            } else {
                strongSelf.aboutCollectionView.reloadData()
            }
        }
    }
    
    private func addUnfollowMenu() -> UIMenu? {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: AppStrings.Alerts.Actions.unfollow + " " + user.firstName!, image: UIImage(systemName: AppStrings.Icons.xmarkPersonFill, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, attributes: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                
                strongSelf.actionButton.isUserInteractionEnabled = false
                
                UserService.unfollow(uid: strongSelf.user.uid!) { [weak self] error in
                    guard let strongSelf = self else { return }
                    strongSelf.user.isFollowed = false
                    strongSelf.user.stats.set(followers: strongSelf.user.stats.followers - 1)
                    let viewModel = ProfileHeaderViewModel(user: strongSelf.user)
                    var container = AttributeContainer()
                    container.font = .systemFont(ofSize: 14, weight: .bold)
                    strongSelf.actionButton.configuration?.baseBackgroundColor = viewModel.followBackgroundColor
                    strongSelf.actionButton.configuration?.baseForegroundColor = viewModel.followTextColor
                    strongSelf.actionButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
                    strongSelf.actionButton.configuration?.background.strokeWidth = viewModel.followButtonBorderWidth
                    strongSelf.actionButton.configuration?.attributedTitle = AttributedString(viewModel.followText, attributes: container)
                    strongSelf.actionButton.isUserInteractionEnabled = true
                    strongSelf.actionButton.showsMenuAsPrimaryAction = false
                    
                    strongSelf.followers.attributedText = viewModel.followingFollowersText
                }

            })
        ])
        return menuItems
    }
    
    // MARK: - Actions
    
    @objc func handleImageTap() {
        let controller = ProfileImageViewController(isBanner: false)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if let imageUrl = strongSelf.user.profileUrl, imageUrl != "" {
                controller.profileImageView.sd_setImage(with: URL(string: imageUrl))
            } else {
                controller.profileImageView.image = UIImage(named: AppStrings.Assets.profile)
            }
            controller.modalPresentationStyle = .overFullScreen
            strongSelf.present(controller, animated: true)
        }
    }
    
    @objc func handleShowFollowers() {
        let controller = FollowersFollowingViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleButtonTap() {
        
        if user.isCurrentUser {
            let controller = EditProfileViewController(user: user)
            controller.delegate = self
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        } else {
            
            guard let uid = user.uid else { return }
            actionButton.isUserInteractionEnabled = false
            UserService.follow(uid: uid) { [weak self] error in
                guard let strongSelf = self else { return }
                
                strongSelf.actionButton.isUserInteractionEnabled = true
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.user.isFollowed = true
                    strongSelf.user.stats.set(followers: strongSelf.user.stats.followers + 1)
                    let viewModel = ProfileHeaderViewModel(user: strongSelf.user)
                    var container = AttributeContainer()
                    container.font = .systemFont(ofSize: 14, weight: .bold)
                    strongSelf.actionButton.configuration?.baseBackgroundColor = viewModel.followBackgroundColor
                    strongSelf.actionButton.configuration?.baseForegroundColor = viewModel.followTextColor
                    strongSelf.actionButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
                    strongSelf.actionButton.configuration?.background.strokeWidth = viewModel.followButtonBorderWidth
                    strongSelf.actionButton.configuration?.attributedTitle = AttributedString(viewModel.followText, attributes: container)
                    strongSelf.actionButton.showsMenuAsPrimaryAction = true
                    
                    strongSelf.followers.attributedText = viewModel.followingFollowersText
                }
            }
        }
    }
    
    func showBottomSpinner(for section: ProfileSection) {
        switch section {
            
        case .posts:
            isFetchingMorePosts = true
        case .cases:
            isFetchingMoreCases = true
        case .reply:
            isFetchingMoreReplies = true
        case .about:
            break
        }
    }
    
    func hideBottomSpinner(or section: ProfileSection) {
        switch section {
            
        case .posts:
            isFetchingMorePosts = false
        case .cases:
            isFetchingMoreCases = false
        case .reply:
            isFetchingMoreReplies = false
        case .about:
            break
        }
    }

}

extension UserProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        
        if scrollView.contentOffset.y != 0 {
            isScrollingHorizontally = false
        }
        
        if scrollView.contentOffset.y == 0 && isScrollingHorizontally {
            profileToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
        }
        
        if scrollView.contentOffset.y == 0 && !isScrollingHorizontally {
            isScrollingHorizontally = true
            return
        }
        
        if scrollView.contentOffset.x > view.frame.width * 0.2 && !isFetchingOrDidFetchCases {
            fetchCases()
        }
        
        if scrollView.contentOffset.x > view.frame.width * 1.2 && !isFetchingOrDidFetchReplies {
            fetchComments()
        }
        
        if scrollView.contentOffset.x > view.frame.width * 2.2 && !isFetchingOrDidFetchAbout {
            fetchAbout()
        }
        
        guard scrollView.contentOffset.y != 0 else { return }

        let minimumContentHeight = visibleScreenHeight - 49

        if collectionsLoaded {
            postsCollectionView.contentInset.bottom = max(0, minimumContentHeight - postsCollectionView.contentSize.height)
            casesCollectionView.contentInset.bottom = max(0, minimumContentHeight - casesCollectionView.contentSize.height)
            repliesCollectionView.contentInset.bottom = max(0, minimumContentHeight - repliesCollectionView.contentSize.height)
            aboutCollectionView.contentInset.bottom = max(0, minimumContentHeight - aboutCollectionView.contentSize.height)
        }
        
        switch index {
        case 0:
            topToolbarAnchorConstraint.constant = max(0, -(offset.y + postsCollectionView.contentInset.top - headerTopInset))
            topHeaderAnchorConstraint.constant = -(offset.y + postsCollectionView.contentInset.top - padding)
        case 1:
            topToolbarAnchorConstraint.constant = max(0, -(offset.y + casesCollectionView.contentInset.top - headerTopInset))
            topHeaderAnchorConstraint.constant = -(offset.y + casesCollectionView.contentInset.top - padding)
        case 2:
            topToolbarAnchorConstraint.constant = max(0, -(offset.y + repliesCollectionView.contentInset.top - headerTopInset))
            topHeaderAnchorConstraint.constant = -(offset.y + repliesCollectionView.contentInset.top - padding)
        default:
            topToolbarAnchorConstraint.constant = max(0, -(offset.y + aboutCollectionView.contentInset.top - headerTopInset))
            topHeaderAnchorConstraint.constant = -(offset.y + aboutCollectionView.contentInset.top - padding)
        }
        
        if offset.y < -50 {
            postsCollectionView.contentOffset.y = scrollView.contentOffset.y
            casesCollectionView.contentOffset.y = scrollView.contentOffset.y
            repliesCollectionView.contentOffset.y = scrollView.contentOffset.y
            aboutCollectionView.contentOffset.y = scrollView.contentOffset.y
            
        } else {

            switch index {
            case 0:
                casesCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, casesCollectionView.contentOffset.y))
                repliesCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, repliesCollectionView.contentOffset.y))
                aboutCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, aboutCollectionView.contentOffset.y))
            case 1:
                postsCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, postsCollectionView.contentOffset.y))
                repliesCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, repliesCollectionView.contentOffset.y))
                aboutCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, aboutCollectionView.contentOffset.y))
            case 2:
                postsCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, postsCollectionView.contentOffset.y))
                casesCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, casesCollectionView.contentOffset.y))
                aboutCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, aboutCollectionView.contentOffset.y))
            default:
                postsCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, postsCollectionView.contentOffset.y))
                casesCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, casesCollectionView.contentOffset.y))
                repliesCollectionView.contentOffset = CGPoint(x: 0, y: max(-toolbarHeight, repliesCollectionView.contentOffset.y))

            }
        }
        
        switch index {
        case 0:
            if offset.y < -toolbarHeight {
                postsCollectionView.verticalScrollIndicatorInsets.top = -(offset.y)
            } else {
                postsCollectionView.verticalScrollIndicatorInsets.top = toolbarHeight
            }
        case 1:
            if offset.y < -toolbarHeight {
                casesCollectionView.verticalScrollIndicatorInsets.top = -(offset.y)
            } else {
                casesCollectionView.verticalScrollIndicatorInsets.top = toolbarHeight
            }
        case 2:
            if offset.y < -toolbarHeight {
                repliesCollectionView.verticalScrollIndicatorInsets.top = -(offset.y)
            } else {
                repliesCollectionView.verticalScrollIndicatorInsets.top = toolbarHeight
            }
        default:
            if offset.y < -toolbarHeight {
                aboutCollectionView.verticalScrollIndicatorInsets.top = -(offset.y)
            } else {
                aboutCollectionView.verticalScrollIndicatorInsets.top = toolbarHeight
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        if scrollView.contentOffset.y != 0 {
            return 
        }
        
        switch offsetX {
        case 0 ..< view.frame.width:
            index = 0
        case view.frame.width ..< 2 * view.frame.width:
            index = 1
        case 2 * view.frame.width ..< 3 * view.frame.width:
            index = 2
        default:
            index = 3
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            switch index {
            case 0:
                fetchMorePosts()
            case 1:
                fetchMoreCases()
            case 2:
                fetchMoreReplies()
            default:
                break
            }
        }
    }
    
    private func fetchMorePosts() {
        guard !isFetchingMorePosts, !fetchPostLimit, !posts.isEmpty else { return }
        
        showBottomSpinner(for: .posts)
        
        DatabaseManager.shared.fetchHomeFeedPosts(lastTimestampValue: postLastTimestamp, forUid: user.uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let postIds):
               
                if postIds.count < 10 {
                    strongSelf.fetchPostLimit = true
                }
                
                PostService.fetchPosts(withPostIds: postIds) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let posts):
                        
                        strongSelf.posts.append(contentsOf: posts)
                        strongSelf.postLastTimestamp = strongSelf.posts.last?.timestamp.seconds
                    case .failure(_):
                        break
                    }
                    
                    strongSelf.hideBottomSpinner(or: .posts)
                    
                }
            case .failure(_):
                strongSelf.fetchPostLimit = true
                strongSelf.hideBottomSpinner(or: .cases)
                break
            }
        }
    }
    
    private func fetchMoreCases() {
        guard !isFetchingMoreCases, !fetchCaseLimit, !cases.isEmpty else { return }
        
        showBottomSpinner(for: .cases)
        
        DatabaseManager.shared.getRecentCaseIds(lastTimestampValue: caseLastTimestamp, forUid: user.uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let caseIds):
                
                if caseIds.count < 10 {
                    strongSelf.fetchCaseLimit = true
                }
                
                CaseService.fetchCases(withCaseIds: caseIds) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let cases):
                        strongSelf.cases.append(contentsOf: cases)
                        strongSelf.caseLastTimestamp = strongSelf.cases.last?.timestamp.seconds
                    case .failure(_):
                        break
                    }
                    
                    strongSelf.hideBottomSpinner(or: .cases)
                }
                
            case .failure(_):
                strongSelf.fetchPostLimit = true
                strongSelf.hideBottomSpinner(or: .cases)
                break
            }
        }
    }
    
    private func fetchMoreReplies() {

        guard !isFetchingMoreReplies, !fetchReplyLimit, !replies.isEmpty else { return }
        
        guard let uid = user.uid else { return }
        
        showBottomSpinner(for: .reply)

        DatabaseManager.shared.fetchRecentComments(lastTimestampValue: replyLastTimestamp, forUid: uid) { [weak self] result in

            guard let strongSelf = self else { return }
            switch result {
            case .success(let replies):
                
                if replies.count < 10 {
                    strongSelf.fetchReplyLimit = true
                }
                
                strongSelf.replies.append(contentsOf: replies)
                strongSelf.replyLastTimestamp = Int64(strongSelf.replies.last?.timestamp ?? 0)
            case .failure(_):
                strongSelf.fetchReplyLimit = true
            }
            
            strongSelf.hideBottomSpinner(or: .reply)
        }
    }
}

extension UserProfileViewController: ProfileToolbarDelegate {
    func didTapIndex(_ index: Int) {
        scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width) + index * 10, y: 0), animated: true)
        self.index = index
    }
}

extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == aboutCollectionView {
            return aboutLoaded ? 6 : 1
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == postsCollectionView {
            return postsLoaded ? posts.isEmpty ? 1 : posts.count : 0
        } else if collectionView == casesCollectionView {
            return casesLoaded ? cases.isEmpty ? 1 : cases.count : 0
        } else if collectionView == repliesCollectionView {
            return repliesLoaded ? replies.isEmpty ? 1 : replies.count : 0
        } else {
            if aboutLoaded {
                if section == 0 {
                    if about.isEmpty && experiences.isEmpty && patents.isEmpty && publications.isEmpty && languages.isEmpty {
                        return 1
                    } else {
                        return about.isEmpty ? 0 : 1
                    }
                } else if section == 1 {
                    return experiences.isEmpty ? 0 : min(experiences.count, 3)
                } else if section == 2 {
                    return education.isEmpty ? 0 : min(education.count, 3)
                } else if section == 3 {
                    return patents.isEmpty ? 0 : min(patents.count, 3)
                } else if section == 4 {
                    return publications.isEmpty ? 0 : min(publications.count, 3)
                } else {
                    return languages.isEmpty ? 0 : min(languages.count, 3)
                }
            } else {
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == aboutCollectionView {
            if aboutLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileHeaderReuseIdentifier, for: indexPath) as! PrimaryProfileHeader
                header.delegate = self
                header.tag = indexPath.section
                
                if indexPath.section == 0 {
                    header.configureWith(title: AppStrings.Sections.aboutSection, linkText: "")
                    header.hideSeparator()
                } else if indexPath.section == 1 {
                    header.configureWith(title: AppStrings.Sections.experienceTitle, linkText: AppStrings.Content.Search.seeAll)
                    header.hideSeeAllButton(experiences.count < 3)
                } else if indexPath.section == 2 {
                    header.configureWith(title: AppStrings.Sections.educationTitle, linkText: AppStrings.Content.Search.seeAll)
                    header.hideSeeAllButton(education.count < 3)
                } else if indexPath.section == 3 {
                    header.configureWith(title: AppStrings.Sections.patentsTitle, linkText: AppStrings.Content.Search.seeAll)
                    header.hideSeeAllButton(patents.count < 3)
                } else if indexPath.section == 4 {
                    header.configureWith(title: AppStrings.Sections.publicationsTitle, linkText: AppStrings.Content.Search.seeAll)
                    header.hideSeeAllButton(publications.count < 3)
                } else {
                    header.configureWith(title: AppStrings.Sections.languagesTitle, linkText: AppStrings.Content.Search.seeAll)
                    header.hideSeeAllButton(languages.count < 3)
                }
                return header
                
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            }
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == postsCollectionView {
            if posts.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                cell.set(withTitle: AppStrings.Content.Search.emptyTitle, withDescription: AppStrings.Content.Search.emptyContent)
                return cell
            } else {
                let currentPost = posts[indexPath.row]
                let kind = currentPost.kind
                
                switch kind {
                    
                case .plainText:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTextCellReuseIdentifier, for: indexPath) as! HomeTextCell
                    cell.delegate = self
                    cell.postTextView.isSelectable = false
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: user)
                    return cell
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCellReuseIdentifier, for: indexPath) as! HomeImageTextCell
                    cell.delegate = self
                    cell.postTextView.isSelectable = false
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: user)
                    return cell
                case .textWithTwoImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCellReuseIdentifier, for: indexPath) as! HomeTwoImageTextCell
                    cell.delegate = self
                    cell.postTextView.isSelectable = false
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: user)
                    return cell
                case .textWithThreeImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCellReuseIdentifier, for: indexPath) as! HomeThreeImageTextCell
                    cell.delegate = self
                    cell.postTextView.isSelectable = false
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: user)
                    return cell
                case .textWithFourImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCellReuseIdentifier, for: indexPath) as! HomeFourImageTextCell
                    cell.delegate = self
                    cell.postTextView.isSelectable = false
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    cell.set(user: user)
                    return cell
                }
            }
        } else if collectionView == casesCollectionView {
            if cases.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                cell.set(withTitle: AppStrings.Content.Search.emptyTitle, withDescription: AppStrings.Content.Search.emptyContent)
                return cell
            } else {
                let clinicalCase = cases[indexPath.row]

                switch clinicalCase.kind {
                    
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
                    cell.delegate = self
                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    cell.set(user: user)
                    return cell
                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    cell.delegate = self
                    cell.set(user: user)
                    return cell
                }
            }
        } else if collectionView == repliesCollectionView {
            if replies.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                cell.set(withTitle: AppStrings.Content.Search.emptyTitle, withDescription: AppStrings.Content.Search.emptyContent)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentsCellReuseIdentifier, for: indexPath) as! UserProfileCommentCell
                cell.user = user
                cell.configure(recentComment: replies[indexPath.row])
                return cell
            }
        } else {
            if indexPath.section == 0 {
                if about.isEmpty && experiences.isEmpty && patents.isEmpty && publications.isEmpty && languages.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                    cell.set(withTitle: AppStrings.Content.Search.emptyTitle, withDescription: AppStrings.Content.Search.emptyContent)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileAboutCellReuseIdentifier, for: indexPath) as! UserProfileAboutCell
                    cell.set(body: about)
                    return cell
                }
            } else if indexPath.section == 1 {
                // Experience
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: experienceCellReuseIdentifier, for: indexPath) as! ProfileExperienceCell
                cell.set(experience: experiences[indexPath.row])
                if indexPath.row == experiences.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                return cell
                
            } else if indexPath.section == 2 {
                // Education
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: educationCellReuseIdentifier, for: indexPath) as! ProfileEducationCell
                cell.set(education: education[indexPath.row])
                if indexPath.row == education.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                return cell
                
            } else if indexPath.section == 3 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: patentCellReuseIdentifier, for: indexPath) as! ProfilePatentCell
                cell.set(patent: patents[indexPath.row])
                if indexPath.row == patents.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                return cell
                
            } else if indexPath.section == 4 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: publicationsCellReuseIdentifier, for: indexPath) as! ProfilePublicationCell
                cell.set(publication: publications[indexPath.row])
                if indexPath.row == publications.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                cell.delegate = self
                return cell
                
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: languageCellReuseIdentifier, for: indexPath) as! ProfileLanguageCell
                cell.set(language: languages[indexPath.row])
                if indexPath.row == languages.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == repliesCollectionView {
            guard !replies.isEmpty else { return }
            let reply = replies[indexPath.row]
            
            switch reply.source {
                
            case .post:
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .vertical
                layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: .leastNonzeroMagnitude)
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
                
                if reply.path.isEmpty {
                    let controller = DetailsPostViewController(postId: reply.contentId, collectionViewLayout: layout)
                    navigationController?.pushViewController(controller, animated: true)
                } else {
                    let controller = CommentPostRepliesViewController(postId: reply.contentId, uid: user.uid!, path: reply.path)
                    navigationController?.pushViewController(controller, animated: true)
                }
            case .clinicalCase:
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .vertical
                layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: .leastNonzeroMagnitude)
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
                
                if reply.path.isEmpty {
                    let controller = DetailsCaseViewController(caseId: reply.contentId, collectionViewLayout: layout)
                    navigationController?.pushViewController(controller, animated: true)
                } else {
                    let controller = CommentCaseRepliesViewController(caseId: reply.contentId, uid: user.uid!, path: reply.path)
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
}

extension UserProfileViewController: HomeCellDelegate {
    func cell(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(didTapMenuOptionsFor post: Post, option: PostMenu) {
        switch option {
        case .delete:
            if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                deletePost(withId: post.postId, at: IndexPath(item: index, section: 0))
            }
        case .edit:
            let controller = EditPostViewController(post: post)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
        case .report:
            let controller = ReportViewController(source: .post, contentUid: post.uid, contentId: post.postId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
            
        case .reference:
            guard let reference = post.reference else { return }
            referenceMenu.showImageSettings(in: view, forPostId: post.postId, forReferenceKind: reference)
            referenceMenu.delegate = self
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        
        self.navigationController?.delegate = zoomTransitioning
        
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
        let controller = LikesViewController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)
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
                    
                    strongSelf.posts.remove(at: indexPath.item)
                    if strongSelf.posts.isEmpty {
                        strongSelf.postsCollectionView.reloadData()
                    } else {
                        strongSelf.postsCollectionView.deleteItems(at: [indexPath])
                    }
                }
            }
        }
    }
    
    private func handleLikeUnLike(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        let postId = post.postId
        let didLike = posts[indexPath.row].didLike
        
        postDidChangeLike(postId: postId, didLike: didLike)

        cell.viewModel?.post.didLike.toggle()
        self.posts[indexPath.row].didLike.toggle()
        
        cell.viewModel?.post.likes = post.didLike ? post.likes - 1 : post.likes + 1
        self.posts[indexPath.row].likes = post.didLike ? post.likes - 1 : post.likes + 1
        
    }
    
    func handleBookmarkUnbookmark(for cell: HomeCellProtocol, at indexPath: IndexPath) {
        guard let post = cell.viewModel?.post else { return }
        
        let postId = post.postId
        let didBookmark = posts[indexPath.row].didBookmark
        
        postDidChangeBookmark(postId: postId, didBookmark: didBookmark)

        cell.viewModel?.post.didBookmark.toggle()
        self.posts[indexPath.row].didBookmark.toggle()
    }
}

//MARK: - PostChangesDelegate

extension UserProfileViewController: PostChangesDelegate {
    func postDidChangeComment(postId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }
    
    func postDidChangeVisible(postId: String) {
        currentNotification = true
        ContentManager.shared.visiblePostChange(postId: postId)
    }
    
    @objc func postVisibleChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostVisibleChange {
            if let index = posts.firstIndex(where: { $0.postId == change.postId }) {
                posts.remove(at: index)
                if posts.isEmpty {
                    postsCollectionView.reloadData()
                } else {
                    postsCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
    }
    
    func postDidChangeComment(postId: String, comment: Comment, action: CommentAction) {
        fatalError()
    }
    
    func postDidChangeBookmark(postId: String, didBookmark: Bool) {
        currentNotification = true
        ContentManager.shared.bookmarkPostChange(postId: postId, didBookmark: !didBookmark)
    }
    
    func postDidChangeLike(postId: String, didLike: Bool) {
        currentNotification = true
        ContentManager.shared.likePostChange(postId: postId, didLike: !didLike)
    }
    
    @objc func postBookmarkChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostBookmarkChange {
            if let index = posts.firstIndex(where: { $0.postId == change.postId }) {
                if let cell = postsCollectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? HomeCellProtocol {
                    self.posts[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.post.didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func postLikeChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? PostLikeChange {
            if let index = posts.firstIndex(where: { $0.postId == change.postId }) {
                if let cell = postsCollectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? HomeCellProtocol {
                    
                    let likes = self.posts[index].likes
                    
                    self.posts[index].likes = change.didLike ? likes + 1 : likes - 1
                    self.posts[index].didLike = change.didLike
                    
                    currentCell.viewModel?.post.didLike = change.didLike
                    currentCell.viewModel?.post.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
    
    @objc func postCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? PostCommentChange {
            if let index = posts.firstIndex(where: { $0.postId == change.postId }), change.path.isEmpty {
                if let cell = postsCollectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? HomeCellProtocol {
                    
                    let comments = self.posts[index].numberOfComments
                    
                    switch change.action {
                    case .add:
                        self.posts[index].numberOfComments = comments + 1
                        currentCell.viewModel?.post.numberOfComments = comments + 1
                    case .remove:
                        self.posts[index].numberOfComments = comments - 1
                        currentCell.viewModel?.post.numberOfComments = comments - 1
                    }
                }
            }
        }
    }
    
    @objc func postEditChange(_ notification: NSNotification) {
        if let change = notification.object as? PostEditChange {
            let post = change.post
            if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                posts[index] = post
                postsCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }
}

extension UserProfileViewController: CaseCellDelegate {
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete:
            if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                deleteCase(withId: clinicalCase.caseId, privacy: clinicalCase.privacy, at: IndexPath(item: index , section: 0))
            }

        case .revision:
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)
            navigationController?.pushViewController(controller, animated: true)
        case .solve:
            let controller = CaseDiagnosisViewController(clinicalCase: clinicalCase)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
        case .report:
            let controller = ReportViewController(source: .clinicalCase, contentUid: clinicalCase.uid, contentId: clinicalCase.caseId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        }
    }

    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        navigationController?.delegate = zoomTransitioning

        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)

        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)
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
        let controller = LikesViewController(clinicalCase: clinicalCase)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)

        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func handleLikeUnLike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didLike = self.cases[indexPath.row].didLike
        caseDidChangeLike(caseId: caseId, didLike: didLike)

        cell.viewModel?.clinicalCase.didLike.toggle()
        self.cases[indexPath.row].didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        self.cases[indexPath.row].likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
    }
    
    func handleBookmarkUnbookmark(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didBookmark = self.cases[indexPath.row].didBookmark
        caseDidChangeBookmark(caseId: caseId, didBookmark: didBookmark)

        cell.viewModel?.clinicalCase.didBookmark.toggle()
        self.cases[indexPath.row].didBookmark.toggle()
        
    }
    
    private func deleteCase(withId id: String, privacy: CasePrivacy, at indexPath: IndexPath) {
        displayAlert(withTitle: AppStrings.Alerts.Title.deleteCase, withMessage: AppStrings.Alerts.Subtitle.deleteCase, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            
            guard let _ = self else { return }
            
            CaseService.deleteCase(withId: id, privacy: privacy) { [weak self] error in
                guard let strongSelf = self else { return }
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.caseDidChangeVisible(caseId: id)
                    
                    strongSelf.cases.remove(at: indexPath.item)
                    if strongSelf.cases.isEmpty {
                        strongSelf.casesCollectionView.reloadData()
                    } else {
                        strongSelf.casesCollectionView.deleteItems(at: [indexPath])
                    }
                }
            }
        }
    }
}

extension UserProfileViewController: CaseChangesDelegate {

    func caseDidChangeVisible(caseId: String) {
        currentNotification = true
        ContentManager.shared.visibleCaseChange(caseId: caseId)
    }
    
    @objc func caseVisibleChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseVisibleChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                
                cases.remove(at: index)
                if cases.isEmpty {
                    casesCollectionView.reloadData()
                } else {
                    casesCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
    }

    func caseDidChangeLike(caseId: String, didLike: Bool) {
        currentNotification = true
        ContentManager.shared.likeCaseChange(caseId: caseId, didLike: !didLike)
    }
    
    
    @objc func caseLikeChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }

        if let change = notification.object as? CaseLikeChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? CaseCellProtocol {

                    let likes = self.cases[index].likes
                    
                    self.cases[index].likes = change.didLike ? likes + 1 : likes - 1
                    self.cases[index].didLike = change.didLike
                    
                    currentCell.viewModel?.clinicalCase.didLike = change.didLike
                    currentCell.viewModel?.clinicalCase.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
    
    func caseDidChangeBookmark(caseId: String, didBookmark: Bool) {
        currentNotification = true
        ContentManager.shared.bookmarkCaseChange(caseId: caseId, didBookmark: !didBookmark)
    }
    
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }

        if let change = notification.object as? CaseBookmarkChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? CaseCellProtocol {

                    self.cases[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.clinicalCase.didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.revision = .update
                    cases[index].revision = .update
                    casesCollectionView.reloadData()
                }
            }
        }
    }

    func caseDidChangeComment(caseId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }
    

    @objc func caseCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseCommentChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }), change.path.isEmpty {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    let comments = self.cases[index].numberOfComments

                    switch change.action {
                        
                    case .add:
                        cases[index].numberOfComments = comments + 1
                        cell.viewModel?.clinicalCase.numberOfComments = comments + 1
                    case .remove:
                        cases[index].numberOfComments = comments - 1
                        cell.viewModel?.clinicalCase.numberOfComments = comments - 1
                    }
                }
            }
        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseSolveChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.phase = .solved
                    cases[index].phase = .solved
                    
                    if let diagnosis = change.diagnosis {
                        cases[index].revision = diagnosis
                        cell.viewModel?.clinicalCase.revision = diagnosis
                    }
                    casesCollectionView.reloadData()
                }
            }
        }
    }
}


extension UserProfileViewController: ReferenceMenuDelegate {
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
        return selectedImage
    }
}

extension UserProfileViewController: PrimarySearchHeaderDelegate {
    func didTapSeeAll(_ header: UICollectionReusableView) {
        if header.tag == 1 {
            guard !experiences.isEmpty else { return }
            let controller = ExperienceSectionViewController(user: user, experiences: experiences)
            controller.delegate = self
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        } else if header.tag == 2 {
            guard !education.isEmpty else { return }
            let controller = EducationSectionViewController(user: user, educations: education)
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            
            navigationController?.pushViewController(controller, animated: true)
            navigationController?.pushViewController(controller, animated: true)
            
        } else if header.tag == 3 {
            guard !patents.isEmpty else { return }
            let controller = PatentSectionViewController(user: user, patents: patents)
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            
            navigationController?.pushViewController(controller, animated: true)
        } else if header.tag == 4 {
            guard !publications.isEmpty else { return }
            let controller = PublicationSectionViewController(user: user, publications: publications, isCurrentUser: user.isCurrentUser)
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            
            navigationController?.pushViewController(controller, animated: true)
            
        } else if header.tag == 5 {
            guard !experiences.isEmpty else { return }
            let controller = LanguageSectionViewController(languages: languages, user: user)
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension UserProfileViewController: ExperienceSectionViewControllerDelegate, EducationSectionViewControllerDelegate, PatentSectionViewControllerDelegate, PublicationSectionViewControllerDelegate, LanguageSectionViewControllerDelegate, ProfilePublicationCellDelegate {
    
    func didTapURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            presentSafariViewController(withURL: url)
        } else {
            presentWebViewController(withURL: url)
        }
    }
    
    func didUpdateExperience() {
        fetchExperience()
    }
    
    func didUpdateEducation() {
        fetchEducation()
    }
    
    func didUpdatePatent() {
        fetchPatents()
    }
    
    func didUpdatePublication() {
        fetchPublications()
    }
    
    func didUpdateLanguage() {
        fetchLanguages()
    }
}

extension UserProfileViewController: EditProfileViewControllerDelegate {
    func didUpdateProfile(user: User) {
        self.user = user
        
        configureUser()

        postsCollectionView.reloadData()
        casesCollectionView.reloadData()
        repliesCollectionView.reloadData()
        aboutCollectionView.reloadData()
        
        setUserDefaults(for: user)
        
        currentNotification = true
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil, userInfo: ["user": user])
        
        guard let tab = self.tabBarController as? MainTabController else { return }
        tab.updateUser(user: user)
    }

    func fetchNewAboutValues(withUid uid: String) {
        fetchAbout()
    }
    
    func fetchNewExperienceValues() {
        fetchExperience()
    }
    
    func fetchNewEducationValues() {
        fetchEducation()
    }
    
    func fetchNewPatentValues() {
        fetchPatents()
    }
    
    func fetchNewPublicationValues() {
        fetchPublications()
    }
    
    func fetchNewLanguageValues() {
        fetchLanguages()
    }
}

// User Changes

extension UserProfileViewController {
    @objc func userDidChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }

        if let user = notification.userInfo!["user"] as? User {
            self.user = user
            configureUser()
            postsCollectionView.reloadData()
            casesCollectionView.reloadData()
            repliesCollectionView.reloadData()
            aboutCollectionView.reloadData()
        }
    }
    
    @objc func followDidChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? UserFollowChange {
            if user.uid == change.uid, !user.isCurrentUser {
                user.set(isFollowed: change.isFollowed)
                fetchStats()
                configureUser()
                
                postsCollectionView.reloadData()
                casesCollectionView.reloadData()
                repliesCollectionView.reloadData()
                aboutCollectionView.reloadData()

                if change.isFollowed {
                    actionButton.menu = addUnfollowMenu()
                } else {
                    
                    let viewModel = ProfileHeaderViewModel(user: user)
                    var container = AttributeContainer()
                    container.font = .systemFont(ofSize: 14, weight: .bold)
                    
                    actionButton.configuration?.baseBackgroundColor = viewModel.followBackgroundColor
                    actionButton.configuration?.baseForegroundColor = viewModel.followTextColor
                    actionButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
                    actionButton.configuration?.background.strokeWidth = viewModel.followButtonBorderWidth
                    actionButton.configuration?.attributedTitle = AttributedString(viewModel.followText, attributes: container)
                    actionButton.showsMenuAsPrimaryAction = false
                }
            }
        }
    }
    
    func userDidChangeFollow(uid: String, didFollow: Bool) {
        currentNotification = true
        ContentManager.shared.userFollowChange(uid: uid, isFollowed: didFollow)
    }
}
