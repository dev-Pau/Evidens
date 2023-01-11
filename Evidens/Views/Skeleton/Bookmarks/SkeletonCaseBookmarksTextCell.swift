//
//  SkeletonCaseBookmarksTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/11/22.
//

import UIKit

class SekeletonCaseBookmarksTextCell: UICollectionViewCell, SkeletonLoadable {
    
    private let cellContentView = UIView()
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    
    private let profileImageLabel = UILabel()
    private let profileImageLayer = CAGradientLayer()
    
    private let fullNameLabel = UILabel()
    private let fullNameLayer = CAGradientLayer()
    
    private let categoryLabel = UILabel()
    private let categoryLayer = CAGradientLayer()
    
    private let imageLabel = UILabel()
    private let imageLayer = CAGradientLayer()
    
    private let timestampLabel = UILabel()
    private let timestampLayer = CAGradientLayer()
    
    private let caseStageLabel = UILabel()
    private let caseStageLayer = CAGradientLayer()
    
    private let firstTextLabel = UILabel()
    private let firstTextLayer = CAGradientLayer()

    private let secondTextLabel = UILabel()
    private let secondTextLayer = CAGradientLayer()
    private let thirdTextLabel = UILabel()
    private let thirdTextLayer = CAGradientLayer()

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
        
        caseStageLayer.frame = caseStageLabel.bounds
        caseStageLayer.cornerRadius = caseStageLabel.bounds.height / 2
        
        firstTextLayer.frame = firstTextLabel.bounds
        firstTextLayer.cornerRadius = firstTextLabel.bounds.height / 2

        secondTextLayer.frame = secondTextLabel.bounds
        secondTextLayer.cornerRadius = secondTextLabel.bounds.height / 2
        
        thirdTextLayer.frame = thirdTextLabel.bounds
        thirdTextLayer.cornerRadius = thirdTextLabel.bounds.height / 2

        imageLayer.frame = imageLabel.bounds
        imageLayer.cornerRadius = imageLabel.bounds.height / 2
    }
    
    private func configure() {
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.heightAnchor.constraint(equalToConstant: 210),
        ])
        
        profileImageLabel.translatesAutoresizingMaskIntoConstraints = false
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        
        imageLabel.translatesAutoresizingMaskIntoConstraints = false
        caseStageLabel.translatesAutoresizingMaskIntoConstraints = false
    
        firstTextLabel.translatesAutoresizingMaskIntoConstraints = false

        secondTextLabel.translatesAutoresizingMaskIntoConstraints = false
        thirdTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cellContentView.addSubviews(profileImageLabel, fullNameLabel, categoryLabel, timestampLabel, caseStageLabel, firstTextLabel, secondTextLabel, thirdTextLabel, imageLabel)
        
        NSLayoutConstraint.activate([
            profileImageLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: paddingTop),
            profileImageLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: paddingLeft),
            profileImageLabel.heightAnchor.constraint(equalToConstant: 53),
            profileImageLabel.widthAnchor.constraint(equalToConstant: 53),
            
            fullNameLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: paddingTop),
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageLabel.trailingAnchor, constant: paddingLeft),
            fullNameLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -90),
            fullNameLabel.heightAnchor.constraint(equalToConstant: 15),
            
            categoryLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: paddingTop/2),
            categoryLabel.leadingAnchor.constraint(equalTo: profileImageLabel.trailingAnchor, constant: paddingLeft),
            categoryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -180),
            categoryLabel.heightAnchor.constraint(equalToConstant: 15),
            
            timestampLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: paddingTop/2),
            timestampLabel.leadingAnchor.constraint(equalTo: profileImageLabel.trailingAnchor, constant: paddingLeft),
            timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -230),
            timestampLabel.heightAnchor.constraint(equalToConstant: 15),
            
            caseStageLabel.topAnchor.constraint(equalTo: profileImageLabel.bottomAnchor, constant: 10),
            caseStageLabel.leadingAnchor.constraint(equalTo: profileImageLabel.leadingAnchor),
            caseStageLabel.heightAnchor.constraint(equalToConstant: 30),
            caseStageLabel.widthAnchor.constraint(equalToConstant: 60),
            
            firstTextLabel.topAnchor.constraint(equalTo: caseStageLabel.bottomAnchor, constant: paddingTop),
            firstTextLabel.leadingAnchor.constraint(equalTo: profileImageLabel.leadingAnchor),
            firstTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            firstTextLabel.heightAnchor.constraint(equalToConstant: 15),

            secondTextLabel.topAnchor.constraint(equalTo: firstTextLabel.bottomAnchor, constant: paddingTop),
            secondTextLabel.leadingAnchor.constraint(equalTo: profileImageLabel.leadingAnchor),
            secondTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            secondTextLabel.heightAnchor.constraint(equalToConstant: 15),
            
            thirdTextLabel.topAnchor.constraint(equalTo: secondTextLabel.bottomAnchor, constant: paddingTop / 2),
            thirdTextLabel.leadingAnchor.constraint(equalTo: profileImageLabel.leadingAnchor),
            thirdTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            thirdTextLabel.heightAnchor.constraint(equalToConstant: 15),

            imageLabel.topAnchor.constraint(equalTo: thirdTextLabel.bottomAnchor, constant: paddingTop),
            imageLabel.leadingAnchor.constraint(equalTo: profileImageLabel.leadingAnchor),
            imageLabel.widthAnchor.constraint(equalToConstant: 80),
            imageLabel.heightAnchor.constraint(equalToConstant: 15),
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
        
        caseStageLayer.startPoint = CGPoint(x: 0, y: 0.5)
        caseStageLayer.endPoint = CGPoint(x: 1, y: 0.5)
        caseStageLabel.layer.addSublayer(caseStageLayer)
        
        firstTextLayer.startPoint = CGPoint(x: 0, y: 0.5)
        firstTextLayer.endPoint = CGPoint(x: 1, y: 0.5)
        firstTextLabel.layer.addSublayer(firstTextLayer)

        secondTextLayer.startPoint = CGPoint(x: 0, y: 0.5)
        secondTextLayer.endPoint = CGPoint(x: 1, y: 0.5)
        secondTextLabel.layer.addSublayer(secondTextLayer)
        
        thirdTextLayer.startPoint = CGPoint(x: 0, y: 0.5)
        thirdTextLayer.endPoint = CGPoint(x: 1, y: 0.5)
        thirdTextLabel.layer.addSublayer(thirdTextLayer)

        imageLayer.startPoint = CGPoint(x: 0, y: 0.5)
        imageLayer.endPoint = CGPoint(x: 1, y: 0.5)
        imageLabel.layer.addSublayer(imageLayer)
       
        let profileImageGroup = makeAnimationGroup()
        profileImageGroup.beginTime = 0.0
        profileImageLayer.add(profileImageGroup, forKey: "backgroundColor")
        
        fullNameLayer.add(profileImageGroup, forKey: "backgroundColor")
        categoryLayer.add(profileImageGroup, forKey: "backgroundColor")
        timestampLayer.add(profileImageGroup, forKey: "backgroundColor")
        caseStageLayer.add(profileImageGroup, forKey: "backgroundColor")
        
        firstTextLayer.add(profileImageGroup, forKey: "backgroundColor")

        secondTextLayer.add(profileImageGroup, forKey: "backgroundColor")
        thirdTextLayer.add(profileImageGroup, forKey: "backgroundColor")

        imageLayer.add(profileImageGroup, forKey: "backgroundColor")
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



