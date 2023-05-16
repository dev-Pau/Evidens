//
//  NotificationsLikeCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/8/22.
//

import UIKit

class NotificationLikeCommentCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    weak var delegate: NotificationCellDelegate?
    
    var viewModel: NotificationViewModel? {
        didSet {
            dotsImageButton.menu = addMenuItems()
        }
    }
    
    private var user: User?
    
    private let cellContentView = UIView()

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
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 4
        label.lineBreakMode = .byTruncatingMiddle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis")?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.configuration?.cornerStyle = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAction))
        addGestureRecognizer(tap)
        
        backgroundColor = .systemBackground

        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        cellContentView.backgroundColor = .systemBackground
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
   
        cellContentView.addSubviews(profileImageView, dotsImageButton, fullNameLabel, separatorView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            
            dotsImageButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 15),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 15),
            
            fullNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            fullNameLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10),
            fullNameLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor)
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
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
    
    func set(user: User) {
        guard let viewModel = viewModel else { return }
        self.user = user
        if let imageUrl = user.profileImageUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        
        let attributedText = NSMutableAttributedString(string: user.firstName! + " ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: user.lastName!, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: viewModel.notificationTypeDescription, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]))

        attributedText.append(NSAttributedString(string: viewModel.notification.type.notificationMessage + " ", attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        
        //attributedText.append(NSAttributedString(string: viewModel.groupInformation, attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.label.cgColor]))
        
        attributedText.append(NSAttributedString(string: viewModel.groupInformation, attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.label.cgColor]))

        
        attributedText.append(NSAttributedString(string: viewModel.notificationTypeSummary.trimmingCharacters(in: .newlines), attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.secondaryLabel.cgColor]))
        
        
        attributedText.append(NSAttributedString(string: viewModel.notificationTimeStamp, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.secondaryLabel.cgColor]))
        
        fullNameLabel.attributedText = attributedText
        

        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
   
    @objc func handleAction() {
        guard let viewModel = viewModel else { return }
        let type = viewModel.notification.type
        if type == .likePost || type == .commentPost {
            delegate?.cell(self, wantsToViewPost: viewModel.notification.contentId)
            return
        } else if type == .likeCase || type == .commentCase {
            delegate?.cell(self, wantsToViewCase: viewModel.notification.contentId)
            return
        } else {
            return
        }
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
}

