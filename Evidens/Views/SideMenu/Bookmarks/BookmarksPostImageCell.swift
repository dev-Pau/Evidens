//
//  BookmarksPostImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/9/22.
//

import UIKit

class BookmarksPostImageCell: UICollectionViewCell {
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoBottomAnchor.isActive = false
    }
    
    private var photoBottomAnchor: NSLayoutConstraint!
    
    private var userPostView = MEUserPostView()
    
    private var postTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 5
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    
    private let likesButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "heart.fill")?.scalePreservingAspectRatio(targetSize: CGSize(width: 12, height: 12)).withRenderingMode(.alwaysOriginal).withTintColor(pinkColor)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let likesCommentsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .systemBackground
        userPostView.isUserInteractionEnabled = false

        photoBottomAnchor = postImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)

        addSubviews(userPostView, postTextLabel, postImage, likesButton, likesCommentsLabel, separatorView)
        
        let userPostViewHeightConstraint = userPostView.heightAnchor.constraint(equalToConstant: 67)
        userPostViewHeightConstraint.priority = .defaultHigh
        userPostViewHeightConstraint.isActive = true

        let spacingConstraint = userPostView.bottomAnchor.constraint(equalTo: postTextLabel.topAnchor)
        spacingConstraint.priority = .defaultHigh
        spacingConstraint.isActive = true
        
        let postTextLabelTopConstraint = postTextLabel.topAnchor.constraint(equalTo: userPostView.bottomAnchor)
        postTextLabelTopConstraint.priority = .defaultLow
        postTextLabelTopConstraint.isActive = true

        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),

            postImage.topAnchor.constraint(equalTo: userPostView.bottomAnchor),
            postImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            postImage.widthAnchor.constraint(equalToConstant: 75),
            postImage.heightAnchor.constraint(equalToConstant: 75),
            photoBottomAnchor,

            postTextLabelTopConstraint,
            postTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postTextLabel.trailingAnchor.constraint(equalTo: postImage.leadingAnchor, constant: -10),
            postTextLabel.bottomAnchor.constraint(equalTo: postImage.bottomAnchor),

            likesCommentsLabel.topAnchor.constraint(equalTo: postImage.bottomAnchor, constant: 5),
            likesCommentsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            likesButton.centerYAnchor.constraint(equalTo: likesCommentsLabel.centerYAnchor),
            likesButton.trailingAnchor.constraint(equalTo: likesCommentsLabel.leadingAnchor, constant: -2),
            likesButton.widthAnchor.constraint(equalToConstant: 12),
            likesButton.heightAnchor.constraint(equalToConstant: 12),

            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        userPostView.dotsImageButton.isHidden = true
        
        userPostView.postTimeLabel.text = viewModel.postIsEdited ? viewModel.timestampString! + " • Edited • " : viewModel.timestampString! + " • "
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        postImage.sd_setImage(with: viewModel.postImageUrl.first)
        postTextLabel.text = viewModel.postText
        likesCommentsLabel.text = viewModel.likesCommentsText
        likesButton.isHidden = viewModel.likesButtonIsHidden
        
        if viewModel.likes > 0 || viewModel.comments > 0 {
            photoBottomAnchor.constant = -25
        } else {
            photoBottomAnchor.constant = -10
        }
        
        photoBottomAnchor.isActive = true
        
        layoutIfNeeded()
        
    }
    
    func set(user: User) {
        if let profileImageUrl = user.profileImageUrl, profileImageUrl != "" {
            userPostView.profileImageView.sd_setImage(with: URL(string: profileImageUrl))
        }
        
        userPostView.usernameLabel.text = user.firstName! + " " + user.lastName!
        userPostView.userInfoCategoryLabel.attributedText = user.getUserAttributedInfo()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 175)

        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

