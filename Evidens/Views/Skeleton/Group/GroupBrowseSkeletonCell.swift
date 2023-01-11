//
//  GroupBrowseSkeletonCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/12/22.
//

import UIKit

class GroupBrowseSkeletonCell: UICollectionViewCell, SkeletonLoadable {
    
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
    
    private let summLabel = UILabel()
    private let summLayer = CAGradientLayer()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        
        summLayer.frame = summLabel.bounds
        summLayer.cornerRadius = summLabel.bounds.height / 2
    }
    
    private func configure() {
        
        backgroundColor = .systemBackground
        
        layer.borderWidth = 1
        layer.borderColor = lightColor.cgColor
        layer.cornerRadius = 7
        
        layer.shadowColor = lightColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 1
        layer.masksToBounds = false
        
        groupImageLayer.cornerRadius = 7
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.heightAnchor.constraint(equalToConstant: 115),
        ])
        
        groupImageLabel.translatesAutoresizingMaskIntoConstraints = false
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        membersLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        summLabel.translatesAutoresizingMaskIntoConstraints = false
     
        cellContentView.addSubviews(groupImageLabel, fullNameLabel, membersLabel, descriptionLabel, summLabel)
        
        NSLayoutConstraint.activate([
            groupImageLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 4),
            groupImageLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 4),
            groupImageLabel.heightAnchor.constraint(equalToConstant: 70),
            groupImageLabel.widthAnchor.constraint(equalToConstant: 70),
            
            fullNameLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: paddingTop),
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
            membersLabel.heightAnchor.constraint(equalToConstant: 30),
            
            summLabel.topAnchor.constraint(equalTo: membersLabel.bottomAnchor, constant: paddingTop),
            summLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            summLabel.widthAnchor.constraint(equalToConstant: 120),
            summLabel.heightAnchor.constraint(equalToConstant: 15),
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
        
        summLayer.startPoint = CGPoint(x: 0, y: 0.5)
        summLayer.endPoint = CGPoint(x: 1, y: 0.5)
        summLabel.layer.addSublayer(summLayer)
        
        let profileImageGroup = makeAnimationGroup()
        profileImageGroup.beginTime = 0.0
        groupImageLayer.add(profileImageGroup, forKey: "backgroundColor")
        
        fullNameLayer.add(profileImageGroup, forKey: "backgroundColor")
        membersLayer.add(profileImageGroup, forKey: "backgroundColor")
       
        descriptionLayer.add(profileImageGroup, forKey: "backgroundColor")
        
        summLayer.add(profileImageGroup, forKey: "backgroundColor")
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

