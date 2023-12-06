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
private let postTextImageCellReuseIdentifier = "PostTextImageCellReuseIdentifier"

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
    
    private var viewModel: UserProfileViewModel
    
    private var scrollView: UIScrollView!
    private var postsCollectionView: UICollectionView!
    private var casesCollectionView: UICollectionView!
    private var repliesCollectionView: UICollectionView!
    private var aboutCollectionView: UICollectionView!

    private var topHeaderAnchorConstraint: NSLayoutConstraint!
    private var topProfileAnchorConstraint: NSLayoutConstraint!
    private var topToolbarAnchorConstraint: NSLayoutConstraint!
    private var topButtonAnchorConstraint: NSLayoutConstraint!
    private var topWebsiteAnchorConstraint: NSLayoutConstraint!
    
    private var profileToolbar: ProfileToolbar!
    private var postsSpacingView = SpacingView()
    private var casesSpacingView = SpacingView()
    private var repliesSpacingView = SpacingView()
    private var headerTopInset: CGFloat!
    
    private var zoomTransitioning = ZoomTransitioning()
    
    private let referenceMenu = ReferenceMenu()
    private var connectionMenu: ConnectionMenu!
    
    private let activityIndicator = LoadingIndicatorView(frame: .zero)

    private let bannerImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = primaryColor
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
        button.tintAdjustmentMode = .normal
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
        configuration.cornerStyle = .capsule
        button.configuration = configuration
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleActionButtonTap), for: .touchUpInside)
        return button
    }()
    
    private let name: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.addFont(size: 23, scaleStyle: .largeTitle, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        return label
    }()
    
    private let discipline: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var connections: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowFollowers)))
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var websiteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintAdjustmentMode = .normal
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .label
        configuration.buttonSize = .mini
        configuration.image = UIImage(named: AppStrings.Assets.link)?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 25))
        configuration.imagePlacement = .leading
        configuration.imagePadding = 5
        button.configuration = configuration
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleWebsiteTap), for: .touchUpInside)
        return button
    }()
    
    private let padding: CGFloat = 10.0
    private let profileImageHeight: CGFloat = 70.0
    private var bannerHeight = 0.0
    private let buttonHeight = 40.0
    private let toolbarHeight = 50.0
    
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
        
        if !viewModel.collectionsLoaded && viewModel.uid == nil {
            viewModel.collectionsLoaded = true
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
        view.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false

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
        postsCollectionView.register(PostTextCell.self, forCellWithReuseIdentifier: homeTextCellReuseIdentifier)
        postsCollectionView.register(PostTextImageCell.self, forCellWithReuseIdentifier: postTextImageCellReuseIdentifier)
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
        
        if let banner = viewModel.user.bannerUrl, !banner.isEmpty {
            topHeaderAnchorConstraint = bannerImage.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10)
            bannerHeight = (view.frame.width - 20.0) / bannerAR
            headerTopInset = 3 * padding + bannerHeight + profileImageHeight + buttonHeight + padding / 2
            topProfileAnchorConstraint = profileImage.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: padding + padding / 2)
        } else {
            headerTopInset = 3 * padding + profileImageHeight + buttonHeight
            topHeaderAnchorConstraint = bannerImage.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0)
            bannerHeight = 0
            topProfileAnchorConstraint = profileImage.topAnchor.constraint(equalTo: bannerImage.bottomAnchor)
        }
        
        topToolbarAnchorConstraint = profileToolbar.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: headerTopInset)
        topWebsiteAnchorConstraint = websiteButton.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 15)
        topButtonAnchorConstraint = actionButton.topAnchor.constraint(equalTo: websiteButton.bottomAnchor, constant: 5)
        
        scrollView.addSubviews(postsCollectionView, casesCollectionView, repliesCollectionView, aboutCollectionView, profileToolbar, postsSpacingView, casesSpacingView, repliesSpacingView, bannerImage, profileImage, actionButton, name, discipline, connections, websiteButton)
        
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
            
            connections.topAnchor.constraint(equalTo: discipline.bottomAnchor),
            connections.leadingAnchor.constraint(equalTo: discipline.leadingAnchor),
            connections.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            topWebsiteAnchorConstraint,
            websiteButton.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            websiteButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),

            topButtonAnchorConstraint,
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
        bannerImage.layer.cornerRadius = 12
        profileImage.layer.cornerRadius = profileImageHeight / 2
        
        postsCollectionView.backgroundColor = .systemBackground
        casesCollectionView.backgroundColor = .systemBackground
        repliesCollectionView.backgroundColor = .systemBackground
        aboutCollectionView.backgroundColor = .systemBackground
