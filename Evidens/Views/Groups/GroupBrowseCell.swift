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
        iv.backgroundColor = lightColor
        return iv
    }()
    
    private let groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
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
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dotsButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lightColor
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .white
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        
        cellContentView.addSubviews(groupImageView, groupNameLabel, memberTypeButton, groupSizeLabel, dotsButton, separatorView)
        
        NSLayoutConstraint.activate([
            groupImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            groupImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            groupImageView.heightAnchor.constraint(equalToConstant: 50),
            groupImageView.widthAnchor.constraint(equalToConstant: 50),
            
            dotsButton.centerYAnchor.constraint(equalTo: groupImageView.centerYAnchor),
            dotsButton.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            dotsButton.widthAnchor.constraint(equalToConstant: 20),
            dotsButton.heightAnchor.constraint(equalToConstant: 20),
            
            groupNameLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            groupNameLabel.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 10),
            groupNameLabel.trailingAnchor.constraint(equalTo: dotsButton.trailingAnchor, constant: -10),
            
            memberTypeButton.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 2),
            memberTypeButton.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 10),
            
            groupSizeLabel.topAnchor.constraint(equalTo: memberTypeButton.bottomAnchor, constant: 2),
            groupSizeLabel.leadingAnchor.constraint(equalTo: memberTypeButton.leadingAnchor),
            groupSizeLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: groupNameLabel.leadingAnchor)
        ])
        
        groupImageView.layer.cornerRadius = 50 / 2
    }
    
    private func configureGroup() {
        guard let viewModel = viewModel else { return }
        groupImageView.sd_setImage(with: URL(string: viewModel.groupProfileUrl!))
        groupNameLabel.text = viewModel.groupName
        groupSizeLabel.text = viewModel.groupSizeString
        
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
