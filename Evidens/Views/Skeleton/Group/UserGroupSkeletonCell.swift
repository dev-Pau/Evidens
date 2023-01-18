//
//  UserGroupSkeletonCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/1/23.
//


import UIKit

class UserGroupSkeletonCell: UICollectionViewCell, SkeletonLoadable {
    
    private let cellContentView = UIView()
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    
    private let profileImageLabel = UILabel()
    private let profileImageLayer = CAGradientLayer()
    
    private let fullNameLabel = UILabel()
    private let fullNameLayer = CAGradientLayer()
    
    private let categoryLabel = UILabel()
    private let categoryLayer = CAGradientLayer()
    
    private let followButtonLabel = UILabel()
    private let followButtonLayer = CAGradientLayer()
    
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
        
        profileImageLayer.frame = profileImageLabel.bounds
        profileImageLayer.cornerRadius = profileImageLabel.bounds.height / 2
        
        fullNameLayer.frame = fullNameLabel.bounds
        fullNameLayer.cornerRadius = fullNameLabel.bounds.height / 2
        
        categoryLayer.frame = categoryLabel.bounds
        categoryLayer.cornerRadius = categoryLabel.bounds.height / 2
        
        followButtonLayer.frame = followButtonLabel.bounds
        followButtonLayer.cornerRadius = followButtonLabel.bounds.height / 2
    }
    
    private func configure() {
        
        profileImageLabel.translatesAutoresizingMaskIntoConstraints = false
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        followButtonLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(profileImageLabel, followButtonLabel, fullNameLabel, categoryLabel)
        
        NSLayoutConstraint.activate([
            profileImageLabel.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            profileImageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddingLeft),
            profileImageLabel.heightAnchor.constraint(equalToConstant: 53),
            profileImageLabel.widthAnchor.constraint(equalToConstant: 53),
            
            followButtonLabel.centerYAnchor.constraint(equalTo: profileImageLabel.centerYAnchor),
            followButtonLabel.heightAnchor.constraint(equalToConstant: 30),
            followButtonLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            followButtonLabel.widthAnchor.constraint(equalToConstant: 100),
            
            fullNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageLabel.trailingAnchor, constant: paddingLeft),
            fullNameLabel.widthAnchor.constraint(equalToConstant: 130),
            fullNameLabel.heightAnchor.constraint(equalToConstant: 15),
            
            categoryLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: paddingTop),
            categoryLabel.leadingAnchor.constraint(equalTo: profileImageLabel.trailingAnchor, constant: paddingLeft),
            categoryLabel.widthAnchor.constraint(equalToConstant: 180),
            categoryLabel.heightAnchor.constraint(equalToConstant: 15),
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
        
        followButtonLayer.startPoint = CGPoint(x: 0, y: 0.5)
        followButtonLayer.endPoint = CGPoint(x: 1, y: 0.5)
        followButtonLabel.layer.addSublayer(followButtonLayer)
        
        let profileImageGroup = makeAnimationGroup()
        profileImageGroup.beginTime = 0.0
        profileImageLayer.add(profileImageGroup, forKey: "backgroundColor")
        
        fullNameLayer.add(profileImageGroup, forKey: "backgroundColor")
        categoryLayer.add(profileImageGroup, forKey: "backgroundColor")
        followButtonLayer.add(profileImageGroup, forKey: "backgroundColor")
       
    }
}


