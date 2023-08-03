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
    func fetchNewExperienceValues()
    func fetchNewEducationValues()
    func fetchNewPatentValues()
    func fetchNewPublicationValues()
    func fetchNewLanguageValues()
}

class EditProfileViewController: UIViewController {
    
    private var user: User
    private let imageBottomMenuLanucher = MediaMenu()
    
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
        let leftBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .label
        
        let rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.save, style: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        navigationItem.title = AppStrings.Profile.editProfile
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(EditProfilePictureCell.self, forCellWithReuseIdentifier: profilePictureReuseIdentifier)
        collectionView.register(EditNameCell.self, forCellWithReuseIdentifier: nameCellReuseIdentifier)
        collectionView.register(EditCategoryCell.self, forCellWithReuseIdentifier: categoryCellReuseIdentifier)
        collectionView.register(ManageSectionsCell.self, forCellWithReuseIdentifier: customSectionCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    private func cropImage(image: UIImage) {
        if isProfile {
            let vc = CropViewController(croppingStyle: .circular , image: image)
            vc.delegate = self
            vc.aspectRatioLockEnabled = true
            vc.toolbarPosition = .bottom
            vc.doneButtonTitle = AppStrings.Global.done
            vc.cancelButtonTitle = AppStrings.Global.cancel
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
            vc.doneButtonTitle = AppStrings.Global.done
            vc.cancelButtonTitle = AppStrings.Global.cancel
            self.present(vc, animated: true)
        }
    }
    
    //MARK: - Actions
    
    @objc func handleDone() {
        
        guard NetworkMonitor.shared.isConnected else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.network)
            return
        }
        
        guard let firstName = viewModel.firstName, let lastName = viewModel.lastName, let speciality = viewModel.speciality else { return }
        var newProfile = User(dictionary: [:])
        newProfile.firstName = firstName
        newProfile.lastName = lastName
        newProfile.speciality = speciality
        
        progressIndicator.show(in: view)
        
        if viewModel.hasProfile && viewModel.hasBanner {
            guard let profile = viewModel.profileImage, let banner = viewModel.bannerImage else { return }
            let images = [banner, profile]
            StorageManager.addUserImages(images: images) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let urls):
                    newProfile.bannerUrl = urls.first(where: { url in
                        url.contains("banner")
                    })
                    
                    newProfile.profileUrl = urls.first(where: { url in
                        url.contains("profile")
                    })
                    
                    UserService.updateUser(from: strongSelf.user, to: newProfile) { [weak self] result in
                        guard let strongSelf = self else { return }
                        strongSelf.progressIndicator.dismiss(animated: true)
                        switch result {
                        case .success(let user):
                            
                            strongSelf.delegate?.didUpdateProfile(user: user)
                            strongSelf.dismiss(animated: true)
                        case .failure(let error):
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        }
                    }
                    
                case .failure(_):
                    strongSelf.progressIndicator.show(in: strongSelf.view)
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                    strongSelf.progressIndicator.dismiss(animated: true)
                }
            }
        } else if viewModel.hasBanner {
            guard let image = viewModel.bannerImage else { return }
            StorageManager.addBannerImage(image: image) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let bannerUrl):
                    newProfile.bannerUrl = bannerUrl
                    UserService.updateUser(from: strongSelf.user, to: newProfile) { [weak self] result in
                        strongSelf.progressIndicator.dismiss(animated: true)
                        guard let strongSelf = self else { return }
                        switch result {
                        case .success(let user):
                            
                            strongSelf.delegate?.didUpdateProfile(user: user)
                            strongSelf.dismiss(animated: true)
                        case .failure(let error):
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        }
                    }
                case .failure(_):
                    strongSelf.progressIndicator.show(in: strongSelf.view)
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                    strongSelf.progressIndicator.dismiss(animated: true)
                }
            }
        } else if viewModel.hasProfile {
            guard let image = viewModel.profileImage else { return }
            StorageManager.addProfileImage(image: image) { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.progressIndicator.dismiss(animated: true)

                switch result {
                    
                case .success(let profileUrl):
                    newProfile.profileUrl = profileUrl
                    UserService.updateUser(from: strongSelf.user, to: newProfile) { [weak self] result in
                       
                        guard let strongSelf = self else { return }
                        strongSelf.progressIndicator.dismiss(animated: true)
                        switch result {
                        case .success(let user):
                            
                            strongSelf.delegate?.didUpdateProfile(user: user)
                            strongSelf.dismiss(animated: true)
                        case .failure(let error):
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        }
                    }
                case .failure(_):
                    strongSelf.progressIndicator.show(in: strongSelf.view)
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                    strongSelf.progressIndicator.dismiss(animated: true)
                }
            }
        } else {
            UserService.updateUser(from: user, to: newProfile) { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.progressIndicator.dismiss(animated: true)

                switch result {
                case .success(let user):
                    
                    strongSelf.delegate?.didUpdateProfile(user: user)
                    strongSelf.dismiss(animated: true)
                case .failure(let error):
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        }
    }


    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    //MARK: - API
    
    private func isValid() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.profileIsValid
    }
}

extension EditProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profilePictureReuseIdentifier, for: indexPath) as! EditProfilePictureCell
            cell.delegate = self
            cell.set(user: user)
            return cell
            
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.delegate = self
            cell.set(title: AppStrings.Opening.registerFirstName, placeholder: AppStrings.Sections.firstName, name: user.firstName!)
            return cell
        } else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.delegate = self
            cell.set(title: AppStrings.Opening.registerLastName, placeholder: AppStrings.Sections.lastName, name: user.lastName!)
            return cell
        } else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! EditCategoryCell
            cell.set(title: AppStrings.Sections.category, subtitle: user.kind.title, image: AppStrings.Icons.lock)
            return cell
        } else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! EditCategoryCell
            cell.set(title: AppStrings.Opening.discipline, subtitle: user.discipline!.name, image: AppStrings.Icons.lock)
            return cell
        } else if indexPath.row == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! EditCategoryCell
            cell.set(title: AppStrings.Opening.speciality, subtitle: user.speciality!.name, image: AppStrings.Icons.rightChevron)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customSectionCellReuseIdentifier, for: indexPath) as! ManageSectionsCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            // Speciality
            let controller = SpecialityViewController(user: user)
            controller.isEditingProfileSpeciality = true
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
            
        } else if indexPath.row == 6 {
            let controller = SectionListViewController(user: user)
            controller.delegate = self
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
                viewModel.firstName = text
            } else {
                viewModel.lastName = text
            }
            
            isValid()
        }
    }
}

extension EditProfileViewController: MediaMenuDelegate {
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
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                guard let _ = self else { return }
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.progressIndicator.dismiss(animated: true)
                    strongSelf.cropImage(image: image)
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
        viewModel.profileImage = image
        isValid()
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        let cell = self.collectionView.cellForItem(at: IndexPath.init(row: 0, section: 0)) as! EditProfilePictureCell
        cell.bannerImageView.image = image
        viewModel.bannerImage = image
        isValid()
    }
}

extension EditProfileViewController: SectionListViewControllerDelegate {
    
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
        delegate?.fetchNewExperienceValues()
    }
    
    func aboutSectionDidChange() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        delegate?.fetchNewAboutValues(withUid: uid)
    }
}

extension EditProfileViewController: SpecialityRegistrationViewControllerDelegate {
    func didEditSpeciality(speciality: Speciality) {
        let cell = collectionView.cellForItem(at: IndexPath(item: 5, section: 0)) as! EditCategoryCell
        cell.updateSpeciality(speciality: speciality.name)
        viewModel.speciality = speciality
        isValid()
    }
}
