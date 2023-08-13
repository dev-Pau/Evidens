//
//  UserProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/5/22.
//

import UIKit
import GoogleSignIn

private let stretchyReuseIdentifier = "StretchyReuseIdentifier"
private let profileHeaderReuseIdentifier = "ProfileHeaderReuseIdentifier"
private let profileAboutCellReuseIdentifier = "ProfileAboutCellReuseIdentifier"
private let profileHeaderTitleReuseIdentifier = "ProfileHeaderTitleReuseIdentifier"
private let profileFooterTitleReuseIdentifier = "ProfileFooterTitleReuseIdentifier"
private let noRecentPostsCellReuseIdentifier = "NoRecentPostsCellReuseIdentifier"
private let postImageCellReuseIdentifier = "ProfileImageCellReuseIdentifier"
private let postTextCellReuseIdentifier = "PostTextCellReuseIdentifier"
private let noRecentCasesCellReuseIdentifier = "NoRecentCasesCellReuseIdentifier"
private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseImageCellReuseIdentifier = "CaseImageCellReuseIdentifier"
private let noCommentsCellReuseIdentifier = "NoCommentsCellReuseIdentifier"
private let commentsCellReuseIdentifier = "CommentsCellReuseIdentifier"
private let experienceCellReuseIdentifier = "ExperienceCellReuseIdentifier"
private let educationCellReuseIdentifier = "EducationCellReuseIdentifier"
private let patentCellReuseIdentifier = "PatentCellReuseIdentifier"
private let publicationsCellReuseIdentifier = "PublicationCellReuseIdentifier"
private let languageCellReuseIdentifier = "LanguageCellReuseIdentifier"
private let seeOthersCellReuseIdentifier = "SeeOthersCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"


protocol UserProfileViewControllerDelegate: AnyObject {
    func didFollowUser(user: User, didFollow: Bool)
}

class UserProfileViewController: UIViewController {

    //MARK: - Properties
    
    weak var delegate: UserProfileViewControllerDelegate?
    private var standardAppearance = UINavigationBarAppearance()
    private lazy var profileImageTopPadding = view.frame.width / 3 - 20

    private var user: User
    private var loaded: Bool = false
    private var collectionView: UICollectionView!
    private var recentPosts = [Post]()
    private var recentCases = [Case]()
    private var recentComments = [BaseComment]()
    private var relatedUsers = [User]()
    
    private var networkError = false
    
    private var scrollViewDidScrollHigherThanActionButton: Bool = false

    private var aboutText: String = ""
    private var languages = [Language]()
    private var patents = [Patent]()
    private var publications = [Publication]()
    private var educations = [Education]()
    private var experiences = [Experience]()
    
