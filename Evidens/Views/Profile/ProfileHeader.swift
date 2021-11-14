//
//  ProfileHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/10/21.
//

import UIKit


protocol ProfileHeaderDelegate: AnyObject {
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User)
    func updateProfileImage(_ profileHeader: ProfileHeader, didTapChangeProfilePicFor user: User)
}

class ProfileHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    var viewModel: ProfileHeaderViewModel? {
        didSet { configure() }
    }
    
    weak var delegate: ProfileHeaderDelegate?

    
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
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didTapEditFollowProfile), for: .touchUpInside)
        return button
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
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
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        profileImageView.addGestureRecognizer(gesture)
        profileImageView.isUserInteractionEnabled = true
        
        
        addSubview(nameLabel)
        nameLabel.centerX(inView: profileImageView)
        nameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 8)
        
        
        let stack = UIStackView(arrangedSubviews: [postsLabel, followingLabel, followersLabel])
        stack.distribution = .fillEqually
        stack.spacing = 5
        
        addSubview(stack)
        stack.centerX(inView: profileImageView)
        stack.anchor(top: nameLabel.bottomAnchor, paddingTop: 10)
        
        addSubview(editProfileButton)
        editProfileButton.anchor(top: stack.bottomAnchor, left: stack.leftAnchor, right: stack.rightAnchor, paddingTop: 10)
        
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
        nameLabel.text = viewModel.firstName + " " + viewModel.lastName
        
        editProfileButton.setTitle(viewModel.followButtonText, for: .normal)
        editProfileButton.setTitleColor(viewModel.followButtonTextColor, for: .normal)
        editProfileButton.backgroundColor = viewModel.followButtonBackgroundColor
        
        postsLabel.attributedText = viewModel.numberOfPosts
        followersLabel.attributedText = viewModel.numberOfFollowers
        followingLabel.attributedText = viewModel.numberOfFollowing
    }

    //MARK: - Actions
    
    @objc func didTapEditFollowProfile() {
        guard let viewModel = viewModel else { return }
        delegate?.header(self, didTapActionButtonFor: viewModel.user)
    }
    
    @objc func didTapChangeProfilePic() {
        guard let viewModel = viewModel else { return }
        delegate?.updateProfileImage(self, didTapChangeProfilePicFor: viewModel.user)
    }
}
