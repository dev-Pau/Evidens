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
private let createGroupPermissionCellReuseIdentifier = "CreateGroupPermissionCellReuseIdentifier"
private let createGroupCategoriesCellReuseIdentifier = "CreateGroupCategoriesCellReuseIdentifier"
private let createGroupCategoryCellReuseIdentifier = "CreateGroupCategoryCellReuseIdentifier"

protocol CreateGroupViewControllerDelegate: AnyObject {
    func didUpdateGroup(_ group: Group)
    func didCreateGroup(_ group: Group)
}

class CreateGroupViewController: UIViewController {
    
    weak var delegate: CreateGroupViewControllerDelegate?
    
    private var viewModel = CreateGroupViewModel()
    
    private var group: Group?
    
    enum GroupSections: String, CaseIterable {
        case groupPictures = "Group Pictures"
        case groupName = "Name"
        case groupDescription = "Description"
        case groupProfession = "Profession"
        case groupVisibility = "Visibility"
        case groupPermission = "Permission"
        case groupCategories = "Categories"
        
        var index: Int {
            switch self {
            case .groupPictures:
                return 0
            case .groupName:
                return 1
            case .groupDescription:
                return 2
            case .groupProfession:
                return 3
            case .groupCategories:
                return 4
            case .groupVisibility:
                return 5
            case .groupPermission:
                return 6
            }
        }
    }
    
    private let imageBottomMenuLanucher = RegisterBottomMenuLauncher()
    
    private var groupBannerImage = UIImage()
    private var groupProfileImage = UIImage()
    private var visibilityState: GroupVisibility = .visible
    private var groupPermissions: GroupPermission = .invite
    private var groupCategories = [String]()
    
    private var isProfile: Bool = false
    private var profileImageChanged: Bool = false
    
