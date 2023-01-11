//
//  SkeletonCasesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/9/22.
//

import UIKit

class SkeletonCasesCell: UICollectionViewCell, SkeletonLoadable {
    
    private let cellContentView = UIView()
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    
    private let caseImageLabel = UILabel()
    private let caseImageLayer = CAGradientLayer()
    
    private let profileImageLabel = UILabel()
    private let profileImageLayer = CAGradientLayer()
    
    private let stateLabel = UILabel()
    private let stateLayer = CAGradientLayer()
    
    private let firstTextLabel = UILabel()
    private let firstTextLayer = CAGradientLayer()
    private let secondTextLabel = UILabel()
    private let secondTextLayer = CAGradientLayer()
    private let thirdTextLabel = UILabel()
    private let thirdTextLayer = CAGradientLayer()
    private let fourthTextLabel = UILabel()
    private let fourthTextLayer = CAGradientLayer()
    
    
    private let likesLabel = UILabel()
    private let likesLayer = CAGradientLayer()
   
    private let sharesLabel = UILabel()
    private let sharesLayer = CAGradientLayer()
    
    
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
        
        layer.borderColor = lightGrayColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10
        
        profileImageLayer.frame = profileImageLabel.bounds
        profileImageLayer.cornerRadius = profileImageLabel.bounds.height / 2
        
        caseImageLayer.frame = caseImageLabel.bounds
        caseImageLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        caseImageLayer.cornerRadius = 10
     
        stateLayer.frame = stateLabel.bounds
        stateLayer.cornerRadius = stateLabel.bounds.height / 2
        
        firstTextLayer.frame = firstTextLabel.bounds
        firstTextLayer.cornerRadius = firstTextLabel.bounds.height / 2
        
        secondTextLayer.frame = secondTextLabel.bounds
        secondTextLayer.cornerRadius = secondTextLabel.bounds.height / 2
        
        thirdTextLayer.frame = thirdTextLabel.bounds
        thirdTextLayer.cornerRadius = thirdTextLabel.bounds.height / 2
        
        fourthTextLayer.frame = fourthTextLabel.bounds
        fourthTextLayer.cornerRadius = fourthTextLabel.bounds.height / 2
        
        likesLayer.frame = likesLabel.bounds
        likesLayer.cornerRadius = likesLabel.bounds.height / 2
        
