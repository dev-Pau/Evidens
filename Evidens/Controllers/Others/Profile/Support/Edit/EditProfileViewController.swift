//
//  EditProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit
import PhotosUI
import CropViewController

private let profilePictureReuseIdentifier = "ProfilePictureReuseIdentifier"
private let nameCellReuseIdentifier = "NameCellReuseIdentifier"
private let categoryCellReuseIdentifier = "CategoryCellReuseIdentifier"
private let customSectionCellReuseIdentifier = "CustomSectionsCellReuseIdentifier"

protocol EditProfileViewControllerDelegate: AnyObject {
    func didUpdateProfile(user: User)
    func fetchNewAboutValues(withUid uid: String)
    func fetchNewWebsiteValues()
}

class EditProfileViewController: UIViewController {
    
    private var user: User
    private var viewModel: EditProfileViewModel
    
    weak var delegate: EditProfileViewControllerDelegate?
    
    private var collectionView: UICollectionView!
    
    private var userDidChangeProfilePicture: Bool = false
    private var userDidChangeBannerPicture: Bool = false
    
    private var imageKind: ImageKind?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
    }
    
    init(user: User) {
        self.user = user
        viewModel = EditProfileViewModel(user: user)
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
        navigationItem.rightBarButtonItem?.tintColor = K.Colors.primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        navigationItem.title = AppStrings.Profile.editProfile
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: addLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.backgroundColor = .systemBackground
        collectionView.register(EditProfilePictureCell.self, forCellWithReuseIdentifier: profilePictureReuseIdentifier)
        collectionView.register(EditNameCell.self, forCellWithReuseIdentifier: nameCellReuseIdentifier)
        collectionView.register(EditCategoryCell.self, forCellWithReuseIdentifier: categoryCellReuseIdentifier)
        collectionView.register(ManageSectionsCell.self, forCellWithReuseIdentifier: customSectionCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func cropImage(image: UIImage) {
        guard let imageKind else { return }
        
        switch imageKind {
            
        case .profile:
            let vc = CropViewController(croppingStyle: .circular , image: image)
            vc.delegate = self
            vc.aspectRatioLockEnabled = true
            vc.toolbarPosition = .bottom
            vc.doneButtonTitle = AppStrings.Global.done
            vc.cancelButtonTitle = AppStrings.Global.cancel
            self.present(vc, animated: true)
        case .banner:
            let vc = CropViewController(image: image)
            vc.delegate = self
            vc.aspectRatioLockEnabled = true
            vc.aspectRatioPickerButtonHidden = true
            vc.rotateButtonsHidden = true
            vc.resetButtonHidden = true
            vc.aspectRatioPreset = .presetCustom
            vc.customAspectRatio = CGSize(width: K.Ratio.bannerAR, height: 1)
            vc.toolbarPosition = .bottom
            vc.doneButtonTitle = AppStrings.Global.done
            vc.cancelButtonTitle = AppStrings.Global.cancel
            self.present(vc, animated: true)
        }
    }
    
    //MARK: - Actions
    
    @objc func handleDone() {
        
        let popupView = PopUpBanner(title: AppStrings.PopUp.profileModified, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
        showProgressIndicator(in: view)
        collectionView.endEditing(true)
        
        viewModel.updateProfile { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            switch result {
                
            case .success(let user):
                
                strongSelf.delegate?.didUpdateProfile(user: user)
                popupView.showTopPopup(inView: strongSelf.view)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.dismiss(animated: true)
                }
                
            case .failure(let error):
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
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
            cell.set(user: viewModel.user)
            return cell
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.delegate = self
            cell.set(title: AppStrings.Opening.registerFirstName, placeholder: AppStrings.Sections.firstName, name: viewModel.user.firstName!)
            return cell
        } else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.delegate = self
            cell.set(title: AppStrings.Opening.registerLastName, placeholder: AppStrings.Sections.lastName, name: viewModel.user.lastName!)
            return cell
        } else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! EditCategoryCell
            cell.set(title: AppStrings.Sections.category, subtitle: viewModel.user.kind.title, image: AppStrings.Icons.lock)
            return cell
        } else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! EditCategoryCell
            cell.set(title: AppStrings.Opening.discipline, subtitle: viewModel.user.discipline!.name, image: AppStrings.Icons.lock)
            return cell
        } else if indexPath.row == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! EditCategoryCell
            cell.set(title: AppStrings.Opening.speciality, subtitle: viewModel.user.speciality!.name, image: AppStrings.Icons.rightChevron)
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
            let controller = SpecialityViewController(user: viewModel.user)
            controller.viewModel.isEditingProfileSpeciality = true
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
            
        } else if indexPath.row == 6 {
            let controller = SectionListViewController(user: viewModel.user)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension EditProfileViewController: EditProfilePictureCellDelegate {
    func didTapChangeProfilePicture() {
        imageKind = .profile
        guard let imageKind else { return }
        showMediaMenu(kind: imageKind)
    }
    
    func didTapChangeBannerPicture() {
        imageKind = .banner
        guard let imageKind else { return }
        showMediaMenu(kind: imageKind)
    }
    
    private func showMediaMenu(kind: ImageKind) {
        let controller = MediaMenuViewController(user: viewModel.user, imageKind: kind)
        controller.delegate = self
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: false)
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

extension EditProfileViewController: MediaMenuViewControllerDelegate {
    func didTapMediaKind(_ kind: MediaKind) {
        switch kind {
        case .camera:
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        case .gallery:
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.selectionLimit = 1
            config.preferredAssetRepresentationMode = .current
            config.filter = PHPickerFilter.any(of: [.images])
            
            
            let vc = PHPickerViewController(configuration: config)
            vc.delegate = self
            present(vc, animated: true)
        case .remove:
            guard let imageKind else { return }
            showProgressIndicator(in: view)
            
            viewModel.removeImage(kind: imageKind) { [weak self] error in
                guard let strongSelf = self else  { return }
                strongSelf.dismissProgressIndicator()
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    
                    strongSelf.viewModel.removeImage(kind: imageKind)
                    strongSelf.delegate?.didUpdateProfile(user: strongSelf.viewModel.user)
                    let cell = strongSelf.collectionView.cellForItem(at: IndexPath.init(row: 0, section: 0)) as! EditProfilePictureCell
                    cell.set(user: strongSelf.viewModel.user)
                    
                    switch imageKind {
                    case .profile:
                        strongSelf.viewModel.profileImage = nil
                    case .banner:
                        strongSelf.viewModel.bannerImage = nil
                    }
                }
            }
        }
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

        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                guard let _ = self else { return }
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }

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
        cell.setImage(image: image)
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

    func websiteSectionDidChange() {
        delegate?.fetchNewWebsiteValues()
    }

    func aboutSectionDidChange() {
        guard let uid = UserDefaults.getUid() else { return }
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
