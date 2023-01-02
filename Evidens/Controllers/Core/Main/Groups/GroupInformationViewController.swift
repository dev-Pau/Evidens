//
//  GroupConfigurationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/12/22.
//

import UIKit

private let profileHeaderReuseIdentifier = "ProfileHeaderReuseIdentifier"
private let groupTitleReuseIdentifier = "GroupTitleReuseIdentifier"
private let groupDetailsReuseIdentifier = "GroupDetailsReuseIdentifier"
private let profileAboutReuseIdentifier = "ProfileAboutReuseIdentifier"
private let groupAdminReuseIdentifier = "GroupAdminReuseIdentifier"
private let groupPageCategoriesReuseIdentifier = "GroupPageCategoriesReuseIdentifier"

class GroupInformationViewController: UIViewController {
    
    private let group: Group
    private var users = [User]()
    
    private var collectionView: UICollectionView!
    
    init(group: Group) {
        self.group = group
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        fetchUser()
    }
    
    private func configureNavigationBar() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        if group.ownerUid == uid {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(handleEditGroupTap))
            navigationItem.rightBarButtonItem?.tintColor = grayColor
        }
        
        title = "Group details"
    }
    
    private func configureUI() {
        view.backgroundColor = .white
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.frame = view.bounds
        collectionView.backgroundColor = lightColor
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GroupAboutHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: groupTitleReuseIdentifier)
        collectionView.register(UserProfileTitleHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: profileHeaderReuseIdentifier)
        collectionView.register(GroupDetailsCell.self, forCellWithReuseIdentifier: groupDetailsReuseIdentifier)
        collectionView.register(UserProfileAboutCell.self, forCellWithReuseIdentifier: profileAboutReuseIdentifier)
        collectionView.register(GroupPageCategoriesCell.self, forCellWithReuseIdentifier: groupPageCategoriesReuseIdentifier)
        collectionView.register(GroupAdminCell.self, forCellWithReuseIdentifier: groupAdminReuseIdentifier)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            if sectionNumber == 0 || sectionNumber == 1 {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                return section
                
                
                
            } else if sectionNumber == 2 {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                return section
            } else {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                return section
            }
            
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        //config.scrollDirection = .horizontal
        config.interSectionSpacing = 0
        layout.configuration = config
        return layout
    }
    
    @objc func handleEditGroupTap() {
        let controller = CreateGroupViewController(group: group)
        
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        
        present(navVC, animated: true)
    }
    
    private func fetchUser() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        UserService.fetchUser(withUid: uid) { user in
            #warning("FETCH ADMIN TEAM")
            self.users = [user]
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

extension GroupInformationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 3 { return users.count }
        else { return 1 }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: ElementKind.sectionHeader, withReuseIdentifier: groupTitleReuseIdentifier, for: indexPath) as! GroupAboutHeader
            header.set(title: "Details")
            return header
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: ElementKind.sectionHeader, withReuseIdentifier: profileHeaderReuseIdentifier, for: indexPath) as! UserProfileTitleHeader
        header.buttonImage.isHidden = true
        
        if indexPath.section == 1 {
            header.set(title: "Description")
        } else if indexPath.section == 2 {
            header.set(title: "Categories")
        } else {
            header.set(title: "Administrators")
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            // Details
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupDetailsReuseIdentifier, for: indexPath) as! GroupDetailsCell
            cell.set(title: group.name, creationDate: group.timestamp)
            return cell
        } else if indexPath.section == 1 {
            // Description
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileAboutReuseIdentifier, for: indexPath) as! UserProfileAboutCell
            cell.set(body: group.description)
            return cell
        } else if indexPath.section == 2 {
            // Categories
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupPageCategoriesReuseIdentifier, for: indexPath) as! GroupPageCategoriesCell
            cell.categories = group.categories
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupAdminReuseIdentifier, for: indexPath) as! GroupAdminCell
        cell.user = users[indexPath.row]
        cell.configureButtonText()
        #warning("Create a 'admin team' inside RTD to fetch admin users with its role")
        return cell
    }
}
