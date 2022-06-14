//
//  MEUserPostView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/6/22.
//

import UIKit

class MEUserPostView: UIView {
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    
    lazy var profileImageView = MEProfileImageView(frame: .zero)
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = blackColor
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let userCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    private let clockImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "clock")
        iv.setDimensions(height: 9.6, width: 9.6)
        return iv
    }()
    
    let postTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = grayColor
        return label
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        
        addSubviews(profileImageView, usernameLabel, userCategoryLabel, clockImage, postTimeLabel)
        
        //userTypeButton.setTitle("Professional", for: .normal)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfile)))
       
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddingLeft),
            profileImageView.heightAnchor.constraint(equalToConstant: 47),
            profileImageView.widthAnchor.constraint(equalToConstant: 47),
       
            usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: paddingLeft),
            usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddingLeft),
            usernameLabel.heightAnchor.constraint(equalToConstant: 15),
            
            userCategoryLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor),
            userCategoryLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            userCategoryLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            userCategoryLabel.heightAnchor.constraint(equalToConstant: 20),
            
            clockImage.topAnchor.constraint(equalTo: userCategoryLabel.bottomAnchor),
            clockImage.leadingAnchor.constraint(equalTo: userCategoryLabel.leadingAnchor),
            clockImage.heightAnchor.constraint(equalToConstant: 9.6),
            clockImage.widthAnchor.constraint(equalToConstant: 9.6),
            
            postTimeLabel.centerYAnchor.constraint(equalTo: clockImage.centerYAnchor),
            postTimeLabel.leadingAnchor.constraint(equalTo: clockImage.trailingAnchor, constant: 5),
            postTimeLabel.heightAnchor.constraint(equalToConstant: 20),
            postTimeLabel.trailingAnchor.constraint(equalTo: userCategoryLabel.trailingAnchor)
            
        ])
        
        profileImageView.layer.cornerRadius = 47 / 2
        
        
    }
    
    @objc func didTapProfile() {
        
    }
}
