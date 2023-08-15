//
//  BookmarksPostImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/9/22.
//

import UIKit

class BookmarksPostImageCell: UICollectionViewCell {
    
    weak var delegate: BookmarksCellDelegate?
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    private var user: User?

    override func prepareForReuse() {
        super.prepareForReuse()
        photoBottomAnchor.isActive = false
    }
    
    private var photoBottomAnchor: NSLayoutConstraint!
    
    private var userPostView = PrimaryUserView()
    private var postTextView = SecondaryTextView()
    
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
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.fillHeart)?.scalePreservingAspectRatio(targetSize: CGSize(width: 12, height: 12)).withRenderingMode(.alwaysOriginal).withTintColor(pinkColor)
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
        userPostView.isUserInteractionEnabled = true
        userPostView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileTap)))
        postTextView.isUserInteractionEnabled = false
        photoBottomAnchor = postImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)

        addSubviews(userPostView, postTextView, postImage, likesButton, likesCommentsLabel, separatorView)
        
        let userPostViewHeightConstraint = userPostView.heightAnchor.constraint(equalToConstant: 67)
        userPostViewHeightConstraint.priority = .defaultHigh
        userPostViewHeightConstraint.isActive = true

        let spacingConstraint = userPostView.bottomAnchor.constraint(equalTo: postTextView.topAnchor)
        spacingConstraint.priority = .defaultHigh
        spacingConstraint.isActive = true
        
        let postTextLabelTopConstraint = postTextView.topAnchor.constraint(equalTo: userPostView.bottomAnchor)
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
            postTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postTextView.trailingAnchor.constraint(equalTo: postImage.leadingAnchor, constant: -10),
            postTextView.bottomAnchor.constraint(equalTo: postImage.bottomAnchor),

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
        postTextView.isUserInteractionEnabled = false
        userPostView.postTimeLabel.text = viewModel.time
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        
        if let firstImage = viewModel.imageUrl.first {
            postImage.sd_setImage(with: firstImage)
        }
        
        postTextView.attributedText = NSMutableAttributedString(string: viewModel.postText.appending(" "), attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.label])
        _ = postTextView.hashtags()
        postTextView.isSelectable = false

        likesCommentsLabel.text = viewModel.valueText
        likesButton.isHidden = viewModel.likeIsHidden
        
        if viewModel.likes > 0 || viewModel.comments > 0 {
            photoBottomAnchor.constant = -25
        } else {
            photoBottomAnchor.constant = -10
        }
        
        photoBottomAnchor.isActive = true
        
        layoutIfNeeded()
        
    }
    
    func set(user: User) {
        self.user = user
        userPostView.set(user: user)
    }
    
    @objc func handleProfileTap() {
        guard let user = user else { return }
        delegate?.cell(self, wantsToShowProfileFor: user)
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

extension BookmarksPostImageCell: HomeCellProtocol { }

