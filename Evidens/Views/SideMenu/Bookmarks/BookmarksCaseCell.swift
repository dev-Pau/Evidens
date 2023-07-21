//
//  BookmarksCaseCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/9/22.
//

import UIKit

class BookmarksCaseCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet {
            configure()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        caseBottomAnchor.isActive = false
    }
    
    private var userPostView = MEUserPostView()
    private var postTextView = MEPostTextView()
    private var caseBottomAnchor: NSLayoutConstraint!
    
    private let titleCaseLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let caseInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
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

        addSubviews(userPostView, titleCaseLabel, caseInfoLabel, postTextView, likesButton, likesCommentsLabel, separatorView)
        
        caseBottomAnchor = postTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
            
            caseInfoLabel.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 5),
            caseInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            caseInfoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
           
            titleCaseLabel.topAnchor.constraint(equalTo: caseInfoLabel.bottomAnchor, constant: 10),
            titleCaseLabel.leadingAnchor.constraint(equalTo: caseInfoLabel.leadingAnchor),
            titleCaseLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            postTextView.topAnchor.constraint(equalTo: titleCaseLabel.bottomAnchor, constant: 5),
            postTextView.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            postTextView.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
            caseBottomAnchor,
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            likesCommentsLabel.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 5),
            likesCommentsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            //likesCommentsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            likesButton.centerYAnchor.constraint(equalTo: likesCommentsLabel.centerYAnchor),
            likesButton.trailingAnchor.constraint(equalTo: likesCommentsLabel.leadingAnchor, constant: -2),
            likesButton.widthAnchor.constraint(equalToConstant: 12),
            likesButton.heightAnchor.constraint(equalToConstant: 12),
            
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        userPostView.dotsImageButton.isHidden = true
        caseInfoLabel.text = viewModel.caseSummaryInfoString.joined(separator: " • ")
        titleCaseLabel.text = viewModel.title
        userPostView.postTimeLabel.text = viewModel.timestampString! + " • "
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        
        postTextView.attributedText = NSMutableAttributedString(string: viewModel.content.appending(" "), attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.label])
        _ = postTextView.hashtags()
        postTextView.isSelectable = false
        postTextView.textContainer.maximumNumberOfLines = 4
        
        likesCommentsLabel.text = viewModel.likesCommentsText
        likesButton.isHidden = viewModel.likesButtonIsHidden
        
        if viewModel.isAnonymous {
            userPostView.profileImageView.image = UIImage(named: "user.profile.privacy")
            userPostView.nameLabel.text = "Anonymous Case"
        } else {
            userPostView.profileImageView.image = UIImage(named: "user.profile")
        }
        
        if viewModel.caseLikes > 0 || viewModel.caseComments > 0 {
            caseBottomAnchor.constant = -25
        } else {
            caseBottomAnchor.constant = -10
        }
        
        caseBottomAnchor.isActive = true
        
        layoutIfNeeded()
    }
    
    func set(user: User) {
        if let imageUrl = user.profileUrl, imageUrl != "" {
            userPostView.profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        //userPostView.userInfoCategoryLabel.attributedText = user.details()
        userPostView.userInfoCategoryLabel.text = user.details()
        userPostView.nameLabel.text = user.firstName! + " " + user.lastName!
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

