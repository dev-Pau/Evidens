//
//  GroupMembersViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/12/22.
//

import UIKit

private let groupMemberCellReuseIdentifier = "GroupMemberCellReuseIdentifier"

class GroupMembersViewController: UIViewController {
    
    private let members: String
    private let group: Group
    
    private var users = [User]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        fetchGroupUsers()
    }
    
    init(members: String, group: Group) {
        self.members = members
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = members
    }
    
    private func fetchGroupUsers() {
        DatabaseManager.shared.fetchGroupUsers(forGroupId: group.groupId) { uids in
            UserService.fetchUsers(withUids: uids) { users in
                self.users = users
                self.tableView.reloadData()
            }
        }
    }
    
    private func configureTableView() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(HomeLikesCell.self, forCellReuseIdentifier: groupMemberCellReuseIdentifier)
    }
}

extension GroupMembersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: groupMemberCellReuseIdentifier, for: indexPath) as! HomeLikesCell
        cell.selectionStyle = .none
        cell.user = users[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = UserProfileViewController(user: users[indexPath.row])
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .black
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}
