//
//  RegisterProfessionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit

class RegisterCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            selectionImageView.image = UIImage(systemName: isSelected ? AppStrings.Icons.checkmarkCircleFill : AppStrings.Icons.circle)?.withRenderingMode(.alwaysOriginal).withTintColor(isSelected ? primaryColor : .secondaryLabel)
        }
    }
    
    let professionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: AppStrings.Icons.circle)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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
        addSubviews(professionLabel, selectionImageView)
        
        NSLayoutConstraint.activate([
            selectionImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectionImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            selectionImageView.heightAnchor.constraint(equalToConstant: 25),
            selectionImageView.widthAnchor.constraint(equalToConstant: 25),
            
            professionLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            professionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            professionLabel.trailingAnchor.constraint(equalTo: selectionImageView.leadingAnchor, constant: -10),
            professionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            professionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func set(value: String) {
        professionLabel.text = value
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
