//
//  EditProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit

private let profilePictureReuseIdentifier = "ProfilePictureReuseIdentifier"
private let nameCellReuseIdentifier = "NameCellReuseIdentifier"
private let aboutCellReuseIdentifier = "AboutCellReuseIdentifier"

class EditProfileViewController: UICollectionViewController {
    
    private let user: User
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
    }
    
    init(user: User) {
        self.user = user
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        let leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        let rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
    }
    
    private func configureCollectionView() {
        collectionView.register(EditProfilePictureCell.self, forCellWithReuseIdentifier: profilePictureReuseIdentifier)
        collectionView.register(EditNameCell.self, forCellWithReuseIdentifier: nameCellReuseIdentifier)
        collectionView.register(EditAboutCell.self, forCellWithReuseIdentifier: aboutCellReuseIdentifier)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
    }
    
    //MARK: - Actions
    
    @objc func handleDone() {
        print("update profile with information")
        
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension EditProfileViewController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profilePictureReuseIdentifier, for: indexPath) as! EditProfilePictureCell
            return cell
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: "First name", placeholder: "Enter your first name")
            return cell
        } else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: "Last name", placeholder: "Enter your last name")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: aboutCellReuseIdentifier, for: indexPath) as! EditAboutCell
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
}
