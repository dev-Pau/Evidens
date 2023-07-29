//
//  WhoToFollowCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/2/23.
//

import UIKit

class WhoToFollowCell: UICollectionViewCell {
    weak var followerDelegate: UsersFollowCellDelegate?
    
    var isUpdatingFollowState: Bool? {
        didSet {
            followButton.setNeedsUpdateConfiguration()
        }
    }
    
    var userIsFollowing: Bool? {
        didSet {
            configureButtonText()
        }
    }
    
    private var user: User?
    
    private lazy var profileImageView = ProfileImageView(frame: .zero)
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let userCategoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        
        button.configuration?.baseBackgroundColor = primaryColor
        
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 1
        
        button.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    private let aboutTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 3
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        isUpdatingFollowState = false
        addSubviews(followButton, profileImageView, nameLabel, userCategoryLabel, aboutTextLabel)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            
            followButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            followButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            followButton.widthAnchor.constraint(equalToConstant: 100),
            followButton.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -10),
            
            userCategoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            userCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userCategoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            aboutTextLabel.leadingAnchor.constraint(equalTo: userCategoryLabel.leadingAnchor),
            aboutTextLabel.trailingAnchor.constraint(equalTo: followButton.trailingAnchor),
            aboutTextLabel.topAnchor.constraint(equalTo: userCategoryLabel.bottomAnchor, constant: 10),
            aboutTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
    }
    
    func configureWithUser(user: User) {
        self.user = user
        userIsFollowing = user.isFollowed
        if let imageUrl = user.profileUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        nameLabel.text = user.name()
        userCategoryLabel.text = user.details()

    }
    
    func configureButtonText() {
        guard let userIsFollowing = userIsFollowing else { return }
        let titleString = userIsFollowing ? AppStrings.Alerts.Actions.following : AppStrings.Alerts.Actions.follow
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        followButton.configuration?.attributedTitle = AttributedString(titleString, attributes: container)
        followButton.configuration?.baseBackgroundColor = userIsFollowing ? .secondarySystemGroupedBackground : .label
        followButton.configuration?.baseForegroundColor = userIsFollowing ? .label : .systemBackground
        followButton.configuration?.background.strokeColor = userIsFollowing ? .quaternarySystemFill : .label
        followButton.menu = userIsFollowing ? addMenuItems() : nil
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let user = user else { return nil }
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: AppStrings.Alerts.Actions.unfollow + " " + user.firstName!, image: UIImage(systemName: AppStrings.Icons.xmarkPersonFill, withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.isUpdatingFollowState = true
                strongSelf.followerDelegate?.didUnfollowOnFollower(strongSelf, user: user)
            })
        ])
        
        followButton.showsMenuAsPrimaryAction = true
        return menuItems
    }
    
    @objc func handleFollow() {
        guard let user = user else { return }
        followerDelegate?.didFollowOnFollower(self, user: user)
    }
}
