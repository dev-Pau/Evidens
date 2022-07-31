//
//  EditProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit

private let profilePictureReuseIdentifier = "ProfilePictureReuseIdentifier"
private let nameCellReuseIdentifier = "NameCellReuseIdentifier"
private let categoryCellReuseIdentifier = "CategoryCellReuseIdentifier"
private let customSectionCellReuseIdentifier = "CustomSectionsCellReuseIdentifier"

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
        
        navigationItem.title = "Edit Profile"
    }
    
    private func configureCollectionView() {
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(EditProfilePictureCell.self, forCellWithReuseIdentifier: profilePictureReuseIdentifier)
        collectionView.register(EditNameCell.self, forCellWithReuseIdentifier: nameCellReuseIdentifier)
        collectionView.register(EditCategoryCell.self, forCellWithReuseIdentifier: categoryCellReuseIdentifier)
        collectionView.register(CustomSectionCell.self, forCellWithReuseIdentifier: customSectionCellReuseIdentifier)

        //collectionView.register(EditAboutCell.self, forCellWithReuseIdentifier: aboutCellReuseIdentifier)
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
        } else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! EditCategoryCell
            cell.set(title: "Category", subtitle: "Professional", image: "lock")
            return cell
        } else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! EditCategoryCell
            cell.set(title: "Profession", subtitle: "Odontology", image: "chevron.right")
            return cell
        } else if indexPath.row == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! EditCategoryCell
            cell.set(title: "Speciality", subtitle: "General Odontology", image: "chevron.right")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customSectionCellReuseIdentifier, for: indexPath) as! CustomSectionCell
            cell.delegate = self
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
}

extension EditProfileViewController: CustomSectionCellDelegate {
    func didTapConfigureSections() {
        let controller = ConfigureSectionViewController()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        backItem.tintColor = .black
        
        navigationController?.pushViewController(controller, animated: true)
    }
}
