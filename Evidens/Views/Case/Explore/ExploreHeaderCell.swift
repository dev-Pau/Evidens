//
//  ExploreHeaderCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/10/22.
//

import UIKit

private let exploreReuseIdentifier = "ExploreReuseIdentifier"
private let exploreFooterReuseIdentifier = "ExploreFooterReuseIdentifier"

protocol ExploreHeaderCellDelegate: AnyObject {
    func didTapExploreCell(forProfession profession: String)
}

class ExploreHeaderCell: UICollectionReusableView {
    
    private var categoriesCollectionView: UICollectionView!
    
    weak var delegate: ExploreHeaderCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {
        categoriesCollectionView = UICollectionView(frame: bounds, collectionViewLayout: createExploreLayout())
        categoriesCollectionView.register(CategoriesExploreCasesCell.self, forCellWithReuseIdentifier: exploreReuseIdentifier)
        categoriesCollectionView.register(ExploreFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: exploreFooterReuseIdentifier)
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        addSubview(categoriesCollectionView)
    }
    

    private func createExploreLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in

            
            
            let doubleItem = NSCollectionLayoutItem(

                            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                               heightDimension: .fractionalHeight(1.0)))
            doubleItem.contentInsets.trailing = 10
            doubleItem.contentInsets.bottom = 10

            let doubleVerticalGroup = NSCollectionLayoutGroup.vertical(

                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.16),
                                                               heightDimension: .fractionalHeight(1.0)),
                            subitem: doubleItem, count: 3)
            
            
            let repeatingGroup = NSCollectionLayoutGroup.horizontal(
                          
                            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(2),
                                                               heightDimension: .absolute(320)),
                            subitems: [doubleVerticalGroup])
            
            repeatingGroup.contentInsets.leading = 10
            repeatingGroup.contentInsets.top = 10

                        let section = NSCollectionLayoutSection(group: repeatingGroup)
            section.orthogonalScrollingBehavior = .continuous
            
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(20)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)

            section.boundarySupplementaryItems = [footer]

            return section
        }
        return layout
    }
}

extension ExploreHeaderCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Profession.Professions.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreReuseIdentifier, for: indexPath) as! CategoriesExploreCasesCell
        cell.set(category: Profession.Professions.allCases[indexPath.row].rawValue)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: exploreFooterReuseIdentifier, for: indexPath) as! ExploreFooter
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let professionSelected = Profession.Professions.allCases[indexPath.row].rawValue
        delegate?.didTapExploreCell(forProfession: professionSelected)
    }
}

