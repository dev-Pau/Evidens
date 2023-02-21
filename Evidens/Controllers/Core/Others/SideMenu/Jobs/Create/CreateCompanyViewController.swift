//
//  CreateCompanyViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/2/23.
//

import UIKit
import PhotosUI
import CropViewController
import JGProgressHUD

private let createCompanyImageCellReuseIdentifier = "CreateCompanyImageCellReuseIdentifier"
private let createCompanyNameCellReuseIdentifier = "CreateGroupNameCellReuseIdentifier"
private let createCompanyDescriptionCellReuseIdentifier = "CreateCompanyDescriptionCellReuseIdentifier"
private let createCompanyCategoriesCellReuseIdentifier = "CreateCompanyCategoriesCellReuseIdentifier"

protocol CreateCompanyViewControllerDelegate: AnyObject {
    func didCreateCompany(company: Company)
}

class CreateCompanyViewController: UIViewController {
    
    weak var delegate: CreateCompanyViewControllerDelegate?
    
    private var companyImageChanged: Bool = false
    private var companyProfileImage = UIImage()
    
    private let user: User
    
    private let imageBottomMenuLanucher = RegisterBottomMenuLauncher()
    
    private var viewModel = CreateCompanyViewModel()
    
    private var selectedIndex: Int = 0
    var isControllerPresented: Bool = false
    
