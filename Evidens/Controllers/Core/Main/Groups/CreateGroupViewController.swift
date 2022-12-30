//
//  CreateGroupViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/11/22.
//

import UIKit
import PhotosUI
import CropViewController
import JGProgressHUD

private let createGroupImageCellReuseIdentifier = "CreateGroupImageCellReuseIdentifier"
private let createGroupNameCellReuseIdentifier = "CreateGroupNameCellReuseIdentifier"
private let createGroupDescriptionCellReuseIdentifier = "CreateGroupDescriptionCellReuseIdentifier"
private let createGroupVisibilityCellReuseIdentifier = "CreateGroupVisibilityCellReuseIdentifier"
private let createGroupCategoriesCellReuseIdentifier = "CreateGroupCategoriesCellReuseIdentifier"

class CreateGroupViewController: UIViewController {
    
    private var viewModel = CreateGroupViewModel()
    
    enum GroupSections: String, CaseIterable {
        case groupPictures = "Group Pictures"
        case groupName = "Name"
        case groupDescription = "Description"
        case groupVisibility = "Visibility"
        case groupCategories = "Categories"
        
        var index: Int {
            switch self {
            case .groupPictures:
                return 0
            case .groupName:
                return 1
            case .groupDescription:
                return 2
            case .groupVisibility:
                return 3              
            case .groupCategories:
                return 4
            }
        }
    }
    
    private let group = Group(groupId: "", dictionary: [:])
    
    private let imageBottomMenuLanucher = RegisterBottomMenuLauncher()
    
    private var groupBannerImage = UIImage()
    private var groupProfileImage = UIImage()
    private var visibilityState: Group.Visibility = .visible
    private var groupCategories = [String]()
    
    private var isProfile: Bool = false
    private var isBanner: Bool = false
    
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
    
    private let progressIndicator = JGProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        imageBottomMenuLanucher.delegate = self
        configureNavigationBar()
        configureCollectionView()
        configureUI()
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
        collectionView.register(EditProfilePictureCell.self, forCellWithReuseIdentifier: createGroupImageCellReuseIdentifier)
        collectionView.register(EditNameCell.self, forCellWithReuseIdentifier: createGroupNameCellReuseIdentifier)
        collectionView.register(GroupDescriptionCell.self, forCellWithReuseIdentifier: createGroupDescriptionCellReuseIdentifier)
        collectionView.register(GroupVisibilityCell.self, forCellWithReuseIdentifier: createGroupVisibilityCellReuseIdentifier)
        collectionView.register(GroupCategoriesCell.self, forCellWithReuseIdentifier: createGroupCategoriesCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func groupIsValid() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.groupIsValid
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    private func cropImage(image: UIImage) {
        let vc = CropViewController(image: image)
        vc.aspectRatioLockEnabled = true
        vc.delegate = self
        vc.doneButtonTitle = "Done"
        vc.aspectRatioPickerButtonHidden = true
        vc.resetButtonHidden = true
        vc.cancelButtonTitle = "Cancel"
        
        if self.isProfile {
            vc.aspectRatioPreset = .presetSquare
        } else {
            vc.aspectRatioPreset = .presetCustom
            vc.customAspectRatio = CGSize(width: 4, height: 1)
        }
        
        self.present(vc, animated: true)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func handleCreateGroup() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let groupName = viewModel.name, let groupDescription = viewModel.description else { return }
        
        var groupToUpload = Group(groupId: "", dictionary: [:])
        
        groupToUpload.name = groupName
        groupToUpload.description = groupDescription
        groupToUpload.ownerUid = uid
        groupToUpload.visibility = visibilityState
        groupToUpload.categories = groupCategories
        groupToUpload.memberType = .owner
        
        progressIndicator.show(in: view)
        
        if viewModel.hasBothImages {
            // Upload banner and profile
            let imagesToUpload = [groupBannerImage, groupProfileImage]
            StorageManager.uploadGroupImages(images: imagesToUpload) { urls in
                self.progressIndicator.dismiss(animated: true)
                groupToUpload.bannerUrl = urls[0]
                groupToUpload.profileUrl = urls[1]
                
                GroupService.uploadGroup(group: groupToUpload) { error in
                    guard error == nil else { return }
                    #warning("present group page")
                }
            }
        } else {
            if viewModel.hasProfile {
                StorageManager.uploadGroupImage(image: groupProfileImage) { url in
                    self.progressIndicator.dismiss(animated: true)
                    groupToUpload.profileUrl = url
                    
                    GroupService.uploadGroup(group: groupToUpload) { error in
                        guard error == nil else { return }
                        #warning("present group page")
                    }
                }
            } else if viewModel.hasBanner {
                StorageManager.uploadGroupImage(image: groupBannerImage) { url in
                    self.progressIndicator.dismiss(animated: true)
                    groupToUpload.bannerUrl = url
                    
                    GroupService.uploadGroup(group: groupToUpload) { error in
                        guard error == nil else { return }
                        #warning("present group page")
                    }
                }
            } else {
                // No banner no profile
                GroupService.uploadGroup(group: groupToUpload) { error in
                    self.progressIndicator.dismiss(animated: true)
                    guard error == nil else { return }
                    #warning("present group page")
                }
            }
        }
    }
    
    private func createLeftAlignedLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(          // this is your cell
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .estimated(40),         // variable width
                heightDimension: .absolute(40)          // fixed height
            )
        )
        
