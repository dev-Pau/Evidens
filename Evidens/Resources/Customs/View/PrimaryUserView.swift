//
//  PrimaryUserView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/6/22.
//

import UIKit

protocol PrimaryUserViewDelegate: AnyObject {
    func didTapProfile()
    func didTapThreeDots()
}

class PrimaryUserView: UIView {
    
    weak var delegate: PrimaryUserViewDelegate?
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    private var trailingConstantConstraint: NSLayoutConstraint!
    lazy var profileImageView = ProfileImageView(frame: .zero)
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var dotButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.ellipsis)
        button.configuration?.baseForegroundColor = separatorColor
        button.configuration?.buttonSize = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleThreeDots), for: .touchUpInside)
        return button
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.isUserInteractionEnabled = false
        button.isHidden = true
        button.configuration?.image = UIImage(named: AppStrings.Assets.pencil)?.withRenderingMode(.alwaysOriginal).withTintColor(.link).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        return button
    }()
    
    var userInfoCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let clockImage: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.clock, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label).scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        return button
    }()
    
    let privacyImage: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        return button
    }()
    
    let postTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
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
    
        addSubviews(profileImageView, nameLabel, timestampLabel, editButton, dotButton, userInfoCategoryLabel)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddingLeft),
            profileImageView.heightAnchor.constraint(equalToConstant: 53),
            profileImageView.widthAnchor.constraint(equalToConstant: 53),
 
            nameLabel.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: paddingLeft),
            nameLabel.trailingAnchor.constraint(equalTo: timestampLabel.leadingAnchor, constant: 2),
            
            timestampLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            trailingConstantConstraint,
            
            editButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 30),
            editButton.widthAnchor.constraint(equalToConstant: 30),
            editButton.leadingAnchor.constraint(equalTo: timestampLabel.trailingAnchor),
            
            dotButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            dotButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddingLeft),
            dotButton.heightAnchor.constraint(equalToConstant: 30),
            dotButton.widthAnchor.constraint(equalToConstant: 30),
            
            userInfoCategoryLabel.topAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            userInfoCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userInfoCategoryLabel.trailingAnchor.constraint(equalTo: dotButton.trailingAnchor),
        ])
        
        profileImageView.layer.cornerRadius = 53 / 2
    
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
        nameLabel.text = AppStrings.Content.Case.Privacy.anonymousTitle
    }
    
    func set(isEdited: Bool) {
        trailingConstantConstraint.constant = isEdited ? -35 : -5
        editButton.isHidden = !isEdited
        layoutIfNeeded()
    }
    
    
    @objc func didTapProfile() {
        delegate?.didTapProfile()
    }
    
    @objc func handleThreeDots() {
        delegate?.didTapThreeDots()
    }
}
