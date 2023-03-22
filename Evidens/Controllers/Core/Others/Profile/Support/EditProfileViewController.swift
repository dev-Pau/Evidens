//
//  EditProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit
import PhotosUI
import CropViewController
import JGProgressHUD

private let profilePictureReuseIdentifier = "ProfilePictureReuseIdentifier"
private let nameCellReuseIdentifier = "NameCellReuseIdentifier"
private let categoryCellReuseIdentifier = "CategoryCellReuseIdentifier"
private let customSectionCellReuseIdentifier = "CustomSectionsCellReuseIdentifier"

private let aboutCellReuseIdentifier = "AboutCellReuseIdentifier"

protocol EditProfileViewControllerDelegate: AnyObject {
    func didUpdateProfile(user: User)
    func fetchNewUserValues(withUid uid: String)
    func fetchNewAboutValues(withUid uid: String)
    func fetchNewExperienceValues(withUid uid: String)
    func fetchNewEducationValues()
    func fetchNewPatentValues()
    func fetchNewPublicationValues()
    func fetchNewLanguageValues()
}


class EditProfileViewController: UIViewController {
    
    private var user: User
    private let imageBottomMenuLanucher = RegisterBottomMenuLauncher()
    
    private var viewModel = ProfileViewModel()
    
    private var progressIndicator = JGProgressHUD()
    
    weak var delegate: EditProfileViewControllerDelegate?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
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
        
        viewModel.firstName = user.firstName!
        viewModel.lastName = user.lastName!
        viewModel.speciality = user.speciality!
      
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        let leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .label
        
        let rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        navigationItem.title = "Edit Profile"
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(EditProfilePictureCell.self, forCellWithReuseIdentifier: profilePictureReuseIdentifier)
        collectionView.register(EditNameCell.self, forCellWithReuseIdentifier: nameCellReuseIdentifier)
        collectionView.register(EditCategoryCell.self, forCellWithReuseIdentifier: categoryCellReuseIdentifier)
        collectionView.register(CustomSectionCell.self, forCellWithReuseIdentifier: customSectionCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self

    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        //delegate?.fetchNewUserValues(withUid: user.uid!)
    }
    
    private func cropImage(image: UIImage) {
        if isProfile {
            let vc = CropViewController(croppingStyle: .circular , image: image)
            vc.delegate = self
            vc.aspectRatioLockEnabled = true
            vc.toolbarPosition = .bottom
            vc.doneButtonTitle = "Done"
            vc.cancelButtonTitle = "Cancel"
            self.present(vc, animated: true)
        } else {
            let vc = CropViewController(image: image)
            vc.delegate = self
            vc.aspectRatioLockEnabled = true
            vc.aspectRatioPickerButtonHidden = true
            vc.rotateButtonsHidden = true
            vc.resetButtonHidden = true
            vc.aspectRatioPreset = .presetCustom
            vc.customAspectRatio = CGSize(width: 4, height: 1)
            vc.toolbarPosition = .bottom
            vc.doneButtonTitle = "Done"
            vc.cancelButtonTitle = "Cancel"
            self.present(vc, animated: true)
        }
    }
    
    //MARK: - Actions
    
