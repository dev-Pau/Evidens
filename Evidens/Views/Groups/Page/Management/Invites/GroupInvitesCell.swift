//
//  GroupInvitesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/1/23.
//

import UIKit

private let emptyGroupMembersCellReuseIdentifier = "EmptyGroupMembersCellReuseIdentifier"
private let groupMembersHeaderReuseIdentifier = "GroupMembersHeaderReuseIdentifier"
private let userGroupSkeletonCellReuseIdentifier = "UserGroupSkeletonnCellReuseIdentifier"
private let groupMemberUserCellReuseIdentifier = "GroupMemberUserCellReuseIdentifier"

class GroupInvitesCell: UICollectionViewCell {
    
    var group: Group? {
        didSet {
            fetchGroupInvites()
        }
    }
    
    weak var delegate: GroupRequestCellDelegate?
    
    private var users = [User]()
    
    private var loaded: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionHeadersPinToVisibleBounds = true
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(collectionView)
        collectionView.frame = bounds
        collectionView.register(UserGroupSkeletonCell.self, forCellWithReuseIdentifier: userGroupSkeletonCellReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupMembersCellReuseIdentifier)
        collectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: groupMembersHeaderReuseIdentifier)
        collectionView.register(GroupMemberUserCell.self, forCellWithReuseIdentifier: groupMemberUserCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func fetchGroupInvites() {
        guard let group = group else { return }
        DatabaseManager.shared.fetchGroupInvites(groupId: group.groupId) { members in
            if members.isEmpty {
                self.loaded = true
                self.collectionView.isScrollEnabled = true
                self.collectionView.reloadData()
                return
            }
            
            let uids = members.map { $0.uid }
            UserService.fetchUsers(withUids: uids) { users in
                self.users = users
                self.loaded = true
                self.collectionView.isScrollEnabled = true
                self.collectionView.reloadData()
            }
        }
    }
}

extension GroupInvitesCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loaded ? (users.isEmpty ? 1 : users.count) : 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !loaded {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userGroupSkeletonCellReuseIdentifier, for: indexPath) as! UserGroupSkeletonCell
            return cell
        }
        
        if users.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupMembersCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: nil, title: "Build your community.", description: "Invite your network to join the group", buttonText: "  Invite  ")
            cell.delegate = self
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupMemberUserCellReuseIdentifier, for: indexPath) as! GroupMemberUserCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: groupMembersHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return loaded ? (users.isEmpty ? CGSize(width: UIScreen.main.bounds.width, height: self.collectionView.frame.size.height * 0.9 - 51) : CGSize(width: UIScreen.main.bounds.width, height: 65)) : CGSize(width: UIScreen.main.bounds.width, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return loaded ? (users.isEmpty ? CGSize.zero : CGSize(width: UIScreen.main.bounds.width, height: 55)) : CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if users.isEmpty || !loaded { return }
        let user = users[indexPath.row]
        delegate?.didTapUser(user: user)
    }
}

extension GroupInvitesCell: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton() {
        delegate?.didTapEmptyCellButton(membershipOption: .invited)
    }
}

