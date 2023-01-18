//
//  GroupRequestsCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/1/23.
//

import UIKit

private let skeletonFollowersFollowingCell = "SkeletonFollowersFollowingCell"
private let emptyCellReuseIdentifier = "EmptyCellReuseIdentifier"
private let pendingUserCellReuseIdentifier = "PendingUserCellReuseIdentifier"


protocol GroupRequestCellDelegate: AnyObject {
    //func handleAcceptUser(user: User)
    //func handleIgnoreUser(user: User)
    func didTapEmptyCellButton()
    func didTapUser(user: User)
}
 

class GroupRequestCell: UICollectionViewCell {
    
    var group: Group? {
        didSet {
            fetchGroupUserRequests()
        }
    }
    
    weak var delegate: GroupRequestCellDelegate?
    
    private var users = [User]()
    
    private var loaded: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
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
            if pendingUsers.isEmpty {
                self.collectionView.isScrollEnabled = true
                self.collectionView.reloadData()
            }
            let pendingUserUids = pendingUsers.map({ $0.uid })
            UserService.fetchUsers(withUids: pendingUserUids) { users in
                self.users = users
                self.loaded = true
                self.collectionView.isScrollEnabled = true
                self.collectionView.reloadData()
            }
        }
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        addSubview(collectionView)
        collectionView.frame = bounds
        collectionView.register(GroupUserRequestCell.self, forCellWithReuseIdentifier: pendingUserCellReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        //collectionView.register(SkeletonFollowersFollowingCell.self, forCellWithReuseIdentifier: skeletonFollowersFollowingCell)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension GroupRequestCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.isEmpty ? 1 : users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        /*
        if !loaded {
            let cell = tableView.dequeueReusableCell(withIdentifier: skeletonFollowersFollowingCell, for: indexPath) as! SkeletonFollowersFollowingCell
            return cell
        }
         */
        
        if users.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: nil, title: "No active requests", description: "Check back for all new requests.", buttonText: "  Go to group  ")
            cell.delegate = self
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pendingUserCellReuseIdentifier, for: indexPath) as! GroupUserRequestCell
        cell.user = users[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if users.isEmpty { return }
        let user = users[indexPath.row]
        delegate?.didTapUser(user: user)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if users.isEmpty { return CGSize(width: UIScreen.main.bounds.width, height: self.collectionView.frame.size.height * 0.9 - 51)}
        return CGSize(width: UIScreen.main.bounds.width, height: 65)
    }
}

extension GroupRequestCell: GroupUserRequestCellDelegate {
    func didTapAccept(user: User) {
        guard let group = group else { return }
        let userIndex = users.firstIndex { arrayUser in
            if user.uid == arrayUser.uid {
                return true
            }
            
            return false
        }
        
        guard let userIndex = userIndex else { return }
        
        DatabaseManager.shared.acceptUserRequestToGroup(groupId: group.groupId, uid: user.uid!) { accepted in
            self.collectionView.performBatchUpdates {
                self.users.remove(at: userIndex)
                self.collectionView.deleteItems(at: [IndexPath(item: userIndex, section: 0)])
            }
        }
        
        //delegate?.handleAcceptUser(user: user)
    }
    
    func didTapIgnore(user: User) {
        guard let group = group else { return }
        let userIndex = users.firstIndex { arrayUser in
            if user.uid == arrayUser.uid {
                return true
            }
            
            return false
        }
        
        guard let userIndex = userIndex else { return }
        
        DatabaseManager.shared.ignoreUserRequestToGroup(groupId: group.groupId, uid: user.uid!) { ignored in
            if ignored {
                
                self.collectionView.performBatchUpdates {
                    self.users.remove(at: userIndex)
                    self.collectionView.deleteItems(at: [IndexPath(item: userIndex, section: 0)])
                }
            }
        }
        #warning("Delegate per després mostrar una alerta a l'usuari")
        //delegate?.handleAcceptUser(user: user)
    }
}

extension GroupRequestCell: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton() {
        delegate?.didTapEmptyCellButton()
    }
}
