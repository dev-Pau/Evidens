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
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.ellipsis)?.withRenderingMode(.alwaysOriginal).withTintColor(separatorColor)
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
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.buttonSize = .mini
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        button.addTarget(self, action: #selector(handleConnect), for: .touchUpInside)
        return button
    }()
    
    private lazy var ignoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.buttonSize = .mini
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeColor = UIColor.secondaryLabel
        button.configuration?.background.strokeWidth = 1
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
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

        addSubviews(unreadImage, separatorLabel, profileImageView, dotButton, fullNameLabel, timeLabel, connectButton, ignoreButton)
        
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

            ignoreButton.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 10),
            ignoreButton.leadingAnchor.constraint(equalTo: connectButton.trailingAnchor, constant: 10),

            timeLabel.topAnchor.constraint(equalTo: ignoreButton.bottomAnchor, constant: 5),
            timeLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
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
    
    //MARK: - Helpers
    
    private func configureConnectionButton() {
        guard let viewModel = viewModel else { return }
        var container = AttributeContainer()
        
        container.font = UIFont.addFont(size: 15, scaleStyle: .body, weight: .bold, scales: false)

        let boldFont = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        _ = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .medium)
        let font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        
        connectButton.configuration?.attributedTitle = AttributedString(viewModel.connectText, attributes: container)
        connectButton.configuration?.baseForegroundColor = viewModel.connectTextColor
        
        ignoreButton.configuration?.attributedTitle = AttributedString(viewModel.ignoreText, attributes: container)
        
        unreadImage.isHidden = viewModel.isRead
        backgroundColor = viewModel.isRead ? .systemBackground : primaryColor.withAlphaComponent(0.1)

        let attributedText = NSMutableAttributedString(string: viewModel.name, attributes: [.font: boldFont])
        attributedText.append(NSAttributedString(string: viewModel.message + ".", attributes: [.font: font]))

        fullNameLabel.attributedText = attributedText
        
        timeLabel.text = viewModel.time
        
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
