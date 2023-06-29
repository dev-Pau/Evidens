//
//  GroupPageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/11/22.
//

import UIKit
import Firebase

private let stretchyHeaderReuseIdentifier = "StretchyHeaderReuseIdentifier"
private let groupHeaderReuseIdentifier = "GroupHeaderReuseIdentifier"
private let groupContentCreationReuseIdentifier = "GroupContentCreationReuseIdentifier"
private let groupContentSelectionReuseIdentifier = "GroupContentSelectionReuseIdentifier"
private let groupContentCollectionViewReuseIdentifier = "GroupContentCollectionViewReuseIdentifier"
private let groupContentAdminReuseIdentifier = "GroupContentAdminReuseIdentifier"
private let groupContentHeaderReuseIdentifier = "GroupContentHeaderReuseIdentifier"
private let groupContentDescriptionReuseIdentifier = "GroupContentDescriptionReuseIdentifier"
private let emptyGroupContentCellReuseIdentifier = "EmptyGroupContentCellReuseIdentifier"
private let homeTextCellReuseIdentifier = "HomeTextCellReuseIdentifier"
private let homeFourImageTextCell = "HomeFourImageTextCell"
private let homeThreeImageTextCell = "HomeThreeImageTextCell"
private let homeTwoImageTextCell = "HomeTwoImageTextCell"
private let homeImageTextCell = "HomeImageTextCell"
private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseImageCellReuseIdentifier = "CaseImageCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIDentifier"

protocol GroupPageViewControllerDelegate: AnyObject {
    func didUpdateGroup(_ group: Group)
}

class GroupPageViewController: UIViewController, UINavigationControllerDelegate {
    
    weak var delegate: GroupPageViewControllerDelegate?
    private var groupContextMenu = MEContextMenuLauncher(menuLauncherData: Display(content: .groupPrivacy))
    
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
    
    private var scrollViewDidScrollHigherThanActionButton: Bool = false
    
    private var standardAppearance = UINavigationBarAppearance()

    private var collectionView: UICollectionView!
    
    private var group: Group
    private var members: [User]?
    private var countGroupInformationFetched: Int = 0
    private var countGroupInformationToFetch: Int = 0
    private var groupInformationFetched: Bool = false
    
    private var adminUserRoles = [UserGroup]()
    private var adminUsers = [User]()
    
    private var contentIndexSelected: ContentGroup.ContentTopics = .all
    private var content = [ContentGroup]()
    private var contentLastTimestamp: Int64?
    
    private var posts = [Post]()
    private var postLastTimestamp: Int64?
    private var cases = [Case]()
    private var casesLastTimestamp: Int64?
    
    private let referenceMenuLauncher = MEReferenceMenuLauncher()
    
    private var users = [User]()
    
    private var loaded: Bool = false
    
    private var memberType: Group.MemberType?
    
