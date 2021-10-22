//
//  ProfileHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/10/21.
//

import UIKit

class ProfileHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.fill")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Pau Evidens"
        label.font = UIFont(name: "Raleway-Bold", size: 15)
        return label
    }()
    
    private lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit profile", for: .normal)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont(name: "Raleway-SemiBold", size: 15)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(rgb: 0x79CBBF)
        button.addTarget(self, action: #selector(didTapEditProfile), for: .touchUpInside)
        return button
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = attributedStatText(value: 2, label: "Followers")
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = attributedStatText(value: 1, label: "Following")
        return label
    }()
    
    private lazy var postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = attributedStatText(value: 5, label: "Posts")
        return label
    }()
    
    //MARK:  - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 16)
        profileImageView.setDimensions(height: 80, width: 80)
        profileImageView.layer.cornerRadius = 80/2
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 12)
        
        addSubview(editProfileButton)
        editProfileButton.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 6, paddingLeft: frame.width * 0.7 , paddingRight: 10)
        
        let stack = UIStackView(arrangedSubviews: [followingLabel, followersLabel])
        stack.distribution = .fillEqually
        stack.spacing = 5
        
        addSubview(stack)
        stack.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, paddingTop: 10)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func attributedStatText(value: Int, label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(value) ", attributes: [.font: UIFont(name: "Raleway-SemiBold", size: 15)!])
        attributedText.append(NSAttributedString(string: label, attributes: [.font: UIFont(name: "Raleway-SemiBold", size: 15)!, .foregroundColor : UIColor.lightGray]))
        return attributedText
    }
    
    //MARK: - Actions
    @objc func didTapEditProfile() {
        print("DEBUG: did tap edit profile")
    }
}
