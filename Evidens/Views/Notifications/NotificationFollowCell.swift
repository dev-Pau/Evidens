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
    
    var viewModel: NotificationViewModel?
    
    private let cellContentView = UIView()
    
    private var user: User?

    /*
    private let notificationTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
     */
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis")
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.configuration?.cornerStyle = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleThreeDots), for: .touchUpInside)
        return button
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.buttonSize = .mini
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        return button
    }()
    
    private lazy var separatorLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground

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
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 15),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 15),
            
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            fullNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            fullNameLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10),
            
            followButton.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 10),
            followButton.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            followButton.heightAnchor.constraint(equalToConstant: 30),
            
            separatorLabel.topAnchor.constraint(equalTo: followButton.bottomAnchor),
            separatorLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: 10),
            separatorLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            separatorLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor)
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    @objc func handleFollow() {
        print("follow before")
        guard let viewModel = viewModel else { return }
        print("handle follow")
        if viewModel.notification.userIsFollowed {
            delegate?.cell(self, wantsToUnfollow: viewModel.notification.uid, firstName: viewModel.notification.firstName)
        } else {
            delegate?.cell(self, wantsToFollow: viewModel.notification.uid, firstName: viewModel.notification.firstName)
        }
    }
    
    @objc func handleThreeDots() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, didPressThreeDotsFor: viewModel.notification)

    }
    
    
    @objc func didTapProfile() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToViewProfile: viewModel.notification.uid)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        
        let height = max(autoLayoutSize.height, 65)
        
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    //MARK: - Helpers

    func set(user: User) {
        guard let viewModel = viewModel else { return }
        
        self.user = user
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        
        let attributedText = NSMutableAttributedString(string: user.firstName! + " ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: user.lastName!, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: viewModel.notification.type.notificationMessage, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: viewModel.notificationComment!, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: ".  \(viewModel.notificationTimeStamp)", attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor.secondaryLabel.cgColor]))
        
        fullNameLabel.attributedText = attributedText
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        followButton.configuration?.attributedTitle = AttributedString("   \(viewModel.followButtonText)   ", attributes: container)
        followButton.configuration?.baseBackgroundColor = viewModel.followButtonBackgroundColor
        followButton.configuration?.baseForegroundColor = viewModel.followButtonTextColor
        
    }
}