    private lazy var customRightButton: UIButton = {
        let button = UIButton()

        button.configuration = .filled()

        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
       
        button.configuration?.cornerStyle = .capsule
        
        button.addTarget(self, action: #selector(handleGroupButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var groupProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 3
        iv.image = UIImage(named: "group.profile")
        iv.backgroundColor = .quaternarySystemFill
        iv.layer.borderColor = UIColor.systemBackground.cgColor
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileTap)))
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
      
        return iv
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        
        if let memberType = memberType {
            
            customRightButton.menu = addMenuItems()
            var container = AttributeContainer()
            container.font = .systemFont(ofSize: 15, weight: .bold)
            customRightButton.configuration?.baseBackgroundColor = .systemBackground
            customRightButton.configuration?.baseForegroundColor = .label
            customRightButton.configuration?.background.strokeColor = .quaternarySystemFill
            customRightButton.configuration?.background.strokeWidth = 1
            customRightButton.configuration?.attributedTitle = AttributedString(memberType.buttonText, attributes: container)
        
            // User is from group or is pending
            // If user is pending, don't have access to members
            guard memberType != .pending else {
                countGroupInformationToFetch = 1
                fetchGroupAdminTeam()
                return
            }
            // User is from group, fetch group users
            countGroupInformationToFetch = 2
            fetchGroupUsers()
            fetchGroupContent()
            
        } else {
            // User comes from discover tab or might be pending. Fetch user member type.
            fetchUserMemberType()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollViewDidScroll(collectionView)
    }
    
    init(group: Group, memberType: Group.MemberType? = nil) {
        self.group = group
        if let memberType = memberType { self.memberType = memberType }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fetchUserMemberType() {
        DatabaseManager.shared.fetchUserMemberTypeForGroup(groupId: group.groupId) { memberType in
            self.memberType = memberType
            var container = AttributeContainer()
            container.font = .systemFont(ofSize: 15, weight: .bold)
            self.customRightButton.configuration?.attributedTitle = AttributedString(memberType.buttonText, attributes: container)
            
            if memberType != .external {
                self.customRightButton.menu = self.addMenuItems()
                self.customRightButton.configuration?.baseBackgroundColor = .systemBackground
                self.customRightButton.configuration?.baseForegroundColor = .label
                self.customRightButton.configuration?.background.strokeColor = .quaternarySystemFill
                self.customRightButton.configuration?.background.strokeWidth = 1
            }

            if memberType == .external || memberType == .pending {
                self.countGroupInformationToFetch = 1
                self.fetchGroupAdminTeam()
            } else {
                self.countGroupInformationToFetch = 2
                self.fetchGroupUsers()
                self.fetchGroupContent()
                return
            }
        }
    }
    
    private func fetchGroupAdminTeam() {
        DatabaseManager.shared.fetchGroupAdminTeamRoles(groupId: self.group.groupId) { adminUserRoles in
            self.adminUserRoles = adminUserRoles
            // Get all admin uid's
            let adminUids = adminUserRoles.map { $0.uid }

            UserService.fetchUsers(withUids: adminUids) { admins in
                self.adminUsers = admins
                self.checkIfAllGroupInformationIsFetched()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxVerticalOffset = (view.frame.width / 3) / 2
        let currentVeritcalOffset = scrollView.contentOffset.y
        groupProfileImageView.frame.origin.y = (view.frame.width / 3 - 25) - currentVeritcalOffset
        let percentageOffset = currentVeritcalOffset / maxVerticalOffset
        standardAppearance.backgroundColor = .systemBackground.withAlphaComponent(percentageOffset)
        self.navigationItem.standardAppearance = standardAppearance
        //navigationController?.navigationBar.standardAppearance = standardAppearance
        
        if currentVeritcalOffset > (view.frame.width / 3 + 40 - topbarHeight) && !scrollViewDidScrollHigherThanActionButton  {
            scrollViewDidScrollHigherThanActionButton.toggle()
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.label).withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(handleBack))
            groupProfileImageView.isHidden = true

            
            if memberType == .external || memberType == .admin || memberType == .owner {
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customRightButton)
            } else {
                navigationItem.setRightBarButton(nil, animated: true)
            }
            
         
        } else if currentVeritcalOffset < (view.frame.width / 3 + 40 - topbarHeight) && scrollViewDidScrollHigherThanActionButton {
            scrollViewDidScrollHigherThanActionButton.toggle()
            groupProfileImageView.isHidden = false
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
            navigationItem.setRightBarButton(nil, animated: true)

        }
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        self.navigationItem.scrollEdgeAppearance = appearance
        //let appearance = UINavigationBarAppearance()
        //appearance.configureWithTransparentBackground()
        
        //navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = .systemBackground
        self.navigationItem.standardAppearance = standardAppearance
        //navigationController?.navigationBar.standardAppearance = standardAppearance
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func fetchGroupUsers() {
        DatabaseManager.shared.fetchFirstGroupUsers(forGroupId: group.groupId) { uids in
            UserService.fetchUsers(withUids: uids) { users in
                self.members = users
                self.checkIfAllGroupInformationIsFetched()
                //self.collectionView.reloadData()
            }
        }
    }
    
    private func checkIfAllGroupInformationIsFetched() {
        if groupInformationFetched {
            loaded = true
            collectionView.reloadData()
        } else {
            countGroupInformationFetched += 1
            if countGroupInformationFetched == countGroupInformationToFetch {
                // All Group data fetched
                groupInformationFetched = true
                loaded = true
                collectionView.reloadData()
                scrollViewDidScroll(collectionView)
            }
        }
    }
    
    private func fetchGroupContent() {
        // Fetch the post/cases id's ordered by timestamp
        // For each id obtained, fetch the case or post associated
        // Update collection view
        DatabaseManager.shared.fetchAllGroupContent(withGroupId: group.groupId, lastTimestampValue: contentLastTimestamp) { contentGroup in
            guard !contentGroup.isEmpty else {
                // There's no content published in the group
                self.loaded = true
                self.checkIfAllGroupInformationIsFetched()
                return
            }
            // If there's content, check content type and fetch accordingly
            self.content = contentGroup

            contentGroup.forEach { content in
                if content.type == .post {
                    PostService.fetchGroupPost(withGroupId: self.group.groupId, withPostId: content.id) { post in
                        self.posts.append(post)
                        if contentGroup.count == self.cases.count + self.posts.count {
                            let ownerUids = self.posts.map { $0.ownerUid } + self.cases.map { $0.ownerUid }
                            let ownerUniqueUids = Array(Set(ownerUids))
                            
                            if let lastTimestamp = self.content.last {
                                self.contentLastTimestamp = lastTimestamp.timestamp.milliseconds / 1000
                            } else {
                                return
                            }
                            
                            UserService.fetchUsers(withUids: ownerUniqueUids) { users in
                                self.users = users
                                print("called from fetchGroupContents")
                                self.checkIfAllGroupInformationIsFetched()
                                //self.loaded = true
                                //self.collectionView.reloadData()
                                //self.collectionView.isHidden = false
                            }
                        }
                    }
                } else {
                    CaseService.fetchGroupCase(withGroupId: self.group.groupId, withCaseId: content.id) { clinicalCase in
                        self.cases.append(clinicalCase)
                        if contentGroup.count == self.cases.count + self.posts.count {
                            //self.content.last?.timestamp.self.sec
                            let ownerUids = self.posts.map { $0.ownerUid } + self.cases.map { $0.ownerUid }
                            let ownerUniqueUids = Array(Set(ownerUids))
                            
                            if let lastTimestamp = self.content.last {
                                self.contentLastTimestamp = lastTimestamp.timestamp.milliseconds / 1000
                            } else {
                                return
                            }
                            
                            UserService.fetchUsers(withUids: ownerUniqueUids) { users in
                                self.users = users
                                print("called from fetchGroupContents")
                                self.checkIfAllGroupInformationIsFetched()
                                //self.loaded = true
                                //self.collectionView.reloadData()
                                //self.collectionView.isHidden = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func fetchGroupCases() {
        DatabaseManager.shared.fetchAllGroupCases(withGroupId: group.groupId, lastTimestampValue: nil) { caseIds in
            guard !caseIds.isEmpty else {
                self.checkIfAllGroupInformationIsFetched()
                return
            }
            
            caseIds.forEach { id in
                CaseService.fetchGroupCase(withGroupId: self.group.groupId, withCaseId: id) { clinicalCase in
                    self.cases.append(clinicalCase)
                    if caseIds.count == self.cases.count {
                        // Sort cases by timestamp
                        self.cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                        self.casesLastTimestamp = self.cases.last?.timestamp.seconds
                        // Obtain all cases owner uids & make the array unique
                        let uniqueOwnerUids = Array(Set(self.cases.map({ $0.ownerUid })))
                        UserService.fetchUsers(withUids: uniqueOwnerUids) { users in
                            //self.checkIfUserLikedCase()
                            //self.checkIfUserBookmarkedCase()
                            self.users = users
                            self.checkIfAllGroupInformationIsFetched()
                        }
                    }
                }
            }
        }
    }
    
    private func fetchGroupPosts() {
        DatabaseManager.shared.fetchAllGroupPosts(withGroupId: self.group.groupId, lastTimestampValue: nil) { postIds in
            guard !postIds.isEmpty else {
                self.checkIfAllGroupInformationIsFetched()
                return
            }
            postIds.forEach { id in
                PostService.fetchGroupPost(withGroupId: self.group.groupId, withPostId: id) { post in
                    self.posts.append(post)
                    if postIds.count == self.posts.count {
                        self.posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                        self.postLastTimestamp = self.posts.last?.timestamp.seconds

                        let uniqueOwnerUids = Array(Set(self.posts.map({ $0.ownerUid })))
                        UserService.fetchUsers(withUids: uniqueOwnerUids) { users in
                            //self.checkIfUserLikedPosts()
                            //self.checkIfUserBookmarkedPost()
                            self.users = users
                            self.checkIfAllGroupInformationIsFetched()
                        }
                    }
                }
            }
        }
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(collectionView, groupProfileImageView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            groupProfileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.width / 3 - 25),
            groupProfileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            groupProfileImageView.widthAnchor.constraint(equalToConstant: 90),
            groupProfileImageView.heightAnchor.constraint(equalToConstant: 90),
        ])
        
        if let imageUrl = group.profileUrl, imageUrl != "" {
            groupProfileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        
        //groupProfileImageView.layer.cornerRadius = 90 / 3
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.bounces = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        //if memberType == nil { collectionView.isHidden = true }
    
        
        collectionView.register(MEStretchyHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: stretchyHeaderReuseIdentifier)
        collectionView.register(GroupPageHeaderCell.self, forCellWithReuseIdentifier: groupHeaderReuseIdentifier)
        collectionView.register(GroupContentCreationCell.self, forCellWithReuseIdentifier: groupContentCreationReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(GroupContentSelectionHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: groupContentSelectionReuseIdentifier)
        
        // External users
        collectionView.register(GroupAdminCell.self, forCellWithReuseIdentifier: groupContentAdminReuseIdentifier)
        collectionView.register(GroupAboutHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: groupContentHeaderReuseIdentifier)
        
        collectionView.register(UserProfileAboutCell.self, forCellWithReuseIdentifier: groupContentDescriptionReuseIdentifier)
        
        // Content cells
        collectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupContentCellReuseIdentifier)
        collectionView.register(HomeTextCell.self, forCellWithReuseIdentifier: homeTextCellReuseIdentifier)
        collectionView.register(HomeImageTextCell.self, forCellWithReuseIdentifier: homeImageTextCell)
        collectionView.register(HomeTwoImageTextCell.self, forCellWithReuseIdentifier: homeTwoImageTextCell)
        collectionView.register(HomeThreeImageTextCell.self, forCellWithReuseIdentifier: homeThreeImageTextCell)
        collectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCell)
        
        collectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        collectionView.register(HomeFourImageTextCell.self, forCellWithReuseIdentifier: homeFourImageTextCell)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: groupContentCollectionViewReuseIdentifier)
        //collectionView.register(UserProfileTitleHeader.self, forCellWithReuseIdentifier: profileHeaderTitleReuseIdentifier)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                 groupProfileImageView.layer.borderColor = UIColor.systemBackground.cgColor
             }
         }
    }
    
    private func createLayout() -> StretchyHeaderLayout {
        let layout = StretchyHeaderLayout { sectionNumber, env in
            if sectionNumber == 0 {
                // Just the profile header
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(self.view.frame.width / 3)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                // Profile Header
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)))

                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                return section
            } else if sectionNumber == 1 {
                // Loading header while fetching data && Group Header
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                //section.orthogonalScrollingBehavior = .continuous
                return section
            } else {
                if self.memberType == .external || self.memberType == .pending || !self.loaded {
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                             elementKind: ElementKind.sectionHeader,
                                                                             alignment: .top)
        
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(65)))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(65)), subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.boundarySupplementaryItems = [header]
                    //section.orthogonalScrollingBehavior = .continuous
                    return section
                } else {
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(65)))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(65)), subitems: [item])
                    let section = NSCollectionLayoutSection(group: group)
                    //section.orthogonalScrollingBehavior = .continuous
                    return section
                    
                }
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()

        config.interSectionSpacing = 0
        layout.configuration = config
        
        return layout
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let memberType = memberType else { return nil }
        
        switch memberType {
        case .owner:
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: Group.GroupManagement.posts.rawValue, image: Group.GroupManagement.posts.groupManagementImage, handler: { _ in
                    self.didTapGroupOptions(option: Group.GroupManagement.posts)
                }),
                UIAction(title: Group.GroupManagement.membership.rawValue, image: Group.GroupManagement.membership.groupManagementImage, handler: { _ in
                    self.didTapGroupOptions(option: Group.GroupManagement.membership)
                }),
                UIAction(title: Group.GroupManagement.edit.rawValue, image: Group.GroupManagement.edit.groupManagementImage, handler: { _ in
                    self.didTapGroupOptions(option: Group.GroupManagement.edit)
                })
            ])
            customRightButton.showsMenuAsPrimaryAction = true
            return menuItems
            
        case .admin:
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: Group.GroupManagement.posts.rawValue, image: Group.GroupManagement.posts.groupManagementImage, handler: { _ in
                    self.didTapGroupOptions(option: Group.GroupManagement.posts)
                }),
                UIAction(title: Group.GroupManagement.membership.rawValue, image: Group.GroupManagement.membership.groupManagementImage, handler: { _ in
                    self.didTapGroupOptions(option: Group.GroupManagement.membership)
                })
            ])
            customRightButton.showsMenuAsPrimaryAction = true
            return menuItems
        case .member:
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: Group.GroupManagement.leave.rawValue, image: Group.GroupManagement.leave.groupManagementImage, attributes: .destructive, handler: { _ in
                    #warning("update leave")
                }),
                UIAction(title: Group.GroupManagement.report.rawValue, image: Group.GroupManagement.report.groupManagementImage, handler: { _ in
                    self.didTapGroupOptions(option: Group.GroupManagement.report)
                })
                
            ])
            customRightButton.showsMenuAsPrimaryAction = true
            return menuItems
        case .pending:
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: Group.GroupManagement.withdraw.rawValue, image: Group.GroupManagement.withdraw.groupManagementImage, handler: { _ in
                    self.didTapGroupOptions(option: Group.GroupManagement.withdraw)
                }),
                UIAction(title: Group.GroupManagement.report.rawValue, image: Group.GroupManagement.report.groupManagementImage, handler: { _ in
                    self.didTapGroupOptions(option: Group.GroupManagement.report)
                })
            ])
            customRightButton.showsMenuAsPrimaryAction = true
            return menuItems
        case .external:
            return nil
        case .invited:
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: Group.GroupManagement.accept.rawValue, image: Group.GroupManagement.accept.groupManagementImage, handler: { _ in
                    self.didTapGroupOptions(option: Group.GroupManagement.accept)
                }),
                UIAction(title: Group.GroupManagement.ignore.rawValue, image: Group.GroupManagement.ignore.groupManagementImage, handler: { _ in
                    self.didTapGroupOptions(option: Group.GroupManagement.ignore)
                }),
                UIAction(title: Group.GroupManagement.report.rawValue, image: Group.GroupManagement.report.groupManagementImage, handler: { _ in
                    self.didTapGroupOptions(option: Group.GroupManagement.report)
                })
            ])
            customRightButton.showsMenuAsPrimaryAction = true
            return menuItems
        case .blocked:
            return nil
        }
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleProfileTap() {
        let controller = ProfileImageViewController(isBanner: false)
        controller.cornerRadius = 0
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            if let imageUrl = self.group.profileUrl, imageUrl != "" {
                controller.profileImageView.sd_setImage(with: URL(string: imageUrl))
            } else {
                controller.profileImageView.image = UIImage(named: "group.profile")
            }
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true)
        }
    }
    
    @objc func handleGroupButton() {
        guard let memberType = memberType else { return }
        if memberType == .external {
            customRightButton.isUserInteractionEnabled = false
            DatabaseManager.shared.sendRequestToGroup(groupId: group.groupId) { send in
                self.customRightButton.isUserInteractionEnabled = true
                if send {
                    self.customRightButton.showsMenuAsPrimaryAction = true
                    var container = AttributeContainer()
                    container.font = .systemFont(ofSize: 14, weight: .bold)
                    self.customRightButton.configuration?.baseBackgroundColor = .systemBackground
                    self.customRightButton.configuration?.baseForegroundColor = .label
                    self.customRightButton.configuration?.background.strokeColor = .quaternarySystemFill
                    self.customRightButton.configuration?.background.strokeWidth = 1
                    self.memberType = .pending
                    self.customRightButton.configuration?.attributedTitle = AttributedString(self.memberType?.buttonText ?? "Pending", attributes: container)
                    
                    let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! GroupPageHeaderCell
                    cell.memberType = self.memberType!
                    self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
                    
                    let popUp = METopPopupView(title: "Group request sent", image: "checkmark.circle.fill", popUpType: .regular)
                    popUp.showTopPopup(inView: self.view)
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            print("get more content")
            getMoreContent()
        }
    }
    
    private func getMoreContent() {
        switch contentIndexSelected {
        case .all:
            DatabaseManager.shared.fetchAllGroupContent(withGroupId: group.groupId, lastTimestampValue: contentLastTimestamp) { contentGroup in
                var newOwners = [String]()
                self.content.append(contentsOf: contentGroup)
                // There's no content published in the group
                if contentGroup.isEmpty {
                    self.loaded = true
                    self.collectionView.reloadData()
                    return
                }

                // If there's content, check content type and fetch accordingly
                contentGroup.forEach { content in
                    if content.type == .post {
                        PostService.fetchGroupPost(withGroupId: self.group.groupId, withPostId: content.id) { post in
                            self.posts.append(post)
                            newOwners.append(post.ownerUid)
                            if newOwners.count == contentGroup.count {
                                let ownerUids = self.posts.map { $0.ownerUid } + self.cases.map { $0.ownerUid }
                                let ownerUniqueUids = Array(Set(ownerUids))
                                
                                if let lastTimestamp = self.content.last {
                                    self.contentLastTimestamp = lastTimestamp.timestamp.milliseconds / 1000
                                } else {
                                    return
                                }
                                
                                UserService.fetchUsers(withUids: newOwners) { users in
                                    self.users.append(contentsOf: users)
                                    //self.checkIfUserLikedPosts()
                                    //self.checkIfUserLikedCase()
                                    //self.checkIfUserBookmarkedCase()
                                    //self.checkIfUserBookmarkedPost()
                                    self.loaded = true
                                    self.collectionView.reloadData()
                                }
                                // get all uids from posts & cases into a new array
                                // make it unique so all duplicates get deleted
                                // fetch users with uids.

                            }
                        }
                    } else {
                        CaseService.fetchGroupCase(withGroupId: self.group.groupId, withCaseId: content.id) { clinicalCase in
                            self.cases.append(clinicalCase)
                            newOwners.append(clinicalCase.ownerUid)
                            if newOwners.count == contentGroup.count {
                                //self.content.last?.timestamp.self.sec
                                let ownerUids = self.posts.map { $0.ownerUid } + self.cases.map { $0.ownerUid }
                                let ownerUniqueUids = Array(Set(ownerUids))
                                
                                if let lastTimestamp = self.content.last {
                                    self.contentLastTimestamp = lastTimestamp.timestamp.milliseconds / 1000
                                } else {
                                    return
                                }
                                
                                UserService.fetchUsers(withUids: newOwners) { users in
                                    self.users.append(contentsOf: users)
                                    self.loaded = true
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        case .cases:
            DatabaseManager.shared.fetchAllGroupCases(withGroupId: group.groupId, lastTimestampValue: casesLastTimestamp) { caseIds in
                var newOwners = [String]()
                caseIds.forEach { id in
                    CaseService.fetchGroupCase(withGroupId: self.group.groupId, withCaseId: id) { clinicalCase in
                        self.cases.append(clinicalCase)
                        newOwners.append(clinicalCase.ownerUid)
                        if newOwners.count == caseIds.count {
                            // Sort cases by timestamp
                            self.cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                            self.casesLastTimestamp = self.cases.last?.timestamp.seconds
                            // Obtain all cases owner uids & make the array unique
                            //let uniqueOwnerUids = Array(Set(self.cases.map({ $0.ownerUid })))
                            UserService.fetchUsers(withUids: newOwners) { users in
                              
                                self.users.append(contentsOf: users)
                                self.loaded = true
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        case .posts:
            DatabaseManager.shared.fetchAllGroupPosts(withGroupId: self.group.groupId, lastTimestampValue: postLastTimestamp) { postIds in
                var newOwners = [String]()
                
                postIds.forEach { id in
                    PostService.fetchGroupPost(withGroupId: self.group.groupId, withPostId: id) { post in
                        newOwners.append(post.ownerUid)
                        self.posts.append(post)
                        if newOwners.count == postIds.count {
                        //if postIds.count == self.posts.count {
                            self.posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                            self.postLastTimestamp = self.posts.last?.timestamp.seconds

                            //let uniqueOwnerUids = Array(Set(self.posts.map({ $0.ownerUid })))
                            UserService.fetchUsers(withUids: newOwners) { users in
                               
                                self.users.append(contentsOf: users)
                                self.loaded = true
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
   
}

extension GroupPageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groupInformationFetched ? 3 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            // If is not loaded, just return 1 item -> Group header with all the information
            return groupInformationFetched ? (memberType == .external || memberType == .pending) ? 1 : 2 : 1
        } else if section == 1 {
            guard groupInformationFetched else { return 0 }
            if memberType == .external || memberType == .pending {
                return 1
            } else {
                // Cases & Posts
                //if !loaded { return 3 }
                switch contentIndexSelected {
                case .all:
                    return loaded ? content.isEmpty ? 1 : content.count : 0//loaded ? (content.isEmpty ? 1 : content.count) : 3
                case .cases:
                    return loaded ? cases.isEmpty ? 1 : cases.count : 0//loaded ? (cases.isEmpty ? 1 : cases.count) : 3  //cases.isEmpty ? 1 :  loaded ? cases.count : 4
                case .posts:
                    return  loaded ? posts.isEmpty ? 1 : posts.count : 0//loaded ? (posts.isEmpty ? 1 : posts.count) : 3 //posts.isEmpty ? 1 : loaded ? posts.count : 4
                }
            }
        } else {
            return (memberType == .external || memberType == .pending) ? adminUserRoles.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupHeaderReuseIdentifier, for: indexPath) as! GroupPageHeaderCell
                
                cell.configurationButton.isHidden = groupInformationFetched ? false : true
                cell.customUserButton.isHidden = groupInformationFetched ? false : true

                cell.viewModel = GroupViewModel(group: group)
                cell.users = members
                cell.memberType = memberType
                cell.delegate = self
                return cell
                
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupContentCreationReuseIdentifier, for: indexPath) as! GroupContentCreationCell
                cell.delegate = self
                return cell
            }
            
        } else if indexPath.section == 1 {
            if memberType == .pending || memberType == .external {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupContentDescriptionReuseIdentifier, for: indexPath) as! UserProfileAboutCell
                cell.set(body: group.description)
                return cell
            } else {
                // Group posts & clinical cases content
                switch contentIndexSelected {
                    
                case .all:
                    if content.isEmpty {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupContentCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                        cell.set(withImage: UIImage(named: "onboarding.date")!, withTitle: "Be the first to share content in this group.", withDescription: "Start sharing content and get the conversation going.", withButtonText: "  Dismiss  ")
                        cell.delegate = self
                        return cell
                    }
                    // Content can be a post or a clinical case
                    let currentContent = content[indexPath.row]
                    
                    switch currentContent.type {
                    case .clinicalCase:
                        let caseIndex = cases.firstIndex { clincalCase in
                            if clincalCase.caseId == currentContent.id {
                                return true
                            }
                            return false
                        }
                        
                        if let caseIndex = caseIndex {
                            let caseToDisplay = cases[caseIndex]
                            return displayClinicalCaseCell(clinicalCase: caseToDisplay, indexPath: indexPath, collectionView: collectionView)
                        }
                        
                        
                    case .post:
                        // Content is a post, search the post in the post array
                        let postIndex = posts.firstIndex { post in
                            if post.postId == currentContent.id {
                                return true
                            }
                            return false
                        }
                        
                        if let postIndex = postIndex {
                            let postToDisplay = posts[postIndex]
                            return displayPostCell(post: postToDisplay, indexPath: indexPath, collectionView: collectionView)
                        }
                    }
                    
                case .cases:
                    if cases.isEmpty {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupContentCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                        cell.set(withImage: UIImage(named: "onboarding.date")!, withTitle: "Be the first to share cases in this group.", withDescription: "Start sharing cases and get the conversation going.", withButtonText: "  Dismiss  ")
                        cell.delegate = self
                        return cell
                    }
                    return displayClinicalCaseCell(clinicalCase: cases[indexPath.row], indexPath: indexPath, collectionView: collectionView)
                    
                    
                case .posts:
                    if posts.isEmpty {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupContentCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                        cell.set(withImage: UIImage(named: "onboarding.date")!, withTitle: "Be the first to share posts in this group.", withDescription: "Start uploading posts and get the conversation going.", withButtonText: "  Dismiss  ")
                        cell.delegate = self
                        return cell
                    }
                    return displayPostCell(post: posts[indexPath.row], indexPath: indexPath, collectionView: collectionView)
                }
            }
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupContentAdminReuseIdentifier, for: indexPath) as! GroupAdminCell
            
            cell.configureWithAdminRole(admin: adminUserRoles[indexPath.row])
            
            let userIndex = adminUsers.firstIndex { user in
                if adminUserRoles[indexPath.row].uid == user.uid {
                    return true
                }
                return false
            }
            
            if let userIndex = userIndex {
                cell.user = adminUsers[userIndex]
            }
            
            return cell
        }
        
        return UICollectionViewCell()
        
    }

        
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: stretchyHeaderReuseIdentifier, for: indexPath) as! MEStretchyHeader
            header.delegate = self
            header.setImageWithStringUrl(imageUrl: group.bannerUrl!)
            return header
        }
        
        if !groupInformationFetched && indexPath.section == 1 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }
        
        if !loaded && indexPath.section == 2 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }
        
        if memberType == .external || memberType == .pending {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: groupContentHeaderReuseIdentifier, for: indexPath) as! GroupAboutHeader
            if indexPath.section == 1 {
                header.set(title: "Description")
            } else if indexPath.section == 2 {
                header.set(title: "Admin Team")
            }
            
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: groupContentSelectionReuseIdentifier, for: indexPath) as! GroupContentSelectionHeader
            header.delegate = self
            return header
        }
    }
    
    func displayPostCell(post: Post, indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        let userIndex = users.firstIndex { user in
            if user.uid == post.ownerUid {
                return true
            }
            return false
        }
        
        switch post.type {
            
        case .plainText:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTextCellReuseIdentifier, for: indexPath) as! HomeTextCell
            cell.viewModel = PostViewModel(post: post)
            cell.delegate = self
            if let userIndex = userIndex { cell.set(user: users[userIndex]) }
            return cell
        case .textWithImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCell, for: indexPath) as! HomeImageTextCell
            cell.viewModel = PostViewModel(post: post)
            cell.delegate = self
            if let userIndex = userIndex { cell.set(user: users[userIndex]) }
            return cell
        case .textWithTwoImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCell, for: indexPath) as! HomeTwoImageTextCell
            cell.viewModel = PostViewModel(post: post)
            cell.delegate = self
            if let userIndex = userIndex { cell.set(user: users[userIndex]) }
            return cell
        case .textWithThreeImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCell, for: indexPath) as! HomeThreeImageTextCell
            cell.viewModel = PostViewModel(post: post)
            cell.delegate = self
            if let userIndex = userIndex { cell.set(user: users[userIndex]) }
            return cell
        case .textWithFourImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCell, for: indexPath) as! HomeFourImageTextCell
            cell.viewModel = PostViewModel(post: post)
            cell.delegate = self
            if let userIndex = userIndex { cell.set(user: users[userIndex]) }
            return cell
        case .document:
            return UICollectionViewCell()
        case .poll:
            return UICollectionViewCell()
        case .video:
            return UICollectionViewCell()
        }
    }
    
    func displayClinicalCaseCell(clinicalCase: Case, indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        
        let userIndex = users.firstIndex { user in
            if user.uid == clinicalCase.ownerUid {
                return true
            }
            return false
        }
        
        switch clinicalCase.type {
        case .text:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
            cell.viewModel = CaseViewModel(clinicalCase: clinicalCase)
            cell.delegate = self
            if let userIndex = userIndex { cell.set(user: users[userIndex]) }
            return cell
        case .textWithImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
            cell.viewModel = CaseViewModel(clinicalCase: clinicalCase)
            cell.delegate = self
            if let userIndex = userIndex { cell.set(user: users[userIndex]) }
            return cell
        }
    }
}


