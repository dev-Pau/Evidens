//
//  GroupPendingCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/1/23.
//


import UIKit

class GroupPendingCell: UICollectionViewCell {
    
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
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    
    private let groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let memberTypeButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .medium
        button.configuration?.buttonSize = .mini
        button.translatesAutoresizingMaskIntoConstraints  = false
        return button
    }()
    
    private let groupSizeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
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
        
        backgroundColor = .systemBackground
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.quaternarySystemFill.cgColor
        layer.cornerRadius = 7
        
        layer.shadowColor = UIColor.quaternarySystemFill.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 1
        layer.masksToBounds = false
        
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
            groupImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 4),
            groupImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 4),
            groupImageView.heightAnchor.constraint(equalToConstant: 70),
            groupImageView.widthAnchor.constraint(equalToConstant: 70),
            
            groupNameLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            groupNameLabel.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 10),
            groupNameLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            
            memberTypeButton.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 2),
            memberTypeButton.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 10),
            
            groupSizeLabel.topAnchor.constraint(equalTo: memberTypeButton.bottomAnchor, constant: 2),
            groupSizeLabel.leadingAnchor.constraint(equalTo: memberTypeButton.leadingAnchor),
            groupSizeLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10),
        ])
        
        groupImageView.layer.cornerRadius = 7
    }
    
    private func configureGroup() {
        guard let viewModel = viewModel else { return }
        groupImageView.sd_setImage(with: URL(string: viewModel.groupProfileUrl!))
        groupNameLabel.text = viewModel.groupName
        groupSizeLabel.text = viewModel.groupSizeString
       
        memberTypeButton.configuration?.baseForegroundColor = primaryColor
        memberTypeButton.configuration?.baseBackgroundColor = .white
    }
    
    func setGroupRole(role: Group.MemberType) {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .bold)
        memberTypeButton.configuration?.attributedTitle = AttributedString(role.memberTypeString, attributes: container)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        
        let height = max(90, autoLayoutSize.height)
        
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

