//
//  ContextMenuCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/4/23.
//

import UIKit

class ContextMenuCell: UICollectionViewCell {
    private let contextDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
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
        addSubviews(contextDescriptionLabel)
        NSLayoutConstraint.activate([
            contextDescriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contextDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contextDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contextDescriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
    func configure(withDescription description: String) {
        contextDescriptionLabel.text = description
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}