extension GroupPageViewController: GroupPageHeaderCellDelegate {
    func didTapGroupOptions(option: Group.GroupManagement) {
        guard let memberType = memberType else { return }
        switch option {
        case .posts:
            let controller = GroupContentManagementViewController(group: group)
            
            let backItem = UIBarButtonItem()
            backItem.tintColor = .label
            backItem.title = ""
            
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        case .membership:
            let controller = GroupMembershipViewController(group: group, userMemberType: memberType)
            
            let backItem = UIBarButtonItem()
            backItem.tintColor = .label
            backItem.title = ""
            
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        case .edit:
            let controller = CreateGroupViewController(group: group)
            controller.delegate = self
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            
            present(navVC, animated: true)
        case .leave:
            guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            displayMEDestructiveAlert(withTitle: "Leave group", withMessage: "You will loose access to the group content and its rights to interact within the group", withCancelButtonText: "Cancel", withDoneButtonText: "Leave") {
                
                let cell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! GroupPageHeaderCell
                DatabaseManager.shared.removeFromGroup(groupId: self.group.groupId, uid: uid) { ignored in
                    if ignored {
                        self.memberType = .external
                        cell.memberType = .external
                        cell.isUpdatingJoiningState = false
                        cell.setNeedsUpdateConfiguration()
                        
                        var container = AttributeContainer()
                        container.font = .systemFont(ofSize: 15, weight: .bold)
                        self.customRightButton.configuration?.baseBackgroundColor = .label
                        self.customRightButton.configuration?.baseForegroundColor = .systemBackground
                        self.customRightButton.configuration?.background.strokeWidth = 0
                        self.customRightButton.configuration?.attributedTitle = AttributedString(self.memberType!.buttonText, attributes: container)
                        self.customRightButton.showsMenuAsPrimaryAction = false
                        
                        let reportPopup = METopPopupView(title: "You are no longer a member of this group", image: "hand.wave.fill", popUpType: .regular)
                        reportPopup.showTopPopup(inView: self.view)
                    }
                }
            }
            
        case .report:
            let reportPopup = METopPopupView(title: "Group has been reported", image: "flag.fill", popUpType: .regular)
            reportPopup.showTopPopup(inView: self.view)
        case .withdraw:
            let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! GroupPageHeaderCell
            DatabaseManager.shared.unsendRequestToGroup(groupId: group.groupId) { unsend in
                if unsend {
                    self.memberType = .external
                    cell.memberType = .external
                    
                    var container = AttributeContainer()
                    container.font = .systemFont(ofSize: 15, weight: .bold)
                    self.customRightButton.configuration?.baseBackgroundColor = .label
                    self.customRightButton.configuration?.baseForegroundColor = .systemBackground
                    self.customRightButton.configuration?.background.strokeWidth = 0
                    self.customRightButton.configuration?.attributedTitle = AttributedString(self.memberType!.buttonText, attributes: container)
                    self.customRightButton.showsMenuAsPrimaryAction = false
                    
                    cell.isUpdatingJoiningState = false
                    cell.setNeedsUpdateConfiguration()
                    
                    
                }
            }
        case .accept:
            guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! GroupPageHeaderCell
            DatabaseManager.shared.acceptUserRequestToGroup(groupId: group.groupId, uid: uid) { accepted in
                if accepted {
                    self.memberType = .member
                    cell.memberType = .member
                    cell.isUpdatingJoiningState = false
                    cell.setNeedsUpdateConfiguration()
                    
                    var container = AttributeContainer()
                    container.font = .systemFont(ofSize: 15, weight: .bold)
                    self.customRightButton.configuration?.attributedTitle = AttributedString(self.memberType!.buttonText, attributes: container)
                    self.customRightButton.showsMenuAsPrimaryAction = true
                    
                    let reportPopup = METopPopupView(title: "You are now a new member of this group", image: "hand.thumbsup.fill", popUpType: .destructive)
                    reportPopup.showTopPopup(inView: self.view)
                }
            }
        case .ignore:
            let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! GroupPageHeaderCell
            DatabaseManager.shared.unsendRequestToGroup(groupId: group.groupId) { ignored in
                if ignored {
                    self.memberType = .external
                    cell.memberType = .external
                    cell.isUpdatingJoiningState = false
                    
                    var container = AttributeContainer()
                    container.font = .systemFont(ofSize: 15, weight: .bold)
                    self.customRightButton.configuration?.baseBackgroundColor = .label
                    self.customRightButton.configuration?.baseForegroundColor = .systemBackground
                    self.customRightButton.configuration?.background.strokeWidth = 0
                    self.customRightButton.configuration?.attributedTitle = AttributedString(self.memberType!.buttonText, attributes: container)
                    self.customRightButton.showsMenuAsPrimaryAction = false
                    
                    cell.setNeedsUpdateConfiguration()
                }
            }
        }
    }
    
    
    func didTapActionButton(memberType: Group.MemberType) {
        let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! GroupPageHeaderCell
        switch memberType {
        case .owner:
            break
        case .admin:
            break
        case .member:
            break
        case .pending:
            break
        case .external:
            DatabaseManager.shared.sendRequestToGroup(groupId: group.groupId) { send in
                if send {
                    self.memberType = .pending
                    cell.memberType = .pending
                    cell.isUpdatingJoiningState = false
                    cell.setNeedsUpdateConfiguration()
                    
                    var container = AttributeContainer()
                    container.font = .systemFont(ofSize: 15, weight: .bold)
                    self.customRightButton.configuration?.baseBackgroundColor = .systemBackground
                    self.customRightButton.configuration?.baseForegroundColor = .label
                    self.customRightButton.configuration?.background.strokeColor = .quaternarySystemFill
                    self.customRightButton.configuration?.background.strokeWidth = 1
                    self.customRightButton.configuration?.attributedTitle = AttributedString(self.memberType!.buttonText, attributes: container)
                    self.customRightButton.showsMenuAsPrimaryAction = true
                    
                    let popUp = METopPopupView(title: "Group request sent", image: "checkmark.circle.fill", popUpType: .regular)
                    popUp.showTopPopup(inView: self.view)
                    
                }
            }
        case .invited:
            break
        case .blocked:
            break
        }
    }
    
