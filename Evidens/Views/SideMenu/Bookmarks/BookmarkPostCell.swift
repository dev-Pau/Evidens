//
//  BookmarkPostCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/9/22.
//

import UIKit

class BookmarkPostCell: UICollectionViewCell {
    
    weak var delegate: BookmarksCellDelegate?
    private var user: User?
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postBottomAnchor.isActive = false
    }
    
    private var userPostView = PrimaryUserView()
    private var postTextView = SecondaryTextView()
    private var postBottomAnchor: NSLayoutConstraint!
    
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
        addSubviews(userPostView, postTextView, likesButton, likesCommentsLabel, separatorView)
        postBottomAnchor = postTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
           
            postTextView.topAnchor.constraint(equalTo: userPostView.bottomAnchor),
            postTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            postBottomAnchor,
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            likesCommentsLabel.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 5),
            likesCommentsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            likesButton.centerYAnchor.constraint(equalTo: likesCommentsLabel.centerYAnchor),
            likesButton.trailingAnchor.constraint(equalTo: likesCommentsLabel.leadingAnchor, constant: -2),
            likesButton.widthAnchor.constraint(equalToConstant: 12),
            likesButton.heightAnchor.constraint(equalToConstant: 12),
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        userPostView.dotsImageButton.isHidden = true
        
        userPostView.postTimeLabel.text = viewModel.time
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        postTextView.attributedText = NSMutableAttributedString(string: viewModel.postText.appending(" "), attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.label])
        _ = postTextView.hashtags()
        postTextView.isSelectable = false
        postTextView.textContainer.maximumNumberOfLines = 4
        
        likesCommentsLabel.text = viewModel.valueText
        likesButton.isHidden = viewModel.likeIsHidden
        
        if viewModel.likes > 0 || viewModel.comments > 0 {
            postBottomAnchor.constant = -25
        } else {
            postBottomAnchor.constant = -10
        }
        
        postBottomAnchor.isActive = true
        
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

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 170)

        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

extension BookmarkPostCell: HomeCellProtocol { }


