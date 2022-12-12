//
//  GroupSkeletonCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/12/22.
//

import UIKit

class GroupSkeletonCell: UICollectionViewCell, SkeletonLoadable {
    
    private let cellContentView = UIView()
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    
    private let groupBannerLabel = UILabel()
    private let groupBannerLayer = CAGradientLayer()
    
    private let groupImageLabel = UILabel()
    private let groupImageLayer = CAGradientLayer()
    
    private let fullNameLabel = UILabel()
    private let fullNameLayer = CAGradientLayer()
    
    private let membersLabel = UILabel()
    private let membersLayer = CAGradientLayer()

    private let descriptionLabel = UILabel()
    private let descriptionLayer = CAGradientLayer()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setup()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        groupBannerLayer.frame = groupBannerLabel.bounds
        
        groupImageLayer.frame = groupImageLabel.bounds
        
        fullNameLayer.frame = fullNameLabel.bounds
        fullNameLayer.cornerRadius = fullNameLabel.bounds.height / 2
        
        membersLayer.frame = membersLabel.bounds
        membersLayer.cornerRadius = membersLabel.bounds.height / 2
        
        descriptionLayer.frame = descriptionLabel.bounds
        descriptionLayer.cornerRadius = descriptionLabel.bounds.height / 2
    }

    private func configure() {
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.heightAnchor.constraint(equalToConstant: 150),
        ])
        
        groupImageLabel.translatesAutoresizingMaskIntoConstraints = false
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        membersLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        groupBannerLabel.translatesAutoresizingMaskIntoConstraints = false
     
        cellContentView.addSubviews(groupBannerLabel, groupImageLabel, fullNameLabel, membersLabel, descriptionLabel)
        
        NSLayoutConstraint.activate([
            groupBannerLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            groupBannerLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            groupBannerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            groupBannerLabel.heightAnchor.constraint(equalToConstant: 70),
            
            groupImageLabel.centerYAnchor.constraint(equalTo: groupBannerLabel.bottomAnchor),
            groupImageLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: paddingLeft),
            groupImageLabel.heightAnchor.constraint(equalToConstant: 60),
            groupImageLabel.widthAnchor.constraint(equalToConstant: 60),
            
            fullNameLabel.topAnchor.constraint(equalTo: groupBannerLabel.bottomAnchor, constant: paddingTop),
            fullNameLabel.leadingAnchor.constraint(equalTo: groupImageLabel.trailingAnchor, constant: paddingLeft),
            fullNameLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -paddingLeft),
            fullNameLabel.heightAnchor.constraint(equalToConstant: 15),
            
            descriptionLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: paddingTop / 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -100),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 15),
            
            membersLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: paddingTop),
            membersLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            membersLabel.widthAnchor.constraint(equalToConstant: 60),
            membersLabel.heightAnchor.constraint(equalToConstant: 15),
            
        ])
        
        groupImageLayer.borderColor = UIColor.white.cgColor
        groupImageLayer.borderWidth = 2

    }
    
    private func setup() {
        groupBannerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        groupBannerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        groupBannerLabel.layer.addSublayer(groupBannerLayer)
        
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
        
        let profileImageGroup = makeAnimationGroup()
        profileImageGroup.beginTime = 0.0
        groupBannerLayer.add(profileImageGroup, forKey: "backgroundColor")
        groupImageLayer.add(profileImageGroup, forKey: "backgroundColor")
        
        fullNameLayer.add(profileImageGroup, forKey: "backgroundColor")
        membersLayer.add(profileImageGroup, forKey: "backgroundColor")
       
        descriptionLayer.add(profileImageGroup, forKey: "backgroundColor")
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