    func didTapInfoButton() {
        let controller = GroupInformationViewController(group: group)
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension GroupPageViewController: GroupContentCreationCellDelegate {
    func didTapShowAudience() {
        print("show audience menu")
        groupContextMenu.showImageSettings(in: view)
    }
    
    func didTapUploadPost() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let controller = UploadPostViewController(user: user, group: group)
        
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        
        present(navVC, animated: true)
    }
    
    func didTapUploadCase() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }

        let controller = ShareCaseProfessionsViewController(user: user, group: group)
       
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        
        present(navVC, animated: true)
         
    }
}

extension GroupPageViewController: GroupInformationViewControllerDelegate {
    func updateGroupInformation(_ group: Group) {
        self.group = group
        delegate?.didUpdateGroup(group)
        collectionView.reloadData()
    }
}

extension GroupPageViewController: GroupContentSelectionHeaderDelegate {
    func didTapContentCategory(category: ContentGroup.ContentTopics) {
        if contentIndexSelected == category { return } else {
            contentIndexSelected = category
            self.loaded = false
            self.collectionView.reloadData()
            
            switch category {
            case .all:
                self.cases.removeAll()
                self.posts.removeAll()
                self.content.removeAll()
                self.contentLastTimestamp = nil
                fetchGroupContent()
            case .cases:
                self.cases.removeAll()
                fetchGroupCases()
            case .posts:
                self.posts.removeAll()
                fetchGroupPosts()
            }
        }
    }
}

