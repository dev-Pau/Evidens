//
//  UserProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/5/22.
//

import UIKit

private let profileHeaderReuseIdentifier = "ProfileHeaderReuseIdentifier"
private let test = "testIdentifier"

class UserProfileViewController: UICollectionViewController {
    

    //MARK: - Properties
    private var user: User
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItemButton()
        configureCollectionView()
    }
        
    init(user: User) {
        self.user = user
        
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            if sectionNumber == 0 {
                // Profile Header
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(400)))
                //item.contentInsets.bottom = 16
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(400)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
                return section
            } else {
                // About section
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(50), heightDimension: .absolute(50)))
                //item.contentInsets.bottom = 16
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                //section.orthogonalScrollingBehavior = .continuous
                //section.interGroupSpacing = 10
                //section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
                return section
            }
            
        }

        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configureNavigationItemButton() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                                            style: .plain,
                                                            target: self, action: #selector(didTapSettings))
        
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        navigationItem.titleView = searchBar
        
        guard let firstName = user.firstName, let lastName = user.lastName else { return }
        
        searchBar.text = ("\(firstName ) \(lastName)")
        searchBar.searchTextField.clearButtonMode = .never
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = lightGrayColor
        collectionView.register(UserProfileHeaderCell.self, forCellWithReuseIdentifier: profileHeaderReuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: test)
        
        //tableView.register(UserProfileHeader.self, forHeaderFooterViewReuseIdentifier: profileHeaderReuseIdentifier)
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: test)
    }
    
    
    //MARK: - API
    
    //MARK: - Actions
    @objc func didTapSettings() {
        
    }
}

extension UserProfileViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileHeaderReuseIdentifier, for: indexPath) as! UserProfileHeaderCell
            cell.viewModel = ProfileHeaderViewModel(user: user)
            cell.backgroundColor = .systemCyan
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileHeaderReuseIdentifier, for: indexPath) as! UserProfileHeaderCell
            cell.viewModel = ProfileHeaderViewModel(user: user)
            cell.backgroundColor = .systemCyan
            return cell
        }
        
    }
}



/*
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
 */
