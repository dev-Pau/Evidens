//
//  NotificationCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/11/21.
//

import Foundation
import UIKit

class NotificationFollowCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    weak var delegate: NotificationCellDelegate?

    var viewModel: NotificationViewModel? {
        didSet {
            configureFollowButton()
            dotsImageButton.menu = addMenuItems()
        }
    }
    
    var isUpdatingFollowingState: Bool? {
        didSet {
            followButton.setNeedsUpdateConfiguration()
        }
    }
    
    private lazy var profileImageView = ProfileImageView(frame: .zero)
    
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingMiddle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.ellipsis)?.withRenderingMode(.alwaysOriginal).withTintColor(separatorColor!)
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.configuration?.cornerStyle = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
      
        return button
    }()
    
    private lazy var unreadImage: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = primaryColor
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.buttonSize = .mini
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.background.strokeWidth = 1
        button.configuration?.background.strokeColor = .tertiarySystemFill
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        return button
    }()
    
    private lazy var separatorLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        isUpdatingFollowingState = false

        addSubviews(unreadImage, separatorLabel, profileImageView, dotsImageButton, fullNameLabel, followButton)
        
        NSLayoutConstraint.activate([

            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
            profileImageView.widthAnchor.constraint(equalToConstant: 53),
            profileImageView.heightAnchor.constraint(equalToConstant: 53),
            
            unreadImage.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            unreadImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            unreadImage.heightAnchor.constraint(equalToConstant: 7),
            unreadImage.widthAnchor.constraint(equalToConstant: 7),
            
            dotsImageButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 15),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 15),
            
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            fullNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            fullNameLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10),

            followButton.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 10),
            followButton.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            followButton.heightAnchor.constraint(equalToConstant: 30),
            followButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorLabel.heightAnchor.constraint(equalToConstant: 0.4),
            separatorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        followButton.configurationUpdateHandler = { [unowned self] button in
            button.isUserInteractionEnabled = self.isUpdatingFollowingState! ? false : true
        }
        
        profileImageView.layer.cornerRadius = 53 / 2
        unreadImage.layer.cornerRadius = 7 / 2
        
        backgroundColor = .systemBackground

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    @objc func handleFollow() {
        guard let viewModel = viewModel else { return }
        isUpdatingFollowingState = true
        delegate?.cell(self, wantsToFollow: viewModel.notification.uid)
    }
    
    func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel else { return nil }
        let menuItem = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
            UIAction(title: AppStrings.Alerts.Title.deleteNotification, image: UIImage(systemName: AppStrings.Icons.trash), handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.cell(strongSelf, didPressThreeDotsFor: viewModel.notification, option: .delete)
            })
        ])
        dotsImageButton.showsMenuAsPrimaryAction = true
        return menuItem
    }
    
    func addUnfollowMenu() -> UIMenu? {
        guard let viewModel = viewModel else { return nil }
        let menuItem = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
            UIAction(title: AppStrings.Alerts.Actions.unfollow + " " + viewModel.name, image: UIImage(systemName: AppStrings.Icons.minus), handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.cell(strongSelf, wantsToUnfollow: viewModel.notification.uid)
                //self.followButton.menu = nil
            })
        ])
        followButton.showsMenuAsPrimaryAction = true
        return menuItem
    }
    
    
    @objc func didTapProfile() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToViewProfile: viewModel.notification.uid)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        
        //let height = max(autoLayoutSize.height)
        
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    //MARK: - Helpers
/*
    func set(user: User) {
        guard let viewModel = viewModel else { return }
        
        self.user = user
        if let imageUrl = user.profileUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        
        let attributedText = NSMutableAttributedString(string: user.firstName! + " ", attributes: [.font: UIFont.boldSystemFont(ofSize: 15)])
        attributedText.append(NSAttributedString(string: user.lastName!, attributes: [.font: UIFont.boldSystemFont(ofSize: 15)]))
        if followers > 1 {
            attributedText.append(NSAttributedString(string: " " + AppStrings.Miscellaneous.andOthers, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]))
        }

        attributedText.append(NSAttributedString(string: " " + viewModel.notification.kind.message + ". ", attributes: [.font: UIFont.systemFont(ofSize: 14)]))

        attributedText.append(NSAttributedString(string: viewModel.time, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium), .foregroundColor: UIColor.secondaryLabel.cgColor]))
        
        fullNameLabel.attributedText = attributedText
    }
    */
    private func configureFollowButton() {
        guard let viewModel = viewModel else { return }
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        
        followButton.configuration?.attributedTitle = AttributedString("   \(viewModel.followText)   ", attributes: container)
        followButton.configuration?.baseBackgroundColor = viewModel.followColor
        followButton.configuration?.baseForegroundColor = viewModel.followTextColor
        
        unreadImage.isHidden = viewModel.isRead
        backgroundColor = viewModel.isRead ? .systemBackground : primaryColor.withAlphaComponent(0.1)
        
        if let isFollowed = viewModel.notification.isFollowed {
            
            followButton.menu = isFollowed ? addUnfollowMenu() : nil
        } else {
            followButton.menu = nil
        }
        
        let attributedText = NSMutableAttributedString(string: viewModel.name, attributes: [.font: UIFont.boldSystemFont(ofSize: 15)])
        attributedText.append(NSAttributedString(string: " " + viewModel.notification.kind.message + ". ", attributes: [.font: UIFont.systemFont(ofSize: 14)]))

        attributedText.append(NSAttributedString(string: viewModel.time, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium), .foregroundColor: UIColor.secondaryLabel.cgColor]))
        fullNameLabel.attributedText = attributedText
        
        if let image = viewModel.image() {
            profileImageView.sd_setImage(with: image)
        } else {
            if viewModel.notification.uid.isEmpty {
                profileImageView.image = UIImage(named: AppStrings.Assets.privacyProfile)!
            } else {
                profileImageView.image = UIImage(named: AppStrings.Assets.profile)!
            }
        }
    }
}