extension GroupPageViewController: CreateGroupViewControllerDelegate {
    func didCreateGroup(_ group: Group) { return }
    
    func didUpdateGroup(_ group: Group) {
        self.group = group
        delegate?.didUpdateGroup(group)
        collectionView.reloadData()
    }
}


class StretchyGroupHeaderLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        layoutAttributes?.forEach { attribute in
            if attribute.representedElementKind == UICollectionView.elementKindSectionHeader && attribute.indexPath.section == 0  {
                guard let collectionView = collectionView else { return }
               
                let contentOffsetY = collectionView.contentOffset.y

                if contentOffsetY < 0 {
                    let width = collectionView.frame.width
                    let height = attribute.frame.height - contentOffsetY
                    attribute.frame = CGRect(x: 0, y: 0, width: width, height: height)
                }
 
            }
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
}

extension GroupPageViewController: HomeCellDelegate {
    func cell(_ cell: UICollectionViewCell, wantsToSeeReference reference: Reference) {
        referenceMenuLauncher.reference = reference
        referenceMenuLauncher.delegate = self
        referenceMenuLauncher.showImageSettings(in: view)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor: User) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        let controller = CommentPostViewController(post: post, user: forAuthor, type: .group, currentUser: currentUser)
        controller.delegate = self
       // displayState = displaysSinglePost ? .others : .none
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, didLike post: Post) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }

        var indexPath = IndexPath()
        if contentIndexSelected == .all {
            if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                indexPath = IndexPath(item: index, section: 1)
            } else { return }
        } else {
            guard let index = collectionView.indexPath(for: cell) else { return }
            indexPath = index
        }

        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                GroupService.unlikeGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                GroupService.likeGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                    //NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likeGroupPost, post: post)
                }
            }
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                GroupService.unlikeGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                GroupService.likeGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                    //NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likeGroupPost, post: post)
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                GroupService.unlikeGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                    
                }
            } else {
                //Like post here
                GroupService.likeGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                    //NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likeGroupPost, post: post)
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                GroupService.unlikeGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                GroupService.likeGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                    //NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likeGroupPost, post: post)
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didLike.toggle()
            
            if post.didLike {
                //Unlike post here
                GroupService.unlikeGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes - 1
                    self.posts[indexPath.row].didLike = false
                    self.posts[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                GroupService.likeGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.likes = post.likes + 1
                    self.posts[indexPath.row].didLike = true
                    self.posts[indexPath.row].likes += 1
                    //NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likeGroupPost, post: post)
                }
            }
            
        default:
            break
        }
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    func cell(_ cell: UICollectionViewCell, didTapMenuOptionsFor post: Post, option: Post.PostMenuOptions) {
        switch option {
        case .delete:
            print("delete post here")
        case .edit:
            let controller = EditPostViewController(post: post)
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            
            present(nav, animated: true)
        case .report:
            let reportPopup = METopPopupView(title: "Post reported", image: "flag.fill", popUpType: .regular)
            reportPopup.showTopPopup(inView: self.view)
            
        case .reference:
            let reference = Reference(option: post.reference, referenceText: post.referenceText)
            referenceMenuLauncher.reference = reference
            referenceMenuLauncher.delegate = self
            referenceMenuLauncher.showImageSettings(in: view)
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post) {
        var indexPath = IndexPath()
        if contentIndexSelected == .all {
            if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                indexPath = IndexPath(item: index, section: 1)
            } else { return }
        } else {
            guard let index = collectionView.indexPath(for: cell) else { return }
            indexPath = index
        }
        
        switch cell {
        case is HomeTextCell:
            let currentCell = cell as! HomeTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                GroupService.unbookmarkGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                GroupService.bookmarkGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.posts[indexPath.row].didBookmark = true
                }
            }
        case is HomeImageTextCell:
            let currentCell = cell as! HomeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                GroupService.unbookmarkGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                GroupService.bookmarkGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeTwoImageTextCell:
            let currentCell = cell as! HomeTwoImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                GroupService.unbookmarkGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                GroupService.bookmarkGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeThreeImageTextCell:
            let currentCell = cell as! HomeThreeImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                GroupService.unbookmarkGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                GroupService.bookmarkGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.posts[indexPath.row].didBookmark = true
                }
            }
            
        case is HomeFourImageTextCell:
            let currentCell = cell as! HomeFourImageTextCell
            currentCell.viewModel?.post.didBookmark.toggle()
            
            if post.didBookmark {
                //Unlike post here
                GroupService.unbookmarkGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks - 1
                    self.posts[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                GroupService.bookmarkGroupPost(groupId: group.groupId, post: post) { _ in
                    currentCell.viewModel?.post.numberOfBookmarks = post.numberOfBookmarks + 1
                    self.posts[indexPath.row].didBookmark = true
                }
            }

        default:
            break
        }
    }
    
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        self.navigationController?.delegate = zoomTransitioning
        //displayState = .photo
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .clear
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToSeeLikesFor post: Post) {
        let controller = PostLikesViewController(contentType: post)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
        
        //displayState = displaysSinglePost ? .others : .none
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsPostViewController(post: post, user: user, type: .group, collectionViewLayout: layout)
        controller.delegate = self
       
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension GroupPageViewController: EditPostViewControllerDelegate {
    func didEditPost(post: Post) {
        var indexPath = IndexPath()
        if contentIndexSelected == .all {
            if let index = content.firstIndex(where: { $0.id == post.postId }) {
                indexPath = IndexPath(item: index, section: 1)
                if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
                    posts[postIndex] = post
                } else { return }
            } else { return }
        } else {
            if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                posts[index] = post
                indexPath = IndexPath(item: index, section: 1)
            } else { return }
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}

extension GroupPageViewController: CommentPostViewControllerDelegate {
    func didPressUserProfileFor(_ user: User) {
        let controller = UserProfileViewController(user: user)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    func didDeletePostComment(post: Post, comment: Comment) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex].numberOfComments -= 1
            
            switch post.type {
            case .plainText:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithTwoImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeTwoImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithThreeImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeThreeImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithFourImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeFourImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .document:
                break
            case .poll:
                break
            case .video:
                break
            }
        }
    }
    
    func didCommentPost(post: Post, user: User, comment: Comment) {
        if let postIndex = posts.firstIndex (where: { $0.postId == post.postId } ) {
            posts[postIndex].numberOfComments += 1
            
            var indexPath = IndexPath()
            if contentIndexSelected == .all {
                if let index = content.firstIndex(where: { $0.id == post.postId }) {
                    indexPath = IndexPath(item: index, section: 1)
                } else { return }
                
            } else {
                indexPath = IndexPath(item: postIndex, section: 1)
            }
            
            switch post.type {
            case .plainText:
                let cell = collectionView.cellForItem(at: indexPath) as! HomeTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: indexPath) as! HomeImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithTwoImage:
                let cell = collectionView.cellForItem(at: indexPath) as! HomeTwoImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithThreeImage:
                let cell = collectionView.cellForItem(at: indexPath) as! HomeThreeImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .textWithFourImage:
                let cell = collectionView.cellForItem(at: indexPath) as! HomeFourImageTextCell
                cell.viewModel?.post.numberOfComments += 1
                
            case .document:
                break
            case .poll:
                break
            case .video:
                break
            }
        }
    }
}

