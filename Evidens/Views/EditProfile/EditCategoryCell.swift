//
//  EditCategoryCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/7/22.
//

import UIKit

class EditCategoryCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let tf = UILabel()
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 1
        label.textColor = primaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
        
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        cellContentView.addSubviews(titleLabel, subtitleLabel, chevronImageView, separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            separatorView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            titleLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10),
            titleLabel.widthAnchor.constraint(equalToConstant: 100),
            
            chevronImageView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            chevronImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 15),
            chevronImageView.heightAnchor.constraint(equalToConstant: 15),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -5)

        ])
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height + 1))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func set(title: String, subtitle: String, image: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        chevronImageView.image = UIImage(systemName: image)?.withRenderingMode(.alwaysOriginal).withTintColor(lightGrayColor)
    }
}

