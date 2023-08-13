//
//  ShareCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/4/23.
//

import UIKit
import PhotosUI

private let shareCaseImageCellReuseIdentifier = "ShareCaseImageCellReuseIdentifier"
private let shareCaseInformationFooterReuseIdentifier = "ShareCaseInformationFooter"
private let shareCasePrivacyCellReuseIdentifier = "ShareCasePrivacyCellReuseIdentifier"
private let shareCaseTitleCellReuseIdentifier = "ShareCaseTitleCellReuseIdentifier"
private let shareCaseDescriptionCellReuseIdentifier = "ShareCaseDescriptionCellReuseIdentifier"
private let shareCaseSpecialitiesCellReuseIdentifier = "ShareCaseSpecialitiesCellReuseIdentifier"
private let shareCaseEditHeaderReuseIdentifier = "ShareCaseEditHeaderReuseIdentifier"
private let shareCaseSeparatorFooterReuseIdentifier = "ShareCaseSeparatorFooterReuseIdentifier"

class ShareCaseViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var viewModel: ShareCaseViewModel
    
    private var casePrivacyMenuLauncher = CasePrivacyMenu()
    private var user: User

    private var activeIndexPath = IndexPath(item: 0, section: 0)

    init(user: User, viewModel: ShareCaseViewModel) {
        self.user = user
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }

    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Miscellaneous.next, style: .done, target: self, action: #selector(handleShareCase))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(ShareCaseImageCell.self, forCellWithReuseIdentifier: shareCaseImageCellReuseIdentifier)
        collectionView.register(CasePrivacyFooter.self, forSupplementaryViewOfKind: ElementKind.sectionFooter, withReuseIdentifier: shareCaseInformationFooterReuseIdentifier)
        collectionView.register(CasePrivacyCell.self, forCellWithReuseIdentifier: shareCasePrivacyCellReuseIdentifier)
        collectionView.register(CaseTitleCell.self, forCellWithReuseIdentifier: shareCaseTitleCellReuseIdentifier)
        collectionView.register(CaseDescriptionCell.self, forCellWithReuseIdentifier: shareCaseDescriptionCellReuseIdentifier)
        collectionView.register(SecondarySpecialityCell.self, forCellWithReuseIdentifier: shareCaseSpecialitiesCellReuseIdentifier)
        collectionView.register(EditCaseHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: shareCaseEditHeaderReuseIdentifier)
        collectionView.register(CaseSeparatorFooter.self, forSupplementaryViewOfKind: ElementKind.sectionFooter, withReuseIdentifier: shareCaseSeparatorFooterReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .onDrag
        view.addSubviews(collectionView)
        
        casePrivacyMenuLauncher.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                              selector: #selector(keyboardWillHide(notification:)),
                                              name: UIResponder.keyboardWillHideNotification,
                                              object:nil)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            if sectionNumber == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: strongSelf.viewModel.images.isEmpty ? .fractionalWidth(1) : .estimated(200), heightDimension: .fractionalHeight(1)))
               
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: strongSelf.viewModel.images.isEmpty ? .fractionalWidth(0.93) : .estimated(200), heightDimension: .absolute(200)), subitems: [item])
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), elementKind: ElementKind.sectionFooter, alignment: .bottom)
                                                                         
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [footer]
                section.orthogonalScrollingBehavior = strongSelf.viewModel.images.isEmpty ? .groupPagingCentered : .continuousGroupLeadingBoundary
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
                return section
            } else if sectionNumber == 4 || sectionNumber == 5 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(300), heightDimension: .absolute(40)))
               
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(300), heightDimension: .absolute(40)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(20)), elementKind: ElementKind.sectionHeader, alignment: .top)
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(1)), elementKind: ElementKind.sectionFooter, alignment: .bottom)
                section.boundarySupplementaryItems = [footer]
                
                if sectionNumber == 4 {
                    if !strongSelf.viewModel.specialities.isEmpty { section.boundarySupplementaryItems.append(header) }
                } else {
                    if !strongSelf.viewModel.items.isEmpty { section.boundarySupplementaryItems.append(header) }
                }

                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                return section
                
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
               
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)

                return section
            }
        }
        
        return layout
    }
    
    @objc func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc func handlePhotoTap() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 6
        config.preferredAssetRepresentationMode = .current
        config.selection = .ordered
        config.filter = PHPickerFilter.any(of: [.images])
        
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let keyboardViewEndFrame = view.convert(keyboardSize, from: view.window)
            
            if notification.name == UIResponder.keyboardWillHideNotification {
                collectionView.contentInset = .zero
            } else {
                collectionView.contentInset = UIEdgeInsets(top: 0,
                                                           left: 0,
                                                           bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + 20,
                                                           right: 0)
                collectionView.scrollToItem(at: activeIndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        collectionView.contentInset = .zero
    }
    
    @objc func handleShareCase() {
        let controller = ShareCaseStageViewController(viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ShareCaseViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.images.isEmpty ? 1 : viewModel.images.count
        } else if section == 4 {
            return viewModel.specialities.isEmpty ? 1 : viewModel.specialities.count
        } else if section == 5 {
            return viewModel.items.isEmpty ? 1 : viewModel.items.count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: shareCaseInformationFooterReuseIdentifier, for: indexPath) as! CasePrivacyFooter
            footer.delegate = self
            return footer
        } else {
            if kind == ElementKind.sectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: shareCaseEditHeaderReuseIdentifier, for: indexPath) as! EditCaseHeader
                if indexPath.section == 4 {
                    header.setTitle(AppStrings.Opening.specialities)
                } else {
                    header.setTitle(AppStrings.Content.Case.Share.details)
                }
                
                return header
            } else {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: shareCaseSeparatorFooterReuseIdentifier, for: indexPath) as! CaseSeparatorFooter
                return footer
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shareCaseImageCellReuseIdentifier, for: indexPath) as! ShareCaseImageCell
            if !viewModel.images.isEmpty { cell.caseImage = viewModel.images[indexPath.row] } else {
                cell.restartCellConfiguration()
            }
            cell.delegate = self
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shareCasePrivacyCellReuseIdentifier, for: indexPath) as! CasePrivacyCell
            cell.viewModel = viewModel
            return cell
        } else if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shareCaseTitleCellReuseIdentifier, for: indexPath) as! CaseTitleCell
            cell.delegate = self
            return cell
        } else if indexPath.section == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shareCaseDescriptionCellReuseIdentifier, for: indexPath) as! CaseDescriptionCell
            cell.delegate = self
            return cell
        } else if indexPath.section == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shareCaseSpecialitiesCellReuseIdentifier, for: indexPath) as! SecondarySpecialityCell

            if viewModel.specialities.isEmpty {
                cell.configureWithDefaultSettings(AppStrings.Opening.specialities)
            } else {
                cell.configureWithSpeciality(viewModel.specialities[indexPath.row])
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shareCaseSpecialitiesCellReuseIdentifier, for: indexPath) as! SecondarySpecialityCell
            
            if viewModel.items.isEmpty {
                cell.configureWithDefaultSettings(AppStrings.Content.Case.Share.details)
            } else {
                cell.configureWithItem(viewModel.items[indexPath.row])
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard viewModel.images.isEmpty else { return }
            handlePhotoTap()
        } else if indexPath.section == 1 {
            casePrivacyMenuLauncher.showPostSettings(in: view)
        } else if indexPath.section == 4 {
            let controller = SpecialityListViewController(filteredSpecialities: viewModel.specialities, professions: viewModel.disciplines)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
            
        } else if indexPath.section == 5 {
            let controller = ClinicalTypeViewController(selectedItems: viewModel.items)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension ShareCaseViewController: ShareCaseImageCellDelegate {
    func delete(_ cell: ShareCaseImageCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            collectionView.performBatchUpdates {
                viewModel.removeImage(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
            }
        }
    }
}

extension ShareCaseViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        if results.count == 0 { return }
        showProgressIndicator(in: view)
        let group = DispatchGroup()
        var asyncDict = [String:UIImage]()
        var order = [String]()
        var images = [UIImage]()
        
        
        results.forEach { result in
            group.enter()
            order.append(result.assetIdentifier ?? "")
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                guard let _ = self else { return }
                defer {
                    group.leave()
                }
                guard let image = reading as? UIImage, error == nil else { return }
                asyncDict[result.assetIdentifier ?? ""] = image
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            for id in order {
                images.append(asyncDict[id]!)
                if images.count == results.count {
                    strongSelf.viewModel.images = images
                    strongSelf.collectionView.reloadSections(IndexSet(integer: 0))
                    strongSelf.dismissProgressIndicator()
                }
            }
        }
    }
}