extension GroupPageViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension GroupPageViewController: DetailsPostViewControllerDelegate {
    func didDeleteComment(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex].numberOfComments -= 1
            
            switch post.type {
            case .plainText:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithTwoImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeTwoImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithThreeImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeThreeImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .textWithFourImage:
                let cell = collectionView.cellForItem(at: IndexPath(item: postIndex, section: 0)) as! HomeFourImageTextCell
                cell.viewModel?.post.numberOfComments -= 1
                
            case .document:
                break
            case .poll:
                break
            case .video:
                break
            }
        }
    }
    
    func didTapLikeAction(forPost post: Post) {
        var indexPath = IndexPath()
        if contentIndexSelected == .all {
            if let index = content.firstIndex(where: { $0.id == post.postId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) {
                    self.cell(cell, didLike: post)
                }
            } else { return }


        } else {
            if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                indexPath = IndexPath(item: index, section: 1)
                if let cell = collectionView.cellForItem(at: indexPath) {
                    self.cell(cell, didLike: post)
                }
            } else { return }
        }
    }
    
    func didTapBookmarkAction(forPost post: Post) {
        var indexPath = IndexPath()
        if contentIndexSelected == .all {
            if let index = content.firstIndex(where: { $0.id == post.postId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) {
                    self.cell(cell, didBookmark: post)
                }
            } else { return }

        } else {
            if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                indexPath = IndexPath(item: index, section: 1)
                if let cell = collectionView.cellForItem(at: indexPath) {
                    self.cell(cell, didBookmark: post)
                }
            } else { return }
        }
    }
    
    func didComment(forPost post: Post) {
        var indexPath = IndexPath()
        if contentIndexSelected == .all {
            if let index = content.firstIndex(where: { $0.id == post.postId }) {
                indexPath = IndexPath(item: index, section: 1)
                if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
                    posts[postIndex].numberOfComments += 1
                } else { return }
            } else { return }
        } else {
            if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                posts[index].numberOfComments += 1
                indexPath = IndexPath(item: index, section: 1)
            } else { return }
        }
        
        switch post.type {
        case .plainText:
            let cell = collectionView.cellForItem(at: indexPath) as! HomeTextCell
            cell.viewModel?.post.numberOfComments += 1
            
        case .textWithImage:
            let cell = collectionView.cellForItem(at: indexPath) as! HomeImageTextCell
            cell.viewModel?.post.numberOfComments += 1
            
        case .textWithTwoImage:
            let cell = collectionView.cellForItem(at: indexPath) as! HomeTwoImageTextCell
            cell.viewModel?.post.numberOfComments += 1
            
        case .textWithThreeImage:
            let cell = collectionView.cellForItem(at: indexPath) as! HomeThreeImageTextCell
            cell.viewModel?.post.numberOfComments += 1
            
        case .textWithFourImage:
            let cell = collectionView.cellForItem(at: indexPath) as! HomeFourImageTextCell
            cell.viewModel?.post.numberOfComments += 1
            
        case .document:
            break
        case .poll:
            break
        case .video:
            break
        }
    }
    
    func didEditPost(forPost post: Post) {
        print("editing")
        var indexPath = IndexPath()
        if contentIndexSelected == .all {
            if let index = content.firstIndex(where: { $0.id == post.postId }) {
                indexPath = IndexPath(item: index, section: 1)
                if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
                    posts[postIndex] = post
                } else { return }
            } else { return }
        } else {
            if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                posts[index] = post
                indexPath = IndexPath(item: index, section: 1)
            } else { return }
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}

