//
//  ShareCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/4/23.
//

import UIKit
import PhotosUI
import JGProgressHUD

private let shareCaseImageCellReuseIdentifier = "ShareCaseImageCellReuseIdentifier"
private let shareCaseInformationFooterReuseIdentifier = "ShareCaseInformationFooter"

class ShareCaseViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var user: User
    private var group: Group?
    private var caseImages = [UIImage]()
    private var progressIndicator = JGProgressHUD()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Share", attributes: container)
        //button.addTarget(self, action: #selector(handleShareCase), for: .touchUpInside)
        return button
    }()
    
    
    init(user: User, group: Group? = nil) {
        self.user = user
        if let group = group {
            //casePrivacy = .group
            self.group = group
        }
        
        // Assign primary user profession to categorize the clinical case
        //professionsSelected = [Profession(profession: user.profession!)]
        
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
        title = "Share Case"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(ShareCaseImageCell.self, forCellWithReuseIdentifier: shareCaseImageCellReuseIdentifier)
        collectionView.register(ShareCaseInformationFooter.self, forSupplementaryViewOfKind: ElementKind.sectionFooter, withReuseIdentifier: shareCaseInformationFooterReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: self.caseImages.isEmpty ? .fractionalWidth(1) : .estimated(200), heightDimension: .fractionalHeight(1)))
           
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: self.caseImages.isEmpty ? .fractionalWidth(0.93) : .estimated(200), heightDimension: .absolute(200)), subitems: [item])
            
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), elementKind: ElementKind.sectionFooter, alignment: .bottom)
                                                                     
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [footer]
            section.orthogonalScrollingBehavior = self.caseImages.isEmpty ? .groupPagingCentered : .continuousGroupLeadingBoundary
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
            return section
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
}

extension ShareCaseViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return caseImages.isEmpty ? 1 : caseImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: shareCaseInformationFooterReuseIdentifier, for: indexPath) as! ShareCaseInformationFooter
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shareCaseImageCellReuseIdentifier, for: indexPath) as! ShareCaseImageCell
        if !caseImages.isEmpty { cell.caseImage = caseImages[indexPath.row] } else {
            cell.restartCellConfiguration()
        }
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard caseImages.isEmpty else { return }
            handlePhotoTap()
        }
    }
}

extension ShareCaseViewController: ShareCaseImageCellDelegate {
    func delete(_ cell: ShareCaseImageCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            collectionView.performBatchUpdates {
                caseImages.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
            }
        }
    }
}

extension ShareCaseViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        if results.count == 0 { return }
        progressIndicator.show(in: view)
        let group = DispatchGroup()
        var asyncDict = [String:UIImage]()
        var order = [String]()
        var images = [UIImage]()
        
        
        results.forEach { result in
            group.enter()
            order.append(result.assetIdentifier ?? "")
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                defer {
                    group.leave()
                }
                guard let image = reading as? UIImage, error == nil else { return }
                asyncDict[result.assetIdentifier ?? ""] = image
            }
        }
        
        group.notify(queue: .main) {
            for id in order {
                images.append(asyncDict[id]!)
                if images.count == results.count {
                    self.caseImages = images
                    self.collectionView.reloadSections(IndexSet(integer: 0))
                    self.progressIndicator.dismiss(animated: true)
                }
            }
        }
    }
}
    
