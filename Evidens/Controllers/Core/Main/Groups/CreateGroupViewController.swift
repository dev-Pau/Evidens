//
//  CreateGroupViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/11/22.
//

import UIKit

private let createGroupImageCellReuseIdentifier = "CreateGroupImageCellReuseIdentifier"
private let createGroupNameCellReuseIdentifier = "CreateGroupNameCellReuseIdentifier"
private let createGroupDescriptionCellReuseIdentifier = "CreateGroupDescriptionCellReuseIdentifier"

class CreateGroupViewController: UIViewController {
    
    enum GroupSections: String, CaseIterable {
        case groupPictures = "Group Pictures"
        case groupName = "Name"
        case groupDescription = "Description"
        
        var index: Int {
            switch self {
            case .groupPictures:
                return 0
                
            case .groupName:
                return 1
            case .groupDescription:
                return 2
            }
        }
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
    }
    
    private func configureNavigationBar() {
        title = "Create group"
        
        let leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        let rightBarButtonItem =  UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(handleCreateGroup))
        rightBarButtonItem.tintColor = primaryColor
        rightBarButtonItem.isEnabled = false
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .white
        
        collectionView.register(EditProfilePictureCell.self, forCellWithReuseIdentifier: createGroupImageCellReuseIdentifier)
        collectionView.register(EditNameCell.self, forCellWithReuseIdentifier: createGroupNameCellReuseIdentifier)
        collectionView.register(GroupDescriptionCell.self, forCellWithReuseIdentifier: createGroupDescriptionCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.frame = view.bounds
        view.addSubview(collectionView)

    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func handleCreateGroup() {
        print("Update group to Firebase here")
    }
}

extension CreateGroupViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        GroupSections.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupImageCellReuseIdentifier, for: indexPath) as! EditProfilePictureCell
            return cell
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: "Name", placeholder: "Group name", name: "")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupDescriptionCellReuseIdentifier, for: indexPath) as! GroupDescriptionCell
            cell.set(title: "Description")
            return cell
        }
    }
}


