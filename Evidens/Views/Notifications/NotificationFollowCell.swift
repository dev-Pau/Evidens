//
//  NotificationCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/11/21.
//

import Foundation
import UIKit
import JGProgressHUD


class NotificationFollowCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    weak var delegate: NotificationCellDelegate?
    var followers = 0

    
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
    
    private let cellContentView = UIView()
    
    private var user: User?

    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "user.profile")
        iv.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingMiddle
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFollowersTap)))
        return label
    }()
    
    private lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis")?.withRenderingMode(.alwaysOriginal).withTintColor(separatorColor!)
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.configuration?.cornerStyle = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
      
        return button
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

        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            //heightAnchor.constraint(equalToConstant: 115),
        ])
   
        cellContentView.addSubviews(separatorLabel, profileImageView, dotsImageButton, fullNameLabel, followButton)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            
            dotsImageButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 15),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 15),
            
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            fullNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            fullNameLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10),
            fullNameLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -50),
            
            followButton.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 10),
            followButton.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            followButton.heightAnchor.constraint(equalToConstant: 30),
            
            separatorLabel.heightAnchor.constraint(equalToConstant: 0.4),
            separatorLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),
            separatorLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            separatorLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor)
        ])
        
        followButton.configurationUpdateHandler = { [unowned self] button in
            button.isUserInteractionEnabled = self.isUpdatingFollowingState! ? false : true
            /*
            var container = AttributeContainer()
            container.font = .systemFont(ofSize: 14, weight: .bold)
            
            button.configuration?.attributedTitle = AttributedString("   \(viewModel.followButtonText)   ", attributes: container)
            button.configuration?.baseBackgroundColor = viewModel?.followButtonBackgroundColor
            button.configuration?.baseForegroundColor = viewModel?.followButtonTextColor
            button.configuration?.background.strokeWidth = viewModel?.followButtonCornerWidth ?? 0.0
             */
        }
        
        profileImageView.layer.cornerRadius = 45 / 2

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    @objc func handleFollow() {
        guard let viewModel = viewModel else { return }
        isUpdatingFollowingState = true
        delegate?.cell(self, wantsToFollow: viewModel.notification.uid)
        /*
        if viewModel.notification.userIsFollowed {
            delegate?.cell(self, wantsToUnfollow: viewModel.notification.uid)
        } else {
            delegate?.cell(self, wantsToFollow: viewModel.notification.uid)
        }
         */
    }
    
    func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel else { return nil }
        let menuItem = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
            UIAction(title: "Delete Notification", image: UIImage(systemName: "trash"), handler: { (_) in
                self.delegate?.cell(self, didPressThreeDotsFor: viewModel.notification, option: .delete)
            })
        ])
        dotsImageButton.showsMenuAsPrimaryAction = true
        return menuItem
    }
    
    func addUnfollowMenu() -> UIMenu? {
        guard let user = user, let viewModel = viewModel else { return nil }
        let menuItem = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
            UIAction(title: "Unfollow \(user.firstName!)", image: UIImage(systemName: "minus"), handler: { (_) in
                self.delegate?.cell(self, wantsToUnfollow: viewModel.notification.uid)
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
    
    @objc func handleFollowersTap() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToSeeFollowingDetailsForNotification: viewModel.notification)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        
        //let height = max(autoLayoutSize.height)
        
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    //MARK: - Helpers

    func set(user: User) {
        guard let viewModel = viewModel else { return }
        
        self.user = user
        if let imageUrl = user.profileImageUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        
        let attributedText = NSMutableAttributedString(string: user.firstName! + " ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: user.lastName!, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]))
        if followers > 1 {
            attributedText.append(NSAttributedString(string: " and others", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]))
        }

        attributedText.append(NSAttributedString(string: " " + viewModel.notification.kind.message + ". ", attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        //attributedText.append(NSAttributedString(string: viewModel.notificationText!, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: viewModel.notificationTimeStamp, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.secondaryLabel.cgColor]))
        
        fullNameLabel.attributedText = attributedText
    }
    
    private func configureFollowButton() {
        guard let viewModel = viewModel else { return }
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        followButton.configuration?.attributedTitle = AttributedString("   \(viewModel.followButtonText)   ", attributes: container)
        followButton.configuration?.baseBackgroundColor = viewModel.followButtonBackgroundColor
        followButton.configuration?.baseForegroundColor = viewModel.followButtonTextColor
        followButton.configuration?.background.strokeWidth = viewModel.followButtonBorderWidth
        
        
        if viewModel.notification.userIsFollowed {
            followButton.menu = addUnfollowMenu()
        } else {
            followButton.menu = nil
        }
    }
}
