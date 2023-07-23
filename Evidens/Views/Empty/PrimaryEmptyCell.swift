//
//  EmtpyGroupCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/1/23.
//

import UIKit

protocol PrimaryEmptyCellDelegate: AnyObject {
    func didTapEmptyAction()
}

class PrimaryEmptyCell: UICollectionViewCell {
    
    weak var delegate: PrimaryEmptyCellDelegate?
    private var heightImageAnchor: NSLayoutConstraint!
    private var topImageAnchor: NSLayoutConstraint!
    
    private let cellContentView = UIView()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        iv.layer.cornerRadius = 5
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 30, weight: .heavy)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var discoverButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25)
        button.addTarget(self, action: #selector(handleDiscoverGroups), for: .touchUpInside)
        return button
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
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.6)
        ])
        
        cellContentView.addSubviews(imageView, titleLabel, descriptionLabel, discoverButton)
        topImageAnchor = imageView.topAnchor.constraint(equalTo: cellContentView.topAnchor)
        heightImageAnchor = imageView.heightAnchor.constraint(equalToConstant: frame.width / 2)
        
        NSLayoutConstraint.activate([
            topImageAnchor,
            imageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            heightImageAnchor,
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -30),
           
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        
            discoverButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            discoverButton.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
        ])
    }
    
    func set(withImage image: UIImage? = nil, withTitle title: String, withDescription description: String, withButtonText buttonText: String? = nil) {
        if let image = image {
            imageView.image = image
            topImageAnchor.constant = 30
            topImageAnchor.isActive = true
        } else {
            heightImageAnchor.constant = 0
            heightImageAnchor.isActive = true
        }

        descriptionLabel.text = description
        titleLabel.text = title
        
        if let buttonText = buttonText {
            var container = AttributeContainer()
            container.font = .systemFont(ofSize: 16, weight: .bold)
            discoverButton.configuration?.attributedTitle = AttributedString(buttonText, attributes: container)
        } else {
            discoverButton.isHidden = true
        }
    }
    
    @objc func handleDiscoverGroups() {
        delegate?.didTapEmptyAction()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}
