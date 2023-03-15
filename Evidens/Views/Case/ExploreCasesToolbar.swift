//
//  ExploreCasesToolbar.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/1/23.
//

import UIKit

private let separatorCellReuseIdentifier = "SeparatorCellReuseIdentifier"
private let exploreCellReuseIdentifier = "ExploreCellReuseIdentifier"
private let filterCellReuseIdentifier = "FilterCellReuseIdentifier"

protocol ExploreCasesToolbarDelegate: AnyObject {
    func wantsToSeeCategory(category: Case.FilterCategories)
}

class ExploreCasesToolbar: UIToolbar {
    
    private var filterCollectionView: UICollectionView!
    
    private var indexSelected: Int = 1
    
    weak var exploreDelegate: ExploreCasesToolbarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createFilterCellLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(45), heightDimension: .fractionalHeight(1)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(45), heightDimension: .absolute(30)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0)
            return section
        }
        return layout
    }
    
    private func configure() {
        filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createFilterCellLayout())
        filterCollectionView.bounces = true
        filterCollectionView.alwaysBounceVertical = false
        filterCollectionView.alwaysBounceHorizontal = true
        filterCollectionView.backgroundColor = .clear
        
        addSubview(filterCollectionView)
        NSLayoutConstraint.activate([
            filterCollectionView.topAnchor.constraint(equalTo: topAnchor),
            filterCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            filterCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            filterCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        filterCollectionView.register(FilterCasesCell.self, forCellWithReuseIdentifier: filterCellReuseIdentifier)
        filterCollectionView.register(ExploreCasesCell.self, forCellWithReuseIdentifier: exploreCellReuseIdentifier)
        //filterCollectionView.register(SeparatorCell.self, forCellWithReuseIdentifier: separatorCellReuseIdentifier)
        
        filterCollectionView.allowsSelection = true
        filterCollectionView.allowsMultipleSelection = false
        filterCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
        
        filterCollectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: true, scrollPosition: [])
        
    }
}

extension ExploreCasesToolbar: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Case.FilterCategories.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! FilterCasesCell
        cell.tagsLabel.text = Case.FilterCategories.allCases[indexPath.row].rawValue
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selection = Case.FilterCategories.allCases[indexPath.row]
        
        switch selection {
        case .explore:
           break
        case .all:
            if indexSelected == indexPath.row { return }
            exploreDelegate?.wantsToSeeCategory(category: .all)
            indexSelected = indexPath.row
        case .recents:
            if indexSelected == indexPath.row { return }
            exploreDelegate?.wantsToSeeCategory(category: .recents)
            indexSelected = indexPath.row
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            exploreDelegate?.wantsToSeeCategory(category: .explore)
            return false
        }
        return true
    }
}

extension ExploreCasesToolbar: FilterCasesCellDelegate {
    func didTapFilterImage(_ cell: UICollectionViewCell) {
        
    }
}
