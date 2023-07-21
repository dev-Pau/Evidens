//
//  MESecondaryEmptyCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/1/23.
//

import UIKit

protocol MESecondaryEmptyCellDelegate: AnyObject {
    func didTapContent(_ content: EmptyContent)
}

class MESecondaryEmptyCell: UICollectionViewCell {
    
    weak var delegate: MESecondaryEmptyCellDelegate?
    var multiplier = 0.7
    
    private var content: EmptyContent?
    
    private let image: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var contentButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        button.addTarget(self, action: #selector(didTapEmptyCellButton), for: .touchUpInside)
        return button
    }()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubviews(image, titleLabel, contentLabel, contentButton)
        NSLayoutConstraint.activate([
            image.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            image.centerXAnchor.constraint(equalTo: centerXAnchor),
            image.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2.5),
            image.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2.5),
            
            titleLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            contentButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            contentButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        image.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        image.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        image.layer.cornerRadius = (UIScreen.main.bounds.width / 2.5) / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(image: UIImage?, title: String, description: String, content: EmptyContent) {
        if let image {
            self.image.image = image
        }
        
        titleLabel.text = title
        contentLabel.text = description
        
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        contentButton.configuration?.attributedTitle = AttributedString(content.title, attributes: container)
        
        self.content = content
    }
    
    @objc func didTapEmptyCellButton() {
        guard let content = content else { return }
        delegate?.didTapContent(content)
    }
    
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let height = max(UIScreen.main.bounds.height * multiplier, autoLayoutSize.height)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