/*
        postsCollectionView.contentInset.top = headerTopInset + toolbarHeight
        postsCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
        
        casesCollectionView.contentInset.top = headerTopInset + toolbarHeight
        casesCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
        
        repliesCollectionView.contentInset.top = headerTopInset + toolbarHeight
        repliesCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
        
        aboutCollectionView.contentInset.top = headerTopInset + toolbarHeight
        aboutCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
 */

    }
    
    private func configureUser() {
        if let url = viewModel.user.profileUrl, url != "" {
            profileImage.sd_setImage(with: URL(string: url))
        }
        
        if let banner = viewModel.user.bannerUrl, banner != "" {
            bannerImage.sd_setImage(with: URL(string: banner))
        }
        
        name.text = viewModel.user.name()
        discipline.text = viewModel.user.details()
        websiteButton.isHidden = viewModel.website.isEmpty
        
        let viewModel = ProfileHeaderViewModel(user: viewModel.user)
        connections.attributedText = viewModel.connectionsText
        
        websiteButton.configuration?.attributedTitle = viewModel.website(self.viewModel.website)
        websiteButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: self.viewModel.website.isEmpty ? 0 : 10, trailing: 0)
        
        topWebsiteAnchorConstraint.constant = self.viewModel.website.isEmpty ? 0 : 15
        headerTopInset = self.viewModel.website.isEmpty ? headerTopInset + 1.5 * padding : headerTopInset + websiteButton.frame.height + padding
        
        topToolbarAnchorConstraint.constant = headerTopInset
        
        postsCollectionView.contentInset.top = headerTopInset + toolbarHeight
        postsCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
        
        casesCollectionView.contentInset.top = headerTopInset + toolbarHeight
        casesCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
        
        repliesCollectionView.contentInset.top = headerTopInset + toolbarHeight
        repliesCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
        
        aboutCollectionView.contentInset.top = headerTopInset + toolbarHeight
        aboutCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
        
        view.layoutIfNeeded()
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
    
    private func aboutLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
            
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.viewModel.aboutLoaded || sectionNumber == 0 && !strongSelf.viewModel.about.isEmpty || sectionNumber == 1 && !strongSelf.viewModel.publications.isEmpty || sectionNumber == 2 && !strongSelf.viewModel.languages.isEmpty {
                 
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
            fetchUserContent()
        }
    }
    
    private func configureActionButton() {
        let viewModel = ProfileHeaderViewModel(user: viewModel.user)
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 16, scaleStyle: .largeTitle, weight: .bold, scales: false)
        
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = viewModel.connectBackgroundColor
        configuration.baseForegroundColor = viewModel.connectTextColor
        configuration.attributedTitle = AttributedString(viewModel.connectionText, attributes: container)
        configuration.background.strokeColor = viewModel.connectButtonBorderColor
       
        configuration.image = viewModel.connectImage
        configuration.imagePlacement = viewModel.connectImagePlacement
        configuration.imagePadding = 10
        
        actionButton.configuration = configuration
        actionButton.isUserInteractionEnabled = true
    }
    
    private func fetchUser() {
        viewModel.fetchUser { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configure()
            strongSelf.fetchUserContent()
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
                strongSelf.connectionMenu = ConnectionMenu(user: strongSelf.viewModel.user)
                strongSelf.connectionMenu.delegate = self
                strongSelf.viewModel.collectionsLoaded = true
                strongSelf.configureUser()
                strongSelf.configureActionButton()
                strongSelf.configureNavigationBar()
                strongSelf.activityIndicator.stop()
                strongSelf.activityIndicator.removeFromSuperview()
                strongSelf.postsCollectionView.reloadData()
                
                let appearance = UINavigationBarAppearance.profileAppearance()
                strongSelf.navigationItem.scrollEdgeAppearance = appearance
                strongSelf.navigationItem.standardAppearance = appearance
                
                strongSelf.scrollView.isHidden = false
                strongSelf.view.layoutIfNeeded()
            }
        }
    }
    
    private func fetchCases() {
        viewModel.fetchCases { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.casesCollectionView.reloadData()
        }
    }
    
    func fetchComments() {
        viewModel.fetchComments { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.repliesCollectionView.reloadData()
        }
    }
    
    private func fetchAbout() {
        viewModel.fetchAbout { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.aboutCollectionView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @objc func handleImageTap() {
        let controller = ProfileImageViewController(isBanner: false)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if let imageUrl = strongSelf.viewModel.user.profileUrl, imageUrl != "" {
                controller.profileImageView.sd_setImage(with: URL(string: imageUrl))
            } else {
                controller.profileImageView.image = UIImage(named: AppStrings.Assets.profile)
            }
            controller.modalPresentationStyle = .overFullScreen
            strongSelf.present(controller, animated: true)
        }
    }
    
    @objc func handleShowFollowers() {
        let controller = UserNetworkViewController(user: viewModel.user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleWebsiteTap() {
        if let url = URL(string: viewModel.getFormatUrl()) {
            if UIApplication.shared.canOpenURL(url) {
                presentSafariViewController(withURL: url)
            } else {
                presentWebViewController(withURL: url)
            }
        }
    }
    
    @objc func handleActionButtonTap() {
        if viewModel.user.isCurrentUser {
            if viewModel.user.phase == .verified {
                let controller = EditProfileViewController(user: viewModel.user)
                controller.delegate = self
                
                let navVC = UINavigationController(rootViewController: controller)
                navVC.modalPresentationStyle = .fullScreen
                present(navVC, animated: true)
            } else {
                ContentManager.shared.permissionAlert(kind: .profile)
            }

        } else {
            if let phase = UserDefaults.getPhase(), phase == .verified {
                guard let connection = viewModel.user.connection else { return }
                
                switch connection.phase {
                    
                case .connected, .pending, .received, .rejected, .withdraw, .none, .unconnect:
                    connectionMenu.showMenu(in: view)
                }
            } else {
                ContentManager.shared.permissionAlert(kind: .connections)
            }
        }
    }
}

extension UserProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        
        guard viewModel.collectionsLoaded else { return }
        
        if scrollView == casesCollectionView || scrollView == postsCollectionView || scrollView == repliesCollectionView || scrollView == aboutCollectionView {
            viewModel.isScrollingHorizontally = false
            
            let minimumContentHeight = visibleScreenHeight - 49

            if viewModel.collectionsLoaded {
                postsCollectionView.contentInset.bottom = max(0, minimumContentHeight - postsCollectionView.contentSize.height)
                casesCollectionView.contentInset.bottom = max(0, minimumContentHeight - casesCollectionView.contentSize.height)
                repliesCollectionView.contentInset.bottom = max(0, minimumContentHeight - repliesCollectionView.contentSize.height)
                aboutCollectionView.contentInset.bottom = max(0, minimumContentHeight - aboutCollectionView.contentSize.height)
            }
            
            switch viewModel.index {
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

                switch viewModel.index {
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
            
            switch viewModel.index {
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
        } else if scrollView == self.scrollView {
            viewModel.isScrollingHorizontally = true
            profileToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
            
            if scrollView.contentOffset.x > view.frame.width * 0.2 && !viewModel.isFetchingOrDidFetchCases {
                fetchCases()
            }
            
            if scrollView.contentOffset.x > view.frame.width * 1.2 && !viewModel.isFetchingOrDidFetchReplies {
                fetchComments()
            }
            
            if scrollView.contentOffset.x > view.frame.width * 2.2 && !viewModel.isFetchingOrDidFetchAbout {
                fetchAbout()
            }
            
            switch offset.x {
            case 0 ..< view.frame.width + 10:
                viewModel.index = 0
            case view.frame.width + 10 ..< 2 * (view.frame.width + 10):
                viewModel.index = 1
            case 2 * (view.frame.width + 10) ..< 3 * (view.frame.width + 10):
                viewModel.index = 2
            default:
                viewModel.index = 3
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
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollView.isUserInteractionEnabled = true
        postsCollectionView.isScrollEnabled = true
        casesCollectionView.isScrollEnabled = true
        repliesCollectionView.isScrollEnabled = true
        aboutCollectionView.isScrollEnabled = true
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
            postsCollectionView.setContentOffset(postsCollectionView.contentOffset, animated: false)
        case 1:
            casesCollectionView.setContentOffset(casesCollectionView.contentOffset, animated: false)
        case 2:
            repliesCollectionView.setContentOffset(repliesCollectionView.contentOffset, animated: false)
        case 3:
            aboutCollectionView.setContentOffset(aboutCollectionView.contentOffset, animated: false)
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
        aboutCollectionView.isScrollEnabled = false
        self.scrollView.isUserInteractionEnabled = false

        scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width) + index * 10, y: 0), animated: true)
        viewModel.index = index
    }
}

extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == aboutCollectionView {
            return viewModel.aboutLoaded ? 3 : 1
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == postsCollectionView {
            return viewModel.postsLoaded ? viewModel.posts.isEmpty ? 1 : viewModel.posts.count : 0
        } else if collectionView == casesCollectionView {
            return viewModel.casesLoaded ? viewModel.cases.isEmpty ? 1 : viewModel.cases.count : 0
        } else if collectionView == repliesCollectionView {
            return viewModel.repliesLoaded ? viewModel.replies.isEmpty ? 1 : viewModel.replies.count : 0
        } else {
            if viewModel.aboutLoaded {
                if section == 0 {
                    if viewModel.about.isEmpty && viewModel.experiences.isEmpty && viewModel.patents.isEmpty && viewModel.publications.isEmpty && viewModel.languages.isEmpty {
                        return 1
                    } else {
                        return viewModel.about.isEmpty ? 0 : 1
                    }
                } else if section == 1 {
                    return viewModel.publications.isEmpty ? 0 : min(viewModel.publications.count, 3)
                } else {
                    return viewModel.languages.isEmpty ? 0 : min(viewModel.languages.count, 3)
                }
            } else {
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == aboutCollectionView {
            if viewModel.aboutLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileHeaderReuseIdentifier, for: indexPath) as! PrimaryProfileHeader
                header.delegate = self
                header.tag = indexPath.section
                
                if indexPath.section == 0 {
                    header.configureWith(title: AppStrings.Sections.aboutSection, linkText: "")
                    header.hideSeparator()
                } else if indexPath.section == 1 {
                    header.configureWith(title: AppStrings.Sections.publicationsTitle, linkText: AppStrings.Content.Search.seeAll)
                    header.hideSeeAllButton(viewModel.publications.count < 3)
                } else {
                    header.configureWith(title: AppStrings.Sections.languagesTitle, linkText: AppStrings.Content.Search.seeAll)
                    header.hideSeeAllButton(viewModel.languages.count < 3)
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
            if viewModel.posts.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                cell.set(withTitle: AppStrings.Content.Search.emptyTitle, withDescription: AppStrings.Content.Search.emptyContent)
                return cell
            } else {
                let currentPost = viewModel.posts[indexPath.row]
                let kind = currentPost.kind
                
                switch kind {
                    
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTextCellReuseIdentifier, for: indexPath) as! PostTextCell
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
        } else if collectionView == repliesCollectionView {
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
        } else {
            if indexPath.section == 0 {
                if viewModel.about.isEmpty && viewModel.experiences.isEmpty && viewModel.patents.isEmpty && viewModel.publications.isEmpty && viewModel.languages.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                    cell.set(withTitle: AppStrings.Content.Search.emptyTitle, withDescription: AppStrings.Content.Search.emptyContent)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileAboutCellReuseIdentifier, for: indexPath) as! UserProfileAboutCell
                    cell.delegate = self
                    cell.set(body: viewModel.about)
                    return cell
                }
            } else if indexPath.section == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: publicationsCellReuseIdentifier, for: indexPath) as! ProfilePublicationCell
                cell.set(publication: viewModel.publications[indexPath.row])
                cell.delegate = self
                return cell
                
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: languageCellReuseIdentifier, for: indexPath) as! ProfileLanguageCell
                cell.set(language: viewModel.languages[indexPath.row])
                return cell
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
                    let controller = CommentPostRepliesViewController(postId: reply.contentId, uid: viewModel.user.uid!, path: reply.path)
                    navigationController?.pushViewController(controller, animated: true)
                }
            case .clinicalCase:
              
                if reply.path.isEmpty {
                    let controller = DetailsCaseViewController(caseId: reply.contentId)
                    navigationController?.pushViewController(controller, animated: true)
                } else {
                    let controller = CommentCaseRepliesViewController(caseId: reply.contentId, uid: viewModel.user.uid!, path: reply.path)
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
        } else if collectionView == aboutCollectionView {
            if indexPath.section == 0 { return }
            else if indexPath.section == 1 {
                guard !viewModel.publications.isEmpty, viewModel.user.isCurrentUser else { return }
                let controller = PublicationSectionViewController(user: viewModel.user, publications: viewModel.publications, isCurrentUser: viewModel.user.isCurrentUser)
                controller.hidesBottomBarWhenPushed = true
                controller.delegate = self
                
                navigationController?.pushViewController(controller, animated: true)
            } else if indexPath.section == 2 {
                guard !viewModel.languages.isEmpty, viewModel.user.isCurrentUser else { return }
                let controller = LanguageSectionViewController(languages: viewModel.languages, user: viewModel.user)
                controller.hidesBottomBarWhenPushed = true
                controller.delegate = self
                
                navigationController?.pushViewController(controller, animated: true)
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
        let controller = DetailsPostViewController(post: post, user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        
        self.navigationController?.delegate = zoomTransitioning
        
        viewModel.selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
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
                    if strongSelf.viewModel.posts.isEmpty {
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
                if viewModel.posts.isEmpty {
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
                postsCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
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
            let controller = ReportViewController(source: .clinicalCase, contentUid: clinicalCase.uid, contentId: clinicalCase.caseId)
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

        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)

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
                if viewModel.cases.isEmpty {
                    casesCollectionView.reloadData()
                } else {
                    casesCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }
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
        return viewModel.selectedImage
    }
}

extension UserProfileViewController: PrimarySearchHeaderDelegate {
    func didTapSeeAll(_ header: UICollectionReusableView) {
        if header.tag == 1 {
            guard !viewModel.publications.isEmpty else { return }
            let controller = PublicationSectionViewController(user: viewModel.user, publications: viewModel.publications, isCurrentUser: viewModel.user.isCurrentUser)
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            
            navigationController?.pushViewController(controller, animated: true)
        } else if header.tag == 2 {
            guard !viewModel.languages.isEmpty else { return }
            let controller = LanguageSectionViewController(languages: viewModel.languages, user: viewModel.user)
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
        fetchNewExperienceValues()
    }
    
    func didUpdateEducation() {
        fetchNewEducationValues()
    }
    
    func didUpdatePatent() {
        fetchNewPatentValues()
    }
    
    func didUpdatePublication() {
        fetchNewPublicationValues()
    }
    
    func didUpdateLanguage() {
        fetchNewLanguageValues()
    }
}

extension UserProfileViewController: ConnectionMenuDelegate {
    func didTapConnectMenu(menu: ConnectMenu) {
        switch menu {
        case .connect:
            guard let connection = viewModel.user.connection else { return }

            switch connection.phase {
                
            case .connected:

                displayAlert(withTitle: AppStrings.Alerts.Title.remove, withMessage: AppStrings.Alerts.Subtitle.remove, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.withdraw, style: .destructive) { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.actionButton.isUserInteractionEnabled = false
                    strongSelf.connectionMenu.handleDismissMenu()

                    strongSelf.viewModel.unconnect { [weak self] error in
                        guard let strongSelf = self else { return }
                        if let error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                            strongSelf.configureActionButton()
                            
                            let viewModel = ProfileHeaderViewModel(user: strongSelf.viewModel.user)
                            strongSelf.connections.attributedText = viewModel.connectionsText
                            strongSelf.connectionMenu.set(user: strongSelf.viewModel.user)
                            
                            strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .unconnect)
                        }
                    }
                }
            case .pending:

                displayAlert(withTitle: AppStrings.Alerts.Title.withdraw, withMessage: AppStrings.Alerts.Subtitle.withdraw, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.withdraw, style: .destructive) { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.actionButton.isUserInteractionEnabled = false
                    strongSelf.connectionMenu.handleDismissMenu()
                    
                    strongSelf.viewModel.withdraw { [weak self] error in
                        guard let strongSelf = self else { return }
                        if let error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                            strongSelf.configureActionButton()
                            strongSelf.connectionMenu.set(user: strongSelf.viewModel.user)
                            
                            strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .withdraw)
                        }
                    }
                }
            case .received:

                guard let tab = self.tabBarController as? MainTabController, let currentUser = tab.user else { return }
                actionButton.isUserInteractionEnabled = false
                connectionMenu.handleDismissMenu()
                
                viewModel.accept(currentUser: currentUser) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        strongSelf.configureActionButton()
                        strongSelf.viewModel.set(isFollowed: true)
                        
                        let viewModel = ProfileHeaderViewModel(user: strongSelf.viewModel.user)
                        strongSelf.connections.attributedText = viewModel.connectionsText
                        
                        strongSelf.connectionMenu.set(user: strongSelf.viewModel.user)
                        
                        strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .connected)
                    }
                }
                
            case .none:
                // Send a connection request
                actionButton.isUserInteractionEnabled = false
                connectionMenu.handleDismissMenu()
                
                viewModel.connect { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        strongSelf.configureActionButton()
                        strongSelf.viewModel.set(isFollowed: true)
                        strongSelf.connectionMenu.set(user: strongSelf.viewModel.user)
                        
                        strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .pending)
                    }
                }
            case .rejected:

                guard viewModel.hasWeeksPassedSince(forWeeks: 5, timestamp: connection.timestamp) else {
                    connectionMenu.handleDismissMenu()
                    displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.connectionDeny)
                    return
                }
                
                actionButton.isUserInteractionEnabled = false
                connectionMenu.handleDismissMenu()
                
                viewModel.connect { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        strongSelf.configureActionButton()
                        strongSelf.viewModel.set(isFollowed: true)
                        strongSelf.connectionMenu.set(user: strongSelf.viewModel.user)
                        
                        strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .pending)
                    }
                }
                
            case .withdraw:
                // The owner withdrawed the request and can send a request again.
                guard viewModel.hasWeeksPassedSince(forWeeks: 3, timestamp: connection.timestamp) else {
                    connectionMenu.handleDismissMenu()
                    displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.connection)
                    return
                }
                
                actionButton.isUserInteractionEnabled = false
                connectionMenu.handleDismissMenu()
                
                viewModel.connect { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        strongSelf.configureActionButton()
                        strongSelf.viewModel.set(isFollowed: true)
                        strongSelf.connectionMenu.set(user: strongSelf.viewModel.user)
                        
                        strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .pending)
                    }
                }
            case .unconnect:
                // Connection was removed by one of the users so connection can be sent again
                guard viewModel.hasWeeksPassedSince(forWeeks: 5, timestamp: connection.timestamp) else {
                    connectionMenu.handleDismissMenu()
                    displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.connection5)
                    return
                }
                
                actionButton.isUserInteractionEnabled = false
                connectionMenu.handleDismissMenu()
                
                viewModel.connect { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        strongSelf.configureActionButton()
                        strongSelf.connectionMenu.set(user: strongSelf.viewModel.user)
                        
                        strongSelf.userDidChangeConnection(uid: strongSelf.viewModel.user.uid!, phase: .pending)
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
                    
                    strongSelf.actionButton.isUserInteractionEnabled = false
                    strongSelf.connectionMenu.handleDismissMenu()

                    strongSelf.viewModel.unfollow { [weak self] error in
                        guard let strongSelf = self else { return }
                        
                        if let error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                            strongSelf.actionButton.isUserInteractionEnabled = true
                            strongSelf.connectionMenu.set(user: strongSelf.viewModel.user)
                            strongSelf.userDidChangeFollow(uid: strongSelf.viewModel.user.uid!, didFollow: false)
                        }
                    }
                }
            } else {
                
                actionButton.isUserInteractionEnabled = false
                connectionMenu.handleDismissMenu()
                
                viewModel.follow { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        strongSelf.actionButton.isUserInteractionEnabled = true
                        strongSelf.connectionMenu.set(user: strongSelf.viewModel.user)
                        strongSelf.userDidChangeFollow(uid: strongSelf.viewModel.user.uid!, didFollow: true)
                    }
                }
            }
        case .message:
            connectionMenu.handleDismissMenu()
            
            guard let connection = viewModel.user.connection, connection.phase == .connected else {
                displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.message)
                return
            }
            
            guard let uid = UserDefaults.getUid() else { return }
            let name = viewModel.user.name()
            let conversation = Conversation(name: name, userId: viewModel.user.uid!, ownerId: uid)
            
            let controller = MessageViewController(conversation: conversation, user: viewModel.user, presented: true)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            
            present(navVC, animated: true)
            connectionMenu.handleDismissMenu()
        case .report:
            connectionMenu.handleDismissMenu()
            let controller = ReportViewController(source: .user, contentUid: viewModel.user.uid!, contentId: "")
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        }
    }
}

