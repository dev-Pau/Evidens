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

struct ElementKind {
    //static let badge = "badge-element-kind"
    //static let background = "background-element-kind"
    static let sectionHeader = "section-header-element-kind"
    static let sectionFooter = "section-footer-element-kind"
    //static let layoutHeader = "layout-header-element-kind"
    //static let layoutFooter = "layout-footer-element-kind"
}

class UserProfileViewController: UIViewController {
    

    //MARK: - Properties
    private var standardAppearance = UINavigationBarAppearance()
    private lazy var profileImageTopPadding = view.frame.width / 3 - 20
    private var userSectionsFetched: Int = 0
    private var user: User
    private var userDataLoaded: Bool = false
    private var collectionView: UICollectionView!
    private var recentPosts = [Post]()
    private var recentCases = [Case]()
    private var recentComments = [[String: Any]]()
    private var relatedUsers = [User]()
    
    private var scrollViewDidScrollHigherThanActionButton: Bool = false

    private var hasAbout: Bool = false
    private var aboutText: String = ""
    private var hasLanguages: Bool = false
    private var languages = [[String: String]]()
    private var hasPatents: Bool = false
    private var patents = [[String: Any]]()
    private var publications = [[String: Any]]()
    private var hasEducation: Bool = false
    private var education = [[String: String]]()
    private var experience = [[String: String]]()
    
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
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
        button.configuration?.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.baseBackgroundColor = .label.withAlphaComponent(0.7)
        button.configuration?.image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground)
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
        iv.image = UIImage(named: "user.profile")
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        //appearance.backgroundColor = .systemBackground.withAlphaComponent(0)
        self.navigationItem.scrollEdgeAppearance = appearance
        //navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        ellipsisRightButton.menu = addEllipsisMenuItems()

        
         standardAppearance.configureWithOpaqueBackground()
         standardAppearance.backgroundColor = .systemBackground
         //navigationController?.navigationBar.standardAppearance = standardAppearance
        self.navigationItem.standardAppearance = standardAppearance
        
        //standardAppearance.configureWithOpaqueBackground()
        //standardAppearance.backgroundColor = .systemBackground
        //self.navigationItem.standardAppearance = standardAppearance
        //navigationController?.navigationBar.standardAppearance = standardAppearance
        //navigationController?.navigationBar.standardAppearance = standardAppearance
        //navigationController?.navigationBar.compactAppearance = standardAppearance
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        
        let viewModel = ProfileHeaderViewModel(user: user)
        customRightButton.configuration?.baseBackgroundColor = viewModel.followButtonBackgroundColor
        customRightButton.configuration?.baseForegroundColor = viewModel.followButtonTextColor
        customRightButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
        customRightButton.configuration?.background.strokeWidth = viewModel.followButtonBorderWidth
        customRightButton.configuration?.attributedTitle = AttributedString(viewModel.customFollowButtonText, attributes: container)
        
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
            UIAction(title: "Report " + user.firstName!, image: UIImage(systemName: "flag", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, handler: { _ in
                print("did report user")
            })
        ])
        ellipsisRightButton.showsMenuAsPrimaryAction = true
        return menuItems
    }
    
    private func addUnfollowMenu() -> UIMenu? {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "Unfollow " + user.firstName!, image: UIImage(systemName: "person.fill.xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, attributes: .destructive, handler: { _ in
                UserService.unfollow(uid: self.user.uid!) { error in
                    print("did unfollow")
                    self.user.isFollowed = false
                    let viewModel = ProfileHeaderViewModel(user: self.user)
                    var container = AttributeContainer()
                    container.font = .systemFont(ofSize: 14, weight: .bold)
                    self.customRightButton.configuration?.baseBackgroundColor = viewModel.followButtonBackgroundColor
                    self.customRightButton.configuration?.baseForegroundColor = viewModel.followButtonTextColor
                    self.customRightButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
                    self.customRightButton.configuration?.background.strokeWidth = viewModel.followButtonBorderWidth
                    self.customRightButton.configuration?.attributedTitle = AttributedString(viewModel.customFollowButtonText, attributes: container)
                    
                }
                self.customRightButton.showsMenuAsPrimaryAction = false
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
        //navigationController?.navigationBar.standardAppearance = standardAppearance
        self.navigationItem.standardAppearance = standardAppearance
        //standardAppearance.backgroundColor = .systemBackground.withAlphaComponent(percentageOffset)
        //navigationController?.navigationBar.standardAppearance = standardAppearance
        
        
        if currentVeritcalOffset > (view.frame.width / 3 + 10 + 30 - topbarHeight) && !scrollViewDidScrollHigherThanActionButton {
            // User pass over the edit profile / follow button
            scrollViewDidScrollHigherThanActionButton.toggle()
            profileImageView.isHidden = true
          
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.label).withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(handleBack))

            if self.user.isFollowed {
                //navigationItem.rightBarButtonItem = UIBarB
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis")?.withTintColor(.label).withRenderingMode(.alwaysOriginal), menu: addEllipsisMenuItems())
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
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                 profileImageView.layer.borderColor = UIColor.systemBackground.cgColor
             }
         }
    }
     
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        //collectionView.isHidden = true
        
        view.addSubviews(collectionView, profileImageView)
       
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: profileImageTopPadding),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
        ])

        if let url = user.profileImageUrl, url != "" {
            profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        }
     
        profileImageView.layer.cornerRadius = 70 / 2

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MEStretchyHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: stretchyReuseIdentifier)
        collectionView.register(UserProfileHeaderCell.self, forCellWithReuseIdentifier: profileHeaderReuseIdentifier)
        collectionView.register(UserProfileTitleHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: profileHeaderTitleReuseIdentifier)
        collectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: profileHeaderTitleReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(UserProfileAboutCell.self, forCellWithReuseIdentifier: profileAboutCellReuseIdentifier)
        collectionView.register(UserProfileNoPostCell.self, forCellWithReuseIdentifier: noRecentPostsCellReuseIdentifier)
        collectionView.register(UserProfilePostImageCell.self, forCellWithReuseIdentifier: postImageCellReuseIdentifier)
        collectionView.register(UserProfilePostCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        collectionView.register(UserProfileNoCaseCell.self, forCellWithReuseIdentifier: noRecentCasesCellReuseIdentifier)
        collectionView.register(UserProfileCaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(UserProfileCaseImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        collectionView.register(UserProfileNoCommentsCell.self, forCellWithReuseIdentifier: noCommentsCellReuseIdentifier)
        collectionView.register(UserProfileCommentCell.self, forCellWithReuseIdentifier: commentsCellReuseIdentifier)
        collectionView.register(UserProfileExperienceCell.self, forCellWithReuseIdentifier: experienceCellReuseIdentifier)
        collectionView.register(UserProfileEducationCell.self, forCellWithReuseIdentifier: educationCellReuseIdentifier)
        collectionView.register(UserProfilePatentCell.self, forCellWithReuseIdentifier: patentCellReuseIdentifier)
        collectionView.register(UserProfilePublicationCell.self, forCellWithReuseIdentifier: publicationsCellReuseIdentifier)
        collectionView.register(UserProfileLanguageCell.self, forCellWithReuseIdentifier: languageCellReuseIdentifier)
        collectionView.register(UserProfileSeeOthersCell.self, forCellWithReuseIdentifier: seeOthersCellReuseIdentifier)
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = StretchyHeaderLayout { sectionNumber, env in
            if sectionNumber == 0 {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(self.view.frame.width / 3)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                // Profile Header
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)))
                //item.contentInsets.bottom = 16
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                //section.contentInsets.bottom = 10
                return section
            } else if sectionNumber == 1 {
                // Loading header while fetching data & About section
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets.bottom = 10
                if !self.userDataLoaded || self.hasAbout { section.boundarySupplementaryItems = [header] }
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
                
            } else if sectionNumber == 10 {
                // Related Users
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), elementKind: ElementKind.sectionHeader, alignment: .top)
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                item.contentInsets.leading = 10
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.30), heightDimension: .absolute(!self.relatedUsers.isEmpty ? 120 : .leastNonzeroMagnitude)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                if !self.relatedUsers.isEmpty { section.boundarySupplementaryItems = [header] }
                section.orthogonalScrollingBehavior = .continuous
                
                return section
            } else {
                // Optional Sections
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), elementKind: ElementKind.sectionHeader, alignment: .top)
                header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)

                if sectionNumber == 5 && !self.experience.isEmpty || sectionNumber == 6 && !self.education.isEmpty || sectionNumber == 7 && !self.patents.isEmpty || sectionNumber == 8 && !self.publications.isEmpty || sectionNumber == 9 && !self.languages.isEmpty   {
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
            let navVC = UINavigationController(rootViewController: controller)

            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        } else {
            customRightButton.isUserInteractionEnabled = false
            UserService.follow(uid: user.uid!) { error in
                self.customRightButton.isUserInteractionEnabled = true
                self.user.isFollowed = true
                self.fetchUserStats()
                self.customRightButton.showsMenuAsPrimaryAction = true
                let viewModel = ProfileHeaderViewModel(user: self.user)
                var container = AttributeContainer()
                container.font = .systemFont(ofSize: 14, weight: .bold)
                self.customRightButton.configuration?.baseBackgroundColor = viewModel.followButtonBackgroundColor
                self.customRightButton.configuration?.baseForegroundColor = viewModel.followButtonTextColor
                self.customRightButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
                self.customRightButton.configuration?.background.strokeWidth = viewModel.followButtonBorderWidth
                self.customRightButton.configuration?.attributedTitle = AttributedString(viewModel.customFollowButtonText, attributes: container)
            }
        }
    }
    
    @objc func handleProfileImageTap() {
        let controller = ProfileImageViewController(isBanner: false)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            if let imageUrl = self.user.profileImageUrl, imageUrl != "" {
                controller.profileImageView.sd_setImage(with: URL(string: imageUrl))
            }
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true)
        }
    }
    
    //MARK: - API
    
    func fetchRecentPosts() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchRecentPosts(forUid: uid) { result in
            switch result {
            case .success(let postIDs):
                guard !postIDs.isEmpty else {
                    self.checkIfAllUserInformationIsFetched()
                    return
                }
                PostService.fetchPosts(withPostIds: postIDs) { recentPosts in
                    self.recentPosts = recentPosts
                    self.checkIfAllUserInformationIsFetched()
                    return
                }
            case .failure(_):
                print("Failure fetching posts")
            }
        }
    }
    
    func fetchRecentCases() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchRecentCases(forUid: uid) { result in
            switch result {
            case .success(let caseIDs):
                guard !caseIDs.isEmpty else {
                    self.checkIfAllUserInformationIsFetched()
                    return
                }
                CaseService.fetchCases(withCaseIds: caseIDs) { recentCases in
                    self.recentCases = recentCases
                    self.checkIfAllUserInformationIsFetched()
                    return
                }
            case .failure(_):
                print("Failure fetching posts")
            }
        }
    }
    
    func fetchRecentComments() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchRecentComments(forUid: uid) { result in
            switch result {
            case .success(let recentComments):
                guard !recentComments.isEmpty else {
                    self.checkIfAllUserInformationIsFetched()
                    return
                }
                
                self.recentComments = recentComments
                self.checkIfAllUserInformationIsFetched()
            case .failure(_):
                print("Failure fetching recent comments")
            }
        }
        
    }
    
    func fetchEducation() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchEducation(forUid: uid) { result in
            switch result {
            case .success(let education):
                guard !education.isEmpty else {
                    self.checkIfAllUserInformationIsFetched()
                    return
                }
                self.education = education
                self.hasEducation = true
                self.checkIfAllUserInformationIsFetched()
            case .failure(_):
                print("No section")
            }
        }
    }
    
    func fetchSections() {
        // About Section
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchAboutSection(forUid: uid) { result in
            switch result {
            case .success(let sectionText):
                guard !sectionText.isEmpty else {
                    self.checkIfAllUserInformationIsFetched()
                    return
                }
                self.aboutText = sectionText
                self.hasAbout = true
                self.checkIfAllUserInformationIsFetched()
            case .failure(_):
                print("No section")
            }
        }
    }
    
    func fetchLanguages() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchLanguages(forUid: uid) { result in
            switch result {
            case .success(let languages):
                guard !languages.isEmpty else {
                    self.checkIfAllUserInformationIsFetched()
                    return
                }
                
                self.hasLanguages = true
                self.languages = languages
                self.checkIfAllUserInformationIsFetched()
            case .failure(_):
                print("No languages ")
            }
        }
    }
    
    func fetchExperience() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchExperience(forUid: uid) { result in
            switch result {
            case .success(let experiences):
                guard !experiences.isEmpty else {
                    self.checkIfAllUserInformationIsFetched()
                    return
                }
                self.experience = experiences
                self.checkIfAllUserInformationIsFetched()
            case .failure(_):
                print("No languages ")
            }
        }
    }
    
    func fetchRelated() {
        guard let profession = user.profession, user.phase == .verified else {
            self.checkIfAllUserInformationIsFetched()
            return
        }
        
        UserService.fetchRelatedUsers(withProfession: profession) { relatedUsers in
            guard !relatedUsers.isEmpty else {
                self.checkIfAllUserInformationIsFetched()
                return
            }
            self.relatedUsers = relatedUsers
            self.checkIfAllUserInformationIsFetched()
        }
    }
    
    func fetchPatents() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchPatents(forUid: uid) { result in
            switch result {
            case .success(let patents):
                guard !patents.isEmpty else {
                    self.checkIfAllUserInformationIsFetched()
                    return
                }
                
                self.hasPatents = true
                self.patents = patents
                self.checkIfAllUserInformationIsFetched()
            case .failure(_):
                print("No Patents")
            }
        }
    }
    
    func fetchPublications() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchPublications(forUid: uid) { result in
            switch result {
            case .success(let publications):
                guard !publications.isEmpty else {
                    self.checkIfAllUserInformationIsFetched()
                    return
                }
                self.publications = publications
                self.checkIfAllUserInformationIsFetched()
            case .failure(_):
                print("No publications")
            }
        }
    }
    
    func fetchUserStats() {
        UserService.fetchUserStats(uid: user.uid!) { stats in
            self.user.stats = stats
            self.checkIfAllUserInformationIsFetched()
        }
    }
    
    func checkIfUserIsFollowed() {
        UserService.checkIfUserIsFollowed(uid: user.uid!) { isFollowed in
            self.user.isFollowed = isFollowed
            self.checkIfAllUserInformationIsFetched()
        }
    }
    
    private func fetchUserInformation() {
        fetchUserStats()
        fetchRecentPosts()
        fetchRecentCases()
        fetchLanguages()
        fetchPatents()
        fetchPublications()
        fetchRecentComments()
        fetchEducation()
        fetchExperience()
        fetchSections()
        fetchRelated()
        checkIfUserIsFollowed()
    }
    
    private func checkIfAllUserInformationIsFetched() {
        userSectionsFetched += 1
        if userSectionsFetched == 12 {
            userDataLoaded = true
            collectionView.reloadData()
            scrollViewDidScroll(collectionView)
        }
    }
}

extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return userDataLoaded ? 11 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Header
        if section == 0 { return 1 }
        //About
        else if section == 1 {
            if userDataLoaded {
                if hasAbout {
                    return 1
                } else {
                    return 0
                }
            } else {
                // 0 for the loading header
                return 0
            }
        } else if section == 2 {
            // Posts
            if user.stats.posts == 0 {
                return 1
            } else {
                return min(recentPosts.count, 3)
            }
        } else if section == 3 {
            // Cases
            if user.stats.cases == 0 {
                return 1
            } else {
                return min(recentCases.count, 3)
            }
        } else if section == 4 {
            if recentComments.count != 0 {
                return min(recentComments.count, 3)
            } else {
                return 1
            }
        } else if section == 5 {
            if experience.count != 0 {
                return min(experience.count, 3)
            } else {
                return 0
            }
            
        } else if section == 6 {
            if education.count != 0 {
                return min(education.count, 3)
            } else {
                return 0
            }
            
        } else if section == 7 {
            if patents.count != 0 {
                return min(patents.count, 3)
            } else {
                return 0
            }
            
        } else if section == 8 {
            if publications.count != 0 {
                return min(publications.count, 3)
            } else {
                return 0
            }

        } else if section == 9 {
            if languages.count != 0 {
                return min(languages.count, 3)
            } else {
                return 0
            }
            
        } else {
            return relatedUsers.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileHeaderReuseIdentifier, for: indexPath) as! UserProfileHeaderCell
            cell.viewModel = ProfileHeaderViewModel(user: user)
            cell.followersLabel.isHidden = userDataLoaded ? false : true
            cell.followButton.isHidden = userDataLoaded ? false : true
            cell.delegate = self
            return cell
            
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileAboutCellReuseIdentifier, for: indexPath) as! UserProfileAboutCell
            cell.set(body: aboutText)
            return cell
        } else if indexPath.section == 2 {
            // Post
            if user.stats.posts == 0 {
                // User has no recent posts, display no activity
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noRecentPostsCellReuseIdentifier, for: indexPath) as! UserProfileNoPostCell
                cell.configure(user: user)
                return cell
                
            } else {
                
                if recentPosts[indexPath.row].type.postType == 0 {
                    // Text Post
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextCellReuseIdentifier, for: indexPath) as! UserProfilePostCell
                    cell.viewModel = PostViewModel(post: recentPosts[indexPath.row])
                    if indexPath.row == recentPosts.count - 1 { cell.separatorView.isHidden = true }
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postImageCellReuseIdentifier, for: indexPath) as! UserProfilePostImageCell
                    cell.viewModel = PostViewModel(post: recentPosts[indexPath.row])
                    if indexPath.row == recentPosts.count - 1 { cell.separatorView.isHidden = true }
                    return cell
                }
            }
            
        } else if indexPath.section == 3 {
            // Cases
            if user.stats.cases == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noRecentCasesCellReuseIdentifier, for: indexPath) as! UserProfileNoCaseCell
                cell.configure(user: user)
                return cell
            } else {
                
                if recentCases[indexPath.row].type.caseType == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! UserProfileCaseTextCell
                    cell.viewModel = CaseViewModel(clinicalCase: recentCases[indexPath.row])
                    if indexPath.row == recentCases.count - 1 { cell.separatorView.isHidden = true }
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath) as! UserProfileCaseImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: recentCases[indexPath.row])
                    if indexPath.row == recentCases.count - 1 { cell.separatorView.isHidden = true }
                    return cell
                }
            }
            
        } else if indexPath.section == 4 {
            // Comments
            if recentComments.count != 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentsCellReuseIdentifier, for: indexPath) as! UserProfileCommentCell
                cell.configure(commentInfo: recentComments[indexPath.row], user: user)
                if indexPath.row == recentComments.count - 1 { cell.separatorView.isHidden = true }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noCommentsCellReuseIdentifier, for: indexPath) as! UserProfileNoCommentsCell
                cell.configure(user: user)
                return cell
            }

            
        } else if indexPath.section == 5 {
            // Experience
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: experienceCellReuseIdentifier, for: indexPath) as! UserProfileExperienceCell
            cell.set(experienceInfo: experience[indexPath.row])
            if indexPath.row == experience.count - 1 { cell.separatorView.isHidden = true }
            return cell
            
        } else if indexPath.section == 6 {
            // Education
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: educationCellReuseIdentifier, for: indexPath) as! UserProfileEducationCell
            cell.set(educationInfo: education[indexPath.row])
            if indexPath.row == education.count - 1 { cell.separatorView.isHidden = true }
            return cell
            
        } else if indexPath.section == 7 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: patentCellReuseIdentifier, for: indexPath) as! UserProfilePatentCell
            cell.set(patentInfo: patents[indexPath.row])
            cell.delegate = self
            if indexPath.row == patents.count - 1 { cell.separatorView.isHidden = true }
            return cell
            
        } else if indexPath.section == 8 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: publicationsCellReuseIdentifier, for: indexPath) as! UserProfilePublicationCell
            cell.set(publicationInfo: publications[indexPath.row])
            if indexPath.row == publications.count - 1 { cell.separatorView.isHidden = true }
            cell.delegate = self
            return cell
            
        } else if indexPath.section == 9 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: languageCellReuseIdentifier, for: indexPath) as! UserProfileLanguageCell
            cell.set(languageInfo: languages[indexPath.row])
            if indexPath.row == languages.count - 1 { cell.separatorView.isHidden = true }
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: seeOthersCellReuseIdentifier, for: indexPath) as! UserProfileSeeOthersCell
            cell.set(user: relatedUsers[indexPath.row])
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: stretchyReuseIdentifier, for: indexPath) as! MEStretchyHeader
            header.delegate = self
            if let bannerUrl = self.user.bannerImageUrl, bannerUrl != "" {
                header.setImageWithStringUrl(imageUrl: user.bannerImageUrl!)
            }
            return header
        }
        
        if indexPath.section == 1 && userDataLoaded == false {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            //header.setImageWithStringUrl(imageUrl: user.bannerImageUrl!)
            return header
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileHeaderTitleReuseIdentifier, for: indexPath) as! SecondarySearchHeader
        if indexPath.section == 1 {
            //header.set(title: "About")
            header.configureWith(title: "About", linkText: "")
        }else if indexPath.section == 2 {
            //header.buttonImage.isHidden = true
            //header.set(title: "Posts")
            header.configureWith(title: "Posts", linkText: "")
            if recentPosts.count < 3 { header.hideSeeAllButton() }
        } else if indexPath.section == 3 {
            //header.buttonImage.isHidden = true
            //header.set(title: "Cases")
            header.configureWith(title: "Cases", linkText: "See All")
            if recentCases.count < 3 { header.hideSeeAllButton() }
        } else if indexPath.section == 4 {
            //header.buttonImage.isHidden = true
            //header.set(title: "Comments")
            header.configureWith(title: "Comments", linkText:"See All")
            if recentComments.count < 3 { header.hideSeeAllButton() }
        } else if indexPath.section == 5 {
            //header.set(title: "Experience")
            header.configureWith(title: "Experience", linkText: "See All")
            if experience.count < 3 { header.hideSeeAllButton() }
        } else if indexPath.section == 6 {
            //header.set(title: "Education")
            header.configureWith(title: "Education", linkText: "See All")
            if education.count < 3 { header.hideSeeAllButton() }
        } else if indexPath.section == 7 {
            //header.set(title: "Patents")
            header.configureWith(title: "Patents", linkText: "See All")
            if patents.count < 3 { header.hideSeeAllButton() }
        } else if indexPath.section == 8 {
            //header.set(title: "Publications")
            header.configureWith(title: "Publications", linkText: "See All")
            if publications.count < 3 { header.hideSeeAllButton() }
        } else if indexPath.section == 9 {
            //header.set(title: "Languages")
            header.configureWith(title: "Languages", linkText: "See All")
            if languages.count < 3 { header.hideSeeAllButton() }
        } else {
            //header.buttonImage.isHidden = true
            //header.set(title: "Related")
            header.configureWith(title: "Related", linkText: "See All")
            if relatedUsers.count < 10 { header.hideSeeAllButton() }
        }
        return header
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            // About
            let controller = AboutSectionViewController(section: aboutText)
            controller.title = "About"
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.section == 2 {
            // Posts
            guard !recentCases.isEmpty else { return }
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let controller = DetailsPostViewController(post: recentPosts[indexPath.row], user: user, type: .regular, collectionViewLayout: layout)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        } else if indexPath.section == 3 {
            guard !recentCases.isEmpty else { return }
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let controller = DetailsCaseViewController(clinicalCase: recentCases[indexPath.row], user: user, type: .regular, collectionViewFlowLayout: layout)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            navigationController?.pushViewController(controller, animated: true)
            
        } else if indexPath.section == 4 {
            // Comments
            guard !recentComments.isEmpty else { return }
            let comment = recentComments[indexPath.row]
            guard let type = comment["type"] as? Int else { return }
            
            if type == 0 {
                // Post
                if let postUid = comment["refUid"] as? String {
                    showLoadingView()
                    PostService.fetchPost(withPostId: postUid) { post in
                        self.dismissLoadingView()
                        let layout = UICollectionViewFlowLayout()
                        layout.scrollDirection = .vertical
                        layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
                        layout.minimumLineSpacing = 0
                        layout.minimumInteritemSpacing = 0
                        
                        let controller = DetailsPostViewController(post: post, user: self.user, type: .regular, collectionViewLayout: layout)
                        
                        let backItem = UIBarButtonItem()
                        backItem.title = ""
                        backItem.tintColor = .label
                        self.navigationItem.backBarButtonItem = backItem
                        
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            } else {
                // Case
                if let caseUid = comment["refUid"] as? String {
                    showLoadingView()
                    CaseService.fetchCase(withCaseId: caseUid) { clinicalCase in
                        self.dismissLoadingView()
                        let layout = UICollectionViewFlowLayout()
                        layout.scrollDirection = .vertical
                        layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
                        layout.minimumLineSpacing = 0
                        layout.minimumInteritemSpacing = 0
                        
                        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: self.user, type: .regular, collectionViewFlowLayout: layout)
                        
                        let backItem = UIBarButtonItem()
                        backItem.tintColor = .label
                        backItem.title = ""
                        self.navigationItem.backBarButtonItem = backItem
                        
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
        }
    }
}


//MARK: - UserProfileHeaderDelegate

extension UserProfileViewController: MEStretchyHeaderDelegate {
    func didTapBanner() {
        print("kek banner push")
        let controller = ProfileImageViewController(isBanner: true)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            if let bannerUrl = self.user.bannerImageUrl, bannerUrl != "" {
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
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func headerCell(_ cell: UICollectionViewCell, didTapEditProfileFor user: User) {

        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
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
                // Handle unfollow user
                UserService.unfollow(uid: uid) { error in
                    
                    self.user.isFollowed = false
                    self.fetchUserStats()
                    currentCell.isUpdatingFollowState = false
                    currentCell.updateButtonAfterAction = true
                    // Delete user feed posts related to the unfollowed user
                    PostService.updateUserFeedAfterFollowing(userUid: uid, didFollow: false)
                }
            } else {
                // Handle follow user
                UserService.follow(uid: uid) { error in
                    self.user.isFollowed = true
                    self.fetchUserStats()
                    currentCell.isUpdatingFollowState = false
                    currentCell.updateButtonAfterAction = true
                    NotificationService.uploadNotification(toUid: uid, fromUser: currentUser, type: .follow)
                    //Update user feed posts related to the followed user
                    PostService.updateUserFeedAfterFollowing(userUid: uid, didFollow: true)
                }
            }
        }
    }
}

extension UserProfileViewController: UserProfileSeeOthersCellDelegate {
    func didTapProfile(forUser user: User) {
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        backItem.tintColor = .label
        
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
        
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    
}

extension UserProfileViewController: UserProfileTitleHeaderDelegate {
    func didTapEditSection(sectionTitle: String) {
        switch sectionTitle {
        case "About":
            let controller = AddAboutViewController()
            controller.title = "About"
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Patents":
            let controller = PatentSectionViewController(user: user, patents: patents, isCurrentUser: user.isCurrentUser)
            controller.title = "Patents"
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Education":
            let controller = EducationSectionViewController(education: education, isCurrentUser: user.isCurrentUser)
            controller.title = "Education"
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Languages":
            let controller = LanguageSectionViewController(languages: languages, isCurrentUser: user.isCurrentUser)
            controller.title = "Languages"
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Publications":
            let controller = PublicationSectionViewController(user: user, publications: publications, isCurrentUser: user.isCurrentUser)
            controller.title = "Publications"
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Experience":
            let controller = ExperienceSectionViewController(experience: experience, isCurrentUser: user.isCurrentUser)
            controller.title = "Experience"
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)

        default:
            print("No cell registered")
        }
    }
}

extension UserProfileViewController: UserProfileTitleFooterDelegate {
    func didTapFooter(section: String) {
        switch section {
        case "Show posts":

            //let layout = UICollectionViewFlowLayout()
            //layout.scrollDirection = .vertical
            //layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 300)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            let controller = HomeViewController(contentSource: .user)
            controller.controllerIsBeeingPushed = true
            controller.displaysSinglePost = true
            controller.user = user
            
            controller.hidesBottomBarWhenPushed = true
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Show cases":
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 300)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            let controller = CaseViewController(user: user, contentSource: .user)
            //controller.controllerIsBeeingPushed = true
            //controller.displaysSinglePost = true
            navigationController?.pushViewController(controller, animated: true)
            
        case "Show comments":
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .zero)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            let controller = UserCommentsViewController(user: user, collectionViewFlowLayout: layout)
       
            navigationController?.pushViewController(controller, animated: true)
        
   
    case "Show experiences":
        let controller = ExperienceSectionViewController(experience: experience, isCurrentUser: user.isCurrentUser)
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
            backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
            navigationController?.pushViewController(controller, animated: true)

         
        case "Show education":
            let controller = EducationSectionViewController(education: education, isCurrentUser: user.isCurrentUser)
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
            
        case "Show patents":
            let controller = PatentSectionViewController(user: user, patents: patents, isCurrentUser: user.isCurrentUser)
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)

            
        case "Show publications":
            let controller = PublicationSectionViewController(user: user, publications: publications, isCurrentUser: user.isCurrentUser)
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Show languages":
            let controller = LanguageSectionViewController(languages: languages, isCurrentUser: user.isCurrentUser)
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem


            navigationController?.pushViewController(controller, animated: true)
            //co
        default:
            print("no footer registered")
        }
    }
}

