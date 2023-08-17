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
    
    private let bannerImage: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = primaryColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let profileLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.text = AppStrings.Profile.view
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bannerHeight = (frame.width - 40) / 3
        bannerImage.heightAnchor.constraint(equalToConstant: bannerHeight).isActive = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap)))
        
        addSubviews(bannerImage, userImage, nameLabel, profileLabel, separatorView)
        NSLayoutConstraint.activate([
           
            bannerImage.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            bannerImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            bannerImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            userImage.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: 10),
            userImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            userImage.heightAnchor.constraint(equalToConstant: 60),
            userImage.widthAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: userImage.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: userImage.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            profileLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            profileLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            profileLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: userImage.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
      
        bannerImage.layer.cornerRadius = 10
        userImage.layer.cornerRadius = 60 / 2
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        if let imageString = UserDefaults.standard.value(forKey: "profileUrl") as? String, imageString != "" {
            userImage.sd_setImage(with: URL(string: imageString))
        }
        
        if let bannerString = UserDefaults.standard.value(forKey: "bannerUrl") as? String, bannerString != "" {
            userImage.sd_setImage(with: URL(string: bannerString))
        }
        if let name = UserDefaults.standard.value(forKey: "name") as? String {
            nameLabel.text = name
        }
    }
    
    @objc func handleHeaderTap() {
        delegate?.didTapProfile()
    }
}