        item.contentInsets = .init(top: 0, leading: 0, bottom: 10, trailing: 0)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30)), subitems: [item])
        group.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        group.interItemSpacing = .fixed(10)
        
        return UICollectionViewCompositionalLayout(section: .init(group: group))
    }
}


extension CreateGroupViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        GroupSections.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupImageCellReuseIdentifier, for: indexPath) as! EditProfilePictureCell
            cell.delegate = self
            cell.profileImageView.layer.cornerRadius = 7
            return cell
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: GroupSections.allCases[indexPath.row].rawValue, placeholder: "Group name", name: "")
            cell.delegate = self
            return cell
        } else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupDescriptionCellReuseIdentifier, for: indexPath) as! GroupDescriptionCell
            cell.set(title: GroupSections.allCases[indexPath.row].rawValue)
            cell.delegate = self
            return cell
        } else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupVisibilityCellReuseIdentifier, for: indexPath) as! GroupVisibilityCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupCategoriesCellReuseIdentifier, for: indexPath) as! GroupCategoriesCell
            cell.delegate = self
            return cell
        }
    }
}

extension CreateGroupViewController: GroupCategoriesCellDelegate {

    func didSelectAddCategory(withSelectedCategories categories: [Category]) {
        let controller = CategoryListViewController(selectedCategories: categories)
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .black
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension CreateGroupViewController: EditProfilePictureCellDelegate {
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

extension CreateGroupViewController: CategoryListViewControllerDelegate {
    func didTapAddCategories(categories: [Category]) {
        if let cell = collectionView.cellForItem(at: IndexPath(item: GroupSections.groupCategories.index, section: 0)) as? GroupCategoriesCell {
            cell.updateCategories(categories: categories)
            categories.forEach { category in
                groupCategories.append(category.name)
            }
            
        }
    }
}

extension CreateGroupViewController: RegisterBottomMenuLauncherDelegate {
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

extension CreateGroupViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension CreateGroupViewController: EditNameCellDelegate {
    func textDidChange(_ cell: UICollectionViewCell, text: String) {
        viewModel.name = text
        groupIsValid()
    }
}

extension CreateGroupViewController: GroupDescriptionCellDelegate {
    func descriptionDidChange(text: String) {
        viewModel.description = text
        groupIsValid()
    }
}

extension CreateGroupViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        let cell = collectionView.cellForItem(at: IndexPath.init(row: 0, section: 0)) as! EditProfilePictureCell
        
        if isProfile {
            cell.profileImageView.image = image
            cell.hideProfileHint()
            groupProfileImage = image
            viewModel.profileImage = true
        } else {
            cell.bannerImageView.image = image
            cell.hideBannerHint()
            groupBannerImage = image
            viewModel.profileBanner = true
        }
    }
}
