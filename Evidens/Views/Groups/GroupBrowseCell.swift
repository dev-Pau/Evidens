//
//  GroupBrowseCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/12/22.
//

import UIKit

class GroupBrowseCell: UICollectionViewCell {
    
    var viewModel: GroupViewModel? {
        didSet {
            configureGroup()
        }
    }
    
    private let cellContentView = UIView()
    
    private let groupImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = grayColor
        return iv
    }()
    
    private let groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let memberTypeButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.translatesAutoresizingMaskIntoConstraints  = false
        return button
    }()
    
    private let groupSizeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        
        cellContentView.addSubviews(groupImageView, groupNameLabel, memberTypeButton, groupSizeLabel)
        
        NSLayoutConstraint.activate([
            groupImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            groupImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            groupImageView.heightAnchor.constraint(equalToConstant: 50),
            groupImageView.widthAnchor.constraint(equalToConstant: 50),
            
            groupNameLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            groupNameLabel.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 10),
            groupNameLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            
            memberTypeButton.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 10),
            memberTypeButton.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 10),
        
            groupSizeLabel.centerYAnchor.constraint(equalTo: memberTypeButton.centerYAnchor),
            groupSizeLabel.leadingAnchor.constraint(equalTo: memberTypeButton.trailingAnchor),
            groupSizeLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10)
        ])
        
        groupImageView.layer.cornerRadius = 50 / 2
    }
    
    private func configureGroup() {
        guard let viewModel = viewModel else { return }
        groupImageView.sd_setImage(with: URL(string: viewModel.groupProfileUrl!))
        groupNameLabel.text = viewModel.groupName
        groupSizeLabel.text = "  · " + viewModel.groupSizeString
        
        memberTypeButton.configuration?.baseForegroundColor = .white
        memberTypeButton.configuration?.baseBackgroundColor = primaryColor
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .bold)
        memberTypeButton.configuration?.attributedTitle = AttributedString("Owner", attributes: container)
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
