//
//  FollowersFollowingCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/10/22.
//

import UIKit

private let followersFollowingReuseIdentifier = "FollowersFollowingReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let skeletonFollowersFollowingCell = "SkeletonFollowersFollowingReuseIdentifier"

class FollowersCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    weak var delegate: FollowingFollowerCellDelegate?

    var user: User? {
        didSet {
            fetchFollowerUsers()
        }
    }
    
    var loaded: Bool = false
    
    private var users = [User]()
    private var userIsFollowing = [UserFollow]()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .grouped)
        return tableView
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 74
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        tableView.register(UsersFollowFollowingCell.self, forCellReuseIdentifier: followersFollowingReuseIdentifier)
        tableView.register(EmptyContentCell.self, forCellReuseIdentifier: emptyContentCellReuseIdentifier)
        tableView.register(SkeletonFollowersFollowingCell.self, forCellReuseIdentifier: skeletonFollowersFollowingCell)
        addSubview(tableView)
        tableView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    //MARK: - Actions
    
    //MARK: - API
    
    // Fetch top users based on current user search
    func fetchFollowerUsers() {
        guard let user = user else { return }

        UserService.fetchFollowers(forUid: user.uid!, completion: { uids in
            uids.forEach { uid in
                
                UserService.fetchUser(withUid: uid!) { user in
                    self.users.append(user)
                    
                    UserService.checkIfUserIsFollowed(uid: uid!) { followed in
                        self.userIsFollowing.append(UserFollow(dictionary: ["uid": uid, "isFollow": followed]))
                        if self.userIsFollowing.count == uids.count {
                            self.loaded = true
                            self.tableView.isScrollEnabled = true
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        })
    }
}

extension FollowersCell: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !loaded { return 15 }
        return users.count > 0 ? users.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !loaded {
            let cell = tableView.dequeueReusableCell(withIdentifier: skeletonFollowersFollowingCell, for: indexPath) as! SkeletonFollowersFollowingCell
            return cell
        }
        
        if users.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyContentCell
            cell.selectionStyle = .none
            cell.set(title: "This user does not have any follower", description: "Be the first to follow!")
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: followersFollowingReuseIdentifier, for: indexPath) as! UsersFollowFollowingCell
        cell.user = users[indexPath.row]
        
        let userIndex = users.firstIndex { user in
            if user.uid == userIsFollowing[indexPath.row].uid {
                return true
            }
            return false
        }
        
        if let userIndex = userIndex {
            cell.userIsFollowing = userIsFollowing[userIndex].isFollow
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didTapUser(users[indexPath.row])
    }
}