    private var isBanner: Bool = false
    private var bannerImageChanged: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var createGroupButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleCreateGroup), for: .touchUpInside)
        return button
    }()
    
    private let progressIndicator = JGProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        imageBottomMenuLanucher.delegate = self
        configureNavigationBar()
        configureCollectionView()
        configureUI()
    }
    
    init(group: Group? = nil) {
        self.group = group
        if let group = group {
            viewModel.name = group.name
            viewModel.description = group.description
            viewModel.categories = group.categories
            viewModel.professions = group.professions
            viewModel.visibility = group.visibility
            viewModel.permissions = group.permissions
        } else {
            viewModel.visibility = .visible
            viewModel.permissions = .invite
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = group != nil ? "Edit Group" : "Create Group"
        let buttonTitle = group != nil ? "Edit" : "Create"
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .bold)
        createGroupButton.configuration?.attributedTitle = AttributedString(buttonTitle, attributes: container)
        
        let leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .label
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: createGroupButton)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureCollectionView() {
        collectionView.register(EditProfilePictureCell.self, forCellWithReuseIdentifier: createGroupImageCellReuseIdentifier)
        collectionView.register(EditNameCell.self, forCellWithReuseIdentifier: createGroupNameCellReuseIdentifier)
        collectionView.register(EditCategoryCell.self, forCellWithReuseIdentifier: createGroupCategoryCellReuseIdentifier)
        collectionView.register(GroupDescriptionCell.self, forCellWithReuseIdentifier: createGroupDescriptionCellReuseIdentifier)
        collectionView.register(GroupVisibilityCell.self, forCellWithReuseIdentifier: createGroupVisibilityCellReuseIdentifier)
        collectionView.register(GroupPermissionCell.self, forCellWithReuseIdentifier: createGroupPermissionCellReuseIdentifier)
        collectionView.register(GroupCategoriesCell.self, forCellWithReuseIdentifier: createGroupCategoriesCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func groupIsValid() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.groupIsValid
    }
    
    private func configureUI() {
        print(groupPermissions)
        view.backgroundColor = .systemBackground
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
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let groupName = viewModel.name, let groupDescription = viewModel.description, let groupCategories = viewModel.categories, let professions = viewModel.professions, let visibility = viewModel.visibility, let permissions = viewModel.permissions else { return }
        
        var groupToUpload = Group(groupId: "", dictionary: [:])
        
        groupToUpload.name = groupName
        groupToUpload.description = groupDescription
        groupToUpload.professions = professions
        groupToUpload.ownerUid = uid
        groupToUpload.visibility = visibility
        groupToUpload.permissions = permissions
        groupToUpload.categories = groupCategories
        
        if let group = group {
            progressIndicator.show(in: view)
            // Editing group. Check what fields have changed between the original group
            if bannerImageChanged && profileImageChanged {
                // Other group fields have changed
                StorageManager.uploadGroupImages(images: [groupBannerImage, groupProfileImage], groupId: group.groupId) { urls in
                    groupToUpload.bannerUrl = urls.first(where: { url in
                        url.contains("banners")
                    })
                    
                    groupToUpload.profileUrl = urls.first(where: { url in
                        url.contains("profiles")
                    })
                    
                    GroupService.updateGroup(from: group, to: groupToUpload) { group in
                        self.progressIndicator.dismiss(animated: true)
                        self.dismiss(animated: true)
                        self.delegate?.didUpdateGroup(group)
                    }
                }
            } else {
                if bannerImageChanged {
                    // Banner group image has changed
                    StorageManager.uploadGroupImage(image: groupProfileImage, isProfile: false, groupId: group.groupId) { url in
                        groupToUpload.profileUrl = url
                        GroupService.updateGroup(from: group, to: groupToUpload) { group in
                            self.progressIndicator.dismiss(animated: true)
                            self.dismiss(animated: true)
                            self.delegate?.didUpdateGroup(group)
                        }
                    }
                } else if profileImageChanged {
                    // Profile group image has changed
                    StorageManager.uploadGroupImage(image: groupProfileImage, isProfile: true, groupId: group.groupId) { url in
                        groupToUpload.profileUrl = url
                        GroupService.updateGroup(from: group, to: groupToUpload) { group in
                            self.progressIndicator.dismiss(animated: true)
                            self.dismiss(animated: true)
                            self.delegate?.didUpdateGroup(group)
                        }
                    }
                } else {
                    // Other group fields have changed
                    GroupService.updateGroup(from: group, to: groupToUpload) { group in
                        self.progressIndicator.dismiss(animated: true)
                        self.dismiss(animated: true)
                        self.delegate?.didUpdateGroup(group)
                    }
                }
            }
        } else {
            // New group
            // Create a new group with a document reference in Firestore
            //groupToUpload.groupId = COLLECTION_GROUPS.document().documentID
            groupToUpload.groupId = COLLECTION_GROUPS.document().documentID
            groupToUpload.members = 1
            progressIndicator.show(in: view)
            
            if viewModel.hasBothImages {
                // Upload banner and profile
                let imagesToUpload = [groupBannerImage, groupProfileImage]
                StorageManager.uploadGroupImages(images: imagesToUpload, groupId: groupToUpload.groupId) { urls in
                    self.progressIndicator.dismiss(animated: true)
                    
                    groupToUpload.bannerUrl = urls.first(where: { url in
                        url.contains("banners")
                    })
                    
                    groupToUpload.profileUrl = urls.first(where: { url in
                        url.contains("profiles")
                    })

                    GroupService.uploadGroup(group: groupToUpload) { error in
                        guard error == nil else { return }
                        self.pushGroupViewController(withGroup: groupToUpload)
                    }
                }
            } else {
                if viewModel.hasProfile {
                    StorageManager.uploadGroupImage(image: groupProfileImage, isProfile: true, groupId: groupToUpload.groupId) { url in
                        self.progressIndicator.dismiss(animated: true)
                        groupToUpload.profileUrl = url
                        
                        GroupService.uploadGroup(group: groupToUpload) { error in
                            guard error == nil else { return }
                            self.pushGroupViewController(withGroup: groupToUpload)
                        }
                    }
                } else if viewModel.hasBanner {
                    StorageManager.uploadGroupImage(image: groupBannerImage, isProfile: false, groupId: groupToUpload.groupId) { url in
                        self.progressIndicator.dismiss(animated: true)
                        groupToUpload.bannerUrl = url
                        
                        GroupService.uploadGroup(group: groupToUpload) { error in
                            guard error == nil else { return }
                            self.pushGroupViewController(withGroup: groupToUpload)
                        }
                    }
                } else {
                    // No banner no profile
                    GroupService.uploadGroup(group: groupToUpload) { error in
                        self.progressIndicator.dismiss(animated: true)
                        guard error == nil else { return }
                        self.pushGroupViewController(withGroup: groupToUpload)
                    }
                }
            }
        }
    }
    
    private func pushGroupViewController(withGroup group: Group) {
        delegate?.didCreateGroup(group)
        self.dismiss(animated: true)
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
            cell.profileImageView.image = UIImage(named: "group.profile")
            cell.profileImageView.layer.cornerRadius = 7
            //cell.editProfileButton.configuration?.image = UIImage(named: "group.profile")?.scalePreservingAspectRatio(targetSize: CGSize(width: 70, height: 70))
            if let group = group {
                cell.set(bannerImageUrl: group.bannerUrl!)
                cell.set(profileImageUrl: group.profileUrl!)
            }
            return cell
            
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: GroupSections.allCases[indexPath.row].rawValue, placeholder: "Group name", name: group?.name ?? "")
            cell.delegate = self
            return cell
            
        } else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupDescriptionCellReuseIdentifier, for: indexPath) as! GroupDescriptionCell
            cell.set(title: GroupSections.allCases[indexPath.row].rawValue)
            if let group = group { cell.set(description: group.description) }
            cell.delegate = self
            return cell
        } else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: Job.JobSections.professions.rawValue, placeholder: GroupSections.allCases[indexPath.row].rawValue, name: "")
            cell.disableTextField()
            if let group = group { cell.set(text: group.professions.joined(separator: ", ")) }
            return cell
        } else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupCategoriesCellReuseIdentifier, for: indexPath) as! GroupCategoriesCell
            if let group = group { cell.updateCategories(categories: group.categories) }
            cell.delegate = self
            return cell
        } else if indexPath.row == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupVisibilityCellReuseIdentifier, for: indexPath) as! GroupVisibilityCell
            cell.delegate = self
            if let group = group { cell.setVisibility(visibility: group.visibility) }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupPermissionCellReuseIdentifier, for: indexPath) as! GroupPermissionCell
            cell.delegate = self
            if let group = group { cell.setPermissions(permissions: group.permissions) }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            let controller = JobAssistantViewController(jobSection: .professions)
            
            if let professions = viewModel.professions {
                controller.selectedProfessions = professions
            }
            
            controller.allowsMultipleSelection = true
            controller.multipleDelegate = self
            let backItem = UIBarButtonItem()
            backItem.tintColor = .label
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension CreateGroupViewController: GroupCategoriesCellDelegate {

    func didSelectAddCategory(withSelectedCategories categories: [Category]) {
        let controller = CategoryListViewController(selectedCategories: categories.reversed(), categories: Category.allCategories())
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
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

extension CreateGroupViewController: GroupVisibilityCellDelegate {
    func didTapVisibility() {
        if visibilityState == .nonVisible {
            visibilityState = .visible
        } else {
            visibilityState = .nonVisible
        }
        
        viewModel.visibility = visibilityState
        groupIsValid()
    }
}

extension CreateGroupViewController: GroupPermissionCellDelegate {
    func didUpdatePermissions(permissions: GroupPermission) {
        groupPermissions = permissions
        viewModel.permissions = groupPermissions
        groupIsValid()
    }
}

extension CreateGroupViewController: CategoryListViewControllerDelegate {
    func didTapAddCategories(categories: [Category]) {
        if let cell = collectionView.cellForItem(at: IndexPath(item: GroupSections.groupCategories.index, section: 0)) as? GroupCategoriesCell {
            groupCategories.removeAll()
            cell.updateCategories(categories: categories)
            

            categories.forEach { category in
                groupCategories.append(category.name)
                viewModel.categories = groupCategories
                groupIsValid()
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

extension CreateGroupViewController: JobAssistantMultipleViewControllerDelegate {
    func didSelectItems(_ text: [String]) {
        let cell = collectionView.cellForItem(at: IndexPath(item: 3, section: 0)) as! EditNameCell
        let professions = text.joined(separator: ", ")
        cell.set(text: professions)
        viewModel.professions = text
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
        
        groupIsValid()
        
        if isProfile {
            cell.profileImageView.image = image
            cell.hideProfileHint()
            groupProfileImage = image
            viewModel.profileImage = true
            if let _ = group { profileImageChanged = true }
        } else {
            cell.bannerImageView.image = image
            groupBannerImage = image
            viewModel.profileBanner = true
            if let _ = group { bannerImageChanged = true }
        }
    }
}
