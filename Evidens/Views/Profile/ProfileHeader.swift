//
//  ProfileHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/10/21.
//

import UIKit

class ProfileHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    var viewModel: ProfileHeaderViewModel? {
        didSet { configure() }
    }
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.fill")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 15)
        return label
    }()
    
    private lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = UIColor(rgb: 0x79CBBF)
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
    
    private var activityRecapLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Activity"
        return label
    }()
    
    private var postsRecapLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Posts"
        return label
    }()
    
    //MARK:  - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 16)
        profileImageView.setDimensions(height: 80, width: 80)
        profileImageView.layer.cornerRadius = 80/2
        
        addSubview(nameLabel)
        nameLabel.centerX(inView: profileImageView)
        nameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 8)
        
        addSubview(editProfileButton)
        editProfileButton.anchor(top: topAnchor, right: rightAnchor, paddingTop: 6, paddingRight: 16)
        
        let stack = UIStackView(arrangedSubviews: [followingLabel, followersLabel])
        stack.distribution = .fillEqually
        stack.spacing = 5
        
        addSubview(stack)
        stack.centerX(inView: profileImageView)
        stack.anchor(top: nameLabel.bottomAnchor, paddingTop: 10)
        
        let topDivider = UIView()
        topDivider.backgroundColor = .white
        
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = .lightGray
        
        let labelRecapStack = UIStackView(arrangedSubviews: [activityRecapLabel, postsRecapLabel])
        labelRecapStack.distribution = .fillEqually
        
        addSubview(labelRecapStack)
        addSubview(topDivider)
        addSubview(bottomDivider)
        
        labelRecapStack.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 50)
        
        topDivider.anchor(top: labelRecapStack.topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        
        bottomDivider.anchor(top: labelRecapStack.bottomAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        print(viewModel.lastName)
        nameLabel.text = viewModel.firstName + " " + viewModel.lastName
        
    }
    
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
