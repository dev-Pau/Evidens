//
//  ShareCaseImagesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/12/23.
//

import UIKit
import PhotosUI

private let contentHeaderCellReuseIdentifier = "ContentHeaderCellReuseIdentifier"
private let contentFooterCellReuseIdentifier = "ContentFooterCellReuseIdentifier"
private let placeholderCaseImageCellReuseIdentifier = "PlaceholderCaseImageCellReuseIdentifier"
private let shareCaseImageCellReuseIdentifier = "ShareCaseImageCellReuseIdentifier"

class ShareCaseImageViewController: UIViewController {
    
    private let user: User
    private var viewModel: ShareCaseViewModel
    
    private var collectionView: UICollectionView!
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .title2, weight: .bold, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Miscellaneous.next, attributes: container)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 0.4
        button.configuration?.background.strokeColor = K.Colors.separatorColor
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .bold)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString(AppStrings.Global.skip, attributes: container)
        button.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    init(user: User, viewModel: ShareCaseViewModel) {
        self.user = user
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance.secondaryAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        addNavigationBarLogo(withTintColor: K.Colors.primaryColor)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: addLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        
        collectionView.register(ContentHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: contentHeaderCellReuseIdentifier)
        collectionView.register(PlaceholderCaseImageCell.self, forCellWithReuseIdentifier: placeholderCaseImageCellReuseIdentifier)
        collectionView.register(CasePrivacyFooter.self, forSupplementaryViewOfKind: ElementKind.sectionFooter, withReuseIdentifier: contentFooterCellReuseIdentifier)
        collectionView.register(ShareCaseImageCell.self, forCellWithReuseIdentifier: shareCaseImageCellReuseIdentifier)
        
        view.addSubviews(collectionView, nextButton, skipButton)
        
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: UIDevice.isPad ? -20 : 0),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            
            skipButton.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10),
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            skipButton.heightAnchor.constraint(equalToConstant: 50),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -10)
        ])
    }
    
    private func addLayout() -> UICollectionViewCompositionalLayout {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)

        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10)
        
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: ElementKind.sectionFooter, alignment: .bottom)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.55))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.top = 20
        item.contentInsets.bottom = 20
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.boundarySupplementaryItems = [header, footer]
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20)
        section.orthogonalScrollingBehavior = .continuous
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func addPhotos() {
        guard viewModel.images.count < 6 else {
            displayAlert(withTitle: AppStrings.Alerts.Title.maxImages)
            return
        }
        
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 6 - viewModel.images.count
        config.preferredAssetRepresentationMode = .current
        config.selection = .ordered
        config.filter = PHPickerFilter.any(of: [.images])
        
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    private func isValid() {
        nextButton.isEnabled = !viewModel.images.isEmpty
    }
    
    @objc func handleNext() {
        let controller = ShareCaseTitleViewController(user: user, viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleSkip() {
        viewModel.images.removeAll()
        
        let controller = ShareCaseTitleViewController(user: user, viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleDismiss() {
        displayAlert(withTitle: AppStrings.Alerts.Title.cancelContent, withMessage: AppStrings.Alerts.Subtitle.cancelContent, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.quit, style: .default) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true)
        }
    }
}

extension ShareCaseImageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: placeholderCaseImageCellReuseIdentifier, for: indexPath) as! PlaceholderCaseImageCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shareCaseImageCellReuseIdentifier, for: indexPath) as! ShareCaseImageCell
            cell.set(image: viewModel.images[indexPath.row - 1])
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == ElementKind.sectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: contentHeaderCellReuseIdentifier, for: indexPath) as! ContentHeader
            header.configure(withTitle: AppStrings.Content.Case.Share.imageTitle, withContent: AppStrings.Content.Case.Share.imageContent)
            return header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: contentFooterCellReuseIdentifier, for: indexPath) as! CasePrivacyFooter
            footer.delegate = self
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            addPhotos()
        }
    }
}

extension ShareCaseImageViewController: CasePrivacyFooterDelegate {
    func didTapPatientPrivacy() {
        #if DEBUG
        if let privacyURL = URL(string: AppStrings.URL.draftPrivacy) {
            if UIApplication.shared.canOpenURL(privacyURL) {
                presentSafariViewController(withURL: privacyURL)
            } else {
                presentWebViewController(withURL: privacyURL)
            }
        }
        #else
        if let privacyURL = URL(string: AppStrings.URL.draftPrivacy) {
            if UIApplication.shared.canOpenURL(privacyURL) {
                presentSafariViewController(withURL: privacyURL)
            } else {
                presentWebViewController(withURL: privacyURL)
            }
        }
        #endif
    }
}


extension ShareCaseImageViewController: PHPickerViewControllerDelegate {
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
                    let processedImages = VisionService.processImages(images)
                    strongSelf.viewModel.images.append(contentsOf: processedImages)
                    strongSelf.collectionView.reloadData()
                    strongSelf.dismissProgressIndicator()
                    strongSelf.isValid()
                    
                    if processedImages.filter({ $0.containsFaces }).count > 0 {
                        strongSelf.displayAlert(withTitle: AppStrings.Alerts.Title.faces, withMessage: AppStrings.Alerts.Subtitle.faces)
                    }
                }
            }
        }
    }
}

extension ShareCaseImageViewController: ShareCaseImageCellDelegate {
    func delete(_ cell: ShareCaseImageCell) {
        
        if let indexPath = collectionView.indexPath(for: cell) {
            collectionView.performBatchUpdates { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.removeImage(at: indexPath.row - 1)
                strongSelf.collectionView.deleteItems(at: [indexPath])
                strongSelf.isValid()
            }
        }
    }
}
