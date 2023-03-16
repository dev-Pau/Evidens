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
    func headerCell(_ cell: UICollectionViewCell, didTapEditProfileFor user: User)
    func headerCell(didTapFollowingFollowersFor user: User)
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
    
    var isUpdatingFollowState: Bool? {
        didSet {
            followButton.setNeedsUpdateConfiguration()
        }
    }
    
    var updateButtonAfterAction: Bool? {
        didSet {
            updateButton()
        }
    }

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 27, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        return label
    }()
    
    private let professionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .label
        return label
    }()
    
    private let sendMessageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .systemBackground
        button.configuration?.baseForegroundColor = .label
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 1
        button.configuration?.background.strokeColor = .quaternarySystemFill
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Message", attributes: container)
        return button
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.background.strokeWidth = 1
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleFollowEditProfile), for: .touchUpInside)
        return button
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowFollowingFollowers)))
        label.isUserInteractionEnabled = true
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUpdatingFollowState = false
        
        backgroundColor = .systemBackground
        
        addSubviews(nameLabel, professionLabel, followButton, followersLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            professionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            professionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            professionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            followersLabel.topAnchor.constraint(equalTo: professionLabel.bottomAnchor, constant: 5),
            followersLabel.leadingAnchor.constraint(equalTo: professionLabel.leadingAnchor),
            followersLabel.trailingAnchor.constraint(equalTo: professionLabel.trailingAnchor),
            followersLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            followButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            followButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            followButton.heightAnchor.constraint(equalToConstant: 30),
            followButton.widthAnchor.constraint(equalToConstant: 100),
            
            //sendMessageButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            //sendMessageButton.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -5),
            //sendMessageButton.heightAnchor.constraint(equalToConstant: 30),
        ])

        followButton.configurationUpdateHandler = { [unowned self] button in
            button.isUserInteractionEnabled = self.isUpdatingFollowState! ? false : true
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        // Configure with user info
        //bannerImageView.sd_setImage(with: viewModel.bannerImageUrl)
        nameLabel.text = "\(viewModel.firstName ) \(viewModel.lastName)"
        professionLabel.text = "\(viewModel.profession ) · \( viewModel.speciality)"
        
        // Edit Profile/Follow/Unfollow button
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        followButton.configuration?.attributedTitle = AttributedString(viewModel.followButtonText, attributes: container)
        followButton.configuration?.baseBackgroundColor = viewModel.followButtonBackgroundColor
        followButton.configuration?.baseForegroundColor = viewModel.followButtonTextColor
        followButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor

        followButton.menu = addMenuItems()
        
        // Message
        sendMessageButton.isUserInteractionEnabled = viewModel.user.isCurrentUser ? false : true
        sendMessageButton.isHidden = viewModel.messageButtonIsHidden
        
        // Followers & Following information
        followersLabel.attributedText = viewModel.followingFollowersText
        
        //pointsMessageButton.configuration?.attributedTitle = AttributedString(viewModel.pointsMessageText, attributes: container)
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel, viewModel.user.isFollowed else { return nil }
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "Unfollow \(viewModel.firstName)", image: UIImage(systemName: "person.fill.xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), handler: { _ in
                self.delegate?.headerCell(self, didTapEditProfileFor: viewModel.user)
            })
        ])
        followButton.showsMenuAsPrimaryAction = true
        return menuItems
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                 //profileImageView.layer.borderColor = UIColor.systemBackground.cgColor
                 //profileImageView.layer.borderColor = UIColor.systemBackground.cgColor
                 //profileImageView.layer.borderColor = UIColor.systemBackground.cgColor
                 sendMessageButton.configuration?.background.strokeColor = .quaternarySystemFill
                 guard let viewModel = viewModel else { return }
                 followButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
             }
         }
    }
    
    func updateButton() {
        guard let viewModel = viewModel else { return }
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        followButton.configuration?.attributedTitle = AttributedString(viewModel.followButtonText, attributes: container)
        followButton.configuration?.baseBackgroundColor = viewModel.followButtonBackgroundColor
        followButton.configuration?.baseForegroundColor = viewModel.followButtonTextColor
        followButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
    }
    
    
    //MARK: - Actions
    
    @objc func handleFollowEditProfile() {
        guard let viewModel = viewModel else { return }
        if viewModel.user.isCurrentUser == false {
            isUpdatingFollowState = true
        }
        delegate?.headerCell(self, didTapEditProfileFor: viewModel.user)
    }
    
    @objc func didTapProfilePicture() {
        guard let viewModel = viewModel else { return }
        delegate?.headerCell(didTapProfilePictureFor: viewModel.user)
    }
    
    @objc func didTapBannerPicture() {
        guard let viewModel = viewModel else { return }
        delegate?.headerCell(didTapBannerPictureFor: viewModel.user)
    }
    
    @objc func handleShowFollowingFollowers() {
        guard let viewModel = viewModel else { return }
        delegate?.headerCell(didTapFollowingFollowersFor: viewModel.user)
    }
    
}
