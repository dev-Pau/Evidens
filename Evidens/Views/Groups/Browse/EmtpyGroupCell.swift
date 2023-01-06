//
//  EmtpyGroupCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/1/23.
//

import UIKit

protocol EmptyGroupCellDelegate: AnyObject {
    func didTapDiscoverGroup()
}

class EmptyGroupCell: UICollectionViewCell {
    
    weak var delegate: EmptyGroupCellDelegate?
    
    private let cellContentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "We could not find any group you are a part of - yet."
        label.font = .systemFont(ofSize: 35, weight: .heavy)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let groupTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.text = "Discover listed groups or communities that share your interests, vision or goals."
        return label
    }()
    
    private lazy var discoverButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false

        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Discover", attributes: container)
        
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.baseBackgroundColor = .label
        
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
        
        cellContentView.addSubviews(titleLabel, groupTitle, discoverButton)
        
        NSLayoutConstraint.activate([
            groupTitle.centerXAnchor.constraint(equalTo: cellContentView.centerXAnchor),
            groupTitle.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 20),
            groupTitle.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -20),
            groupTitle.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor),
            
            discoverButton.topAnchor.constraint(equalTo: groupTitle.bottomAnchor, constant: 30),
            discoverButton.leadingAnchor.constraint(equalTo: groupTitle.leadingAnchor),
            discoverButton.heightAnchor.constraint(equalToConstant: 40),
            discoverButton.widthAnchor.constraint(equalToConstant: 130),
            
            titleLabel.bottomAnchor.constraint(equalTo: groupTitle.topAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(equalTo: groupTitle.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: groupTitle.trailingAnchor)
        ])
    }
    
    @objc func handleDiscoverGroups() {
        delegate?.didTapDiscoverGroup()
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
