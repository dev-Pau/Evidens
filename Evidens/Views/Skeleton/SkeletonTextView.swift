//
//  SkeletonTextView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/9/22.
//

import UIKit

class SkeletonTextView: UIView {
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    
    private let firstTextLabel = UILabel()
    private let secondTextLabel = UILabel()
    private let thirdTextLabel = UILabel()
    
    private let likesLabel = UILabel()
    private let commentsLabel = UILabel()
    private let sharesLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        firstTextLabel.translatesAutoresizingMaskIntoConstraints = false
        secondTextLabel.translatesAutoresizingMaskIntoConstraints = false
        thirdTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        likesLabel.translatesAutoresizingMaskIntoConstraints = false
        commentsLabel.translatesAutoresizingMaskIntoConstraints = false
        sharesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(firstTextLabel, secondTextLabel, thirdTextLabel, likesLabel, commentsLabel, sharesLabel)
        
        NSLayoutConstraint.activate([
            firstTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            firstTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddingLeft),
            firstTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            firstTextLabel.heightAnchor.constraint(equalToConstant: 15),
            
            secondTextLabel.topAnchor.constraint(equalTo: firstTextLabel.bottomAnchor, constant: paddingTop / 2),
            secondTextLabel.leadingAnchor.constraint(equalTo: firstTextLabel.leadingAnchor),
            secondTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            secondTextLabel.heightAnchor.constraint(equalToConstant: 15),
            
            thirdTextLabel.topAnchor.constraint(equalTo: secondTextLabel.bottomAnchor, constant: paddingTop / 2),
            thirdTextLabel.leadingAnchor.constraint(equalTo: firstTextLabel.leadingAnchor),
            thirdTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            thirdTextLabel.heightAnchor.constraint(equalToConstant: 15),
            
            likesLabel.topAnchor.constraint(equalTo: thirdTextLabel.bottomAnchor, constant: paddingTop),
            likesLabel.leadingAnchor.constraint(equalTo: firstTextLabel.leadingAnchor),
            likesLabel.widthAnchor.constraint(equalToConstant: 40),
            likesLabel.heightAnchor.constraint(equalToConstant: 15),
            
            commentsLabel.topAnchor.constraint(equalTo: thirdTextLabel.bottomAnchor, constant: paddingTop),
            commentsLabel.leadingAnchor.constraint(equalTo: likesLabel.trailingAnchor, constant: paddingLeft),
            commentsLabel.widthAnchor.constraint(equalToConstant: 40),
            commentsLabel.heightAnchor.constraint(equalToConstant: 15),
            
            sharesLabel.topAnchor.constraint(equalTo: thirdTextLabel.bottomAnchor, constant: paddingTop),
            sharesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddingLeft),
            sharesLabel.widthAnchor.constraint(equalToConstant: 40),
            sharesLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
}
