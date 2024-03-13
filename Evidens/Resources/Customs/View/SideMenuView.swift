//
//  SideMenuHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/9/22.
//

import UIKit

protocol SideMenuViewDelegate: AnyObject {
    func didTapProfile()
}

class SideMenuView: UIView {
    
    weak var delegate: SideMenuViewDelegate?
    
    private lazy var userImage = ProfileImageView(frame: .zero)
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 17.0, scaleStyle: .title3, weight: .bold)
       
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 14.0, scaleStyle: .title3, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = primaryGray
        label.textAlignment = .left
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap)))
        
        let size: CGFloat = UIDevice.isPad ? 50 : 40
        
        addSubviews(userImage, nameLabel, usernameLabel, separatorView)
        NSLayoutConstraint.activate([

            userImage.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            userImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            userImage.heightAnchor.constraint(equalToConstant: size),
            userImage.widthAnchor.constraint(equalToConstant: size),
            
            nameLabel.topAnchor.constraint(equalTo: userImage.bottomAnchor, constant: 15),
            nameLabel.leadingAnchor.constraint(equalTo: userImage.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            usernameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: userImage.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])

        userImage.layer.cornerRadius = size / 2
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        let size: CGFloat = UIDevice.isPad ? 55 : 45
        
        userImage.addImage(forUrl: UserDefaults.getImage(), size: size)
       
        if let name = UserDefaults.standard.value(forKey: "name") as? String {
            nameLabel.text = name
        }
        
        if let username = UserDefaults.standard.value(forKey: "username") as? String {
            usernameLabel.text = AppStrings.Characters.atSign + username
        }
    }
    
    @objc func handleHeaderTap() {
        delegate?.didTapProfile()
    }
}
