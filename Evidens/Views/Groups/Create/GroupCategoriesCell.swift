//
//  GroupCategoriesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/11/22.
//

import UIKit

protocol GroupCategoriesCellDelegate: AnyObject {
    func didSelectAddCategory(withSelectedCategories categories: [Category])
}

private let categoryCellReuseIdentifier = "CategoryCellReuseIdentifier"

class GroupCategoriesCell: UICollectionViewCell {
    
    weak var delegate: GroupCategoriesCellDelegate?
    
    private let cellContentView = UIView()
    
    private var categoriesSelected: [Category] = [Category(name: "Add category")]
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let categoriesTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Categories"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    private var categoriesCollectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .white
        categoriesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLeftAlignedLayout())
        categoriesCollectionView.isScrollEnabled = false
        categoriesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        categoriesCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: categoryCellReuseIdentifier)
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        cellContentView.addSubviews(separatorView, categoriesTitleLabel, categoriesCollectionView)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            categoriesTitleLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            categoriesTitleLabel.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
            categoriesTitleLabel.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
            
            categoriesCollectionView.topAnchor.constraint(equalTo: categoriesTitleLabel.bottomAnchor, constant: 10),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
            categoriesCollectionView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
    }
    
    private func createLeftAlignedLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(          // this is your cell
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .estimated(40),         // variable width
                heightDimension: .absolute(40)          // fixed height
            )
        )
        
        item.contentInsets = .init(top: 0, leading: 0, bottom: 10, trailing: 0)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30)), subitems: [item])
        group.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        group.interItemSpacing = .fixed(10)
        
        return UICollectionViewCompositionalLayout(section: .init(group: group))
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        
        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height + 1))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func updateCategories(categories: [Category]) {
        categoriesSelected.removeAll()
        
        categoriesSelected = categories

        categoriesCollectionView.reloadData()
    }
    
    func updateCategories(categories: [String]) {
        categoriesSelected.removeAll()
        
        var categoriesArray = [Category]()
        categories.forEach { category in
            categoriesArray.append(Category(name: category))
        }
        
        categoriesSelected = categoriesArray

        categoriesCollectionView.reloadData()
    }
}

extension GroupCategoriesCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesSelected.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! CategoryCell
        if categoriesSelected.first?.name == "Add category" {
            return cell
        }
        
        cell.configure(with: categoriesSelected[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectAddCategory(withSelectedCategories: categoriesSelected)
    }
}
