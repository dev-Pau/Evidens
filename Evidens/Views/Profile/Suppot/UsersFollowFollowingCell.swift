//
//  UsersFollowFollowingCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/10/22.
//

import UIKit


class UsersFollowFollowingCell: UITableViewCell {
    
    //MARK: - Properties
    
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

    private lazy var profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
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
        
        button.addTarget(self, action: #selector(handleFollowUnfollow), for: .touchUpInside)
        
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        isUpdatingFollowState = false
        
        contentView.heightAnchor.constraint(equalToConstant: 65).isActive = true
        backgroundColor = .systemBackground
        
        contentView.addSubviews(followButton, profileImageView, nameLabel, userCategoryLabel)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            
            followButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            followButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            followButton.widthAnchor.constraint(equalToConstant: 100),
            followButton.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -10),
            
            userCategoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            userCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userCategoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
        
        followButton.configurationUpdateHandler = { [unowned self] button in
            var config = button.configuration
            config?.showsActivityIndicator = self.isUpdatingFollowState!
            button.isUserInteractionEnabled = self.isUpdatingFollowState! ? false : true
            var container = AttributeContainer()
            container.font = .systemFont(ofSize: 14, weight: .bold)
            config?.attributedTitle = self.isUpdatingFollowState! ? "" : AttributedString((button.configuration?.title)!, attributes: container)
            button.configuration = config
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configure() {
        guard let user = user else { return }
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        nameLabel.text = user.firstName! + " " + user.lastName!
        if user.category == .student {
            userCategoryLabel.text = user.profession! + ", " + user.speciality! + " · Student"
        } else {
            userCategoryLabel.text = user.profession! + ", " + user.speciality!
        }
    }
    
    func configureButtonText() {
        guard let userIsFollowing = userIsFollowing else { return }
        let titleString = userIsFollowing ? "Following" : "Follow"
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        followButton.configuration?.attributedTitle = AttributedString(titleString, attributes: container)
        followButton.configuration?.baseBackgroundColor = userIsFollowing ? .secondarySystemGroupedBackground : .label
        followButton.configuration?.baseForegroundColor = userIsFollowing ? .label : .systemBackground
        followButton.configuration?.background.strokeColor = userIsFollowing ? .quaternarySystemFill : .label
    }
    
    @objc func handleFollowUnfollow() {
        guard let userIsFollowing = userIsFollowing, let uid = user?.uid else { return }
        isUpdatingFollowState = true
        if userIsFollowing {
            // Handle unfollow
            UserService.unfollow(uid: uid) { error in
                self.isUpdatingFollowState = false
                if let _ = error {
                    return
                }
                self.userIsFollowing = false
                PostService.updateUserFeedAfterFollowing(userUid: uid, didFollow: false)
            }
        } else {
            // Handle follow
            UserService.follow(uid: uid) { error in
                self.isUpdatingFollowState = false
                if let _ = error {
                    return
                }
                self.userIsFollowing = true
                PostService.updateUserFeedAfterFollowing(userUid: uid, didFollow: true)
            }
        }
    }
}

