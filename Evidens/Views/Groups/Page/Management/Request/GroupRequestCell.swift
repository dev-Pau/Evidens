//
//  GroupRequestsCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/1/23.
//

import UIKit

private let skeletonFollowersFollowingCell = "SkeletonFollowersFollowingCell"
private let pendingUserCellReuseIdentifier = "PendingUserCellReuseIdentifier"

class GroupRequestCell: UICollectionViewCell {
    
    var group: Group? {
        didSet {
            fetchGroupUserRequests()
        }
    }
    
    private var users = [User]()
    
    private var loaded: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 65)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        fetchGroupUserRequests()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
    
    private func fetchGroupUserRequests() {
        guard let group = group else { return }
        DatabaseManager.shared.fetchGroupUserRequests(groupId: group.groupId) { pendingUsers in
            let pendingUserUids = pendingUsers.map({ $0.uid })
            UserService.fetchUsers(withUids: pendingUserUids) { users in
                self.users = users
                self.loaded = true
                self.collectionView.reloadData()
            }
        }
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        addSubview(collectionView)
        collectionView.frame = bounds
        collectionView.register(GroupUserRequestCell.self, forCellWithReuseIdentifier: pendingUserCellReuseIdentifier)
        //collectionView.register(SkeletonFollowersFollowingCell.self, forCellWithReuseIdentifier: skeletonFollowersFollowingCell)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension GroupRequestCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        /*
        if !loaded {
            let cell = tableView.dequeueReusableCell(withIdentifier: skeletonFollowersFollowingCell, for: indexPath) as! SkeletonFollowersFollowingCell
            return cell
        }
         */
        
        if users.isEmpty {
            // empty cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pendingUserCellReuseIdentifier, for: indexPath) as! GroupUserRequestCell
        cell.user = users[indexPath.row]
        return cell
    }
}
