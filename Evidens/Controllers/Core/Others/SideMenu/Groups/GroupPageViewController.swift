//
//  GroupPageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/11/22.
//

import UIKit

private let stretchyHeaderReuseIdentifier = "StretchyHeaderReuseIdentifier"
private let groupHeaderReuseIdentifier = "GroupHeaderReuseIdentifier"
private let groupContentCreationReuseIdentifier = "GroupContentCreationReuseIdentifier"

private let groupContentSelectionReuseIdentifier = "GroupContentSelectionReuseIdentifier"
private let groupContentCollectionViewReuseIdentifier = "GroupContentCollectionViewReuseIdentifier"

private let groupContentAdminReuseIdentifier = "GroupContentAdminReuseIdentifier"
private let groupContentHeaderReuseIdentifier = "GroupContentHeaderReuseIdentifier"

private let groupContentDescriptionReuseIdentifier = "GroupContentDescriptionReuseIdentifier"

private let emptyGroupContentCellReuseIdentifier = "EmptyGroupContentCellReuseIdentifier"

private let skeletonTextReuseIdentifier = "SkeletonTextReuseIdentifier"
private let skeletonImageReuseIdentifier = "SkeletonImageReuseIdentifier"

private let homeTextCellReuseIdentifier = "HomeTextCellReuseIdentifier"
private let homeFourImageTextCell = "HomeFourImageTextCell"
private let homeThreeImageTextCell = "HomeThreeImageTextCell"
private let homeTwoImageTextCell = "HomeTwoImageTextCell"
private let homeImageTextCell = "HomeImageTextCell"

private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseImageCellReuseIdentifier = "CaseImageCellReuseIdentifier"

protocol GroupPageViewControllerDelegate: AnyObject {
    func didUpdateGroup(_ group: Group)
}

class GroupPageViewController: UIViewController {
    
    weak var delegate: GroupPageViewControllerDelegate?
    
    private var scrollViewDidScrollHigherThanActionButton: Bool = false
    
    private var standardAppearance = UINavigationBarAppearance()

    private var collectionView: UICollectionView!
   
    private var group: Group
    private var members: [User]?
    
    private var adminUserRoles = [UserGroup]()
    private var adminUsers = [User]()
    
    private var contentIndexSelected: ContentGroup.ContentTopics = .all
    private var content = [ContentGroup]()
    private var posts = [Post]()
    private var cases = [Case]()
    private var users = [User]()
    
    private var loaded: Bool = false
    
    private var memberType: Group.MemberType?
    
    private lazy var customRightButton: UIButton = {
        let button = UIButton()

        button.configuration = .filled()

        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
       
        button.configuration?.cornerStyle = .capsule

        //button.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        return button
    }()
    
    private lazy var groupProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.systemBackground.cgColor
        iv.backgroundColor = .quaternarySystemFill
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
        configureSearchBar()
        configureUI()
        configureCollectionView()
        
        if let memberType = memberType {
            collectionView.isHidden = false
            // User is from group or is pending
            // If user is pending, don't have access to members
            guard memberType != .pending else {
                fetchGroupAdminTeam()
                return
            }
            // User is from group, fetch group users
            fetchGroupUsers()
            fetchGroupContent()
            
            var container = AttributeContainer()
            container.font = .systemFont(ofSize: 15, weight: .bold)
            customRightButton.configuration?.baseBackgroundColor = .systemBackground
            customRightButton.configuration?.baseForegroundColor = .label
            customRightButton.configuration?.background.strokeColor = .quaternarySystemFill
            customRightButton.configuration?.background.strokeWidth = 1
            customRightButton.configuration?.attributedTitle = AttributedString(memberType.buttonText, attributes: container)
            
        } else {
            // User comes from discover tab or might be pending. Fetch user member type.
            fetchUserMemberType()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollViewDidScroll(collectionView)
    }
    