extension GroupPageViewController: CaseCellDelegate {
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        let controller = PostLikesViewController(contentType: clinicalCase)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
        
        //displayState = displaysSinglePost ? .others : .none
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        let controller = CommentCaseViewController(clinicalCase: clinicalCase, user: user, type: .group, currentUser: currentUser)
        controller.delegate = self
       // displayState = displaysSinglePost ? .others : .none
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }

        var indexPath = IndexPath()
        if contentIndexSelected == .all {
            if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                indexPath = IndexPath(item: index, section: 1)
            } else { return }
        } else {
            guard let index = collectionView.indexPath(for: cell) else { return }
            indexPath = index
        }

        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is CaseTextCell:
            let currentCell = cell as! CaseTextCell
            currentCell.viewModel?.clinicalCase.didLike.toggle()
            
            if clinicalCase.didLike {
                //Unlike post here
                GroupService.unlikeGroupCase(groupId: group.groupId, clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                    self.cases[indexPath.row].didLike = false
                    self.cases[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                GroupService.likeGroupCase(groupId: group.groupId, clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    self.cases[indexPath.row].didLike = true
                    self.cases[indexPath.row].likes += 1
                    //NotificationService.uploadNotification(toUid: clinicalCase.ownerUid, fromUser: user, type: .likeGroupCase, clinicalCase: clinicalCase)
                }
            }
        case is CaseTextImageCell:
            let currentCell = cell as! CaseTextImageCell
            currentCell.viewModel?.clinicalCase.didLike.toggle()
            
            if clinicalCase.didLike {
                //Unlike post here
                GroupService.unlikeGroupCase(groupId: group.groupId, clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                    self.cases[indexPath.row].didLike = false
                    self.cases[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                GroupService.likeGroupCase(groupId: group.groupId, clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    self.cases[indexPath.row].didLike = true
                    self.cases[indexPath.row].likes += 1
                    //NotificationService.uploadNotification(toUid: clinicalCase.ownerUid, fromUser: user, type: .likeGroupCase, clinicalCase: clinicalCase)
                }
            }

        default:
            break
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        var indexPath = IndexPath()
        if contentIndexSelected == .all {
            if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                indexPath = IndexPath(item: index, section: 1)
            } else { return }
        } else {
            guard let index = collectionView.indexPath(for: cell) else { return }
            indexPath = index
        }
        
        switch cell {
        case is CaseTextCell:
            let currentCell = cell as! CaseTextCell
            currentCell.viewModel?.clinicalCase.didBookmark.toggle()
            
            if clinicalCase.didBookmark {
                //Unlike post here
                GroupService.unbookmarkGroupCase(groupId: group.groupId, clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks - 1
                    self.cases[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                GroupService.bookmarkGroupCase(groupId: group.groupId, clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    self.cases[indexPath.row].didBookmark = true
                }
            }
        case is CaseTextImageCell:
            let currentCell = cell as! CaseTextImageCell
            currentCell.viewModel?.clinicalCase.didBookmark.toggle()
            
            if clinicalCase.didBookmark {
                //Unlike post here
                GroupService.unbookmarkGroupCase(groupId: group.groupId, clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks - 1
                    self.cases[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                GroupService.bookmarkGroupCase(groupId: group.groupId, clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    self.cases[indexPath.row].didBookmark = true
                }
            }
            
        default:
            break
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: Case.CaseMenuOptions) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        
        switch option {
        case .delete:
            print("delete")
        case .update:
            let controller = CaseUpdatesViewController(clinicalCase: clinicalCase, user: user)
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            controller.controllerIsPushed = true
            controller.delegate = self
            controller.groupId = group.groupId
            navigationController?.pushViewController(controller, animated: true)
            
        case .solved:
            let controller = CaseDiagnosisViewController(diagnosisText: "")
            controller.stageIsUpdating = true
            controller.groupId = group.groupId
            controller.delegate = self
            controller.caseId = clinicalCase.caseId
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        case .report:
            let reportPopup = METopPopupView(title: "Case successfully reported", image: "checkmark.circle.fill", popUpType: .regular)
            reportPopup.showTopPopup(inView: self.view)
        case .edit:
            let controller = CaseDiagnosisViewController(diagnosisText: clinicalCase.diagnosis)
            controller.diagnosisIsUpdating = true
            controller.groupId = group.groupId
            controller.delegate = self
            controller.caseId = clinicalCase.caseId
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let controller = CaseUpdatesViewController(clinicalCase: clinicalCase, user: user)
        controller.controllerIsPushed = true
        //displayState = .others
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backItem
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        self.navigationController?.delegate = zoomTransitioning
        //displayState = .photo
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .clear
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, type: .group, collectionViewFlowLayout: layout)
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension GroupPageViewController: CommentCaseViewControllerDelegate {
    func didDeleteCaseComment(clinicalCase: Case, comment: Comment) {
        didDeleteComment(forCase: clinicalCase)
    }
    
    func didCommentCase(clinicalCase: Case, user: User, comment: Comment) {
        if let caseIndex = cases.firstIndex (where: { $0.caseId == clinicalCase.caseId } ) {
            cases[caseIndex].numberOfComments += 1
            
            var indexPath = IndexPath()
            if contentIndexSelected == .all {
                if let index = content.firstIndex(where: { $0.id == clinicalCase.caseId }) {
                    indexPath = IndexPath(item: index, section: 1)
                } else { return }
                
            } else {
                indexPath = IndexPath(item: caseIndex, section: 1)
            }
            
            switch clinicalCase.type {
            case .text:
                let cell = collectionView.cellForItem(at: indexPath) as! CaseTextCell
                cell.viewModel?.clinicalCase.numberOfComments += 1
                
            case .textWithImage:
                let cell = collectionView.cellForItem(at: indexPath) as! CaseTextImageCell
                cell.viewModel?.clinicalCase.numberOfComments += 1
            }
        }
    }
}

extension GroupPageViewController: DetailsCaseViewControllerDelegate {
    func didDeleteComment(forCase clinicalCase: Case) {
        var indexPath = IndexPath()
        if contentIndexSelected == .all {
            if let index = content.firstIndex(where: { $0.id == clinicalCase.caseId }) {
                indexPath = IndexPath(item: index, section: 1)
                if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                    cases[caseIndex].numberOfComments -= 1
                } else { return }
            } else { return }
        } else {
            if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                cases[index].numberOfComments -= 1
                indexPath = IndexPath(item: index, section: 1)
            } else { return }
        }
        
        switch clinicalCase.type {
        case .text:
            let cell = collectionView.cellForItem(at: indexPath) as! CaseTextCell
            cell.viewModel?.clinicalCase.numberOfComments += 1
        case .textWithImage:
            let cell = collectionView.cellForItem(at: indexPath) as! CaseTextImageCell
            cell.viewModel?.clinicalCase.numberOfComments += 1
        }
    }
    
    func didTapLikeAction(forCase clinicalCase: Case) {
        var indexPath = IndexPath()
        if contentIndexSelected == .all {
            if let index = content.firstIndex(where: { $0.id == clinicalCase.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) {
                    self.clinicalCase(cell, didLike: clinicalCase)
                }
            } else { return }
        } else {
            if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                indexPath = IndexPath(item: index, section: 1)
                if let cell = collectionView.cellForItem(at: indexPath) {
                    self.clinicalCase(cell, didLike: clinicalCase)
                }
            } else { return }
        }
    }
    
    func didTapBookmarkAction(forCase clinicalCase: Case) {
        var indexPath = IndexPath()
        if contentIndexSelected == .all {
            if let index = content.firstIndex(where: { $0.id == clinicalCase.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) {
                    self.clinicalCase(cell, didBookmark: clinicalCase)
                }
            } else { return }

        } else {
            if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                indexPath = IndexPath(item: index, section: 1)
                if let cell = collectionView.cellForItem(at: indexPath) {
                    self.clinicalCase(cell, didBookmark: clinicalCase)
                }
            } else { return }
        }
    }
    
    func didComment(forCase clinicalCase: Case) {
        var indexPath = IndexPath()
        if contentIndexSelected == .all {
            if let index = content.firstIndex(where: { $0.id == clinicalCase.caseId }) {
                indexPath = IndexPath(item: index, section: 1)
                if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                    cases[caseIndex].numberOfComments += 1
                } else { return }
            } else { return }
        } else {
            if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                cases[index].numberOfComments += 1
                indexPath = IndexPath(item: index, section: 1)
            } else { return }
        }
        
        switch clinicalCase.type {
        case .text:
            let cell = collectionView.cellForItem(at: indexPath) as! CaseTextCell
            cell.viewModel?.clinicalCase.numberOfComments += 1
        case .textWithImage:
            let cell = collectionView.cellForItem(at: indexPath) as! CaseTextImageCell
            cell.viewModel?.clinicalCase.numberOfComments += 1
        }
    }
    
    func didAddUpdate(forCase clinicalCase: Case) {
        // cases[index].caseUpdates = clinicalCase.caseUpdates
        if contentIndexSelected == .all {
            if let index = content.firstIndex(where: { $0.id == clinicalCase.caseId }) {
                if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                    cases[caseIndex].caseUpdates = clinicalCase.caseUpdates
                    collectionView.reloadItems(at: [IndexPath(item: index, section: 1)])
                } else { return }
            } else { return }
        } else {
            if let index = cases.firstIndex(where: { $0.groupId == clinicalCase.caseId }) {
                cases[index].caseUpdates = clinicalCase.caseUpdates
                collectionView.reloadItems(at: [IndexPath(item: index, section: 1)])
            } else { return }
        }
    }
    
    func didAddDiagnosis(forCase clinicalCase: Case) {

        if contentIndexSelected == .all {
            if let index = content.firstIndex(where: { $0.id == clinicalCase.caseId }) {
                let indexPath = IndexPath(item: index, section: 1)
                if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                    cases[caseIndex].diagnosis = clinicalCase.diagnosis
                    cases[caseIndex].stage = .resolved
                    collectionView.reloadItems(at: [indexPath])
                } else { return }
            } else { return }
        } else {
            if let index = cases.firstIndex(where: { $0.groupId == clinicalCase.caseId }) {
                cases[index].diagnosis = clinicalCase.diagnosis
                cases[index].stage = .resolved
                collectionView.reloadItems(at: [IndexPath(item: index, section: 1)])
            } else { return }
        }
    }
}

