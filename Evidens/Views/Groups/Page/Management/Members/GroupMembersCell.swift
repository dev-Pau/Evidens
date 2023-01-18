//
//  GroupMembersCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/1/23.
//

import UIKit

private let emptyGroupMembersCellReuseIdentifier = "EmptyGroupMembersCellReuseIdentifier"
private let groupMembersHeaderReuseIdentifier = "GroupMembersHeaderReuseIdentifier"

class GroupMembersCell: UICollectionViewCell {
    
    var group: Group? {
        didSet {
            fetchGroupMembers()
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
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupMembersCellReuseIdentifier)
        collectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: groupMembersHeaderReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func fetchGroupMembers() {
        
    }
}

extension GroupMembersCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.isEmpty ? 1 : users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if users.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupMembersCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: nil, title: "This group has no members - yet.", description: "Invite your network to join the group", buttonText: "  Invite  ")
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: groupMembersHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return users.isEmpty ? CGSize(width: UIScreen.main.bounds.width, height: self.collectionView.frame.size.height * 0.9 - 51) : CGSize(width: UIScreen.main.bounds.width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return users.isEmpty ? CGSize.zero : CGSize(width: UIScreen.main.bounds.width, height: 55)
    }
}