        sharesLayer.frame = sharesLabel.bounds
        sharesLayer.cornerRadius = sharesLabel.bounds.height / 2
    }
    
    private func configure() {
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.heightAnchor.constraint(equalToConstant: 350),
        ])
        
        profileImageLabel.translatesAutoresizingMaskIntoConstraints = false
        caseImageLabel.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        fourthTextLabel.translatesAutoresizingMaskIntoConstraints = false
        firstTextLabel.translatesAutoresizingMaskIntoConstraints = false
        secondTextLabel.translatesAutoresizingMaskIntoConstraints = false
        thirdTextLabel.translatesAutoresizingMaskIntoConstraints = false
    
        likesLabel.translatesAutoresizingMaskIntoConstraints = false
      
        sharesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cellContentView.addSubviews(profileImageLabel, caseImageLabel, firstTextLabel, secondTextLabel, thirdTextLabel, fourthTextLabel, stateLabel, likesLabel, sharesLabel)
        
        NSLayoutConstraint.activate([
            caseImageLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            caseImageLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            caseImageLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            caseImageLabel.heightAnchor.constraint(equalToConstant: 170),
            
            firstTextLabel.topAnchor.constraint(equalTo: caseImageLabel.bottomAnchor, constant: paddingTop),
            firstTextLabel.leadingAnchor.constraint(equalTo: caseImageLabel.leadingAnchor, constant: paddingLeft),
            firstTextLabel.trailingAnchor.constraint(equalTo: caseImageLabel.trailingAnchor, constant: -paddingLeft),
            firstTextLabel.heightAnchor.constraint(equalToConstant: 15),
            
            secondTextLabel.topAnchor.constraint(equalTo: firstTextLabel.bottomAnchor, constant: paddingTop / 2),
            secondTextLabel.leadingAnchor.constraint(equalTo: firstTextLabel.leadingAnchor),
            secondTextLabel.trailingAnchor.constraint(equalTo: firstTextLabel.trailingAnchor, constant: -50),
            secondTextLabel.heightAnchor.constraint(equalToConstant: 15),
            
            thirdTextLabel.topAnchor.constraint(equalTo: secondTextLabel.bottomAnchor, constant: paddingTop / 2),
            thirdTextLabel.leadingAnchor.constraint(equalTo: firstTextLabel.leadingAnchor),
            thirdTextLabel.trailingAnchor.constraint(equalTo: firstTextLabel.trailingAnchor, constant: -20),
            thirdTextLabel.heightAnchor.constraint(equalToConstant: 15),
            
            fourthTextLabel.topAnchor.constraint(equalTo: thirdTextLabel.bottomAnchor, constant: paddingTop / 2),
            fourthTextLabel.leadingAnchor.constraint(equalTo: firstTextLabel.leadingAnchor),
            fourthTextLabel.trailingAnchor.constraint(equalTo: firstTextLabel.trailingAnchor, constant: -80),
            fourthTextLabel.heightAnchor.constraint(equalToConstant: 15),
            
            profileImageLabel.topAnchor.constraint(equalTo: fourthTextLabel.bottomAnchor, constant: paddingTop),
            profileImageLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: paddingLeft),
            profileImageLabel.heightAnchor.constraint(equalToConstant: 30),
            profileImageLabel.widthAnchor.constraint(equalToConstant: 30),
            
            stateLabel.centerYAnchor.constraint(equalTo: profileImageLabel.centerYAnchor),
            stateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -paddingLeft),
            stateLabel.heightAnchor.constraint(equalToConstant: 15),
            stateLabel.widthAnchor.constraint(equalToConstant: 50),

            likesLabel.topAnchor.constraint(equalTo: profileImageLabel.bottomAnchor, constant: paddingTop),
            likesLabel.leadingAnchor.constraint(equalTo: profileImageLabel.leadingAnchor),
            likesLabel.widthAnchor.constraint(equalToConstant: 40),
            likesLabel.heightAnchor.constraint(equalToConstant: 15),
            
            sharesLabel.topAnchor.constraint(equalTo: profileImageLabel.bottomAnchor, constant: paddingTop),
            sharesLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -paddingLeft),
            sharesLabel.widthAnchor.constraint(equalToConstant: 40),
            sharesLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
 
    }
    
    private func setup() {
        profileImageLayer.startPoint = CGPoint(x: 0, y: 0.5)
        profileImageLayer.endPoint = CGPoint(x: 1, y: 0.5)
        profileImageLabel.layer.addSublayer(profileImageLayer)
        
        caseImageLayer.startPoint = CGPoint(x: 0, y: 0.5)
        caseImageLayer.endPoint = CGPoint(x: 1, y: 0.5)
        caseImageLabel.layer.addSublayer(caseImageLayer)

        firstTextLayer.startPoint = CGPoint(x: 0, y: 0.5)
        firstTextLayer.endPoint = CGPoint(x: 1, y: 0.5)
        firstTextLabel.layer.addSublayer(firstTextLayer)
        
        secondTextLayer.startPoint = CGPoint(x: 0, y: 0.5)
        secondTextLayer.endPoint = CGPoint(x: 1, y: 0.5)
        secondTextLabel.layer.addSublayer(secondTextLayer)
        
        thirdTextLayer.startPoint = CGPoint(x: 0, y: 0.5)
        thirdTextLayer.endPoint = CGPoint(x: 1, y: 0.5)
        thirdTextLabel.layer.addSublayer(thirdTextLayer)
        
        fourthTextLayer.startPoint = CGPoint(x: 0, y: 0.5)
        fourthTextLayer.endPoint = CGPoint(x: 1, y: 0.5)
        fourthTextLabel.layer.addSublayer(fourthTextLayer)
        
        stateLayer.startPoint = CGPoint(x: 0, y: 0.5)
        stateLayer.endPoint = CGPoint(x: 1, y: 0.5)
        stateLabel.layer.addSublayer(stateLayer)
        
        likesLayer.startPoint = CGPoint(x: 0, y: 0.5)
        likesLayer.endPoint = CGPoint(x: 1, y: 0.5)
        likesLabel.layer.addSublayer(likesLayer)
        
        sharesLayer.startPoint = CGPoint(x: 0, y: 0.5)
        sharesLayer.endPoint = CGPoint(x: 1, y: 0.5)
        sharesLabel.layer.addSublayer(sharesLayer)
        
        let profileImageGroup = makeAnimationGroup()
        profileImageGroup.beginTime = 0.0
        profileImageLayer.add(profileImageGroup, forKey: "backgroundColor")
        
        caseImageLayer.add(profileImageGroup, forKey: "backgroundColor")
        fourthTextLayer.add(profileImageGroup, forKey: "backgroundColor")
        firstTextLayer.add(profileImageGroup, forKey: "backgroundColor")
        secondTextLayer.add(profileImageGroup, forKey: "backgroundColor")
        thirdTextLayer.add(profileImageGroup, forKey: "backgroundColor")
        stateLayer.add(profileImageGroup, forKey: "backgroundColor")
        likesLayer.add(profileImageGroup, forKey: "backgroundColor")
        sharesLayer.add(profileImageGroup, forKey: "backgroundColor")
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

