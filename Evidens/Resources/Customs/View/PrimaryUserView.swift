//
//  PrimaryUserView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/6/22.
//

import UIKit

protocol PrimaryUserViewDelegate: AnyObject {
    func didTapProfile()
}

class PrimaryUserView: UIView {
    
    weak var delegate: PrimaryUserViewDelegate?
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    private var trailingConstantConstraint: NSLayoutConstraint!
    private var editButtonWidthConstraint: NSLayoutConstraint!
    private var referenceButtonWidthConstraint: NSLayoutConstraint!
    lazy var profileImageView = ProfileImageView(frame: .zero)
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = UIFont.addFont(size: 15, scaleStyle: .title1, weight: .semibold)
        
        label.isUserInteractionEnabled = false
        return label
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.addFont(size: 15, scaleStyle: .title1, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var dotButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.ellipsis)?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysOriginal).withTintColor(separatorColor)
        button.adjustsImageSizeForAccessibilityContentSizeCategory = false
        button.configuration?.buttonSize = .mini
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.isUserInteractionEnabled = false
        button.isHidden = true
        button.configuration?.image = UIImage(named: AppStrings.Assets.fillPencil)?.withRenderingMode(.alwaysOriginal).withTintColor(.link).scalePreservingAspectRatio(targetSize: CGSize(width: 18, height: 18))
        return button
    }()
    
    private let referenceButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.isUserInteractionEnabled = false
        button.isHidden = true
        button.configuration?.image = UIImage(named: AppStrings.Assets.fillQuote)?.withRenderingMode(.alwaysOriginal).withTintColor(.link).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        return button
    }()
    
    var userInfoCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.addFont(size: 15, scaleStyle: .title1, weight: .regular)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfile)))
        backgroundColor = .systemBackground
        
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        timestampLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        trailingConstantConstraint = timestampLabel.trailingAnchor.constraint(lessThanOrEqualTo: dotButton.leadingAnchor, constant: -5)
    
        addSubviews(profileImageView, nameLabel, timestampLabel, editButton, dotButton, referenceButton, referenceButton, userInfoCategoryLabel)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        editButtonWidthConstraint = editButton.widthAnchor.constraint(equalToConstant: 0)
        referenceButtonWidthConstraint = referenceButton.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddingLeft),
            profileImageView.heightAnchor.constraint(equalToConstant: 35),
            profileImageView.widthAnchor.constraint(equalToConstant: 35),
 
            nameLabel.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: paddingLeft),
            nameLabel.trailingAnchor.constraint(equalTo: timestampLabel.leadingAnchor, constant: 3),
            
            timestampLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            trailingConstantConstraint,
            
            editButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 30),
            editButtonWidthConstraint,
            editButton.leadingAnchor.constraint(equalTo: timestampLabel.trailingAnchor),
            
            referenceButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            referenceButton.heightAnchor.constraint(equalToConstant: 30),
            referenceButtonWidthConstraint,
            referenceButton.leadingAnchor.constraint(equalTo: editButton.trailingAnchor),
            
            dotButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            dotButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddingLeft),
            dotButton.heightAnchor.constraint(equalToConstant: 30),
            dotButton.widthAnchor.constraint(equalToConstant: 30),

            userInfoCategoryLabel.topAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            userInfoCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userInfoCategoryLabel.trailingAnchor.constraint(equalTo: dotButton.trailingAnchor),
            userInfoCategoryLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        profileImageView.layer.cornerRadius = 35 / 2
    
    }
    
    func set(user: User) {
        if let imageUrl = user.profileUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        } else {
            profileImageView.image = UIImage(named: AppStrings.Assets.profile)
        }
        
        nameLabel.text = user.name()
        userInfoCategoryLabel.text = user.details()
    }
    
    func anonymize() {
        profileImageView.image = UIImage(named: AppStrings.Assets.privacyProfile)
        nameLabel.text = AppStrings.Content.Case.Privacy.anonymousTitle + AppStrings.Characters.space
        userInfoCategoryLabel.text = AppStrings.Content.Case.Privacy.anonymousCase
    }
    
    func set(isEdited: Bool, hasReference: Bool) {
        if isEdited && hasReference {
            editButtonWidthConstraint.constant = 22
            referenceButtonWidthConstraint.constant = 18
            trailingConstantConstraint.constant = -40
            
            editButton.isHidden = false
            referenceButton.isHidden = false
        } else if isEdited || hasReference {
            editButton.isHidden = !isEdited
            referenceButton.isHidden = !hasReference
            
            editButtonWidthConstraint.constant = isEdited ? 25 : 0
            referenceButtonWidthConstraint.constant = hasReference ? 30 : 0
            
            trailingConstantConstraint.constant = -30
        } else {
            editButtonWidthConstraint.constant = 0
            referenceButtonWidthConstraint.constant = 0
            trailingConstantConstraint.constant = -5
            editButton.isHidden = true
            referenceButton.isHidden = true
        }

        layoutIfNeeded()
    }
    
    
    @objc func didTapProfile() {
        delegate?.didTapProfile()
    }
}
