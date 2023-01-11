//
//  PostGroupSelectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/12/22.
//

import UIKit


protocol PostGroupSelectionViewControllerDelegate: AnyObject {
    func didSelectGroup(_ group: Group)
}

private let groupCellReuseIdentifier = "GroupCellReuseIdentifier"

class PostGroupSelectionViewController: UIViewController {
    
    weak var delegate: PostGroupSelectionViewControllerDelegate?
    
    private var groups = [Group]()
    private var groupSelected = Group(groupId: "", dictionary: [:])
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    init(groupSelected: Group? = nil) {
        if let groupSelected = groupSelected {
            self.groupSelected = groupSelected
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserGroups()
        configureNavigationBar()
        configureUI()
    }
    
    private func configureNavigationBar() {
        title = "Select a group"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelGroupSelection))
        navigationItem.leftBarButtonItem?.tintColor = .label
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleAddGroup))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PostGroupCell.self, forCellWithReuseIdentifier: groupCellReuseIdentifier)
    }
    
    private func fetchUserGroups() {
        GroupService.fetchUserGroups { groups in
            self.groups = groups
            self.collectionView.reloadData()
        }
    }
    
    @objc func handleCancelGroupSelection() {
        dismiss(animated: true)
    }
    
    @objc func handleAddGroup() {
        delegate?.didSelectGroup(groupSelected)
        dismiss(animated: true)
    }
}

extension PostGroupSelectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellReuseIdentifier, for: indexPath) as! PostGroupCell
        cell.viewModel = GroupViewModel(group: groups[indexPath.row])
        if groupSelected.groupId == groups[indexPath.row].groupId {
            navigationItem.rightBarButtonItem?.isEnabled = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PostGroupCell {
            cell.isSelected = true
            groupSelected = groups[indexPath.row]
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
}
