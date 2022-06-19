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
    
    private var users: [String]
    
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
    
    init(users: [String]) {
        self.users = users
        super.init(nibName: nil, bundle: nil)
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
        return cell
    }
}
