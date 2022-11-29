//
//  DiscoverGroupsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/11/22.
//

import UIKit

private let groupCellReuseIdentifier = "GroupCellReuseIdentifier"

class DiscoverGroupsViewController: UIViewController {
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        let atrString = NSAttributedString(string: "Discover groups", attributes: [.font : UIFont.systemFont(ofSize: 15)])
        searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.tintColor = primaryColor
        searchBar.searchTextField.backgroundColor = lightColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .zero)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private var groups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        fetchGroups()
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
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = lightColor
        
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
    }
    
    private func fetchGroups() {
        GroupService.fetchGroups { groups in
            self.groups = groups
            self.collectionView.reloadData()
        }
    }
}

extension DiscoverGroupsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellReuseIdentifier, for: indexPath) as! GroupCell
        cell.viewModel = GroupViewModel(group: groups[indexPath.row])
        return cell
    }
}

extension DiscoverGroupsViewController: UISearchBarDelegate {
    
}


