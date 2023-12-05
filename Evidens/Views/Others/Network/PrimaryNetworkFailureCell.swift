//
//  PrimaryNetworkFailureCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/7/23.
//

import UIKit

protocol NetworkFailureCellDelegate: AnyObject {
    func didTapRefresh()
}
    
class PrimaryNetworkFailureCell: UICollectionViewCell {
    
    weak var delegate: NetworkFailureCellDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 20, scaleStyle: .title2, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let tryButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .secondaryLabel

        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .medium)
        
        config.attributedTitle = AttributedString(AppStrings.Network.Issues.tryAgain, attributes: container)
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
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
        
        addSubviews(titleLabel, tryButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            tryButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            tryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            tryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
        
        tryButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
    }
    
    func set(_ title: String) {
        titleLabel.text = title
    }
    
    @objc func handleRefresh() {
        delegate?.didTapRefresh()
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
