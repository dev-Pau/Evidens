//
//  GroupBrowserViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/12/22.
//

import UIKit

private let groupCellReuseIdentifier = "GroupCellReuseIdentifier"
private let groupBrowseSkeletonCellReuseIdentifier = "GroupBrowseSkeletonCellReuseIdentifier"
private let groupFooterReuseIdentifier = "GroupFooterReuseIdentifier"

protocol GroupBrowserViewControllerDelegate: AnyObject {
    func didTapGroupCreate()
    func didTapDiscoverGroup()
    func didSelectGroup(group: Group)
}

class GroupBrowserViewController: UIViewController {
    
    weak var delegate: GroupBrowserViewControllerDelegate?
    
    private var loaded: Bool = false
    
    private var groups = [Group]()

    private let groupCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width - 30, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        fetchUserGroups()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loaded { groupCollectionView.reloadData() }
    }
    
    private func configureNavigationBar() {
        title = "Groups"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(didTapCreateGroup))
        navigationItem.rightBarButtonItem?.tintColor = grayColor
    }
    
    private func configureCollectionView() {
        groupCollectionView.register(GroupBrowseSkeletonCell.self, forCellWithReuseIdentifier: groupBrowseSkeletonCellReuseIdentifier)
        groupCollectionView.register(GroupBrowseCell.self, forCellWithReuseIdentifier: groupCellReuseIdentifier)
        groupCollectionView.register(GroupBrowseFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: groupFooterReuseIdentifier)
        groupCollectionView.delegate = self
        groupCollectionView.dataSource = self
    }
    
    private func configureUI() {
        view.addSubviews(groupCollectionView)
        groupCollectionView.frame = view.bounds
        
    }
    
    private func fetchUserGroups() {
        GroupService.fetchUserGroups { groups in
            self.groups = groups
            self.loaded = true
            self.groupCollectionView.isScrollEnabled = true
            self.groupCollectionView.reloadData()
        }
    }
    
    @objc func didTapCreateGroup() {
        let controller = CreateGroupViewController()
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        
        present(nav, animated: true)
    }
}

extension GroupBrowserViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return loaded ? CGSize(width: UIScreen.main.bounds.width - 30, height: 50) : CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter && loaded {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: groupFooterReuseIdentifier, for: indexPath) as! GroupBrowseFooter
            footer.delegate = self
            return footer
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loaded ? groups.count : 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !loaded {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupBrowseSkeletonCellReuseIdentifier, for: indexPath) as! GroupBrowseSkeletonCell
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellReuseIdentifier, for: indexPath) as! GroupBrowseCell
        cell.viewModel = GroupViewModel(group: groups[indexPath.row])
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !loaded { return }
        let groupSelected = groups[indexPath.row]
        //delegate?.didSelectGroup(group: groupSelected)
        
        let controller = GroupPageViewController(group: groupSelected, isMember: true)
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension GroupBrowserViewController: GroupBrowseFooterDelegate {
    func didTapDiscoverGroups() {
        let controller = DiscoverGroupsViewController()
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .black
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension GroupBrowserViewController: GroupPageViewControllerDelegate {
    func didUpdateGroup(_ group: Group) {
        let index = groups.firstIndex { currentGroup in
            if group.groupId == currentGroup.groupId {
                return true
            }
            
            return false
        }
        
        if let index = index {
            groups[index] = group
            groupCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
}
