//
//  DiscoverGroupsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/11/22.
//

import UIKit

private let groupCellReuseIdentifier = "GroupCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let searchBarHeaderReuseIdentifier = "SearchBarHeaderReuseIdentifier"
private let emptyGroupCellReuseIdentifier = "EmptyGroupCellReuseIdentifier"

class DiscoverGroupsViewController: UIViewController {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private var groups = [Group]()

    private var groupsLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        fetchGroups()
    }

    private func configureNavigationBar() {
        view.backgroundColor = .systemBackground
        title = "Discover Groups"
    }
    
    private func configureCollectionView() {
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchBarHeaderReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupCellReuseIdentifier)
        collectionView.register(GroupCell.self, forCellWithReuseIdentifier: groupCellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
    }
    
    private func fetchGroups() {
        GroupService.fetchGroups { groups in
            if groups.isEmpty {
                self.groupsLoaded = true
                self.collectionView.reloadData()
            } else {
                self.groups = groups
                self.groupsLoaded = true
                self.collectionView.reloadData()
            }
        }
    }
}

extension DiscoverGroupsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupsLoaded ? groups.isEmpty ? 1 : groups.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if groupsLoaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchBarHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
            header.setSearchBarPlaceholder(text: "Discover groups")
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if groupsLoaded {
            return groups.isEmpty ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
        } else {
            return CGSize(width: view.frame.width, height: 55)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if groups.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: UIImage(named: "content.empty"), title: "No groups found.", description: "Check back later for new groups or create your own.", buttonText: .dismiss)
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellReuseIdentifier, for: indexPath) as! GroupCell
            cell.viewModel = GroupViewModel(group: groups[indexPath.row])
            if indexPath.row == groups.count - 1 { cell.separatorView.isHidden = true }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !groups.isEmpty else { return }
        let groupSelected = groups[indexPath.row]
        
        #warning("PROBLEMA. Aquí em de mirar previament si l'usuari forma part del grup o no, mirar a RTD si forma part del grup i quin rol té")
        let controller = GroupPageViewController(group: groupSelected)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension DiscoverGroupsViewController: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton(option: EmptyCellButtonOptions) {
        navigationController?.popViewController(animated: true)
    }
}

extension DiscoverGroupsViewController: UISearchBarDelegate {
    
}


