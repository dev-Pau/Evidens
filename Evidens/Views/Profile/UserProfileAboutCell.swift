//
//  UserProfileAboutCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/22.
//

import UIKit

class UserProfileAboutCell: UICollectionViewCell {
    
    private var aboutInformationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 6
        label.textAlignment = .left
        label.textColor = .label
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
        backgroundColor = .systemBackground
        addSubviews(aboutInformationLabel)
        
        NSLayoutConstraint.activate([
            aboutInformationLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            aboutInformationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            aboutInformationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            aboutInformationLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func set(body: String) {
        aboutInformationLabel.text = body
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
