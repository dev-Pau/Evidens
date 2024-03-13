//
//  NotificationAcceptConnection.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/1/24.
//

import UIKit

class NotificationAcceptConnectionCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    weak var delegate: NotificationCellDelegate?
    
    var viewModel: NotificationViewModel? {
        didSet {
            configureNotification()
        }
    }
    
    private var user: User?
    
    private lazy var profileImageView = ProfileImageView(frame: .zero)
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var unreadImage: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = primaryColor
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private var dotButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        
        let buttonSize: CGFloat = UIDevice.isPad ? 25 : 20
        
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.ellipsis)?.scalePreservingAspectRatio(targetSize: CGSize(width: buttonSize, height: buttonSize)).withRenderingMode(.alwaysOriginal).withTintColor(separatorColor)
        button.adjustsImageSizeForAccessibilityContentSizeCategory = false
        button.configuration?.buttonSize = .mini
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .medium)
        label.textColor = primaryGray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        let imageSize: CGFloat = UIDevice.isPad ? 63 : 53
        let buttonSize: CGFloat = UIDevice.isPad ? 35 : 30
        
        addSubviews(unreadImage, profileImageView, dotButton, contentLabel, timeLabel, separatorView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
            profileImageView.widthAnchor.constraint(equalToConstant: imageSize),
            profileImageView.heightAnchor.constraint(equalToConstant: imageSize),
            
            unreadImage.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            unreadImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            unreadImage.heightAnchor.constraint(equalToConstant: 7),
            unreadImage.widthAnchor.constraint(equalToConstant: 7),
            
            dotButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            dotButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            dotButton.heightAnchor.constraint(equalToConstant: buttonSize),
            dotButton.widthAnchor.constraint(equalToConstant: buttonSize),
            
            contentLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            contentLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            contentLabel.trailingAnchor.constraint(equalTo: dotButton.leadingAnchor, constant: -10),

            timeLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 5),
            timeLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        profileImageView.layer.cornerRadius = imageSize / 2
        unreadImage.layer.cornerRadius = 7 / 2
        backgroundColor = .systemBackground
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
    
    private func configureNotification() {
        guard let viewModel = viewModel else { return }
        dotButton.menu = addMenuItems()
        let imageSize: CGFloat = UIDevice.isPad ? 63 : 53
        let boldFont = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        let font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)

        let attributedText = NSMutableAttributedString(string: viewModel.name, attributes: [.font: boldFont])

        attributedText.append(NSAttributedString(string: viewModel.message + " ", attributes: [.font: font]))
       
        timeLabel.text = viewModel.time
        
        unreadImage.isHidden = viewModel.isRead
        backgroundColor = viewModel.isRead ? .systemBackground : primaryColor.withAlphaComponent(0.05)
        
        contentLabel.attributedText = attributedText

        if let image = viewModel.image() {
            profileImageView.addImage(forUrl: image.absoluteString, forUsername: viewModel.username, size: imageSize)
        } else {
            profileImageView.addImage(forUrl: nil, forUsername: viewModel.username, size: imageSize)
        }
        
        layoutIfNeeded()
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
