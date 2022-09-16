//
//  SkeletonViewHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/9/22.
//

import UIKit

class SkeletonViewHeader: UIView {
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    
    private let profileImageLabel = UILabel()
    
    private let fullNameLabel = UILabel()
    
    private let categoryLabel = UILabel()
    
    private let timestampLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        profileImageLabel.translatesAutoresizingMaskIntoConstraints = false
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(profileImageLabel, fullNameLabel, categoryLabel, timestampLabel)
        
        NSLayoutConstraint.activate([
            profileImageLabel.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            profileImageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddingLeft),
            profileImageLabel.heightAnchor.constraint(equalToConstant: 53),
            profileImageLabel.widthAnchor.constraint(equalToConstant: 53),
            
            fullNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageLabel.trailingAnchor, constant: paddingLeft),
            fullNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            fullNameLabel.heightAnchor.constraint(equalToConstant: 15),
            
            categoryLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: paddingTop/2),
            categoryLabel.leadingAnchor.constraint(equalTo: profileImageLabel.trailingAnchor, constant: paddingLeft),
            categoryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            categoryLabel.heightAnchor.constraint(equalToConstant: 15),
            
            timestampLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: paddingTop/2),
            timestampLabel.leadingAnchor.constraint(equalTo: profileImageLabel.trailingAnchor, constant: paddingLeft),
            timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            timestampLabel.heightAnchor.constraint(equalToConstant: 15),
        ])
    }
}
