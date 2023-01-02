//
//  GroupCategoryCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/1/23.
//

import UIKit

class GroupCategoryCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    
    private let categoriesButton: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = lightGrayColor
        label.layer.contentsGravity = .center
        label.layer.masksToBounds = true
        label.textColor = .white
        return label
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
        
        categoriesButton.layer.cornerRadius = 15
    }
    
    func configure(with category: String) {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        categoriesButton.attributedText = NSAttributedString(string: "   " + category + "   ", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .bold)])
    }
}
