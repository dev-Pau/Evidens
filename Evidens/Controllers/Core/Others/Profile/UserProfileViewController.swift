//
//  UserProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/5/22.
//

import UIKit

private let profileHeaderReuseIdentifier = "ProfileHeaderReuseIdentifier"
private let test = "testIdentifier"

class UserProfileViewController: UIViewController {
    

    //MARK: - Properties
    private var user: User
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        return tableView
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItemButton()
        configureTableView()
        configureUI()
    }
    
    // Initialize the controller with a User
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configureNavigationItemButton() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                                            style: .plain,
                                                            target: self, action: #selector(didTapSettings))
        
        navigationItem.rightBarButtonItem?.tintColor = blackColor
        
        navigationItem.titleView = searchBar
        
        guard let firstName = user.firstName, let lastName = user.lastName else { return }
        
        searchBar.text = ("\(firstName ) \(lastName)")
        searchBar.searchTextField.clearButtonMode = .never
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserProfileHeader.self, forHeaderFooterViewReuseIdentifier: profileHeaderReuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: test)
    }
    
    func configureUI() {
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    
    //MARK: - API
    
    //MARK: - Actions
    @objc func didTapSettings() {
        
    }
}

extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: profileHeaderReuseIdentifier) as! UserProfileHeader
            header.viewModel = ProfileHeaderViewModel(user: user)
            header.delegate = self
            return header
        } else {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: profileHeaderReuseIdentifier) as! UserProfileHeader
            header.viewModel = ProfileHeaderViewModel(user: user)
            return header
        }


    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 410
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return 5
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: test, for: indexPath)
        cell.backgroundColor = .white
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

//MARK: - UserProfileHeaderDelegate

extension UserProfileViewController: UserProfileHeaderDelegate {
    
    func header(_ userProfileHeader: UserProfileHeader, didTapProfilePictureFor user: User) {
        
        let controller = ProfileImageViewController(user: user)
        controller.hidesBottomBarWhenPushed = true
        
        if user.isCurrentUser {
            DispatchQueue.main.async {
                controller.profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
                controller.modalPresentationStyle = .overFullScreen
                self.present(controller, animated: true)
            }
        } else {
            print("Is not current user")
        }
    }
}
