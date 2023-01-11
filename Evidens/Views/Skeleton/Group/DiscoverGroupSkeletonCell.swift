//
//  DiscoverGroupSkeletonCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/11/22.
//

import UIKit

class DiscoverGroupSkeletonCell: UICollectionViewCell, SkeletonLoadable {
    
    private let cellContentView = UIView()
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    
    private let groupImageLabel = UILabel()
    private let groupImageLayer = CAGradientLayer()
    
    private let fullNameLabel = UILabel()
    private let fullNameLayer = CAGradientLayer()
    
    private let membersLabel = UILabel()
    private let membersLayer = CAGradientLayer()

    private let descriptionLabel = UILabel()
    private let descriptionLayer = CAGradientLayer()
    
    private let finalDescriptionLabel = UILabel()
    private let finalDescriptionLayer = CAGradientLayer()
    
    private let separatorLabel = UILabel()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setup()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        groupImageLayer.frame = groupImageLabel.bounds
        
        fullNameLayer.frame = fullNameLabel.bounds
        fullNameLayer.cornerRadius = fullNameLabel.bounds.height / 2
        
        membersLayer.frame = membersLabel.bounds
        membersLayer.cornerRadius = membersLabel.bounds.height / 2
        
        descriptionLayer.frame = descriptionLabel.bounds
        descriptionLayer.cornerRadius = descriptionLabel.bounds.height / 2
        
        finalDescriptionLayer.frame = finalDescriptionLabel.bounds
        finalDescriptionLayer.cornerRadius = finalDescriptionLabel.bounds.height / 2
    }
    
    private func configure() {
        
        groupImageLayer.cornerRadius = 7
        
        separatorLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorLabel.backgroundColor = lightColor
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.heightAnchor.constraint(equalToConstant: 105),
        ])
        
        groupImageLabel.translatesAutoresizingMaskIntoConstraints = false
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        membersLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        finalDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    
        cellContentView.addSubviews(groupImageLabel, fullNameLabel, membersLabel, descriptionLabel, finalDescriptionLabel, separatorLabel)
        
        NSLayoutConstraint.activate([
            groupImageLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: paddingTop),
            groupImageLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: paddingLeft),
            groupImageLabel.heightAnchor.constraint(equalToConstant: 60),
            groupImageLabel.widthAnchor.constraint(equalToConstant: 60),
            
            fullNameLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: paddingTop),
            fullNameLabel.leadingAnchor.constraint(equalTo: groupImageLabel.trailingAnchor, constant: paddingLeft),
            fullNameLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -paddingLeft),
            fullNameLabel.heightAnchor.constraint(equalToConstant: 15),
            
            membersLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: paddingTop),
            membersLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            membersLabel.widthAnchor.constraint(equalToConstant: 60),
            membersLabel.heightAnchor.constraint(equalToConstant: 15),
           
            descriptionLabel.topAnchor.constraint(equalTo: membersLabel.bottomAnchor, constant: paddingTop),
            descriptionLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 15),
            
            finalDescriptionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: paddingTop / 2),
            finalDescriptionLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            finalDescriptionLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -40),
            finalDescriptionLabel.heightAnchor.constraint(equalToConstant: 15),
            
            separatorLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),
            separatorLabel.heightAnchor.constraint(equalToConstant: 1),
            separatorLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            separatorLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor)
        ])

    }
    
    private func setup() {
        groupImageLayer.startPoint = CGPoint(x: 0, y: 0.5)
        groupImageLayer.endPoint = CGPoint(x: 1, y: 0.5)
        groupImageLabel.layer.addSublayer(groupImageLayer)
        
        fullNameLayer.startPoint = CGPoint(x: 0, y: 0.5)
        fullNameLayer.endPoint = CGPoint(x: 1, y: 0.5)
        fullNameLabel.layer.addSublayer(fullNameLayer)
        
        membersLayer.startPoint = CGPoint(x: 0, y: 0.5)
        membersLayer.endPoint = CGPoint(x: 1, y: 0.5)
        membersLabel.layer.addSublayer(membersLayer)
        
        descriptionLayer.startPoint = CGPoint(x: 0, y: 0.5)
        descriptionLayer.endPoint = CGPoint(x: 1, y: 0.5)
        descriptionLabel.layer.addSublayer(descriptionLayer)
        
        finalDescriptionLayer.startPoint = CGPoint(x: 0, y: 0.5)
        finalDescriptionLayer.endPoint = CGPoint(x: 1, y: 0.5)
        finalDescriptionLabel.layer.addSublayer(finalDescriptionLayer)

        let profileImageGroup = makeAnimationGroup()
        profileImageGroup.beginTime = 0.0
        groupImageLayer.add(profileImageGroup, forKey: "backgroundColor")
        
        fullNameLayer.add(profileImageGroup, forKey: "backgroundColor")
        membersLayer.add(profileImageGroup, forKey: "backgroundColor")
       
        descriptionLayer.add(profileImageGroup, forKey: "backgroundColor")
        finalDescriptionLayer.add(profileImageGroup, forKey: "backgroundColor")
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
