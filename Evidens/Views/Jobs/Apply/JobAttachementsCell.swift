//
//  JobAttachementsCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/2/23.
//

import UIKit

protocol JobAttachementsCellDelegate: AnyObject {
    func didSelectAddFile()
    func didSelectReviewFile()
}

class JobAttachementsCell: UICollectionViewCell {
    weak var delegate: JobAttachementsCellDelegate?
    
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
    
    private lazy var uploadResumeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = primaryColor
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 16, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Upload resume", attributes: container)
        
        button.addTarget(self, action: #selector(handleAddFile), for: .touchUpInside)
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
            uploadResumeButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            uploadResumeButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
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
    
    @objc func handleAddFile() {
        delegate?.didSelectAddFile()
    }
    
    private func addMenuItems() -> UIMenu {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "Review", image: UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), handler: { _ in
                self.delegate?.didSelectReviewFile()
            }),
            UIAction(title: "Change", image: UIImage(systemName: "doc", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)) , handler: { _ in
                self.delegate?.didSelectAddFile()
            })
        ])
        
        return menuItems
    }
    
    func updateButtonWithDocument(fileName: String) {
        uploadResumeButton.configuration = .filled()
        uploadResumeButton.configuration?.baseBackgroundColor = UIColor(rgb: 0xF40F02)
        uploadResumeButton.configuration?.baseForegroundColor = .white
        uploadResumeButton.configuration?.background.strokeWidth = 0
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        uploadResumeButton.configuration?.attributedTitle = AttributedString(fileName, attributes: container)
        uploadResumeButton.menu = addMenuItems()
        uploadResumeButton.showsMenuAsPrimaryAction = true
        uploadResumeButton.configuration?.image = UIImage(systemName: "doc", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        uploadResumeButton.configuration?.imagePadding = 5
        uploadResumeButton.configuration?.imagePlacement = .leading
    }
}
