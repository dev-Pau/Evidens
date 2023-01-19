//
//  GroupAdminsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/1/23.
//

import UIKit

private let skeletonCellReuseIdentifier = "SkeletonCellReuseIdentifier"
private let userCellReuseIdentifier = "UserCellReuseIdentifier"
private let searchHeaderReuseIdentifier = "SearchHeaderReuseIdentifier"

class GroupAdminsViewController: UIViewController {
    
    private var group: Group
    
    private var users = [User]()
    private var groupMembers = [UserGroup]()
    
    private var loaded: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    init(group: Group) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        fetchAdminTeam()
    }
    
    private func configureNavigationBar() {
        title = "Admins"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserGroupSkeletonCell.self, forCellWithReuseIdentifier: skeletonCellReuseIdentifier)
        collectionView.register(AdminUserManagementCell.self, forCellWithReuseIdentifier: userCellReuseIdentifier)
        collectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
    }
    
    private func fetchAdminTeam() {
        DatabaseManager.shared.fetchGroupAdminTeamRoles(groupId: group.groupId) { admins in
            self.groupMembers = admins
            let adminUids = admins.map({ $0.uid })
            UserService.fetchUsers(withUids: adminUids) { users in
                self.users = users
                self.loaded = true
                self.collectionView.isScrollEnabled = true
                self.collectionView.reloadData()
            }
        }
    }
}

extension GroupAdminsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loaded ? users.count : 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !loaded {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: skeletonCellReuseIdentifier, for: indexPath) as! UserGroupSkeletonCell
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellReuseIdentifier, for: indexPath) as! AdminUserManagementCell
        cell.user = users[indexPath.row]
        
        let userIndex = groupMembers.firstIndex { user in
            if user.uid == users[indexPath.row].uid {
                return true
            }
            
            return false
        }
        
        if let userIndex = userIndex { cell.configureMemberType(type: groupMembers[userIndex].memberType) }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return loaded ? CGSize(width: UIScreen.main.bounds.width, height: 65) : CGSize(width: UIScreen.main.bounds.width, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return loaded ? (users.isEmpty ? CGSize.zero : CGSize(width: UIScreen.main.bounds.width, height: 55)) : CGSize.zero
    }
}
