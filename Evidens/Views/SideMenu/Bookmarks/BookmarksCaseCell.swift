//
//  BookmarksCaseCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/9/22.
//

import UIKit

class BookmarksCaseCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet { configure() }
        
    }
    
    private var userPostView = MEUserPostView()
    
    private lazy var caseStateButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.buttonSize = .mini
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 10, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Solved", attributes: container)
        
        button.configuration?.baseBackgroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleCaseLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionCaseLabel: UILabel = {
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        userPostView.isUserInteractionEnabled = false
        
        
        backgroundColor = .systemBackground
        addSubviews(userPostView, caseStateButton, titleCaseLabel, descriptionCaseLabel, likesButton, likesCommentsLabel)
        
        NSLayoutConstraint.activate([
            
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
           
            caseStateButton.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 5),
            caseStateButton.leadingAnchor.constraint(equalTo: userPostView.leadingAnchor, constant: 10),
            caseStateButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleCaseLabel.topAnchor.constraint(equalTo: caseStateButton.bottomAnchor, constant: 10),
            titleCaseLabel.leadingAnchor.constraint(equalTo: caseStateButton.leadingAnchor),
            titleCaseLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            descriptionCaseLabel.topAnchor.constraint(equalTo: titleCaseLabel.bottomAnchor, constant: 5),
            descriptionCaseLabel.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            descriptionCaseLabel.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
            
            likesButton.topAnchor.constraint(equalTo: descriptionCaseLabel.bottomAnchor, constant: 10),
            likesButton.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            likesButton.widthAnchor.constraint(equalToConstant: 12),
            likesButton.heightAnchor.constraint(equalToConstant: 12),
            
            likesCommentsLabel.centerYAnchor.constraint(equalTo: likesButton.centerYAnchor),
            likesCommentsLabel.leadingAnchor.constraint(equalTo: likesButton.trailingAnchor, constant: 2),
            likesCommentsLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            likesCommentsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        userPostView.dotsImageButton.isHidden = true
        titleCaseLabel.text = viewModel.caseTitle
        userPostView.postTimeLabel.text = viewModel.timestampString
        descriptionCaseLabel.text = viewModel.caseDescription
        likesCommentsLabel.text = viewModel.likesCommentsText
        likesButton.isHidden = viewModel.likesButtonIsHidden
        
        caseStateButton.configuration?.attributedTitle = viewModel.caseStage
        caseStateButton.configuration?.baseBackgroundColor = viewModel.caseStageBackgroundColor
        caseStateButton.configuration?.baseForegroundColor = viewModel.caseStageTextColor
    }
    
    func set(user: User) {
        guard let viewModel = viewModel else { return }

        if viewModel.caseIsAnonymous {
            #warning("configiure privacy image")
            userPostView.profileImageView.image = UIImage(named: "")
            userPostView.usernameLabel.text = "Shared anonymously"
            
        } else {
            userPostView.profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
            userPostView.usernameLabel.text = user.firstName! + " " + user.lastName!
        }
        
        
        userPostView.userInfoCategoryLabel.attributedText = user.getUserAttributedInfo()
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