    private var companyCategories = [String]()
    
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
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageBottomMenuLanucher.delegate = self
        configureUI()
        configureNavigationBar()
        configureCollectionView()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Create a company"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(handleCreateCompany))
        navigationItem.rightBarButtonItem?.isEnabled = false
        if isControllerPresented {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        }
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EditProfilePictureCell.self, forCellWithReuseIdentifier: createCompanyImageCellReuseIdentifier)
        collectionView.register(EditNameCell.self, forCellWithReuseIdentifier: createCompanyNameCellReuseIdentifier)
        collectionView.register(GroupDescriptionCell.self, forCellWithReuseIdentifier: createCompanyDescriptionCellReuseIdentifier)
        collectionView.register(GroupCategoriesCell.self, forCellWithReuseIdentifier: createCompanyCategoriesCellReuseIdentifier)
    }
    
    private func companyIsValid() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.companyIsValid
    }
    
    @objc func handleCreateCompany() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let companyName = viewModel.name, let companyLocation = viewModel.location, let companyDescription = viewModel.description, let industry = viewModel.industry, let specialities = viewModel.specialities else { return }
        
        var companyToUpload = Company(dictionary: [:])
        
        companyToUpload.id = COLLECTION_COMPANIES.document().documentID
        companyToUpload.ownerUid = uid
        companyToUpload.location = companyLocation
        companyToUpload.name = companyName
        companyToUpload.description = companyDescription
        companyToUpload.industry = industry
        companyToUpload.specialities = specialities
        
        progressIndicator.show(in: view)
        
        if viewModel.hasProfile {
            StorageManager.uploadCompanyImage(image: companyProfileImage, companyId: companyToUpload.id) { url in
                companyToUpload.companyImageUrl = url
                
                CompanyService.uploadCompany(company: companyToUpload) { error in
                    self.progressIndicator.dismiss(animated: true)
                    guard error == nil else { return }
                    // Company uploaded
                    self.delegate?.didCreateCompany(company: companyToUpload)
                    if self.isControllerPresented {
                        self.dismiss(animated: true)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            CompanyService.uploadCompany(company: companyToUpload) { error in
                self.progressIndicator.dismiss(animated: true)
                guard error == nil else { return }
                // Company uploaded
                self.delegate?.didCreateCompany(company: companyToUpload)
                if self.isControllerPresented {
                    self.dismiss(animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension CreateCompanyViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createCompanyImageCellReuseIdentifier, for: indexPath) as! EditProfilePictureCell
            cell.delegate = self
            cell.profileImageView.layer.cornerRadius = 0
            //if let group = group {
              //  cell.set(bannerImageUrl: group.bannerUrl!)
                //cell.set(profileImageUrl: group.profileUrl!)
            //}
            return cell
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createCompanyNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: "Company", placeholder: "Company name", name: "")
            cell.delegate = self
            return cell
        } else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createCompanyDescriptionCellReuseIdentifier, for: indexPath) as! GroupDescriptionCell
            cell.set(title: Job.JobSections.description.rawValue)
            cell.set(placeholder: "Add a company description")
            //if let group = group { cell.set(description: group.description) }
            cell.delegate = self
            return cell
        } else if indexPath.row == 3 {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createCompanyNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: Job.JobSections.location.rawValue, placeholder: "Location", name: "")
            cell.disableTextField()
            return cell
        } else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createCompanyNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: "Industry", placeholder: "Industry", name: "")
            cell.disableTextField()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createCompanyCategoriesCellReuseIdentifier, for: indexPath) as! GroupCategoriesCell
            cell.updateText(text: "Categories")
            //let category = user.category
            //cell.updateCategories(categories: [Category(name: user.profession!)])
            //if let group = group { cell.updateCategories(categories: group.categories) }
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if indexPath.row == 3 {
            let controller = JobAssistantViewController(jobSection: .location)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 4 {
            let controller = JobAssistantViewController(jobSection: .title)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension CreateCompanyViewController: JobAssistantViewControllerDelegate {
    func didSelectItem(_ text: String) {
        let cell = collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as! EditNameCell
        cell.set(text: text)
        if selectedIndex == 3 {
            viewModel.location = text
        } else {
            viewModel.industry = text
        }
        companyIsValid()
    }
}

extension CreateCompanyViewController: GroupCategoriesCellDelegate {
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

extension CreateCompanyViewController: CategoryListViewControllerDelegate {
    func didTapAddCategories(categories: [Category]) {
        if let cell = collectionView.cellForItem(at: IndexPath(item: 5, section: 0)) as? GroupCategoriesCell {
            companyCategories.removeAll()
            cell.updateCategories(categories: categories)
            companyCategories = categories.map( { $0.name })
            viewModel.specialities = categories.map( { $0.name })
            companyIsValid()
            // categories.forEach { category in
            //   companyCategories.append(category.name)
            //viewModel.categories = groupCategories
            //groupIsValid()
        }
    }
}

extension CreateCompanyViewController: EditProfilePictureCellDelegate {
    func didTapChangeProfilePicture() {
        imageBottomMenuLanucher.showImageSettings(in: view)
    }
    
    func didTapChangeBannerPicture() { return }
    
}

extension CreateCompanyViewController: EditNameCellDelegate {
    func textDidChange(_ cell: UICollectionViewCell, text: String) {
        viewModel.name = text
        companyIsValid()
    }
}

extension CreateCompanyViewController: GroupDescriptionCellDelegate {
    func descriptionDidChange(text: String) {
        viewModel.description = text
        companyIsValid()
    }
}

extension CreateCompanyViewController: RegisterBottomMenuLauncherDelegate {
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

extension CreateCompanyViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    private func cropImage(image: UIImage) {
        let vc = CropViewController(image: image)
        vc.aspectRatioLockEnabled = true
        vc.delegate = self
        vc.doneButtonTitle = "Done"
        vc.aspectRatioPickerButtonHidden = true
        vc.resetButtonHidden = true
        vc.cancelButtonTitle = "Cancel"
        vc.aspectRatioPreset = .presetSquare
        self.present(vc, animated: true)
    }
}


extension CreateCompanyViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        let cell = collectionView.cellForItem(at: IndexPath.init(row: 0, section: 0)) as! EditProfilePictureCell
        cell.profileImageView.image = image
        cell.hideProfileHint()
        companyImageChanged = true
        companyProfileImage = image
        viewModel.profileImage = true
        //if let _ = group { profileImageChanged = true }
    }
}


