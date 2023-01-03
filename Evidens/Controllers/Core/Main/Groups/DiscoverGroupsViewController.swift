//
//  DiscoverGroupsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/11/22.
//

import UIKit

private let groupCellReuseIdentifier = "GroupCellReuseIdentifier"
private let groupCellSkeletonCellReuseIdentifier = "GroupCellSkeletonCellReuseIdentifier"

class DiscoverGroupsViewController: UIViewController {
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        let atrString = NSAttributedString(string: "Discover groups", attributes: [.font : UIFont.systemFont(ofSize: 15)])
        searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.tintColor = primaryColor
        searchBar.searchTextField.backgroundColor = lightColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.setImage(UIImage(named: "groups.selected")?.withTintColor(grayColor).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)), for: .search , state: .normal)
        return searchBar
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .zero)
        layout.minimumLineSpacing = .leastNonzeroMagnitude
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private var groups = [Group]()
    
    private var loaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        fetchGroups()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loaded { collectionView.reloadData() }
    }
    
    private func configureNavigationBar() {
        
        view.backgroundColor = .white

        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchBarContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8).isActive = true
        
        navigationItem.titleView = searchBarContainer
    
        searchBar.delegate = self
    }
    
    private func configureCollectionView() {
        collectionView.register(GroupCell.self, forCellWithReuseIdentifier: groupCellReuseIdentifier)
        collectionView.register(DiscoverGroupSkeletonCell.self, forCellWithReuseIdentifier: groupCellSkeletonCellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
    }
    
    private func fetchGroups() {
        GroupService.fetchGroups { groups in
            self.groups = groups
            self.collectionView.isScrollEnabled = true
            self.loaded = true
            self.collectionView.reloadData()
        }
    }
}

extension DiscoverGroupsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loaded ? groups.count : 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !loaded {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellSkeletonCellReuseIdentifier, for: indexPath) as! DiscoverGroupSkeletonCell
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellReuseIdentifier, for: indexPath) as! GroupCell
        cell.viewModel = GroupViewModel(group: groups[indexPath.row])
        if indexPath.row == groups.count - 1 { cell.separatorView.isHidden = true }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let groupSelected = groups[indexPath.row]
        
        let controller = GroupPageViewController(group: groupSelected, isMember: false)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .black
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension DiscoverGroupsViewController: UISearchBarDelegate {
    
}