    @objc func handleDone() {
        
        guard let firstName = viewModel.firstName, let lastName = viewModel.lastName, let speciality = viewModel.speciality else { return }
        var newProfile = User(dictionary: [:])
        newProfile.firstName = firstName
        newProfile.lastName = lastName
        newProfile.speciality = speciality
        
        progressIndicator.show(in: view)
        
        if userDidChangeBannerPicture && userDidChangeProfilePicture {
            StorageManager.uploadProfileImages(images: [newUserProfileBanner, newUserProfilePicture], userUid: user.uid!) { urls in
                newProfile.bannerImageUrl = urls.first(where: { url in
                    url.contains("banners")
                })
                
                newProfile.profileImageUrl = urls.first(where: { url in
                    url.contains("profile_images")
                })
                
                UserService.updateUser(from: self.user, to: newProfile) { user in
                    self.progressIndicator.dismiss(animated: true)
                    self.delegate?.didUpdateProfile(user: user)
                    self.dismiss(animated: true)
                }
            }
        } else {
            if userDidChangeBannerPicture {
                // Banner image has changed
                StorageManager.uploadBannerImage(image: newUserProfileBanner, uid: user.uid!) { url in
                    newProfile.bannerImageUrl = url
                    
                    UserService.updateUser(from: self.user, to: newProfile) { user in
                        self.progressIndicator.dismiss(animated: true)
                        self.delegate?.didUpdateProfile(user: user)
                        self.dismiss(animated: true)
                    }
                }
            } else if userDidChangeProfilePicture {
                // Profile image has changed
                StorageManager.uploadProfileImage(image: newUserProfilePicture, uid: user.uid!) { url in
                    newProfile.profileImageUrl = url
                    UserService.updateUser(from: self.user, to: newProfile) { user in
                        self.progressIndicator.dismiss(animated: true)
                        self.delegate?.didUpdateProfile(user: user)
                        self.dismiss(animated: true)
                    }
                }
            } else {
                // Other profile fields have changed
                UserService.updateUser(from: self.user, to: newProfile) { user in
                    print(user.speciality!)
                    self.progressIndicator.dismiss(animated: true)
                    self.delegate?.didUpdateProfile(user: user)
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    //MARK: - API
    
    private func groupIsValid() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.profileIsValid
    }
}

extension EditProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profilePictureReuseIdentifier, for: indexPath) as! EditProfilePictureCell
            cell.delegate = self
            if let imageUrl = user.profileImageUrl, imageUrl != "" {
                cell.set(profileImageUrl: imageUrl)
            }
            if let bannerUrl = user.bannerImageUrl, bannerUrl != "" {
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
            cell.set(title: "Category", subtitle: user.category.userCategoryString, image: "lock")
            
            return cell
        } else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! EditCategoryCell
            cell.set(title: "Profession", subtitle: user.profession!, image: "lock")
            return cell
        } else if indexPath.row == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! EditCategoryCell
            cell.set(title: "Speciality", subtitle: user.speciality!, image: "chevron.right")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customSectionCellReuseIdentifier, for: indexPath) as! CustomSectionCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            // Speciality
            let controller = SpecialityRegistrationViewController(user: user)
            controller.isEditingProfileSpeciality = true
            controller.delegate = self

            let backItem = UIBarButtonItem()
            backItem.tintColor = .label
            backItem.title = ""
            
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        } else if indexPath.row == 6 {
            let controller = ConfigureSectionViewController(user: user)
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            backItem.tintColor = .label
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension EditProfileViewController: EditProfilePictureCellDelegate {
    func didTapChangeProfilePicture() {
        isProfile = true
        isBanner = false
        imageBottomMenuLanucher.showImageSettings(in: view)
    }
    
    func didTapChangeBannerPicture() {
        print("is banner")
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
                firstName = text
                viewModel.firstName = text
                groupIsValid()
            } else {
                // Last name edited
                lastName = text
                viewModel.lastName = text
                groupIsValid()
            }
        }
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
        cropImage(image: selectedImage)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        if results.count == 0 { return }
        progressIndicator.show(in: view)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {

                    self.progressIndicator.dismiss(animated: true)
                    self.cropImage(image: image)
                }
            }
        }
    }
}

extension EditProfileViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        let cell = self.collectionView.cellForItem(at: IndexPath.init(row: 0, section: 0)) as! EditProfilePictureCell
        cell.profileImageView.image = image
        self.newUserProfilePicture = image
        self.userDidChangeProfilePicture = true
        cell.hideProfileHint()
        viewModel.profileImage = true
        groupIsValid()
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        print("is banner")
        let cell = self.collectionView.cellForItem(at: IndexPath.init(row: 0, section: 0)) as! EditProfilePictureCell
        cell.bannerImageView.image = image
        self.newUserProfileBanner = image
        self.userDidChangeBannerPicture = true
        viewModel.profileBanner = true
        groupIsValid()
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
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        delegate?.fetchNewExperienceValues(withUid: uid)
    }
    
    func aboutSectionDidChange() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        delegate?.fetchNewAboutValues(withUid: uid)
    }
}

extension EditProfileViewController: SpecialityRegistrationViewControllerDelegate {
    func didEditSpeciality(speciality: String) {
        let cell = collectionView.cellForItem(at: IndexPath(item: 5, section: 0)) as! EditCategoryCell
        cell.updateSpeciality(speciality: speciality)
        viewModel.speciality = speciality
        groupIsValid()
    }
}
