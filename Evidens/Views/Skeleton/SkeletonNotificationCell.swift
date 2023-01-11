//
//  SkeletonNotificationsCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/10/22.
//

import UIKit

class SkeletonNotificationCell: UICollectionViewCell, SkeletonLoadable {
    
    private let cellContentView = UIView()
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    
    private let profileImageLabel = UILabel()
    private let profileImageLayer = CAGradientLayer()
    
    private let fullNameLabel = UILabel()
    private let fullNameLayer = CAGradientLayer()
    
    private let categoryLabel = UILabel()
    private let categoryLayer = CAGradientLayer()
    
    private let timestampLabel = UILabel()
    private let timestampLayer = CAGradientLayer()
    
    private let firstTextLabel = UILabel()
    private let firstTextLayer = CAGradientLayer()
   
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
        
        profileImageLayer.frame = profileImageLabel.bounds
        profileImageLayer.cornerRadius = profileImageLabel.bounds.height / 2
        
        fullNameLayer.frame = fullNameLabel.bounds
        fullNameLayer.cornerRadius = fullNameLabel.bounds.height / 2
        
        categoryLayer.frame = categoryLabel.bounds
        categoryLayer.cornerRadius = categoryLabel.bounds.height / 2
        
        timestampLayer.frame = timestampLabel.bounds
        timestampLayer.cornerRadius = timestampLabel.bounds.height / 2
        
        firstTextLayer.frame = firstTextLabel.bounds
        firstTextLayer.cornerRadius = firstTextLabel.bounds.height / 2
    }
    
    private func configure() {
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.heightAnchor.constraint(equalToConstant: 90),
        ])
        
        profileImageLabel.translatesAutoresizingMaskIntoConstraints = false
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        
        firstTextLabel.translatesAutoresizingMaskIntoConstraints = false
    
        cellContentView.addSubviews(profileImageLabel, fullNameLabel, categoryLabel, timestampLabel, firstTextLabel)
        
        NSLayoutConstraint.activate([
            profileImageLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: paddingTop),
            profileImageLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: paddingLeft),
            profileImageLabel.heightAnchor.constraint(equalToConstant: 53),
            profileImageLabel.widthAnchor.constraint(equalToConstant: 53),
            
            fullNameLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: paddingTop),
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageLabel.trailingAnchor, constant: paddingLeft),
            fullNameLabel.widthAnchor.constraint(equalToConstant: 70),
            fullNameLabel.heightAnchor.constraint(equalToConstant: 15),
            
            categoryLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: paddingTop),
            categoryLabel.leadingAnchor.constraint(equalTo: fullNameLabel.trailingAnchor, constant: paddingLeft),
            categoryLabel.widthAnchor.constraint(equalToConstant: 170),
            categoryLabel.heightAnchor.constraint(equalToConstant: 15),
            
            timestampLabel.topAnchor.constraint(equalTo: profileImageLabel.bottomAnchor, constant: paddingTop/2),
            timestampLabel.centerXAnchor.constraint(equalTo: profileImageLabel.centerXAnchor),
            timestampLabel.widthAnchor.constraint(equalToConstant: 30),
            timestampLabel.heightAnchor.constraint(equalToConstant: 15),
            
            firstTextLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: paddingTop),
            firstTextLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            firstTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            firstTextLabel.heightAnchor.constraint(equalToConstant: 15)
        ])

    }
    
    private func setup() {
        profileImageLayer.startPoint = CGPoint(x: 0, y: 0.5)
        profileImageLayer.endPoint = CGPoint(x: 1, y: 0.5)
        profileImageLabel.layer.addSublayer(profileImageLayer)
        
        fullNameLayer.startPoint = CGPoint(x: 0, y: 0.5)
        fullNameLayer.endPoint = CGPoint(x: 1, y: 0.5)
        fullNameLabel.layer.addSublayer(fullNameLayer)
        
        categoryLayer.startPoint = CGPoint(x: 0, y: 0.5)
        categoryLayer.endPoint = CGPoint(x: 1, y: 0.5)
        categoryLabel.layer.addSublayer(categoryLayer)
        
        timestampLayer.startPoint = CGPoint(x: 0, y: 0.5)
        timestampLayer.endPoint = CGPoint(x: 1, y: 0.5)
        timestampLabel.layer.addSublayer(timestampLayer)
        
        firstTextLayer.startPoint = CGPoint(x: 0, y: 0.5)
        firstTextLayer.endPoint = CGPoint(x: 1, y: 0.5)
        firstTextLabel.layer.addSublayer(firstTextLayer)
        
        let profileImageGroup = makeAnimationGroup()
        profileImageGroup.beginTime = 0.0
        profileImageLayer.add(profileImageGroup, forKey: "backgroundColor")
        
        fullNameLayer.add(profileImageGroup, forKey: "backgroundColor")
        categoryLayer.add(profileImageGroup, forKey: "backgroundColor")
        timestampLayer.add(profileImageGroup, forKey: "backgroundColor")
        firstTextLayer.add(profileImageGroup, forKey: "backgroundColor")
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
