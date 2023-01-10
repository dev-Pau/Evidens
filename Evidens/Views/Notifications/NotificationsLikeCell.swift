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
    
    var viewModel: NotificationViewModel?
    
    private var user: User?
    
    private let cellContentView = UIView()

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
    
    private let postText: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
      
        label.numberOfLines = 3
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
   
        cellContentView.addSubviews(profileImageView, dotsImageButton, fullNameLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            
            dotsImageButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 15),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 15),
            
            fullNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            fullNameLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10),
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
    }
    
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    @objc func handleFollow() {
        guard let viewModel = viewModel else { return }
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
    
    @objc func handleAction() {
        guard let viewModel = viewModel else { return }
        let type = viewModel.notification.type
        if type == .likePost || type == .commentPost {
            delegate?.cell(self, wantsToViewPost: viewModel.notification.postId!)
            return
        } else if type == .likeCase || type == .commentCase {
            delegate?.cell(self, wantsToViewCase: viewModel.notification.caseId!)
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

