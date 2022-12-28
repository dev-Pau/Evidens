//
//  GroupPageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/11/22.
//

import UIKit

private let groupHeaderReuseIdentifier = "GroupHeaderReuseIdentifier"
private let groupContentCreationReuseIdentifier = "GroupContentCreationReuseIdentifier"


private let groupContentSelectionReuseIdentifier = "GroupContentSelectionReuseIdentifier"
private let groupContentCollectionViewReuseIdentifier = "GroupContentCollectionViewReuseIdentifier"

class GroupPageViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    private var group: Group
    private var members: [User]
    
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchTextField.tintColor = primaryColor
        searchBar.searchTextField.backgroundColor = lightColor
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchBar()
        configureUI()
        configureCollectionView()
    }
    
    init(group: Group, members: [User]) {
        self.group = group
        self.members = members
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(handleGroupOptions))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchBarContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.70).isActive = true
        
        navigationItem.titleView = searchBarContainer
        
        searchBar.delegate = self
    }
    
    private func configureSearchBar() {
        let atrString = NSAttributedString(string: "Search content in \(group.name)", attributes: [.font : UIFont.systemFont(ofSize: 15)])
        searchBar.searchTextField.attributedPlaceholder = atrString
    }
    
    private func configureUI() {
        view.backgroundColor = .white

    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = lightColor
        
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        
        collectionView.register(GroupPageHeaderCell.self, forCellWithReuseIdentifier: groupHeaderReuseIdentifier)
        collectionView.register(GroupContentCreationCell.self, forCellWithReuseIdentifier: groupContentCreationReuseIdentifier)
        
        collectionView.register(GroupContentSelectionHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: groupContentSelectionReuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: groupContentCollectionViewReuseIdentifier)
        //collectionView.register(UserProfileTitleHeader.self, forCellWithReuseIdentifier: profileHeaderTitleReuseIdentifier)
        
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            if sectionNumber == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)), subitems: [item])
                group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0), top: .fixed(0), trailing: .fixed(0), bottom: .fixed(5))
                let section = NSCollectionLayoutSection(group: group)
                return section
            } else {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                header.pinToVisibleBounds = true
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0), top: .fixed(0), trailing: .fixed(0), bottom: .fixed(5))
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [header]
                return section
            }

        }
        
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        return layout
    }
    
    
    @objc func handleGroupOptions() {
        
    }
}

extension GroupPageViewController: UISearchBarDelegate {
    
}

extension GroupPageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 2 }
        else { return 10 }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupHeaderReuseIdentifier, for: indexPath) as! GroupPageHeaderCell
                cell.viewModel = GroupViewModel(group: group)
                cell.users = members
                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupContentCreationReuseIdentifier, for: indexPath) as! GroupContentCreationCell
                cell.delegate = self
                return cell
            }

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupContentCollectionViewReuseIdentifier, for: indexPath)
            cell.backgroundColor = .red
            return cell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: groupContentSelectionReuseIdentifier, for: indexPath) as! GroupContentSelectionHeader
        //header.set(title: "Sticky header")
        
        return header
    }
}

extension GroupPageViewController: GroupPageHeaderCellDelegate {
    func didTapGroupProfilePicture() {
        let controller = ProfileImageViewController(isBanner: false)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            controller.profileImageView.sd_setImage(with: URL(string: self.group.profileUrl!))
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true)
        }
    }
    
    func didTapGroupBannerPicture() {
        let controller = ProfileImageViewController(isBanner: true)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            controller.profileImageView.sd_setImage(with: URL(string: self.group.bannerUrl!))
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true)
        }
    }
    
    func didTapInfoButton() {
        let controller = GroupInformationViewController(group: group)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension GroupPageViewController: GroupContentCreationCellDelegate {
    func didTapUploadPost() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let controller = UploadPostViewController(user: user, group: group)
        
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        
        present(navVC, animated: true)
    }
    
    func didTapUploadCase() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let controller = ShareClinicalCaseViewController(user: user, group: group)
        
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        
        present(navVC, animated: true)
    }
}
