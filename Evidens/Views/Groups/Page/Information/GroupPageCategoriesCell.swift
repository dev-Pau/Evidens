//
//  GroupPageCategoriesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/1/23.
//

import UIKit

private let categoryCellReuseIdentifier = "CategoryCellReuseIdentifier"

class GroupPageCategoriesCell: UICollectionViewCell {
    
    var categories: [String]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: createLayout())
        addSubviews(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(GroupCategoryCell.self, forCellWithReuseIdentifier: categoryCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = true
    }
    
    
    private func createLayout() -> UICollectionViewCompositionalLayout {

        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .absolute(30)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        config.scrollDirection = .horizontal
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension GroupPageCategoriesCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! GroupCategoryCell
        cell.configure(with: categories?[indexPath.row] ?? "")
        return cell
    }
}
