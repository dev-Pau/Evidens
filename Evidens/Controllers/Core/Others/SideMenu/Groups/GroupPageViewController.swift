//
//  GroupPageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/11/22.
//

import UIKit

private let groupHeaderReuseIdentifier = "GroupHeaderReuseIdentifier"
private let groupContentCreationReuseIdentifier = "GroupContentCreationReuseIdentifier"


private let groupContentSelectionReuseIdentifier = "GroupContentSelectionReuseIdentifier"
private let groupContentCollectionViewReuseIdentifier = "GroupContentCollectionViewReuseIdentifier"

private let groupContentAdminReuseIdentifier = "GroupContentAdminReuseIdentifier"
private let groupContentHeaderReuseIdentifier = "GroupContentHeaderReuseIdentifier"

private let groupContentDescriptionReuseIdentifier = "GroupContentDescriptionReuseIdentifier"

private let emptyGroupContentCellReuseIdentifier = "EmptyGroupContentCellReuseIdentifier"

protocol GroupPageViewControllerDelegate: AnyObject {
    func didUpdateGroup(_ group: Group)
}

class GroupPageViewController: UIViewController {
    
    weak var delegate: GroupPageViewControllerDelegate?
    
    private var collectionView: UICollectionView!
    
    private var group: Group
    private var members: [User]?
    
    private var adminUserRoles = [UserGroup]()
    private var adminUsers = [User]()
    
    private var contentIndexSelected: ContentGroup.ContentTopics = .all
    private var content = [ContentGroup]()
    private var posts = [Post]()
    private var cases = [Case]()
    
    private var loaded: Bool = false
    
    private var memberType: Group.MemberType?
    
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        //searchBar.searchTextField.tintColor = primaryColor
        //searchBar.searchTextField.backgroundColor = lightColor
        return searchBar
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
            guard memberType != .pending else { return }
            // User is from group, fetch group users
            fetchGroupUsers()
            fetchGroupContent()
        } else {
            // User comes from discover tab or might be pending. Fetch user member type.
            fetchUserMemberType()
            
        }

        #warning("Falta fer una funció per veure el rol de lusuari quan vé de discover group per fer collectionvoiew.ishidden = false i també per fer searchbar user interaction enabled = true quan el trobi")
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
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
            if memberType == .external || memberType == .pending {
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
            } else { return }
        }
    }
    
    private func configureNavigationBar() {

        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchBarContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8).isActive = true
        
        navigationItem.titleView = searchBarContainer
        
        searchBar.delegate = self
    }
    
    private func configureSearchBar() {
        //let atrString = NSAttributedString(string: "Search content in \(group.name)", attributes: [.font : UIFont.systemFont(ofSize: 15)])
        //searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.placeholder = "Search content in \(group.name)"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground

    }
    
    private func fetchGroupUsers() {
        DatabaseManager.shared.fetchFirstGroupUsers(forGroupId: group.groupId) { uids in
            UserService.fetchUsers(withUids: uids) { users in
                self.members = users
                self.collectionView.reloadItems(at: [IndexPath(row: 0, section: 0)])
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
                return
            }
            
            // If there's content, check content type and fetch accordingly
            contentGroup.forEach { content in
                if content.type == .post {
                    PostService.fetchPost(withPostId: content.id) { post in
                        
                    }
                } else {
                    CaseService.fetchCase(withCaseId: content.id) { clinicalCase in
                        
                    }
                }
                
                // Check if all content is fetched
                if contentGroup.count == self.cases.count + self.posts.count {
                    // loaded !!
                    // dismiss the skeleton view
                    // reload data
                }
            }
        }
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground

        if memberType == nil { collectionView.isHidden = true }
        
        view.addSubview(collectionView)

        collectionView.register(GroupPageHeaderCell.self, forCellWithReuseIdentifier: groupHeaderReuseIdentifier)
        collectionView.register(GroupContentCreationCell.self, forCellWithReuseIdentifier: groupContentCreationReuseIdentifier)
        
        collectionView.register(GroupContentSelectionHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: groupContentSelectionReuseIdentifier)
        
        // External users
        collectionView.register(GroupAdminCell.self, forCellWithReuseIdentifier: groupContentAdminReuseIdentifier)
        collectionView.register(GroupAboutHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: groupContentHeaderReuseIdentifier)
        
        collectionView.register(UserProfileAboutCell.self, forCellWithReuseIdentifier: groupContentDescriptionReuseIdentifier)
        
        // Content cells
        collectionView.register(EmptyGroupCell.self, forCellWithReuseIdentifier: emptyGroupContentCellReuseIdentifier)
        
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: groupContentCollectionViewReuseIdentifier)
        //collectionView.register(UserProfileTitleHeader.self, forCellWithReuseIdentifier: profileHeaderTitleReuseIdentifier)
        
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            if sectionNumber == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)), subitems: [item])
                group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0), top: .fixed(0), trailing: .fixed(0), bottom: .fixed(5))
                let section = NSCollectionLayoutSection(group: group)
                return section
            } else {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                header.pinToVisibleBounds = true
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(65)), subitems: [item])
                group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0), top: .fixed(0), trailing: .fixed(0), bottom: .fixed(5))
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [header]
                return section
            }

        }
        
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        return layout
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
            return (memberType == .external || memberType == .pending) ? 1 : 10
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
                switch contentIndexSelected {
                    
                case .all:
                    break
                case .cases:
                    break
                case .posts:
                    break
                }
                 
                if !loaded {
                    // Skeleton
                    
                }
                
                // There's still no content in the group
                if content.isEmpty {
                    
                }
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupContentCollectionViewReuseIdentifier, for: indexPath)
                cell.backgroundColor = .red
                return cell
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
        }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if memberType == .external || memberType == .pending {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: groupContentHeaderReuseIdentifier, for: indexPath) as! GroupAboutHeader
            if indexPath.section == 1 {
                header.set(title: "Description")
            } else {
                header.set(title: "Admin Team")
            }

            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: groupContentSelectionReuseIdentifier, for: indexPath) as! GroupContentSelectionHeader
            return header
        }

    }
}

extension GroupPageViewController: GroupPageHeaderCellDelegate {
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
    func didUpdateGroup(_ group: Group) {
        self.group = group
        delegate?.didUpdateGroup(group)
        collectionView.reloadData()
    }
}
