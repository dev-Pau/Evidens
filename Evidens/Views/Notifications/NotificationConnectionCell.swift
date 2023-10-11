//
//  NotificationConnectionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/11/21.
//

import Foundation
import UIKit

class NotificationConnectionCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    weak var delegate: NotificationCellDelegate?

    var viewModel: NotificationViewModel? {
        didSet {
            configureConnectionButton()
            dotButton.menu = addMenuItems()
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
    
    private lazy var dotButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.ellipsis)?.withRenderingMode(.alwaysOriginal).withTintColor(separatorColor!)
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.buttonSize = .medium
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
    
    private lazy var connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.buttonSize = .mini
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleConnect), for: .touchUpInside)
        return button
    }()
    
    private lazy var ignoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.buttonSize = .mini
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.addTarget(self, action: #selector(handleReject), for: .touchUpInside)
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

        addSubviews(unreadImage, separatorLabel, profileImageView, dotButton, fullNameLabel, connectButton, ignoreButton)
        
        NSLayoutConstraint.activate([

            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
            profileImageView.widthAnchor.constraint(equalToConstant: 53),
            profileImageView.heightAnchor.constraint(equalToConstant: 53),
            
            unreadImage.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            unreadImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            unreadImage.heightAnchor.constraint(equalToConstant: 7),
            unreadImage.widthAnchor.constraint(equalToConstant: 7),
            
            dotButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            dotButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            dotButton.heightAnchor.constraint(equalToConstant: 15),
            dotButton.widthAnchor.constraint(equalToConstant: 15),
            
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            fullNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            fullNameLabel.trailingAnchor.constraint(equalTo: dotButton.leadingAnchor, constant: -10),

            connectButton.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 10),
            connectButton.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            connectButton.heightAnchor.constraint(equalToConstant: 30),
            connectButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            ignoreButton.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 10),
            ignoreButton.leadingAnchor.constraint(equalTo: connectButton.trailingAnchor),
            ignoreButton.heightAnchor.constraint(equalToConstant: 30),
            ignoreButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorLabel.heightAnchor.constraint(equalToConstant: 0.4),
            separatorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        profileImageView.layer.cornerRadius = 53 / 2
        unreadImage.layer.cornerRadius = 7 / 2
        
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    @objc func handleConnect() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToConnect: viewModel.notification.uid)
    }
    
    @objc func handleReject() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToIgnore: viewModel.notification.uid)
    }
    
    func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel else { return nil }
        let menuItem = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
            UIAction(title: AppStrings.Alerts.Title.deleteNotification, image: UIImage(systemName: AppStrings.Icons.trash), handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.cell(strongSelf, didPressThreeDotsFor: viewModel.notification, option: .delete)
            })
        ])
        
        dotButton.showsMenuAsPrimaryAction = true
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
        
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    //MARK: - Helpers
    
    private func configureConnectionButton() {
        guard let viewModel = viewModel else { return }
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        
        connectButton.configuration?.attributedTitle = AttributedString("   \(viewModel.connectText)   ", attributes: container)
        connectButton.configuration?.baseForegroundColor = viewModel.connectTextColor
        
        ignoreButton.configuration?.attributedTitle = AttributedString("   \(viewModel.ignoreText)   ", attributes: container)
        
        unreadImage.isHidden = viewModel.isRead
        backgroundColor = viewModel.isRead ? .systemBackground : primaryColor.withAlphaComponent(0.1)
        
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
