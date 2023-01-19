//
//  AdminUserManagementCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/1/23.
//

import UIKit

class AdminUserManagementCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            configureWithUser()
        }
    }
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        label.sizeToFit()
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let userCategoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var threeDotsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        
        button.configuration?.buttonSize = .mini
        button.configuration?.baseForegroundColor = .label
        
        button.configuration?.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        
        button.addTarget(self, action: #selector(didTapThreeDots), for: .touchUpInside)
        
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    private let userGroupRoleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .medium
        button.configuration?.baseBackgroundColor = .secondarySystemGroupedBackground
        button.configuration?.baseForegroundColor = .label
        button.configuration?.background.strokeColor = .quaternarySystemFill
        button.configuration?.background.strokeWidth = 1
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                 userGroupRoleButton.configuration?.background.strokeColor = .quaternarySystemFill
             }
         }
    }
    
    private func configure() {
        addSubviews(profileImageView, threeDotsButton, userGroupRoleButton, nameLabel, userCategoryLabel)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            
            threeDotsButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            threeDotsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            threeDotsButton.widthAnchor.constraint(equalToConstant: 30),
            threeDotsButton.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: threeDotsButton.leadingAnchor, constant: -5),

            userGroupRoleButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            userGroupRoleButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userGroupRoleButton.heightAnchor.constraint(equalToConstant: 25),
            
            userCategoryLabel.centerYAnchor.constraint(equalTo: userGroupRoleButton.centerYAnchor),
            userCategoryLabel.leadingAnchor.constraint(equalTo: userGroupRoleButton.trailingAnchor, constant: 5),
            userCategoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
    }
    
    private func configureWithUser() {
        guard let user = user else { return }
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        nameLabel.text = user.firstName! + " " + user.lastName!
        if user.category == .student {
            userCategoryLabel.text = user.profession! + ", " + user.speciality! + " · Student"
        } else {
            userCategoryLabel.text = user.profession! + ", " + user.speciality!
        }
    }
    
    func configureMemberType(type: Group.MemberType) {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .medium)
        userGroupRoleButton.configuration?.attributedTitle = AttributedString(type.memberTypeString, attributes: container)
    }
    
    @objc func didTapThreeDots() {
        #warning("show uimenu options")
    }
}