    private lazy var customRightButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleUserButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var ellipsisRightButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.baseBackgroundColor = .label.withAlphaComponent(0.7)
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.baseBackgroundColor = .label.withAlphaComponent(0.7)
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.isHidden = false
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.systemBackground.cgColor
        iv.image = UIImage(named: AppStrings.Assets.profile)
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap)))
        return iv
    }()

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationItemButton()
        configureCollectionView()
        fetchUserInformation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollViewDidScroll(collectionView)
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configureNavigationItemButton() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = appearance
        
        ellipsisRightButton.menu = addEllipsisMenuItems()
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = standardAppearance
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        
        let viewModel = ProfileHeaderViewModel(user: user)
        customRightButton.configuration?.baseBackgroundColor = viewModel.followBackgroundColor
        customRightButton.configuration?.baseForegroundColor = viewModel.followTextColor
        customRightButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
        customRightButton.configuration?.background.strokeWidth = viewModel.followButtonBorderWidth
        customRightButton.configuration?.attributedTitle = AttributedString(viewModel.followText, attributes: container)
        
        if !user.isCurrentUser {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: ellipsisRightButton)
            if !user.isFollowed {
                customRightButton.menu = addUnfollowMenu()
                customRightButton.showsMenuAsPrimaryAction = false
            }
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func addEllipsisMenuItems() -> UIMenu? {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: AppStrings.Report.Opening.title + " " + user.firstName!, image: UIImage(systemName: AppStrings.Icons.flag, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                let controller = ReportViewController(source: .user, contentUid: strongSelf.user.uid!, contentId: strongSelf.user.uid!)
                let navVC = UINavigationController(rootViewController: controller)
                navVC.modalPresentationStyle = .fullScreen
                strongSelf.present(navVC, animated: true)
            })
        ])
        
        ellipsisRightButton.showsMenuAsPrimaryAction = true
        return menuItems
    }
    
    private func addUnfollowMenu() -> UIMenu? {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: AppStrings.Alerts.Actions.unfollow + " " + user.firstName!, image: UIImage(systemName: AppStrings.Icons.xmarkPersonFill, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, attributes: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                
                UserService.unfollow(uid: strongSelf.user.uid!) { [weak self] error in
                    guard let strongSelf = self else { return }
                    strongSelf.user.isFollowed = false
                    let viewModel = ProfileHeaderViewModel(user: strongSelf.user)
                    var container = AttributeContainer()
                    container.font = .systemFont(ofSize: 14, weight: .bold)
                    strongSelf.customRightButton.configuration?.baseBackgroundColor = viewModel.followBackgroundColor
                    strongSelf.customRightButton.configuration?.baseForegroundColor = viewModel.followTextColor
                    strongSelf.customRightButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
                    strongSelf.customRightButton.configuration?.background.strokeWidth = viewModel.followButtonBorderWidth
                    strongSelf.customRightButton.configuration?.attributedTitle = AttributedString(viewModel.followText, attributes: container)
                    
                }
                strongSelf.customRightButton.showsMenuAsPrimaryAction = false
            })
        ])
        customRightButton.showsMenuAsPrimaryAction = true
        return menuItems
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxVerticalOffset = (view.frame.width / 3) / 2
        let currentVeritcalOffset = scrollView.contentOffset.y
        
        profileImageView.frame.origin.y = profileImageTopPadding - currentVeritcalOffset
        
        let percentageOffset = currentVeritcalOffset / maxVerticalOffset

        standardAppearance.backgroundColor = .systemBackground.withAlphaComponent(percentageOffset)
        self.navigationItem.standardAppearance = standardAppearance

        if currentVeritcalOffset > (view.frame.width / 3 + 10 + 30 - topbarHeight) && !scrollViewDidScrollHigherThanActionButton {
            // User pass over the edit profile / follow button
            scrollViewDidScrollHigherThanActionButton.toggle()
            profileImageView.isHidden = true
          
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.label).withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(handleBack))

            if user.isFollowed {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.ellipsis)?.withTintColor(.label).withRenderingMode(.alwaysOriginal), menu: addEllipsisMenuItems())
            } else {
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customRightButton)
            }
            
            
        } else if currentVeritcalOffset < (view.frame.width / 3 + 10 + 30 - topbarHeight) && scrollViewDidScrollHigherThanActionButton {
            scrollViewDidScrollHigherThanActionButton.toggle()
            profileImageView.isHidden = false
           
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
            // Follow button or edit profile are still visible
            if !user.isCurrentUser {
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: ellipsisRightButton)
            } else {
                navigationItem.setRightBarButton(nil, animated: true)
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 profileImageView.layer.borderColor = UIColor.systemBackground.cgColor
             }
         }
    }
     
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubviews(collectionView, profileImageView)
       
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: profileImageTopPadding),
            profileImageView.heightAnchor.constraint(equalToConstant: 90),
            profileImageView.widthAnchor.constraint(equalToConstant: 90),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
        ])

        if let url = user.profileUrl, url != "" {
            profileImageView.sd_setImage(with: URL(string: url))
        }
     
        profileImageView.layer.cornerRadius = 90 / 2

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MEStretchyHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: stretchyReuseIdentifier)
        collectionView.register(UserProfileHeaderCell.self, forCellWithReuseIdentifier: profileHeaderReuseIdentifier)
      
        collectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: profileHeaderTitleReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(UserProfileAboutCell.self, forCellWithReuseIdentifier: profileAboutCellReuseIdentifier)
        collectionView.register(UserProfileEmptyPostCell.self, forCellWithReuseIdentifier: noRecentPostsCellReuseIdentifier)
        collectionView.register(UserProfilePostImageCell.self, forCellWithReuseIdentifier: postImageCellReuseIdentifier)
        collectionView.register(UserProfilePostCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        collectionView.register(UserProfileEmptyCaseCell.self, forCellWithReuseIdentifier: noRecentCasesCellReuseIdentifier)
        collectionView.register(UserProfileCaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(UserProfileCaseImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        collectionView.register(UserProfileEmptyCommentCell.self, forCellWithReuseIdentifier: noCommentsCellReuseIdentifier)
        collectionView.register(UserProfileCommentCell.self, forCellWithReuseIdentifier: commentsCellReuseIdentifier)
        collectionView.register(ProfileExperienceCell.self, forCellWithReuseIdentifier: experienceCellReuseIdentifier)
        collectionView.register(ProfileEducationCell.self, forCellWithReuseIdentifier: educationCellReuseIdentifier)
        collectionView.register(ProfilePatentCell.self, forCellWithReuseIdentifier: patentCellReuseIdentifier)
        collectionView.register(ProfilePublicationCell.self, forCellWithReuseIdentifier: publicationsCellReuseIdentifier)
        collectionView.register(ProfileLanguageCell.self, forCellWithReuseIdentifier: languageCellReuseIdentifier)
        collectionView.register(UserProfileSeeOthersCell.self, forCellWithReuseIdentifier: seeOthersCellReuseIdentifier)
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = StretchyHeaderLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            if sectionNumber == 0 {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(strongSelf.view.frame.width / 3)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                return section
            } else if sectionNumber == 1 {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets.bottom = 10
                if !strongSelf.loaded || !strongSelf.aboutText.isEmpty { section.boundarySupplementaryItems = [header] }
                return section
            } else if sectionNumber == 2 || sectionNumber == 3 || sectionNumber == 4 {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets.bottom = 20
                section.boundarySupplementaryItems = [header]
                return section
                
            } else {
                // Optional Sections
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), elementKind: ElementKind.sectionHeader, alignment: .top)
                header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)

                if sectionNumber == 5 && !strongSelf.experiences.isEmpty || sectionNumber == 6 && !strongSelf.educations.isEmpty || sectionNumber == 7 && !strongSelf.patents.isEmpty || sectionNumber == 8 && !strongSelf.publications.isEmpty || sectionNumber == 9 && !strongSelf.languages.isEmpty   {
                    section.boundarySupplementaryItems = [header]
                    section.contentInsets.bottom = 10
                }
                
                return section
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        return layout
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleUserButton() {
        if user.isCurrentUser {
            let controller = EditProfileViewController(user: user)
            controller.delegate = self
            let navVC = UINavigationController(rootViewController: controller)

            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        } else {
            customRightButton.isUserInteractionEnabled = false

            UserService.follow(uid: user.uid!) { [weak self] error in
                guard let strongSelf = self else { return }
                
                strongSelf.customRightButton.isUserInteractionEnabled = true
                strongSelf.user.isFollowed = true
                strongSelf.fetchUserStats()
                strongSelf.customRightButton.showsMenuAsPrimaryAction = true
                
                let viewModel = ProfileHeaderViewModel(user: strongSelf.user)
                var container = AttributeContainer()
                container.font = .systemFont(ofSize: 14, weight: .bold)
                
                strongSelf.customRightButton.configuration?.baseBackgroundColor = viewModel.followBackgroundColor
                strongSelf.customRightButton.configuration?.baseForegroundColor = viewModel.followTextColor
                strongSelf.customRightButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
                strongSelf.customRightButton.configuration?.background.strokeWidth = viewModel.followButtonBorderWidth
                strongSelf.customRightButton.configuration?.attributedTitle = AttributedString(viewModel.followText, attributes: container)
            }
        }
    }
    
    @objc func handleProfileImageTap() {
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
    
    //MARK: - API
    
    func fetchRecentPosts(group: DispatchGroup) {
        guard let uid = user.uid else { return }
        
        group.enter()
        
        DatabaseManager.shared.getRecentPostIds(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let postIds):
               
                PostService.fetchPosts(withPostIds: postIds) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let recentPosts):
                        strongSelf.recentPosts = recentPosts
                    case .failure(_):
                        break
                    }
                    
                    group.leave()
                }
            case .failure(let error):
                switch error {
                case .network:
                    strongSelf.networkError = true
                default:
                    break
                }
                
                group.leave()
            }
        }
    }
    
    func fetchRecentCases(group: DispatchGroup) {

        guard let uid = user.uid else { return }
        
        group.enter()
        
        DatabaseManager.shared.getRecentCaseIds(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let caseIds):
               
                CaseService.fetchCases(withCaseIds: caseIds) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let recentCases):
                        strongSelf.recentCases = recentCases
                    case .failure(_):
                        break
                    }
                    
                    group.leave()
                }
            case .failure(let error):
                switch error {
                case .network:
                    strongSelf.networkError = true
                default:
                    break
                }
                
                group.leave()
            }
        }
    }
    
    func fetchRecentComments(group: DispatchGroup) {
        guard let uid = user.uid else { return }
        
        group.enter()
        
        DatabaseManager.shared.fetchRecentComments(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let recentComments):
                strongSelf.recentComments = recentComments
                group.leave()
            case .failure(let error):
                switch error {
                case .network:
                    strongSelf.networkError = true
                default:
                    break
                }
                
                group.leave()
            }
        }
    }
    
    func fetchEducation(group: DispatchGroup? = nil) {
        guard let uid = user.uid else { return }
        
        if let group {
            group.enter()
        }

        DatabaseManager.shared.fetchEducation(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {

            case .success(let educations):
                strongSelf.educations = educations
            case .failure(_):
                strongSelf.educations.removeAll()
            }
            
            if let group {
                group.leave()
            } else {
                strongSelf.collectionView.reloadData()
            }
        }
    }
    
    func fetchAbout(group: DispatchGroup? = nil) {
        guard let uid = user.uid else { return }
        
        if let group {
            group.enter()
        }
        
        DatabaseManager.shared.fetchAboutUs(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let sectionText):
                strongSelf.aboutText = sectionText
            case .failure(_):
                strongSelf.aboutText = ""
            }
            
            if let group {
                group.leave()
            } else {
                strongSelf.collectionView.reloadData()
            }
        }
    }
    
    func fetchLanguages(group: DispatchGroup? = nil) {
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
                strongSelf.collectionView.reloadData()
            }
        }
    }
    
    
    func fetchExperience(group: DispatchGroup? = nil) {
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
                strongSelf.languages.removeAll()
            }
            
            if let group {
                group.leave()
            } else {
                strongSelf.collectionView.reloadData()
            }
        }
    }
    
    func fetchPatents(group: DispatchGroup? = nil) {
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
                strongSelf.collectionView.reloadData()
            }
        }
    }
    
    func fetchPublications(group: DispatchGroup? = nil) {
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
                strongSelf.collectionView.reloadData()
            }
        }
    }
    
    func fetchUserStats(group: DispatchGroup? = nil) {
        
        if let group {
            group.enter()
        }

        UserService.fetchUserStats(uid: user.uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let stats):
                strongSelf.user.stats = stats
            case .failure(let error):
                switch error {
                case .network:
                    strongSelf.networkError = true
                default:
                    break
                }
            }
            
            if let group {
                group.leave()
            } else {
                strongSelf.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    func checkIfUserIsFollowed(group: DispatchGroup) {
        group.enter()
        UserService.checkIfUserIsFollowed(withUid: user.uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let isFollowed):
                strongSelf.user.set(isFollowed: isFollowed)
            case .failure(let error):
                switch error {
                case .network:
                    strongSelf.networkError = true
                default:
                    strongSelf.user.set(isFollowed: false)
                }
            }
            
            group.leave()
        }
    }
    
    private func fetchUserInformation() {
        let group = DispatchGroup()
        
        fetchUserStats(group: group)
        fetchRecentPosts(group: group)
        fetchRecentCases(group: group)
        fetchRecentComments(group: group)
        checkIfUserIsFollowed(group: group)
        fetchExperience(group: group)
        fetchLanguages(group: group)
        fetchPatents(group: group)
        fetchEducation(group: group)
        fetchPublications(group: group)
        fetchAbout(group: group)

        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.loaded = true
            strongSelf.collectionView.reloadData()
            strongSelf.scrollViewDidScroll(strongSelf.collectionView)
        }
    }
}

extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return loaded ? Section.allCases.count + 4 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return loaded ? aboutText.isEmpty ? 0 : 1 : 0
        } else if section == 2 {
            return user.stats.posts == 0 ? 1 : min(recentPosts.count, 3)
        } else if section == 3 {
            return user.stats.cases == 0 ? 1 : min(recentCases.count, 3)
        } else if section == 4 {
            return recentComments.isEmpty ? 1 : min(recentComments.count, 3)
        } else if section == 5 {
            return experiences.isEmpty ? 0 : min(experiences.count, 3)
        } else if section == 6 {
            return educations.isEmpty ? 0 : min(educations.count, 3)
        } else if section == 7 {
            return patents.isEmpty ? 0 : min(patents.count, 3)
        } else if section == 8 {
            return publications.isEmpty ? 0 : min(publications.count, 3)
        } else {
            return languages.isEmpty ? 0 : min(languages.count, 3)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileHeaderReuseIdentifier, for: indexPath) as! UserProfileHeaderCell
            cell.viewModel = ProfileHeaderViewModel(user: user)
            cell.followersLabel.isHidden = loaded ? false : true
            cell.followButton.isHidden = loaded ? false : true
            cell.delegate = self
            return cell
            
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileAboutCellReuseIdentifier, for: indexPath) as! UserProfileAboutCell
            cell.set(body: aboutText)
            return cell
        } else if indexPath.section == 2 {
            // Post
            if user.stats.posts == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noRecentPostsCellReuseIdentifier, for: indexPath) as! UserProfileEmptyPostCell
                cell.configure(user: user)
                return cell
            } else {
                if recentPosts[indexPath.row].kind.rawValue == 0 {
                    // Text Post
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextCellReuseIdentifier, for: indexPath) as! UserProfilePostCell
                    cell.user = user
                    cell.viewModel = PostViewModel(post: recentPosts[indexPath.row])
                    if indexPath.row == recentPosts.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postImageCellReuseIdentifier, for: indexPath) as! UserProfilePostImageCell
                    cell.user = user
                    cell.viewModel = PostViewModel(post: recentPosts[indexPath.row])
                    if indexPath.row == recentPosts.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                    return cell
                }
            }
            
        } else if indexPath.section == 3 {
            // Cases
            if user.stats.cases == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noRecentCasesCellReuseIdentifier, for: indexPath) as! UserProfileEmptyCaseCell
                cell.configure(user: user)
                return cell
            } else {
                let currentCase = recentCases[indexPath.row]
                
                switch currentCase.kind {
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! UserProfileCaseTextCell
                    cell.user = user
                    cell.viewModel = CaseViewModel(clinicalCase: recentCases[indexPath.row])
                    if indexPath.row == recentCases.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                    return cell
                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath) as! UserProfileCaseImageCell
                    cell.user = user
                    cell.viewModel = CaseViewModel(clinicalCase: recentCases[indexPath.row])
                    if indexPath.row == recentCases.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                    return cell
                }
            }
        } else if indexPath.section == 4 {
            // Comments
            if recentComments.count != 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentsCellReuseIdentifier, for: indexPath) as! UserProfileCommentCell
                cell.user = user
                cell.configure(recentComment: recentComments[indexPath.row])
                if indexPath.row == recentComments.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noCommentsCellReuseIdentifier, for: indexPath) as! UserProfileEmptyCommentCell
                cell.configure(user: user)
                return cell
            }
        } else if indexPath.section == 5 {
            // Experience
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: experienceCellReuseIdentifier, for: indexPath) as! ProfileExperienceCell
            cell.set(experience: experiences[indexPath.row])
            if indexPath.row == experiences.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
            return cell
            
        } else if indexPath.section == 6 {
            // Education
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: educationCellReuseIdentifier, for: indexPath) as! ProfileEducationCell
            cell.set(education: educations[indexPath.row])
            if indexPath.row == educations.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
            return cell
            
        } else if indexPath.section == 7 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: patentCellReuseIdentifier, for: indexPath) as! ProfilePatentCell
            cell.set(patent: patents[indexPath.row])
            if indexPath.row == patents.count - 1 { cell.separatorView.isHidden = true } else { cell.separatorView.isHidden = false }
            return cell
            
        } else if indexPath.section == 8 {
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: stretchyReuseIdentifier, for: indexPath) as! MEStretchyHeader
            header.delegate = self
            header.setBanner(user.bannerUrl)

            return header
        }
        
        if indexPath.section == 1 && loaded == false {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileHeaderTitleReuseIdentifier, for: indexPath) as! SecondarySearchHeader
        header.delegate = self
        header.tag = indexPath.section
        
        if indexPath.section == 1 {
            header.configureWith(title: AppStrings.Sections.aboutSection, linkText: "")
        } else if indexPath.section == 2 {
            header.configureWith(title: AppStrings.Search.Topics.posts, linkText: AppStrings.Content.Search.seeAll)
            if recentPosts.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
        } else if indexPath.section == 3 {
            header.configureWith(title: AppStrings.Search.Topics.cases, linkText: AppStrings.Content.Search.seeAll)
            if recentCases.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
        } else if indexPath.section == 4 {
            header.configureWith(title: AppStrings.Content.Comment.comment.capitalized, linkText: AppStrings.Content.Search.seeAll)
            if recentComments.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
        } else if indexPath.section == 5 {
            header.configureWith(title: AppStrings.Sections.experienceTitle, linkText: AppStrings.Content.Search.seeAll)
            if experiences.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
        } else if indexPath.section == 6 {
            header.configureWith(title: AppStrings.Sections.educationTitle, linkText: AppStrings.Content.Search.seeAll)
            if educations.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
        } else if indexPath.section == 7 {
            header.configureWith(title: AppStrings.Sections.patentsTitle, linkText: AppStrings.Content.Search.seeAll)
            if patents.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
        } else if indexPath.section == 8 {
            header.configureWith(title: AppStrings.Sections.publicationsTitle, linkText: AppStrings.Content.Search.seeAll)
            if publications.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
        } else {
            header.configureWith(title: AppStrings.Sections.languagesTitle, linkText: AppStrings.Content.Search.seeAll)
            if languages.count < 3 { header.hideSeeAllButton() } else { header.unhideSeeAllButton() }
        }
        
        return header
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if user.isCurrentUser {
                let controller = AddAboutViewController(comesFromOnboarding: false)
                controller.delegate = self
                controller.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller = AboutSectionViewController(user: user, section: aboutText)
                navigationController?.pushViewController(controller, animated: true)
            }
        } else if indexPath.section == 2 {
            // Posts
            guard !recentPosts.isEmpty else { return }
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let controller = DetailsPostViewController(post: recentPosts[indexPath.row], user: user, collectionViewLayout: layout)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
            
        } else if indexPath.section == 3 {
            guard !recentCases.isEmpty else { return }
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let controller = DetailsCaseViewController(clinicalCase: recentCases[indexPath.row], user: user, collectionViewFlowLayout: layout)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
            
        } else if indexPath.section == 4 {
            // Comments
            guard !recentComments.isEmpty else { return }
            let comment = recentComments[indexPath.row]
            
            switch comment.source {
            case .post:

                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .vertical
                layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
                
                let controller = DetailsPostViewController(postId: comment.referenceId, collectionViewLayout: layout)
                controller.delegate = self
                navigationController?.pushViewController(controller, animated: true)

            case .clinicalCase:
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .vertical
                layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
                let controller = DetailsCaseViewController(caseId: comment.referenceId, collectionViewLayout: layout)
                controller.delegate = self
                navigationController?.pushViewController(controller, animated: true)
            }
        }
        else if indexPath.section == 5 {
            guard user.isCurrentUser else { return }
            let controller = AddExperienceViewController(experience: experiences[indexPath.row])
            
            controller.delegate = self
            controller.hidesBottomBarWhenPushed = true
            
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.section == 6 {
            guard user.isCurrentUser else { return }
            
            let controller = AddEducationViewController(education: educations[indexPath.row])
            controller.delegate = self
            controller.hidesBottomBarWhenPushed = true
            
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.section == 7 {
            guard user.isCurrentUser else { return }
            
            let controller = AddPatentViewController(user: user, patent: patents[indexPath.row])
            controller.delegate = self
            controller.hidesBottomBarWhenPushed = true
            
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.section == 8 {
            guard user.isCurrentUser else { return }
            
            let controller = AddPublicationViewController(user: user, publication: publications[indexPath.row])
            controller.delegate = self
            controller.hidesBottomBarWhenPushed = true
            
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.section == 9 {
            guard user.isCurrentUser else { return }
            
            let controller = AddLanguageViewController(language: languages[indexPath.row])
            controller.delegate = self
            controller.hidesBottomBarWhenPushed = true
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}


//MARK: - UserProfileHeaderDelegate

extension UserProfileViewController: MEStretchyHeaderDelegate {
    func didTapBanner() {
        let controller = ProfileImageViewController(isBanner: true)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            if let bannerUrl = self.user.bannerUrl, bannerUrl != "" {
                controller.profileImageView.sd_setImage(with: URL(string: bannerUrl))
            }
        }
        
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true)
    }
}

extension UserProfileViewController: UserProfileHeaderCellDelegate {
    
    func headerCell(didTapFollowingFollowersFor user: User) {
        let controller = FollowersFollowingViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func headerCell(_ cell: UICollectionViewCell, didTapEditProfileFor user: User) {

        guard let currentCell = cell as? UserProfileHeaderCell else { return }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        if user.uid == uid {
            let controller = EditProfileViewController(user: user)
            controller.delegate = self
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        } else {
            
            guard let uid = user.uid else { return }
            if user.isFollowed {
                UserService.unfollow(uid: uid) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.user.isFollowed = false
                    currentCell.viewModel?.user.isFollowed = false
                    currentCell.isUpdatingFollowState = false
                    currentCell.updateButtonAfterAction = true
                    strongSelf.delegate?.didFollowUser(user: user, didFollow: false)
                    strongSelf.fetchUserStats()
                }
            } else {
                UserService.follow(uid: uid) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.user.isFollowed = true
                    currentCell.viewModel?.user.isFollowed = true
                    currentCell.isUpdatingFollowState = false
                    currentCell.updateButtonAfterAction = true
                    strongSelf.delegate?.didFollowUser(user: user, didFollow: true)
                    strongSelf.fetchUserStats()
                }
            }
        }
    }
}

extension UserProfileViewController: PrimarySearchHeaderDelegate {
    func didTapSeeAll(_ header: UICollectionReusableView) {
        if header.tag == 2 {
            let controller = HomeViewController(source: .user)
            controller.controllerIsBeeingPushed = true
            controller.user = user
            
            controller.hidesBottomBarWhenPushed = true
            
            navigationController?.pushViewController(controller, animated: true)
        } else if header.tag == 3 {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 300)

            let controller = CaseViewController(user: user, contentSource: .user)
            navigationController?.pushViewController(controller, animated: true)
            
        } else if header.tag == 4 {
            let controller = CommentsViewController(user: user)
            navigationController?.pushViewController(controller, animated: true)
        } else if header.tag == 5 {
            let controller = ExperienceSectionViewController(user: user, experiences: experiences)
            controller.delegate = self
           
            navigationController?.pushViewController(controller, animated: true)
            
        } else if header.tag == 6 {
            let controller = EducationSectionViewController(user: user, educations: educations)
            controller.delegate = self
           
            navigationController?.pushViewController(controller, animated: true)
        } else if header.tag == 7 {
            let controller = PatentSectionViewController(user: user, patents: patents)
            controller.delegate = self
           
            navigationController?.pushViewController(controller, animated: true)
        } else if header.tag == 8 {
            let controller = PublicationSectionViewController(user: user, publications: publications, isCurrentUser: user.isCurrentUser)
            controller.delegate = self
           
            navigationController?.pushViewController(controller, animated: true)
        } else if header.tag == 9 {
            let controller = LanguageSectionViewController(languages: languages, user: user)
            controller.delegate = self
          
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension UserProfileViewController: ProfilePublicationCellDelegate {
    func didTapURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            presentSafariViewController(withURL: url)
        } else {
            presentWebViewController(withURL: url)
        }
    }
}

extension UserProfileViewController: AddLanguageViewControllerDelegate, AddPublicationViewControllerDelegate, AddPatentViewControllerDelegate, AddEducationViewControllerDelegate, AddExperienceViewControllerDelegate {
    
    func didDeleteEducation(_ education: Education) {
        didUpdateExperience()
    }
    
    func didDeleteExperience(_ experience: Experience) {
        didUpdateExperience()
    }
    
    
    func didDeletePublication(_ publication: Publication) {
        didUpdatePublication()
    }
    
    func didDeletePatent(_ patent: Patent) {
        didUpdatePatent()
    }
    
    func didDeleteLanguage(_ language: Language) {
        didUpdateLanguage()
    }
    
    func didAddExperience(_ experience: Experience) {
        fetchNewExperienceValues()
    }
    
    func didAddEducation(_ education: Education) {
        fetchNewEducationValues()
    }
    
    func didAddPatent(_ patent: Patent) {
        fetchNewPatentValues()
    }
    
    func didAddPublication(_ publication: Publication) {
        fetchNewPublicationValues()
    }
    
    func didAddLanguage(_ language: Language) {
        didUpdateLanguage()
    }
}

extension UserProfileViewController: EditProfileViewControllerDelegate, AddAboutViewControllerDelegate, LanguageSectionViewControllerDelegate, PublicationSectionViewControllerDelegate, PatentSectionViewControllerDelegate, ExperienceSectionViewControllerDelegate, EducationSectionViewControllerDelegate {
    func didUpdateEducation() {
        fetchEducation()
    }
    
    func didUpdateExperience() {
        fetchExperience()
    }
    
    func didUpdatePatent() {
        fetchPatents()
    }
    
    func didUpdateProfile(user: User) {
        self.user = user
        UserDefaults.standard.set(user.profileUrl, forKey: "profileUrl")
        UserDefaults.standard.set(user.bannerUrl, forKey: "bannerUrl")
        UserDefaults.standard.set(user.firstName! + " " + user.lastName!, forKey: "name")

        NotificationCenter.default.post(name: NSNotification.Name("ProfileImageUpdateIdentifier"), object: nil, userInfo: nil)
        
        guard let tab = self.tabBarController as? MainTabController else { return }
        tab.updateUser(user: user)
    }
    
    func didUpdateLanguage() {
        fetchLanguages()
    }
    
    func didUpdatePublication() {
        fetchPublications()
    }
    
    func fetchNewExperienceValues() {
        fetchExperience()
    }

    func fetchNewLanguageValues() {
        fetchLanguages()
    }
    
    func fetchNewPublicationValues() {
        fetchPublications()
    }
    
    func handleDeletePublication(publication: Publication) {
        fetchPublications()
    }
    
    func fetchNewPatentValues() {
        fetchPatents()
    }
    
    func fetchNewEducationValues() {
        fetchEducation()
    }
    
    func fetchNewExperienceValues(withUid uid: String) {
        fetchExperience()
    }
    
    func handleUpdateAbout() {
        fetchAbout()
    }
    
    func fetchNewAboutValues(withUid uid: String) {
        fetchAbout()
    }
    
    func fetchNewUserValues(withUid uid: String) {
        UserService.fetchUser(withUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let user):
                strongSelf.user = user
                strongSelf.collectionView.reloadData()
            case .failure(let error):
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
}

extension UserProfileViewController: DetailsPostViewControllerDelegate {
    func didTapLikeAction(forPost post: Post) {
        if let index = recentPosts.firstIndex(where: { $0.postId == post.postId }) {
            recentPosts[index].likes = post.likes
            recentPosts[index].didLike = post.didLike
            collectionView.reloadData()
        }
    }
    
    func didTapBookmarkAction(forPost post: Post) {
        if let index = recentPosts.firstIndex(where: { $0.postId == post.postId }) {
            recentPosts[index].didBookmark = post.didBookmark
            collectionView.reloadData()
        }
    }
    
    func didComment(forPost post: Post) {
        if let index = recentPosts.firstIndex(where: { $0.postId == post.postId }) {
            recentPosts[index].numberOfComments += 1
            collectionView.reloadData()
        }
    }
    
    func didDeleteComment(forPost post: Post) {
        if let index = recentPosts.firstIndex(where: { $0.postId == post.postId }) {
            recentPosts[index].numberOfComments -= 1
            collectionView.reloadData()
        }
    }
    
    func didEditPost(forPost post: Post) {
        if let index = recentPosts.firstIndex(where: { $0.postId == post.postId }) {
            recentPosts[index] = post
            collectionView.reloadData()
        }
    }
}

extension UserProfileViewController: DetailsCaseViewControllerDelegate {
    func didTapLikeAction(forCase clinicalCase: Case) {
        if let index = recentCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            recentCases[index].likes = clinicalCase.likes
            recentCases[index].didLike = clinicalCase.didLike
            collectionView.reloadData()
        }
    }
    
    func didTapBookmarkAction(forCase clinicalCase: Case) {
        if let index = recentCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            recentCases[index].didBookmark = clinicalCase.didBookmark
            collectionView.reloadData()
        }
    }
    
    func didComment(forCase clinicalCase: Case) {
        if let index = recentCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            recentCases[index].numberOfComments += 1
            collectionView.reloadData()
        }
    }
    
    func didAddRevision(forCase clinicalCase: Case) {
        if let index = recentCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            recentCases[index].revision = .update
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func didSolveCase(forCase clinicalCase: Case, with diagnosis: CaseRevisionKind?) {
        if let index = recentCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            if let diagnosis {
                recentCases[index].revision = diagnosis
            }
            recentCases[index].phase = .solved
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func didDeleteComment(forCase clinicalCase: Case) {
        if let index = recentCases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            recentCases[index].numberOfComments -= 1
            collectionView.reloadData()
        }
    }
}

class StretchyHeaderLayout: UICollectionViewCompositionalLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        layoutAttributes?.forEach { attribute in
            if attribute.representedElementKind == ElementKind.sectionHeader && attribute.indexPath.section == 0 {
                guard let collectionView = collectionView else { return }
               

                let contentOffsetY = collectionView.contentOffset.y

                if contentOffsetY < 0 {
                
                    let width = UIScreen.main.bounds.width
                    let height = width / 3 - contentOffsetY
                    attribute.frame = CGRect(x: 0, y: contentOffsetY, width: width, height: height)
                }
            }
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}


