//
//  UserProfilePostCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/7/22.
//

import UIKit

class UserProfilePostCell: UICollectionViewCell {
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    var user: User?
    
    private var postTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likesButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.fillHeart)?.scalePreservingAspectRatio(targetSize: CGSize(width: 12, height: 12)).withRenderingMode(.alwaysOriginal).withTintColor(primaryRed)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let likesCommentsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
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
        
        addSubviews(postTextLabel, likesButton, likesCommentsLabel, postLabel, separatorView)
        
        NSLayoutConstraint.activate([
            postLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            postLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            postTextLabel.topAnchor.constraint(equalTo: postLabel.bottomAnchor, constant: 8),
            postTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            postTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            likesCommentsLabel.topAnchor.constraint(equalTo: postLabel.topAnchor),
            likesCommentsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            likesButton.centerYAnchor.constraint(equalTo: likesCommentsLabel.centerYAnchor),
            likesButton.trailingAnchor.constraint(equalTo: likesCommentsLabel.leadingAnchor, constant: -2),
            likesButton.widthAnchor.constraint(equalToConstant: 12),
            likesButton.heightAnchor.constraint(equalToConstant: 12),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel, let _ = user else { return }
        postTextLabel.text = viewModel.postText
        postLabel.attributedText = postLabelAttributedString()
        likesCommentsLabel.text = viewModel.valueText
        likesButton.isHidden = viewModel.likeIsHidden
    }
    
    func postLabelAttributedString() -> NSAttributedString? {
        guard let user = user, let viewModel = viewModel else { return nil }
        let attributedText = NSMutableAttributedString(string: user.name(), attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: UIColor.secondaryLabel])
        attributedText.append(NSAttributedString(string: " " + AppStrings.Profile.Post.posted + AppStrings.Characters.dot + viewModel.timestamp, attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor: UIColor.secondaryLabel]))
        return attributedText
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

