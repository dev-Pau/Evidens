//
//  JobAttachementsCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/2/23.
//

import UIKit
import PDFKit

class JobAttachementsCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Resume"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let resumeWarningLabel: UILabel = {
        let label = UILabel()
        label.text = "Be sure to inlcude an updated resume. Submitting this application won't change your profile."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let uploadResumeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = primaryColor
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 16, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Upload resume", attributes: container)
        
        button.configuration?.background.strokeColor = primaryColor
        button.configuration?.background.strokeWidth = 1
        
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
        addSubviews(titleLabel, resumeWarningLabel, uploadResumeButton)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            uploadResumeButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            uploadResumeButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 10),
            uploadResumeButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -10),
            uploadResumeButton.heightAnchor.constraint(equalToConstant: 40),
            
            resumeWarningLabel.topAnchor.constraint(equalTo: uploadResumeButton.bottomAnchor, constant: 10),
            resumeWarningLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            resumeWarningLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            resumeWarningLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
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
