//
//  ContentReferenceCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/4/23.
//

import UIKit

class ReferenceCell: UICollectionViewCell {
    
    private let referenceLabel: UILabel = {
        let label = UILabel()
        label.textColor = primaryColor
        label.numberOfLines = 10
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.contentInsets = .zero
       
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .body, weight: .medium, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Actions.copy, attributes: container)
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.copy, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryGray).scalePreservingAspectRatio(targetSize: CGSize(width: 16, height: 16))
        button.configuration?.baseForegroundColor = primaryGray
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
        addSubviews(referenceLabel, copyButton)
        
        NSLayoutConstraint.activate([
            referenceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            referenceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            referenceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
 
            copyButton.trailingAnchor.constraint(equalTo: referenceLabel.trailingAnchor),
            copyButton.topAnchor.constraint(equalTo: referenceLabel.bottomAnchor, constant: 10),
            copyButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func configureWithReference(text: String) {
        referenceLabel.text = text
    }
    
    @objc func handleCopyReference() {
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: false)
        HapticsManager.shared.triggerWarningHaptic()
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .body, weight: .medium, scales: false)
        copyButton.configuration?.attributedTitle = AttributedString(AppStrings.Miscellaneous.capsCopied, attributes: container)
        copyButton.configuration?.image = nil
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = referenceLabel.text
        UIPasteboard.general.string = referenceLabel.text
    }
    
    @objc func fireTimer() {
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .body, weight: .medium, scales: false)
        copyButton.configuration?.attributedTitle = AttributedString(AppStrings.Actions.copy, attributes: container)
        copyButton.configuration?.image = UIImage(systemName: AppStrings.Icons.copy, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryGray).scalePreservingAspectRatio(targetSize: CGSize(width: 16, height: 16))
    }
}
