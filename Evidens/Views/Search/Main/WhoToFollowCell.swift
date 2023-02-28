//
//  WhoToFollowCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/2/23.
//

import UIKit

class WhoToFollowCell: UICollectionViewCell {
    
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
        
        //button.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        
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
        
        
        
        /*
         private func addMenuItems() -> UIMenu? {
         guard let user = user else { return nil }
         let menuItems = UIMenu(options: .displayInline, children: [
         UIAction(title: "Unfollow \(user.firstName!)", image: UIImage(systemName: "person.fill.xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), handler: { _ in
         //self.isUpdatingFollowState = true
         //self.followerDelegate?.didUnfollowOnFollower(self, user: user)
         //self.followingDelegate?.didUnfollowOnFollowing(self, user: user)
         })
         ])
         followButton.showsMenuAsPrimaryAction = true
         
         return menuItems
         */
    }
    
    func configureWithUser(user: User) {
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        nameLabel.text = user.firstName! + " " + user.lastName!
        if user.category == .student {
            userCategoryLabel.text = user.profession! + ", " + user.speciality! + " · Student"
        } else {
            userCategoryLabel.text = user.profession! + ", " + user.speciality!
        }
        
        let titleString = user.isFollowed ? "Following" : "Follow"
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        followButton.configuration?.attributedTitle = AttributedString(titleString, attributes: container)
        followButton.configuration?.baseBackgroundColor = user.isFollowed ? .secondarySystemGroupedBackground : .label
        followButton.configuration?.baseForegroundColor = user.isFollowed ? .label : .systemBackground
        followButton.configuration?.background.strokeColor = user.isFollowed ? .quaternarySystemFill : .label
        //followButton.menu = user.isFollowed ? addMenuItems() : nil
    }
}
