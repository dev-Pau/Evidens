//
//  GroupAdminsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/1/23.
//

import UIKit

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let userCellReuseIdentifier = "UserCellReuseIdentifier"
private let searchHeaderReuseIdentifier = "SearchHeaderReuseIdentifier"

class GroupAdminsViewController: UIViewController {
    
    private var group: Group
    
    private var users = [User]()
    private var groupMembers = [UserGroup]()
    private let userMemberType: Group.MemberType
    
    private var loaded: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    init(group: Group, userMemberType: Group.MemberType) {
        self.group = group
        self.userMemberType = userMemberType
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
        title = "Administrators"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
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
                self.collectionView.reloadData()
            }
        }
    }
}

extension GroupAdminsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loaded ? users.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellReuseIdentifier, for: indexPath) as! AdminUserManagementCell
        cell.user = users[indexPath.row]
        cell.delegate = self
        let userIndex = groupMembers.firstIndex { user in
            if user.uid == users[indexPath.row].uid {
                return true
            }
            
            return false
        }
        
        if let userIndex = userIndex { cell.configureMemberType(currentUserType: userMemberType, type: groupMembers[userIndex].memberType) }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if !loaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath)
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
            return header
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 55)
    }
}

extension GroupAdminsViewController: AdminUserManagementCellDelegate {

    func handleRemoveAdminPermissions(_ cell: UICollectionViewCell, user: User) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        
        displayMEDestructiveAlert(withTitle: "Remove admin permissions", withMessage: "\(user.firstName!) will no longer have admin permissions but will still be a member of the group", withCancelButtonText: "Cancel", withDoneButtonText: "Remove") {
            // Check number of group owners
            DatabaseManager.shared.getNumberOfOwnersForGroup(groupId: self.group.groupId) { owners in
                guard owners > 1 else {
                    
                    let popUp = METopPopupView(title: "You cannot remove admin permissions since you are the only owner of the group", image: "xmark.circle.fill", popUpType: .destructive)
                    popUp.showTopPopup(inView: self.view)
                    return
                    
                }
                
                // Remove admin permission for user
#warning("Needs to be checked that it works, the upper part already works the guard owners > 1")
                DatabaseManager.shared.removeAdminPermissions(groupId: self.group.groupId, uid: user.uid!) { removed in
                    if removed {
                        let memberIndex = self.groupMembers.firstIndex { member in
                            if member.uid == user.uid {
                                return true
                            }
                            return false
                        }
                        
                        if let memberIndex = memberIndex {
                            self.collectionView.performBatchUpdates {
                                self.groupMembers.remove(at: memberIndex)
                                self.users.remove(at: indexPath.row)
                                self.collectionView.deleteItems(at: [indexPath])
                            }
                        }
                        
                        let popUp = METopPopupView(title: "Admin permissions successfully removed to \(user.firstName!)", image: "checkmark.circle.fill", popUpType: .regular)
                        popUp.showTopPopup(inView: self.view)
                        return
                    }
                }
            }
        }
    }
    
    func handleReportUser(user: User) {
        let reportPopup = METopPopupView(title: "\(user.firstName!) has been reported", image: "flag.fill", popUpType: .destructive)
        reportPopup.showTopPopup(inView: self.view)
        return
    }
    
    func handlePromoteToOwner(user: User) {
#warning("Needs to be checked that it works")
        print("promote to owner")
        DatabaseManager.shared.getNumberOfOwnersForGroup(groupId: group.groupId) { owners in
            guard owners < 5 else {
                // Group already has max number of owners
                let popUp = METopPopupView(title: "Maximum number of group owners reached.", image: "xmark.circle.fill", popUpType: .destructive)
                popUp.showTopPopup(inView: self.view)
                return
            }
            
            // Update user role to owner
            DatabaseManager.shared.promoteToOwner(groupId: self.group.groupId, uid: user.uid!) { promoted in
                if promoted {
                    // Update memberType for user
                    let memberIndex = self.groupMembers.firstIndex { member in
                        if member.uid == user.uid {
                            return true
                        }
                        return false
                    }
                    
                    if let memberIndex = memberIndex {
                        self.groupMembers[memberIndex].memberType = .owner
                        self.collectionView.reloadData()
                        
                        let popUp = METopPopupView(title: "\(user.firstName!) is now a new owner of this group", image: "checkmark.circle.fill", popUpType: .regular)
                        popUp.showTopPopup(inView: self.view)
                    }
                }
            }
        }
    }
    
    func handleBlockUser(_ cell: UICollectionViewCell, user: User) {
        print("block user")
        #warning("Needs to be checked that it works")
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        DatabaseManager.shared.blockUser(groupId: group.groupId, uid: user.uid!) { blocked in
            if blocked {
                let memberIndex = self.groupMembers.firstIndex { member in
                    if member.uid == user.uid {
                        return true
                    }
                    return false
                }
                
                if let memberIndex = memberIndex {
                    self.collectionView.performBatchUpdates {
                        self.groupMembers.remove(at: memberIndex)
                        self.users.remove(at: indexPath.row)
                        self.collectionView.deleteItems(at: [indexPath])
                        
                        let popUp = METopPopupView(title: "\(user.firstName!) has been successfully blocked from this group", image: "checkmark.circle.fill", popUpType: .regular)
                        popUp.showTopPopup(inView: self.view)
                        return
                    }
                }
            }
        }
    }
}