extension GroupPageViewController: CaseDiagnosisViewControllerDelegate {
    func handleAddDiagnosis(_ text: String, caseId: String) {
        // just search the case and add
        if contentIndexSelected == .all {
            if let index = content.firstIndex(where: { $0.id == caseId }) {
                let indexPath = IndexPath(item: index, section: 1)
                if let caseIndex = cases.firstIndex(where: { $0.caseId == caseId }) {
                    cases[caseIndex].diagnosis = text
                    cases[caseIndex].stage = .resolved
                    collectionView.reloadItems(at: [indexPath])
                } else { return }
            } else { return }
        } else {
            if let index = cases.firstIndex(where: { $0.groupId == caseId }) {
                cases[index].diagnosis = text
                cases[index].stage = .resolved
                collectionView.reloadItems(at: [IndexPath(item: index, section: 1)])
            } else { return }
        }
    }
}

extension GroupPageViewController: CaseUpdatesViewControllerDelegate {
    func didAddUpdateToCase(withUpdates updates: [String], caseId: String) {
        // just search the case and add
        if contentIndexSelected == .all {
            if let index = content.firstIndex(where: { $0.id == caseId }) {
                if let caseIndex = cases.firstIndex(where: { $0.caseId == caseId }) {
                    cases[caseIndex].caseUpdates = updates
                    collectionView.reloadItems(at: [IndexPath(item: index, section: 1)])
                } else { return }
            } else { return }
        } else {
            if let index = cases.firstIndex(where: { $0.groupId == caseId }) {
                cases[index].caseUpdates = updates
                collectionView.reloadItems(at: [IndexPath(item: index, section: 1)])
            } else { return }
        }
    }
}

extension GroupPageViewController: EmptyGroupCellDelegate {
    func didTapDiscoverGroup() {
        navigationController?.popViewController(animated: true)
    }
}

extension GroupPageViewController: MEStretchyHeaderDelegate {
    func didTapBanner() {
        let controller = ProfileImageViewController(isBanner: true)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            if let bannerUrl = self.group.bannerUrl, bannerUrl != "" {
                controller.profileImageView.sd_setImage(with: URL(string: bannerUrl))
            }
        }
        
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true)
    }
}

extension GroupPageViewController: MEReferenceMenuLauncherDelegate {
    func didTapReference(reference: Reference) {
        switch reference.option {
        case .link:
            if let url = URL(string: reference.referenceText) {
                if UIApplication.shared.canOpenURL(url) {
                    let webViewController = WebViewController(url: url)
                    let navVC = UINavigationController(rootViewController: webViewController)
                    present(navVC, animated: true, completion: nil)
                }
            }
        case .citation:
            let wordToSearch = reference.referenceText
            if let encodedQuery = wordToSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
                    let webViewController = WebViewController(url: url)
                    let navVC = UINavigationController(rootViewController: webViewController)
                    present(navVC, animated: true, completion: nil)
                }
            }
        }
    }
}