extension ShareCaseViewController: CasePrivacyMenuDelegate {
    func didTapPrivacyOption(_ option: CasePrivacy) {
            viewModel.privacy = option
            collectionView.reloadSections(IndexSet(integer: 1))
    }
}

extension ShareCaseViewController: CaseTitleCellDelegate {
    func didUpdateTitle(_ text: String) {
        viewModel.title = text
        updateForm()
        activeIndexPath = IndexPath(item: 0, section: 2)
    }
}

extension ShareCaseViewController: CaseDescriptionCellDelegate {
    func didUpdateDescription(_ text: String, withHashtags hashtags: [String]) {
        viewModel.description = text
        viewModel.hashtags = hashtags
        updateForm()
        activeIndexPath = IndexPath(item: 0, section: 3)
        collectionView.performBatchUpdates(nil, completion: nil)
    }
}

extension ShareCaseViewController: SpecialityListViewControllerDelegate {
    func presentSpecialities(_ specialities: [Speciality]) {
        viewModel.specialities = specialities
        collectionView.reloadSections(IndexSet(integer: 4))
        updateForm()
    }
}

extension ShareCaseViewController: ClinicalTypeViewControllerDelegate {
    func didSelectCaseType(_ types: [CaseItem]) {
        viewModel.items = types
        collectionView.reloadSections(IndexSet(integer: 5))
        updateForm()
    }
    
    func didSelectCaseType(type: CaseItem) { return }
}

extension ShareCaseViewController: ShareContentViewModel {
    func updateForm() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.caseIsValid
    }
}

extension ShareCaseViewController: ShareCaseInformationFooterDelegate {
    func didTapPatientPrivacy() {
        if let url = URL(string: AppStrings.URL.patientPrivacy) {
            if UIApplication.shared.canOpenURL(url) {
                presentSafariViewController(withURL: url)
            } else {
                presentWebViewController(withURL: url)
            }
        }
    }
}
