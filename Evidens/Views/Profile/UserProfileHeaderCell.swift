//
//  UserProfileHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/5/22.
//

import UIKit

protocol UserProfileHeaderCellDelegate: AnyObject {
    func headerCell(didTapProfilePictureFor user: User)
    func headerCell(didTapBannerPictureFor user: User)
    func headerCell(didTapEditProfileFor user: User)
}

class UserProfileHeaderCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    let screenSize = UIScreen.main.bounds.size.width
    
    weak var delegate: UserProfileHeaderCellDelegate?
    
    var viewModel: ProfileHeaderViewModel? {
        didSet {
            configure()
        }
    }
    
    private lazy var bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        
        iv.backgroundColor = primaryColor.withAlphaComponent(0.5)
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBannerPicture)))
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.white.cgColor
        iv.backgroundColor = lightGrayColor
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePicture))
        iv.addGestureRecognizer(gesture)
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 27, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .black
        return label
    }()
    
    private let professionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .black
        return label
    }()
    
    private let otherProfileInfoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = lightGrayColor
        button.configuration?.image = UIImage(systemName: "ellipsis")?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 20))
        button.configuration?.baseForegroundColor = .black
        button.configuration?.cornerStyle = .capsule
        //button.addTarget(self, action: #selector(googleLoginButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let sendMessageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = lightGrayColor
        
        //button.configuration?.image = UIImage(named: "google")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        //button.configuration?.imagePadding = 15
        button.configuration?.baseForegroundColor = .black
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Message", attributes: container)
        
        //button.addTarget(self, action: #selector(googleLoginButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        
        //button.configuration?.image = UIImage(named: "google")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        //button.configuration?.imagePadding = 15
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        
        button.addTarget(self, action: #selector(handleFollowEditProfile), for: .touchUpInside)
        
        return button
    }()
    
    private let followersLabel: UILabel = {
        let label = UILabel()
        label.textColor = primaryColor
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubviews(bannerImageView, profileImageView, nameLabel, professionLabel, followButton, sendMessageButton, followersLabel)
        
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: topAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: 100),
            
            //editProfileButton.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor),
            //editProfileButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            profileImageView.centerYAnchor.constraint(equalTo: bannerImageView.centerYAnchor, constant: 50),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 110),
            profileImageView.heightAnchor.constraint(equalToConstant: 110),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            professionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            professionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            professionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            //professionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100),
            
            followersLabel.topAnchor.constraint(equalTo: professionLabel.bottomAnchor, constant: 5),
            followersLabel.leadingAnchor.constraint(equalTo: professionLabel.leadingAnchor),
            followersLabel.trailingAnchor.constraint(equalTo: professionLabel.trailingAnchor),
            followersLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            

            /*
            otherProfileInfoButton.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 10),
            otherProfileInfoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            otherProfileInfoButton.widthAnchor.constraint(equalToConstant: 25),
            otherProfileInfoButton.heightAnchor.constraint(equalToConstant: 25),
            
            
            */
            
            followButton.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 10),
            followButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            followButton.heightAnchor.constraint(equalToConstant: 30),
            
            sendMessageButton.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 10),
            sendMessageButton.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -5),
            sendMessageButton.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        profileImageView.layer.cornerRadius = 110 / 2
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        // Configure with user info
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        bannerImageView.sd_setImage(with: viewModel.bannerImageUrl)
        nameLabel.text = "\(viewModel.firstName ) \(viewModel.lastName)"
        professionLabel.text = "\(viewModel.profession ) · \( viewModel.speciality)"
        
        // Edit Profile/Follow/Unfollow button
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        followButton.configuration?.attributedTitle = AttributedString("   \(viewModel.followButtonText)   ", attributes: container)
        followButton.configuration?.baseBackgroundColor = viewModel.followButtonBackgroundColor
        followButton.configuration?.baseForegroundColor = viewModel.followButtonTextColor
        
        // Message
        sendMessageButton.isUserInteractionEnabled = viewModel.user.isCurrentUser ? false : true
        sendMessageButton.isHidden = viewModel.user.isCurrentUser ? true : false
        
        // Followers & Following information
        followersLabel.attributedText = viewModel.followingFollowersText
        
        //pointsMessageButton.configuration?.attributedTitle = AttributedString(viewModel.pointsMessageText, attributes: container)
    }
    
    //MARK: - Actions
    
    @objc func handleFollowEditProfile() {
        guard let viewModel = viewModel else { return }
        delegate?.headerCell(didTapEditProfileFor: viewModel.user)
    }
    
    @objc func didTapProfilePicture() {
        guard let viewModel = viewModel else { return }
        delegate?.headerCell(didTapProfilePictureFor: viewModel.user)
    }
    
    @objc func didTapBannerPicture() {
        guard let viewModel = viewModel else { return }
        delegate?.headerCell(didTapBannerPictureFor: viewModel.user)
    }
    
}