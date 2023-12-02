//
//  CaseExplorerViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/11/23.
//

private let filterCellReuseIdentifier = "FilterCellReuseIdentifier"
private let bodyCellReuseIdentifier = "BodyCellReuseIdentifier"
private let exploreCellReuseIdentifier = "ExploreCellReuseIdentifier"
private let exploreHeaderReuseIdentifier = "ExploreHeaderReuseIdentifier"

import UIKit

class CaseExplorerViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var viewModel = CaseExplorerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureCollectionView()
    }
    
    private func configure() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user, let discipline = user.discipline else { return }
        
        title = AppStrings.Content.Case.Filter.explore
        
        viewModel.addSpecialities(forDiscipline: discipline)
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        
        view.addSubview(collectionView)
        
        collectionView.register(ChoiceCell.self, forCellWithReuseIdentifier: filterCellReuseIdentifier)
        collectionView.register(BodyCell.self, forCellWithReuseIdentifier: bodyCellReuseIdentifier)

        collectionView.register(PrimarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: exploreHeaderReuseIdentifier)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            if sectionNumber == 0 {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
 
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(320), heightDimension: .estimated(40))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(widthDimension: .estimated(320), heightDimension: .estimated(40)), subitems: [item])

                group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 10)
                section.interGroupSpacing = 10
                
                section.boundarySupplementaryItems = [header]
                
                return section

            } else {
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(strongSelf.view.frame.width / 2 + 40), heightDimension: .absolute((strongSelf.view.frame.width / 2) * 2.33 + 40))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: itemSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 20
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
                section.orthogonalScrollingBehavior = .continuous
                
                section.boundarySupplementaryItems = [header]
                
                return section
            }
        }
        return layout
    }
}

extension CaseExplorerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return Discipline.allCases.count
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! ChoiceCell
            cell.isSelectable = false
            cell.set(discipline: Discipline.allCases[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bodyCellReuseIdentifier, for: indexPath) as! BodyCell
            cell.bodyOrientation = indexPath.row == 0 ? .front : .back
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: exploreHeaderReuseIdentifier, for: indexPath) as! PrimarySearchHeader
        header.hideSeeAllButton(true)
        
        if indexPath.section == 0 {
            header.configureWith(title: AppStrings.Content.Case.Filter.disciplines, linkText: "")
        } else {
            header.configureWith(title: AppStrings.Content.Case.Filter.body, linkText: "")
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let discipline = Discipline.allCases[indexPath.row]
            let controller = CaseGroupViewController(group: .discipline(discipline))
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension CaseExplorerViewController: BodyCellDegate {
    func didTapBody(_ body: Body, _ orientation: BodyOrientation) {
        let controller = CaseGroupViewController(group: .body(body, orientation))
        navigationController?.pushViewController(controller, animated: true)
    }
}
