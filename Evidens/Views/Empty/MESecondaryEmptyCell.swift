//
//  MESecondaryEmptyCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/1/23.
//

import UIKit

protocol MESecondaryEmptyCellDelegate: AnyObject {
    func didTapEmptyCellButton(option: EmptyCellButtonOptions)
}

enum EmptyCellButtonOptions: String, CaseIterable {
    case goToGroup = "   Go to group   "
    case invite = "   Invite   "
    case learnMore = "   Learn more   "
    case dismiss = "   Dismiss   "
    case removeFilters = "   Remove filters   "
}

class MESecondaryEmptyCell: UICollectionViewCell {
    
    weak var delegate: MESecondaryEmptyCellDelegate?
    
    private var emptyCellOption: EmptyCellButtonOptions = .goToGroup
    
    private let emptyCellImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.backgroundColor = .quaternarySystemFill
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let emptyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emptyCellButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(didTapEmptyCellButton), for: .touchUpInside)
        return button
    }()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubviews(emptyCellImageView, emptyTitleLabel, emptyDescriptionLabel, emptyCellButton)
        NSLayoutConstraint.activate([
            emptyCellImageView.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            emptyCellImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyCellImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2.5),
            emptyCellImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2.5),
            
            emptyTitleLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 20),
            emptyTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            emptyTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            emptyDescriptionLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: 10),
            emptyDescriptionLabel.leadingAnchor.constraint(equalTo: emptyTitleLabel.leadingAnchor),
            emptyDescriptionLabel.trailingAnchor.constraint(equalTo: emptyTitleLabel.trailingAnchor),
            
            emptyCellButton.topAnchor.constraint(equalTo: emptyDescriptionLabel.bottomAnchor, constant: 20),
            emptyCellButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        emptyCellImageView.layer.cornerRadius = (UIScreen.main.bounds.width / 2.5) / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(image: UIImage?, title: String, description: String, buttonText: EmptyCellButtonOptions) {
        emptyTitleLabel.text = title
        emptyDescriptionLabel.text = description
        emptyCellOption = buttonText
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        emptyCellButton.configuration?.attributedTitle = AttributedString(buttonText.rawValue, attributes: container)
        
    }
    
    @objc func didTapEmptyCellButton() {
        delegate?.didTapEmptyCellButton(option: emptyCellOption)
    }
    
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        
        let height = max(UIScreen.main.bounds.height * 0.7, autoLayoutSize.height)

        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
     
}

