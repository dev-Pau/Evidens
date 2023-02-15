//
//  GroupContentSelectionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/12/22.
//

import UIKit

private let categoriesCellReuseIdentifier = "CategoriesCellReuseIdentifier"

protocol GroupContentSelectionHeaderDelegate: AnyObject {
    func didTapContentCategory(category: ContentGroup.ContentTopics)
}

class GroupContentSelectionHeader: UICollectionReusableView {
    
    weak var delegate: GroupContentSelectionHeaderDelegate?

    private let categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 100, height: 30)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        
        categoriesCollectionView.register(GroupContentSelectorCell.self, forCellWithReuseIdentifier: categoriesCellReuseIdentifier)
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        
        addSubview(categoriesCollectionView)
        NSLayoutConstraint.activate([
            categoriesCollectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 30)
        ])
        categoriesCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
        //categoriesCollectionView.reloadData()
    }
}

extension GroupContentSelectionHeader: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ContentGroup.ContentTopics.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: categoriesCellReuseIdentifier, for: indexPath) as! GroupContentSelectorCell
        cell.set(category: ContentGroup.ContentTopics.allCases[indexPath.row].rawValue)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTapContentCategory(category: ContentGroup.ContentTopics.allCases[indexPath.row])
    }
}