extension UserProfileViewController: UserProfilePatentCellDelegate {
    func didTapEditPatent(_ cell: UICollectionViewCell, patentTitle: String, patentNumber: String, patentDescription: String) { return }
    
    func didTapShowContributors(users: [User]) {
        let controller = ContributorsViewController(users: users)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension UserProfileViewController: UserProfilePublicationCellDelegate {
    func didTapEditPublication(_ cell: UICollectionViewCell, publicationTitle: String, publicationDate: String, publicationUrl: String) { return }
    
    
}

extension UserProfileViewController: EditProfileViewControllerDelegate, AddAboutViewControllerDelegate, LanguageSectionViewControllerDelegate {
    func didUpdateProfile(user: User) {
        self.user = user
        UserDefaults.standard.set(user.profileImageUrl, forKey: "userProfileImageUrl")
        UserDefaults.standard.set(user.bannerImageUrl, forKey: "userProfileBannerUrl")
        UserDefaults.standard.set(user.firstName! + " " + user.lastName!, forKey: "name")
        #warning("mirar si es pot evitar tenir que fer fetch de user stats...")
        UserService.fetchUserStats(uid: user.uid!) { stats in
            self.user.stats = stats
            self.collectionView.reloadSections(IndexSet(integer: 0))
            
            NotificationCenter.default.post(name: NSNotification.Name("ProfileImageUpdateIdentifier"), object: nil, userInfo: nil)
            
            guard let tab = self.tabBarController as? MainTabController else { return }
            tab.updateUser(user: user)
        }
    }
    
    func updateLanguageValues() {
        fetchUserStats()
        fetchLanguages()
    }
    
    
    func fetchNewLanguageValues() {
        fetchUserStats()
        fetchLanguages()
    }
    
    func fetchNewPublicationValues() {
        fetchUserStats()
        fetchPublications()
    }
    
    func fetchNewPatentValues() {
        fetchUserStats()
        fetchPatents()
    }
    
    func fetchNewEducationValues() {
        fetchUserStats()
        fetchEducation()
    }
    
    func fetchNewExperienceValues(withUid uid: String) {
        fetchUserStats()
        fetchExperience()
    }
    
    func handleUpdateAbout() {
        fetchUserStats()
        fetchSections()
    }
    
    func fetchNewAboutValues(withUid uid: String) {
        fetchUserStats()
        fetchSections()
    }
    
    func fetchNewUserValues(withUid uid: String) {
        UserService.fetchUser(withUid: uid) { user in
    
            #warning("Asignar al user al main tab controllerl també perquè sinó es perd la info nova")
            self.user = user
            self.collectionView.reloadData()
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


class LogoContainerView: UIView {
    let imageView: UIImageView
    init(imageView: UIImageView) {
        self.imageView = imageView
        super.init(frame: CGRect.zero)
        
        addSubview(imageView)
    }
    
    override convenience init(frame: CGRect) {
        self.init(imageView: UIImageView())
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}
