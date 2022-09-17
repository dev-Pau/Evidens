//
//  PostLikesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/6/22.
//

import UIKit

private let reuseIdentifier = "ReuseIdentifier"

class PostLikesViewController: UIViewController {
    
    //MARK: - Properties
    
    private var post: Post
    
    private var users: [User] = []
    
    private var likesTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        configureUI()
    }
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
        
        PostService.getAllLikesFor(post: post) { uids in
            uids.forEach { uid in
                UserService.fetchUser(withUid: uid) { user in
                    self.users.append(user)
                    self.likesTableView.reloadData()
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        title = "Likes"
    }
    
    private func configureTableView() {
        likesTableView.register(HomeLikesCell.self, forCellReuseIdentifier: reuseIdentifier)
        likesTableView.delegate = self
        likesTableView.dataSource = self
        
        view.addSubview(likesTableView)
        likesTableView.frame = view.bounds
    }
    
    private func configureUI() {
        view.backgroundColor = lightGrayColor
        
    }
    
    //MARK: - Actions
}

extension PostLikesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = likesTableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! HomeLikesCell
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
