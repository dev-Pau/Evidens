//
//  FollowingCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/10/22.
//
import UIKit

private let followersFollowingReuseIdentifier = "FollowersFollowingReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let skeletonFollowersFollowingCell = "SkeletonFollowersFollowingReuseIdentifier"

protocol FollowingFollowerCellDelegate: AnyObject {
    func didTapUser(_ user: User)
}

class FollowingCell: UICollectionViewCell {
    
    //MARK: - Properties

    var user: User? {
        didSet {
            fetchFollowingUsers()
        }
    }
    
    weak var delegate: FollowingFollowerCellDelegate?
    
    private var users = [User]()
    private var userIsFollowing = [Bool]()
    
    var loaded: Bool = false
    
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
        tableView.backgroundColor = .systemBackground
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
    func fetchFollowingUsers() {
        guard let user = user else { return }

        UserService.fetchFollowing(forUid: user.uid!, completion: { uids in
            uids.forEach { uid in
                
                UserService.fetchUser(withUid: uid) { user in
                    self.users.append(user)
                    
                    UserService.checkIfUserIsFollowed(uid: uid) { followed in
                        self.userIsFollowing.append(followed)
                        if self.userIsFollowing.count == uids.count {
                            self.tableView.isScrollEnabled = true
                            self.loaded = true
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        })
    }
}

extension FollowingCell: UITableViewDataSource, UITableViewDelegate {
    
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
            cell.set(title: "This user is not following anyone", description: "What about trying to get a follow?")
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: followersFollowingReuseIdentifier, for: indexPath) as! UsersFollowFollowingCell
        cell.user = users[indexPath.row]
        cell.userIsFollowing = userIsFollowing[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didTapUser(users[indexPath.row])
    }
}
