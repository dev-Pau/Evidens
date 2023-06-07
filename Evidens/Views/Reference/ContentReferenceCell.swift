//
//  ContentReferenceCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/4/23.
//

import UIKit

class ContentReferenceCell: UICollectionViewCell {
    
    private let referenceLabel: UILabel = {
        let label = UILabel()
        label.textColor = primaryColor
        label.numberOfLines = 10
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var copyTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.contentInsets = .zero
       
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .medium)
        button.configuration?.attributedTitle = AttributedString("Copy", attributes: container)
        button.configuration?.image = UIImage(systemName: "doc", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel).scalePreservingAspectRatio(targetSize: CGSize(width: 16, height: 16))
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.configuration?.imagePadding = 5
        button.addTarget(self, action: #selector(handleCopyReference), for: .touchUpInside)
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
        addSubviews(referenceLabel, copyTextButton)
        NSLayoutConstraint.activate([
            referenceLabel.topAnchor.constraint(equalTo: topAnchor),
            referenceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            referenceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            referenceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -45),
            
            copyTextButton.trailingAnchor.constraint(equalTo: referenceLabel.trailingAnchor),
            copyTextButton.topAnchor.constraint(equalTo: referenceLabel.bottomAnchor, constant: 10)
        ])
    }
    
    func configureWithReference(text: String) {
        referenceLabel.text = text
    }
    
    @objc func handleCopyReference() {
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: false)
        HapticsManager.shared.vibrate(for: .success)
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .medium)
        copyTextButton.configuration?.attributedTitle = AttributedString("COPIED", attributes: container)
        copyTextButton.configuration?.image = nil
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = referenceLabel.text
        UIPasteboard.general.string = referenceLabel.text
    }
    
    @objc func fireTimer() {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .medium)
        copyTextButton.configuration?.attributedTitle = AttributedString("Copy", attributes: container)
        copyTextButton.configuration?.image = UIImage(systemName: "doc", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel).scalePreservingAspectRatio(targetSize: CGSize(width: 16, height: 16))
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