extension UserProfileViewController: EditProfileViewControllerDelegate {
    func didUpdateProfile(user: User) {
        viewModel.set(user: user)
        
        configureUser()

        postsCollectionView.reloadData()
        casesCollectionView.reloadData()
        repliesCollectionView.reloadData()
        aboutCollectionView.reloadData()
        
        setUserDefaults(for: user)
        
        viewModel.currentNotification = true

        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil, userInfo: ["user": user])
        
        guard let tab = self.tabBarController as? MainTabController else { return }
        tab.updateUser(user: user)
    }
    
    func fetchNewWebsiteValues() {
        let hadWebsite = !viewModel.website.isEmpty
        let buttonHeight = websiteButton.frame.height
        viewModel.getWebsite { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.websiteButton.isHidden = strongSelf.viewModel.website.isEmpty
            
            let viewModel = ProfileHeaderViewModel(user: strongSelf.viewModel.user)
            strongSelf.websiteButton.configuration?.attributedTitle = viewModel.website(strongSelf.viewModel.website)
            
            strongSelf.websiteButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: strongSelf.viewModel.website.isEmpty ? 0 : 10, trailing: 0)
            strongSelf.topWebsiteAnchorConstraint.constant = strongSelf.viewModel.website.isEmpty ? 0 : 15
            
            if strongSelf.viewModel.website.isEmpty {
                strongSelf.headerTopInset = strongSelf.headerTopInset - buttonHeight //+ 1.5 * strongSelf.padding
            } else {
                strongSelf.headerTopInset = hadWebsite ? strongSelf.headerTopInset : strongSelf.headerTopInset + strongSelf.websiteButton.frame.height + strongSelf.padding
            }
           
            strongSelf.topToolbarAnchorConstraint.constant = strongSelf.headerTopInset

            strongSelf.postsCollectionView.contentInset.top = strongSelf.headerTopInset + strongSelf.toolbarHeight
            strongSelf.postsCollectionView.verticalScrollIndicatorInsets.top = strongSelf.headerTopInset + strongSelf.toolbarHeight
            
            strongSelf.casesCollectionView.contentInset.top = strongSelf.headerTopInset + strongSelf.toolbarHeight
            strongSelf.casesCollectionView.verticalScrollIndicatorInsets.top = strongSelf.headerTopInset + strongSelf.toolbarHeight
            
            strongSelf.repliesCollectionView.contentInset.top = strongSelf.headerTopInset + strongSelf.toolbarHeight
            strongSelf.repliesCollectionView.verticalScrollIndicatorInsets.top = strongSelf.headerTopInset + strongSelf.toolbarHeight
            
            strongSelf.aboutCollectionView.contentInset.top = strongSelf.headerTopInset + strongSelf.toolbarHeight
            strongSelf.aboutCollectionView.verticalScrollIndicatorInsets.top = strongSelf.headerTopInset + strongSelf.toolbarHeight
            
            strongSelf.view.setNeedsLayout()
            strongSelf.view.layoutIfNeeded()
            
            strongSelf.scrollViewDidScroll(strongSelf.postsCollectionView)
            /*
             if let url = viewModel.user.profileUrl, url != "" {
                 profileImage.sd_setImage(with: URL(string: url))
             }
             
             if let banner = viewModel.user.bannerUrl, banner != "" {
                 bannerImage.sd_setImage(with: URL(string: banner))
             }
             
             name.text = viewModel.user.name()
             discipline.text = viewModel.user.details()
             websiteButton.isHidden = viewModel.website.isEmpty
             
             let viewModel = ProfileHeaderViewModel(user: viewModel.user)
             connections.attributedText = viewModel.connectionsText
             
             websiteButton.configuration?.attributedTitle = viewModel.website(self.viewModel.website)
             websiteButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: self.viewModel.website.isEmpty ? 0 : 10, trailing: 0)
             
             topWebsiteAnchorConstraint.constant = self.viewModel.website.isEmpty ? 0 : 15
             headerTopInset = self.viewModel.website.isEmpty ? headerTopInset + 1.5 * padding : headerTopInset + websiteButton.frame.height + padding
             
             topToolbarAnchorConstraint.constant = headerTopInset
             
             postsCollectionView.contentInset.top = headerTopInset + toolbarHeight
             postsCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
             
             casesCollectionView.contentInset.top = headerTopInset + toolbarHeight
             casesCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
             
             repliesCollectionView.contentInset.top = headerTopInset + toolbarHeight
             repliesCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
             
             aboutCollectionView.contentInset.top = headerTopInset + toolbarHeight
             aboutCollectionView.verticalScrollIndicatorInsets.top = headerTopInset + toolbarHeight
             
             view.layoutIfNeeded()
             */
        }
    }

    func fetchNewAboutValues(withUid uid: String) {
        viewModel.fetchAboutText { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.aboutCollectionView.reloadData()
        }
    }
    
    func fetchNewExperienceValues() {
        viewModel.fetchExperience { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.aboutCollectionView.reloadData()
        }
    }
    
    func fetchNewEducationValues() {
        viewModel.fetchEducation { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.aboutCollectionView.reloadData()
        }
    }
    
    func fetchNewPatentValues() {
        viewModel.fetchPatents { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.aboutCollectionView.reloadData()
        }
    }
    
    func fetchNewPublicationValues() {
        viewModel.fetchPublications { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.aboutCollectionView.reloadData()
        }
    }
    
    func fetchNewLanguageValues() {
        viewModel.fetchLanguages { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.aboutCollectionView.reloadData()
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
            viewModel.set(user: user)
            configureUser()
            postsCollectionView.reloadData()
            casesCollectionView.reloadData()
            repliesCollectionView.reloadData()
            aboutCollectionView.reloadData()
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
                connectionMenu.set(user: viewModel.user)
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
                configureActionButton()
                connectionMenu.set(user: viewModel.user)
            }
        }
    }
    
    func userDidChangeConnection(uid: String, phase: ConnectPhase) {
        viewModel.currentNotification = true
        ContentManager.shared.userConnectionChange(uid: uid, phase: phase)
    }
}
