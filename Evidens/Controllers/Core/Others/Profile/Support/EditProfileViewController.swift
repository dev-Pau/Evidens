//
//  EditProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit
import PhotosUI

private let profilePictureReuseIdentifier = "ProfilePictureReuseIdentifier"
private let nameCellReuseIdentifier = "NameCellReuseIdentifier"
private let categoryCellReuseIdentifier = "CategoryCellReuseIdentifier"
private let customSectionCellReuseIdentifier = "CustomSectionsCellReuseIdentifier"

private let aboutCellReuseIdentifier = "AboutCellReuseIdentifier"

protocol EditProfileViewControllerDelegate: AnyObject {
    func fetchNewUserValues(withUid uid: String)
    func fetchNewAboutValues(withUid uid: String)
    func fetchNewExperienceValues(withUid uid: String)
    func fetchNewEducationValues()
    func fetchNewPatentValues()
    func fetchNewPublicationValues()
    func fetchNewLanguageValues()
}


class EditProfileViewController: UICollectionViewController {
    
    private var user: User
    private let imageBottomMenuLanucher = RegisterBottomMenuLauncher()
    
    weak var delegate: EditProfileViewControllerDelegate?
    
    private var userDidChangeProfilePicture: Bool = false
    private var userDidChangeBannerPicture: Bool = false
    
    private var newUserProfilePicture = UIImage()
    private var newUserProfileBanner = UIImage()
    
    private var firstNameDidChange: Bool = false
    private var firstName: String = ""
    
    private var lastNameDidChange: Bool = false
    private var lastName: String = ""
    
    private var isProfile: Bool = false
    private var isBanner: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageBottomMenuLanucher.delegate = self
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
        navigationItem.rightBarButtonItem?.isEnabled = false
        
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
        delegate?.fetchNewUserValues(withUid: user.uid!)
    }
    
    //MARK: - Actions
    
    @objc func handleDone() {
        showLoadingView()
        
        if userDidChangeProfilePicture {
            updateProfileImage(image: newUserProfilePicture)
        }
        
        if userDidChangeBannerPicture {
            updateBannerImage(image: newUserProfileBanner)
        }
        
        if firstNameDidChange {
            updateUserFirstName()
            
        }
        
        if lastNameDidChange {
           updateUserLastName()
        }
        
        self.dismissLoadingView()
        
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    //MARK: - API
    private func updateProfileImage(image: UIImage) {
        guard let uid = user.uid else { return }
        StorageManager.uploadProfileImage(image: image, uid: uid) { imageUrl in
            UserService.updateProfileUrl(profileImageUrl: imageUrl) { updated in
                if updated {
                    self.user.profileImageUrl = imageUrl
                    self.collectionView.reloadData()
                    self.delegate?.fetchNewUserValues(withUid: uid)
                }
            }
        }
    }
    
    private func updateBannerImage(image: UIImage) {
        guard let uid = user.uid else { return }
        StorageManager.uploadBannerImage(image: image, uid: uid) { bannerUrl in
            UserService.updateBannerUrl(bannerImageUrl: bannerUrl) { updated in
                if updated {
                    self.user.bannerImageUrl = bannerUrl
                    self.collectionView.reloadData()
                    self.delegate?.fetchNewUserValues(withUid: uid)
                }
            }
        }
    }
    
    private func updateUserLastName() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.updateUserLastName(lastName: lastName) { updated in
            if updated {
                UserService.updateUserLastName(lastName: self.lastName) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    self.delegate?.fetchNewUserValues(withUid: uid)
                }
            }
        }
    }
    
    private func updateUserFirstName() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.updateUserFirstName(firstName: firstName) { updated in
            if updated {
                UserService.updateUserFirstName(firstName: self.firstName) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    self.delegate?.fetchNewUserValues(withUid: uid)
                }
            }
        }
    }
}

extension EditProfileViewController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profilePictureReuseIdentifier, for: indexPath) as! EditProfilePictureCell
            cell.delegate = self
            if let imageUrl = user.profileImageUrl {
                cell.set(profileImageUrl: imageUrl)
            }
            if let bannerUrl = user.bannerImageUrl {
                cell.set(bannerImageUrl: bannerUrl)
            }
            return cell
            
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.delegate = self
            cell.set(title: "First name", placeholder: "Enter your first name", name: user.firstName!)
            return cell
        } else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.delegate = self
            cell.set(title: "Last name", placeholder: "Enter your last name", name: user.lastName!)
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

extension EditProfileViewController: EditProfilePictureCellDelegate {
    func didTapChangeProfilePicture() {
        isProfile = true
        isBanner = false
        imageBottomMenuLanucher.showImageSettings(in: view)
    }
    
    func didTapChangeBannerPicture() {
        isProfile = false
        isBanner = true
        imageBottomMenuLanucher.showImageSettings(in: view)
    }
}

extension EditProfileViewController: EditNameCellDelegate {
    func textDidChange(_ cell: UICollectionViewCell, text: String) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        if let indexPath = collectionView.indexPath(for: cell) {
            if indexPath.row == 1 {
                // First name edited
                firstNameDidChange = true
                firstName = text
            } else {
                // Last name edited
                lastNameDidChange = true
                lastName = text
            }
        }
    }
}

extension EditProfileViewController: CustomSectionCellDelegate {
    func didTapConfigureSections() {
        let controller = ConfigureSectionViewController()
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        backItem.tintColor = .black
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension EditProfileViewController: RegisterBottomMenuLauncherDelegate {
    func didTapImportFromGallery() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        config.filter = PHPickerFilter.any(of: [.images])
        
        
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func didTapImportFromCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        let cell = self.collectionView.cellForItem(at: IndexPath.init(row: 0, section: 0)) as! EditProfilePictureCell
        
        if isProfile {
            cell.profileImageView.image = selectedImage
            newUserProfilePicture = selectedImage
            userDidChangeProfilePicture = true
        } else {
            cell.bannerImageView.image = selectedImage
            newUserProfileBanner = selectedImage
            userDidChangeBannerPicture = true
        }
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if results.count == 0 { return }
        showLoadingView()
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    self.dismissLoadingView()
                    let cell = self.collectionView.cellForItem(at: IndexPath.init(row: 0, section: 0)) as! EditProfilePictureCell
                    
                    if self.isProfile {
                        cell.profileImageView.image = image
                        self.newUserProfilePicture = image
                        self.userDidChangeProfilePicture = true
                    } else {
                        cell.bannerImageView.image = image
                        self.newUserProfileBanner = image
                        self.userDidChangeBannerPicture = true
                    }
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }
        }
    }
}

extension EditProfileViewController: ConfigureSectionViewControllerDelegate {
    
    func languageSectionDidChange() {
        delegate?.fetchNewLanguageValues()
    }
    
    
    func publicationSectionDidChange() {
        delegate?.fetchNewPublicationValues()
    }
    
    func patentSectionDidChange() {
        delegate?.fetchNewPatentValues()
    }
    
    
    func educationSectionDidChange() {
        delegate?.fetchNewEducationValues()
    }
    
    func experienceSectionDidChange() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        delegate?.fetchNewExperienceValues(withUid: uid)
    }
    
    func aboutSectionDidChange() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        delegate?.fetchNewAboutValues(withUid: uid)
    }
    
    
}
