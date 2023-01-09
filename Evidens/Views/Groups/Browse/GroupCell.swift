//
//  GroupCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/11/22.
//

import UIKit

class GroupCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    
    var viewModel: GroupViewModel? {
        didSet {
            configure()
        }
    }
    
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
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()
    
    private let sizeGroupLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private let descriptionGroupLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 3
        label.textColor = .secondaryLabel
        return label
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .systemBackground
        cellContentView.backgroundColor = .systemBackground
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        
        cellContentView.addSubviews(groupImageView, groupNameLabel, descriptionGroupLabel, sizeGroupLabel, separatorView)
        NSLayoutConstraint.activate([
            groupImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            groupImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            groupImageView.widthAnchor.constraint(equalToConstant: 60),
            groupImageView.heightAnchor.constraint(equalToConstant: 60),
            
            groupNameLabel.topAnchor.constraint(equalTo: groupImageView.topAnchor),
            groupNameLabel.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 10),
            groupNameLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            
            sizeGroupLabel.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor),
            sizeGroupLabel.leadingAnchor.constraint(equalTo: groupNameLabel.leadingAnchor),
            sizeGroupLabel.trailingAnchor.constraint(equalTo: groupNameLabel.trailingAnchor),
            
            descriptionGroupLabel.topAnchor.constraint(equalTo: sizeGroupLabel.bottomAnchor, constant: 5),
            descriptionGroupLabel.leadingAnchor.constraint(equalTo: sizeGroupLabel.leadingAnchor),
            descriptionGroupLabel.trailingAnchor.constraint(equalTo: sizeGroupLabel.trailingAnchor),
            descriptionGroupLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: groupNameLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        groupImageView.layer.cornerRadius = 7
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        groupImageView.sd_setImage(with: URL(string: viewModel.groupProfileUrl!))
        groupNameLabel.text = viewModel.groupName
        descriptionGroupLabel.text = viewModel.groupDescription
        sizeGroupLabel.text = viewModel.groupSizeString
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)

        // 80 = image height + 2 * padding (upper & down)
        let height = max(80, autoLayoutSize.height)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}
