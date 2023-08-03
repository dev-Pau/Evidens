//
//  UsersFollowFollowingCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/10/22.
//

import UIKit

protocol UsersFollowCellDelegate: AnyObject {
    func didFollowOnFollower(_ cell: UICollectionViewCell, user: User)
    func didUnfollowOnFollower(_ cell: UICollectionViewCell, user: User)
}

protocol UsersFollowingCellDelegate: AnyObject {
    func didFollowOnFollowing(_ cell: UICollectionViewCell, user: User)
    func didUnfollowOnFollowing(_ cell: UICollectionViewCell, user: User)
}


class UsersFollowFollowingCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    weak var followerDelegate: UsersFollowCellDelegate?
    weak var followingDelegate: UsersFollowingCellDelegate?
    
    var user: User? {
        didSet {
            configure()
        }
    }
    
    var userIsFollowing: Bool? {
        didSet {
            configureButtonText()
        }
    }
    
    var isUpdatingFollowState: Bool? {
        didSet {
            followButton.setNeedsUpdateConfiguration()
        }
    }

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
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUpdatingFollowState = false
        
        backgroundColor = .systemBackground
        
        addSubviews(followButton, profileImageView, nameLabel, userCategoryLabel, separatorView)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            
            followButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            followButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            followButton.widthAnchor.constraint(equalToConstant: 100),
            followButton.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -10),
            
            userCategoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            userCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userCategoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
        
        followButton.configurationUpdateHandler = { [unowned self] button in
            let config = button.configuration
            button.isUserInteractionEnabled = self.isUpdatingFollowState! ? false : true
            button.configuration = config
        }
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configure() {
        guard let user = user else { return }

        if let imageUrl = user.profileUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        } else {
            profileImageView.image = UIImage(named: AppStrings.Assets.profile)
        }
        nameLabel.text = user.name()
        userCategoryLabel.text = user.details()
        
        let isFollowed = user.isFollowed
        
        let title = isFollowed ? AppStrings.Alerts.Actions.following : AppStrings.Alerts.Actions.follow
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        followButton.configuration?.attributedTitle = AttributedString(title, attributes: container)
        followButton.configuration?.baseBackgroundColor = isFollowed ? .secondarySystemGroupedBackground : .label
        followButton.configuration?.baseForegroundColor = isFollowed ? .label : .systemBackground
        followButton.configuration?.background.strokeColor = isFollowed ? .quaternarySystemFill : .label
        followButton.menu = isFollowed ? addMenuItems() : nil
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
        followingDelegate?.didFollowOnFollowing(self, user: user)
    }
     
}

