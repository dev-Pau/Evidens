//
//  EditProfilePictureCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit
import SwiftUI

class EditProfilePictureCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    
    private let bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = primaryColor.withAlphaComponent(0.5)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = primaryColor
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        cellContentView.addSubviews(bannerImageView, profileImageView)
        
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: 150),
            
            profileImageView.centerYAnchor.constraint(equalTo: bannerImageView.centerYAnchor, constant: 75),
            profileImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10)
        ])
        
        profileImageView.layer.cornerRadius = 70/2
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