    init(group: Group, memberType: Group.MemberType? = nil) {
        self.group = group
        if let memberType = memberType { self.memberType = memberType }
        /*else {
            #warning("Delete the else statement, aquí si no té member type s'haurà de fer fetch, només és per fer provesUI")
            self.memberType = .external
        }
         */
        
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
                self.customRightButton.configuration?.baseBackgroundColor = .systemBackground
                self.customRightButton.configuration?.baseForegroundColor = .label
                self.customRightButton.configuration?.background.strokeColor = .quaternarySystemFill
                self.customRightButton.configuration?.background.strokeWidth = 1
            }
            
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
            if memberType == .external || memberType == .pending {
                self.fetchGroupAdminTeam()
            } else {
                self.fetchGroupUsers()
                self.fetchGroupContent()
                return
            }
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout()
    }
    
    private func fetchGroupAdminTeam() {
        DatabaseManager.shared.fetchGroupAdminTeamRoles(groupId: self.group.groupId) { adminUserRoles in
            self.adminUserRoles = adminUserRoles
            
            // Get all admin uid's
            let adminUids = adminUserRoles.map { admin in
                return admin.uid
            }
            
            UserService.fetchUsers(withUids: adminUids) { admins in
                self.adminUsers = admins
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxVerticalOffset = (view.frame.width / 3) / 2
        let currentVeritcalOffset = scrollView.contentOffset.y
        groupProfileImageView.frame.origin.y = (view.frame.width / 3 - 35) - currentVeritcalOffset
        let percentageOffset = currentVeritcalOffset / maxVerticalOffset
        standardAppearance.backgroundColor = .systemBackground.withAlphaComponent(percentageOffset)
        navigationController?.navigationBar.standardAppearance = standardAppearance
        
        if currentVeritcalOffset > (view.frame.width / 3 + 40 - topbarHeight) && !scrollViewDidScrollHigherThanActionButton  {
            scrollViewDidScrollHigherThanActionButton.toggle()
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.label).withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(handleBack))
            groupProfileImageView.isHidden = true
            navigationItem.titleView?.isHidden = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customRightButton)
        } else if currentVeritcalOffset < (view.frame.width / 3 + 40 - topbarHeight) && scrollViewDidScrollHigherThanActionButton {
            scrollViewDidScrollHigherThanActionButton.toggle()
            groupProfileImageView.isHidden = false
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
            navigationItem.setRightBarButton(nil, animated: true)
            navigationItem.titleView?.isHidden = true
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
        navigationController?.navigationBar.standardAppearance = standardAppearance
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 3
        imageView.sd_setImage(with: URL(string: group.profileUrl!))
        
        let imageViewContainer = LogoContainerView(imageView: imageView)
        imageViewContainer.frame = CGRect(x: 0, y: 0, width: 30, height: 30)

        navigationItem.titleView = imageViewContainer
        navigationItem.titleView?.isHidden = true
    }
    
    private func configureSearchBar() {
        //let atrString = NSAttributedString(string: "Search content in \(group.name)", attributes: [.font : UIFont.systemFont(ofSize: 15)])
        //searchBar.searchTextField.attributedPlaceholder = atrString
        //searchBar.searchTextField.placeholder = "Search content in \(group.name)"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground

    }
    
    private func fetchGroupUsers() {
        DatabaseManager.shared.fetchFirstGroupUsers(forGroupId: group.groupId) { uids in
            UserService.fetchUsers(withUids: uids) { users in
                self.members = users
                self.collectionView.reloadData()
            }
        }
    }
    
    private func fetchGroupContent() {
        // Fetch the post/cases id's ordered by timestamp
        // For each id obtained, fetch the case or post associated
        // Update collection view
        DatabaseManager.shared.fetchAllGroupContent(withGroupId: group.groupId) { contentGroup in
            self.content = contentGroup
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
                        if contentGroup.count == self.cases.count + self.posts.count {
                            let ownerUids = self.posts.map { $0.ownerUid } + self.cases.map { $0.ownerUid }
                            let ownerUniqueUids = Array(Set(ownerUids))
                            UserService.fetchUsers(withUids: ownerUniqueUids) { users in
                                self.users = users
                                print(self.users)
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
                        if contentGroup.count == self.cases.count + self.posts.count {
                            let ownerUids = self.posts.map { $0.ownerUid } + self.cases.map { $0.ownerUid }
                            let ownerUniqueUids = Array(Set(ownerUids))
                            UserService.fetchUsers(withUids: ownerUniqueUids) { users in
                                self.users = users
                                print(self.users)
                                self.loaded = true
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func fetchGroupCases() {
        DatabaseManager.shared.fetchAllGroupCases(withGroupId: group.groupId) { caseIds in

            caseIds.forEach { id in
                CaseService.fetchGroupCase(withGroupId: self.group.groupId, withCaseId: id) { clinicalCase in
                    self.cases.append(clinicalCase)
                    if caseIds.count == self.cases.count {
                        // Sort cases by timestamp
                        self.cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                        // Obtain all cases owner uids & make the array unique
                        let uniqueOwnerUids = Array(Set(self.cases.map({ $0.ownerUid })))
                        UserService.fetchUsers(withUids: uniqueOwnerUids) { users in
                            self.users = users
                            self.loaded = true
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    private func fetchGroupPosts() {
        DatabaseManager.shared.fetchAllGroupPosts(withGroupId: self.group.groupId) { postIds in
            postIds.forEach { id in
                PostService.fetchGroupPost(withGroupId: self.group.groupId, withPostId: id) { post in
                    self.posts.append(post)
                    if postIds.count == self.posts.count {
                        self.posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                        self.loaded = true
                        self.collectionView.reloadData()
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
            
            groupProfileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.width / 3 - 35 ),
            groupProfileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            groupProfileImageView.widthAnchor.constraint(equalToConstant: 65),
            groupProfileImageView.heightAnchor.constraint(equalToConstant: 65),
        ])
        
        groupProfileImageView.sd_setImage(with: URL(string: group.profileUrl!))
        groupProfileImageView.layer.cornerRadius = 10
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        if memberType == nil { collectionView.isHidden = true }
    
        
        collectionView.register(MEStretchyHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: stretchyHeaderReuseIdentifier)
        collectionView.register(GroupPageHeaderCell.self, forCellWithReuseIdentifier: groupHeaderReuseIdentifier)
        collectionView.register(GroupContentCreationCell.self, forCellWithReuseIdentifier: groupContentCreationReuseIdentifier)
        
        collectionView.register(GroupContentSelectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: groupContentSelectionReuseIdentifier)
        
        // External users
        collectionView.register(GroupAdminCell.self, forCellWithReuseIdentifier: groupContentAdminReuseIdentifier)
        collectionView.register(GroupAboutHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: groupContentHeaderReuseIdentifier)
        
        collectionView.register(UserProfileAboutCell.self, forCellWithReuseIdentifier: groupContentDescriptionReuseIdentifier)
        
        // Content skeleton cells
        collectionView.register(SkeletonTextHomeCell.self, forCellWithReuseIdentifier: skeletonTextReuseIdentifier)
        collectionView.register(SkeletonImageTextHomeCell.self, forCellWithReuseIdentifier: skeletonImageReuseIdentifier)
        
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
    
    private func createLayout() -> StretchyGroupHeaderLayout {
        let layout = StretchyGroupHeaderLayout()
        
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        //layout.sectionHeadersPinToVisibleBounds = true
        //layout.sectionHeadersPinToVisibleBounds = true
        return layout
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleProfileTap() {
        
    }
    
    
    @objc func handleGroupOptions() {
        
    }
}

extension GroupPageViewController: UISearchBarDelegate {
    
}

extension GroupPageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (memberType == .external || memberType == .pending) ? 3 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return (memberType == .external || memberType == .pending) ? 1 : 2
        } else if section == 1 {
            if memberType == .external || memberType == .pending {
                return 1
            } else {
                // Cases & Posts
                if !loaded { return 3 }
                switch contentIndexSelected {
                case .all:
                    return content.isEmpty ? 1 : content.count//loaded ? (content.isEmpty ? 1 : content.count) : 3
                case .cases:
                    return cases.isEmpty ? 1 : cases.count//loaded ? (cases.isEmpty ? 1 : cases.count) : 3  //cases.isEmpty ? 1 :  loaded ? cases.count : 4
                case .posts:
                    return posts.isEmpty ? 1 : posts.count//loaded ? (posts.isEmpty ? 1 : posts.count) : 3 //posts.isEmpty ? 1 : loaded ? posts.count : 4
                }
            }
        } else {
            return adminUserRoles.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupHeaderReuseIdentifier, for: indexPath) as! GroupPageHeaderCell
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
                if !loaded {
                    if indexPath.row == 1 {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: skeletonImageReuseIdentifier, for: indexPath) as! SkeletonImageTextHomeCell
                        return cell
                    } else {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: skeletonTextReuseIdentifier, for: indexPath) as! SkeletonTextHomeCell
                        return cell
                    }
                    
                }
                
                switch contentIndexSelected {
                    
                case .all:
                    if content.isEmpty {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupContentCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                        cell.set(withTitle: "Be the first to share content in this group and get the conversation going.", withDescription: "Create your first post or clinical case")
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
                    if !loaded {
                        if indexPath.row == 1 {
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: skeletonImageReuseIdentifier, for: indexPath) as! SkeletonImageTextHomeCell
                            return cell
                        } else {
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: skeletonTextReuseIdentifier, for: indexPath) as! SkeletonTextHomeCell
                            return cell
                        }
                        
                    }
                    
                    return displayClinicalCaseCell(clinicalCase: cases[indexPath.row], indexPath: indexPath, collectionView: collectionView)
                    
                    
                case .posts:
                    if !loaded {
                        if indexPath.row == 1 {
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: skeletonImageReuseIdentifier, for: indexPath) as! SkeletonImageTextHomeCell
                            return cell
                        } else {
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: skeletonTextReuseIdentifier, for: indexPath) as! SkeletonTextHomeCell
                            return cell
                        }
                        
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
            header.setImageWithStringUrl(imageUrl: group.bannerUrl!)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 { return CGSize(width: view.frame.width, height: view.frame.width / 3) }
        
        return CGSize(width: UIScreen.main.bounds.width, height: 50)
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
            if let userIndex = userIndex { cell.set(user: users[userIndex]) }
            return cell
        case .textWithImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeImageTextCell, for: indexPath) as! HomeImageTextCell
            cell.viewModel = PostViewModel(post: post)
            if let userIndex = userIndex { cell.set(user: users[userIndex]) }
            return cell
        case .textWithTwoImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeTwoImageTextCell, for: indexPath) as! HomeTwoImageTextCell
            cell.viewModel = PostViewModel(post: post)
            if let userIndex = userIndex { cell.set(user: users[userIndex]) }
            return cell
        case .textWithThreeImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeThreeImageTextCell, for: indexPath) as! HomeThreeImageTextCell
            cell.viewModel = PostViewModel(post: post)
            if let userIndex = userIndex { cell.set(user: users[userIndex]) }
            return cell
        case .textWithFourImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFourImageTextCell, for: indexPath) as! HomeFourImageTextCell
            cell.viewModel = PostViewModel(post: post)
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
            if let userIndex = userIndex { cell.set(user: users[userIndex]) }
            return cell
        case .textWithImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
            cell.viewModel = CaseViewModel(clinicalCase: clinicalCase)
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
                    
                    let popUp = METopPopupView(title: "Group request sent", image: "envelope.fill", popUpType: .regular)
                    popUp.showTopPopup(inView: self.view)
                }
            }
        case .invited:
            break
        case .blocked:
            break
        }
    }
    
    func didTapGroupProfilePicture() {
        let controller = ProfileImageViewController(isBanner: false)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            controller.profileImageView.sd_setImage(with: URL(string: self.group.profileUrl!))
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true)
        }
    }
    
    func didTapGroupBannerPicture() {
        let controller = ProfileImageViewController(isBanner: true)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            controller.profileImageView.sd_setImage(with: URL(string: self.group.bannerUrl!))
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true)
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
        
        let controller = ShareClinicalCaseViewController(user: user, group: group)
        
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
                print(contentOffsetY)

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

