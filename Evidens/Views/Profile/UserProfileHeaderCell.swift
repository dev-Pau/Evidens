//
//  UserProfileHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/5/22.
//

import UIKit
import AudioToolbox

protocol UserProfileHeaderCellDelegate: AnyObject {
    func headerCell(didTapProfilePictureFor user: User)
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
        iv.image = UIImage(named: "banner")
        return iv
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.white.cgColor
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePicture))
        iv.addGestureRecognizer(gesture)
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
    private lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        button.configuration?.buttonSize = .medium
        button.configuration?.baseForegroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        return button
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
    
    private let connectButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        
        //button.configuration?.image = UIImage(named: "google")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        //button.configuration?.imagePadding = 15
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("   Connect   ", attributes: container)
        
        //button.addTarget(self, action: #selector(googleLoginButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    private let connectionsLabel: UILabel = {
        let label = UILabel()
        label.text = "24 connections"
        label.textColor = primaryColor
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
 
    private let followersLabel: UILabel = {
        let label = UILabel()
        label.text = "129 followers"
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    /*
     --------------
     */
    
    private lazy var userTypeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(grayColor, for: .normal)
        button.setTitle("  ???  ", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 11
        button.layer.borderWidth = 1.5
        button.layer.borderColor = grayColor.cgColor
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        return button
    }()
    
    private let userDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "I have an extensive professional career of more than 30 years. I'm a speaker in various congresses of the speciality for my important research and education task. I'm currently 1st Vice-president of the Spanish Laser Medical-Surgery Society"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = grayColor
        label.numberOfLines = 0
        return label
    }()
    

    
    private let currentUserProfessionLabel: UILabel = {
        let label = UILabel()
        label.text = "Laser Medical-Surgery at Clinica Planas"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = blackColor
        label.numberOfLines = 0
        return label
    }()
    
    private let pointsMessageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .white
        
        //button.configuration?.background.strokeColor = grayColor
        //button.configuration?.background.strokeWidth = 1
        
        
        //button.configuration?.image = UIImage(named: "google")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        //button.configuration?.imagePadding = 15
        
        button.configuration?.baseForegroundColor = lightGrayColor
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .heavy)
        button.configuration?.attributedTitle = AttributedString("149 points", attributes: container)
        
        //button.addTarget(self, action: #selector(googleLoginButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    
    private let numberOfContacts: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        
        button.configuration?.titleAlignment = .center
        button.configuration?.titlePadding = 4.0
        
        button.configuration?.baseBackgroundColor = .white
        
        button.configuration?.background.strokeColor = grayColor
        button.configuration?.background.strokeWidth = 1
        
        button.configuration?.titleAlignment = .center
        
        var titleContainer = AttributeContainer()
        titleContainer.font = .systemFont(ofSize: 17, weight: .black)
        button.configuration?.attributedTitle = AttributedString("100+", attributes: titleContainer)
        
        var subtitleContainer = AttributeContainer()
        subtitleContainer.font = .systemFont(ofSize: 14, weight: .bold)
        button.configuration?.attributedSubtitle = AttributedString("connections", attributes: subtitleContainer)
        
        
        button.configuration?.baseForegroundColor = blackColor
        button.configuration?.cornerStyle = .medium
        
        return button
    }()
    
    private let numberOfPosts: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        
        button.configuration?.titleAlignment = .center
        button.configuration?.titlePadding = 4.0
        
        button.configuration?.baseBackgroundColor = .white
        
        button.configuration?.background.strokeColor = grayColor
        button.configuration?.background.strokeWidth = 1
        
        button.configuration?.titleAlignment = .center
        
        var titleContainer = AttributeContainer()
        titleContainer.font = .systemFont(ofSize: 17, weight: .black)
        button.configuration?.attributedTitle = AttributedString("12", attributes: titleContainer)
        
        var subtitleContainer = AttributeContainer()
        subtitleContainer.font = .systemFont(ofSize: 14, weight: .bold)
        button.configuration?.attributedSubtitle = AttributedString("posts", attributes: subtitleContainer)
        
        
        button.configuration?.baseForegroundColor = blackColor
        button.configuration?.cornerStyle = .medium
      
        return button
    }()
    
    private let numberOfCases: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        
        button.configuration?.titleAlignment = .center
        button.configuration?.titlePadding = 4.0
        
        button.configuration?.baseBackgroundColor = .white
        
        button.configuration?.background.strokeColor = grayColor
        button.configuration?.background.strokeWidth = 1
        
        button.configuration?.titleAlignment = .center
        
        var titleContainer = AttributeContainer()
        titleContainer.font = .systemFont(ofSize: 17, weight: .black)
        button.configuration?.attributedTitle = AttributedString("5", attributes: titleContainer)
        
        var subtitleContainer = AttributeContainer()
        subtitleContainer.font = .systemFont(ofSize: 14, weight: .bold)
        button.configuration?.attributedSubtitle = AttributedString("cases", attributes: subtitleContainer)
        
        
        button.configuration?.baseForegroundColor = blackColor
        button.configuration?.cornerStyle = .medium
        
        return button
    }()
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [numberOfContacts, numberOfPosts, numberOfCases])
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 10
        
        addSubviews(bannerImageView, profileImageView, nameLabel, professionLabel, connectButton, sendMessageButton, connectionsLabel, followersLabel)
        
        //addSubview(userTypeButton)
        //addSubview(userDescriptionLabel)
        //addSubview(currentUserProfessionLabel)
        //addSubview(editFollowProfileButton)
        //addSubview(pointsMessageButton)
        //addSubview(otherProfileInfoButton)
        //addSubview(stack)
        
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
            
            connectionsLabel.topAnchor.constraint(equalTo: professionLabel.bottomAnchor, constant: 5),
            connectionsLabel.leadingAnchor.constraint(equalTo: professionLabel.leadingAnchor),
            connectionsLabel.trailingAnchor.constraint(equalTo: professionLabel.trailingAnchor),
            
            followersLabel.topAnchor.constraint(equalTo: connectionsLabel.bottomAnchor, constant: 5),
            followersLabel.leadingAnchor.constraint(equalTo: connectionsLabel.leadingAnchor),
            followersLabel.trailingAnchor.constraint(equalTo: professionLabel.trailingAnchor),
            followersLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            /*
            otherProfileInfoButton.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 10),
            otherProfileInfoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            otherProfileInfoButton.widthAnchor.constraint(equalToConstant: 25),
            otherProfileInfoButton.heightAnchor.constraint(equalToConstant: 25),
            
            
            */
            
            connectButton.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 10),
            connectButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            connectButton.heightAnchor.constraint(equalToConstant: 30),
            
            sendMessageButton.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 10),
            sendMessageButton.trailingAnchor.constraint(equalTo: connectButton.leadingAnchor, constant: -5),
            sendMessageButton.heightAnchor.constraint(equalToConstant: 30),
            
            //userTypeButton.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 5),
            //userTypeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            /*
             userDescriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
             userDescriptionLabel.trailingAnchor.constraint(equalTo: userTypeButton.trailingAnchor),
             userDescriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
             
             currentUserProfessionLabel.topAnchor.constraint(equalTo: userDescriptionLabel.bottomAnchor, constant: 10),
             currentUserProfessionLabel.leadingAnchor.constraint(equalTo: userDescriptionLabel.leadingAnchor),
             currentUserProfessionLabel.trailingAnchor.constraint(equalTo: userDescriptionLabel.trailingAnchor),
             
             editFollowProfileButton.topAnchor.constraint(equalTo: currentUserProfessionLabel.bottomAnchor, constant: 20),
             editFollowProfileButton.leadingAnchor.constraint(equalTo: currentUserProfessionLabel.leadingAnchor),
             editFollowProfileButton.widthAnchor.constraint(equalToConstant: screenSize * 0.45),
             editFollowProfileButton.heightAnchor.constraint(equalToConstant: 40),
             
             pointsMessageButton.topAnchor.constraint(equalTo: editFollowProfileButton.topAnchor),
             pointsMessageButton.leadingAnchor.constraint(equalTo: editFollowProfileButton.trailingAnchor, constant: 10),
             pointsMessageButton.widthAnchor.constraint(equalToConstant: screenSize * 0.33),
             pointsMessageButton.bottomAnchor.constraint(equalTo: editFollowProfileButton.bottomAnchor),
             
             otherProfileInfoButton.topAnchor.constraint(equalTo: pointsMessageButton.topAnchor),
             otherProfileInfoButton.trailingAnchor.constraint(equalTo: userTypeButton.trailingAnchor),
             otherProfileInfoButton.bottomAnchor.constraint(equalTo: pointsMessageButton.bottomAnchor),
             otherProfileInfoButton.leadingAnchor.constraint(equalTo: pointsMessageButton.trailingAnchor, constant: 10),
             
             //stack.topAnchor.constraint(equalTo: editFollowProfileButton.bottomAnchor, constant: 10),
             //stack.leadingAnchor.constraint(equalTo: editFollowProfileButton.leadingAnchor),
             //stack.trailingAnchor.constraint(equalTo: userTypeButton.trailingAnchor),
             //stack.heightAnchor.constraint(equalToConstant: 70)
             */
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
        nameLabel.text = "\(viewModel.firstName ) \(viewModel.lastName)"
        professionLabel.text = "\(viewModel.profession ) · \( viewModel.speciality)"
        
        //userTypeButton.setTitle("  \(viewModel.userCategory)  ", for: .normal)
        
        //editFollowProfileButton.configuration?.image = viewModel.followButtonImage?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        //var container = AttributeContainer()
        //container.font = .systemFont(ofSize: 15, weight: .bold)
        
        //editFollowProfileButton.configuration?.attributedTitle = AttributedString(viewModel.followButtonText, attributes: container)
        //editFollowProfileButton.configuration?.baseBackgroundColor = viewModel.followButtonBackgroundColor
        //editFollowProfileButton.configuration?.baseForegroundColor = viewModel.followButtonTextColor
        
        //pointsMessageButton.configuration?.attributedTitle = AttributedString(viewModel.pointsMessageText, attributes: container)
    }
    
    //MARK: - Actions
    
    @objc func handleEditProfile() {
        guard let viewModel = viewModel else { return }
        delegate?.headerCell(didTapEditProfileFor: viewModel.user)
    }
    
    @objc func didTapProfilePicture() {
        guard let viewModel = viewModel else { return }
        delegate?.headerCell(didTapProfilePictureFor: viewModel.user)
    }
    
    //MARK: - API
}
