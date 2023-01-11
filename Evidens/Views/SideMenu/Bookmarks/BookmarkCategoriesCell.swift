//
//  BookmarkCategoriesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/9/22.
//


import UIKit

class BookmarkCategoriesCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            categoryLabel.textColor = isSelected ? .white : .secondaryLabel
            backgroundColor = isSelected ? primaryColor : UIColor.secondarySystemGroupedBackground
            layer.borderWidth = isSelected ? 0 : 1
            //layer.borderColor = isSelected ? primaryColor.cgColor : grayColor.cgColor
        }
    }
    
    let cellContentView = UIView()

    private var categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        
        layer.cornerRadius = 20
        layer.borderColor = UIColor.secondaryLabel.cgColor
        layer.borderWidth = 1
        
        addSubview(cellContentView)
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        cellContentView.addSubviews(categoryLabel)
        NSLayoutConstraint.activate([

            categoryLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            categoryLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            categoryLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),
            
        ])
    }
    
    func set(category: String) {
        categoryLabel.text = category
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 40)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.defaultLow, verticalFittingPriority: UILayoutPriority.required)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

