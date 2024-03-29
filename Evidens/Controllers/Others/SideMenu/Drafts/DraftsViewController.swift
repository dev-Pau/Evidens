//
//  DraftsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/1/24.
//

import UIKit

private let draftCaseTextCellReuseIdentifier = "DraftCaseTextCellReuseIdentifier"
private let draftCaseImageCellReuseIdentifier = "DraftCaseImageCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let draftEmptyCellReuseIdentifier = "DraftEmptyCellReuseIdentifier"
private let networkCellReuseIdentifier = "NetworkCellReuseIdentifier"

class DraftsViewController: UIViewController {
    
    private let viewModel = DraftsViewModel()
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getCases()
    }
    
    private func configureNavigationBar() {
        title = AppStrings.SideMenu.draft
    }

    private func configure() {
        view.backgroundColor = .systemBackground
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: addLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(LoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(DraftCaseTextCell.self, forCellWithReuseIdentifier: draftCaseTextCellReuseIdentifier)
        collectionView.register(DraftCaseImageCell.self, forCellWithReuseIdentifier: draftCaseImageCellReuseIdentifier)
        collectionView.register(SecondaryEmptyCell.self, forCellWithReuseIdentifier: draftEmptyCellReuseIdentifier)
        collectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkCellReuseIdentifier)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: UIDevice.isPad ? view.bottomAnchor : view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func getCases() {
        viewModel.getCases { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
    
    private func getMoreCases() {
        viewModel.getMoreCases { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
    
    
    func draftLoaded() -> Bool {
        return viewModel.caseLoaded
    }
    
    func scrollCollectionViewToTop() {
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    private func addLayout() -> UICollectionViewCompositionalLayout {

        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(45))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(500))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            if !strongSelf.viewModel.caseLoaded {
                section.boundarySupplementaryItems = [header]
            }
            
            return section
        }

        return layout
    }
}

extension DraftsViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreCases()
        }
    }
}

extension DraftsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.caseLoaded ? viewModel.cases.isEmpty ? 1 : viewModel.cases.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! LoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.networkError {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
            cell.set(AppStrings.Network.Issues.Drafts.title)
            cell.delegate = self
            return cell
        } else if viewModel.cases.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: draftEmptyCellReuseIdentifier, for: indexPath) as! SecondaryEmptyCell
            cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Draft.emptyCaseTitle, description: AppStrings.Content.Draft.emptyCaseContent, content: .dismiss)
            cell.delegate = self
            return cell
        } else {
            let clinicalCase = viewModel.cases[indexPath.row]
            let kind = clinicalCase.kind
            
            switch kind {
                
            case .text:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: draftCaseTextCellReuseIdentifier, for: indexPath) as! DraftCaseTextCell
                cell.viewModel = CaseViewModel(clinicalCase: clinicalCase)
                return cell
            case .image:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: draftCaseImageCellReuseIdentifier, for: indexPath) as! DraftCaseImageCell
                cell.delegate = self
                cell.viewModel = CaseViewModel(clinicalCase: clinicalCase)
                return cell
            }
        }
    }
}

extension DraftsViewController: SecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        navigationController?.popViewController(animated: true)
    }
}

extension DraftsViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        viewModel.reset()
        collectionView.reloadData()
        getCases()
    }
}

extension DraftsViewController: DraftCaseImageCellDelegate {
    func didTapImage(_ imageView: UIImageView) {
        if let image = imageView.image {
            let controller = ContentImageViewController(image: image, navVC: navigationController)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.setNavigationBarHidden(true, animated: false)
            navVC.modalPresentationStyle = .overFullScreen
            present(navVC, animated: true)
        }
    }
}
