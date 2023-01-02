//
//  CategoryCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/11/22.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    
    private let categoriesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.baseForegroundColor = grayColor
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Add category", attributes: container)
        
        button.configuration?.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        button.configuration?.imagePlacement = .trailing
        button.configuration?.imagePadding = 5

        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeColor = lightGrayColor
        button.configuration?.background.strokeWidth = 1
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layoutIfNeeded()
    }
    
    private func configure() {
        backgroundColor = .white
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        cellContentView.addSubview(categoriesButton)
        
        NSLayoutConstraint.activate([
            categoriesButton.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            categoriesButton.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            categoriesButton.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            categoriesButton.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
    }
    
    func configure(with category: Category) {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        categoriesButton.configuration?.attributedTitle = AttributedString(category.name, attributes: container)
       
        categoriesButton.configuration?.baseForegroundColor = .white
        categoriesButton.configuration?.baseBackgroundColor = primaryColor
        categoriesButton.configuration?.background.strokeWidth = 0
        
        categoriesButton.configuration?.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
    }
    
    func configure(with category: String) {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        categoriesButton.configuration?.attributedTitle = AttributedString(category, attributes: container)
        categoriesButton.configuration?.baseForegroundColor = .white
        categoriesButton.configuration?.baseBackgroundColor = lightGrayColor
        categoriesButton.configuration?.background.strokeWidth = 0
        
    }
}
