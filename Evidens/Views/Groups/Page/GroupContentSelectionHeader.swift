//
//  GroupContentSelectionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/12/22.
//

import UIKit

private let categoriesCellReuseIdentifier = "CategoriesCellReuseIdentifier"

class GroupContentSelectionHeader: UICollectionReusableView {
    
    enum ContentTopics: String, CaseIterable {
        case all = "All"
        case cases = "Cases"
        case posts = "Posts"
        
        var index: Int {
            switch self {
            case .all:
                return 0
            case .cases:
                return 1
            case .posts:
                return 1
            }
        }
    }
    
    private let categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 100, height: 30)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
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
        backgroundColor = .white
        
        categoriesCollectionView.register(GroupContentSelectorCell.self, forCellWithReuseIdentifier: categoriesCellReuseIdentifier)
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        
        addSubview(categoriesCollectionView)
        categoriesCollectionView.frame = bounds
        categoriesCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
    }
}

extension GroupContentSelectionHeader: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ContentTopics.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: categoriesCellReuseIdentifier, for: indexPath) as! GroupContentSelectorCell
        cell.set(category: ContentTopics.allCases[indexPath.row].rawValue)
        return cell
    }
    
}
