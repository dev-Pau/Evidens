//
//  GroupAdminCells.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/12/22.
//


import UIKit

class GroupAdminCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var user: User? {
        didSet {
            configure()
        }
    }

    private lazy var profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = lightColor
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
    
    private lazy var groupCategoryRoleButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()

        button.configuration?.baseBackgroundColor = primaryColor
        
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        
        return button
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubviews(groupCategoryRoleButton, profileImageView, nameLabel, userCategoryLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            
            groupCategoryRoleButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            groupCategoryRoleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            groupCategoryRoleButton.widthAnchor.constraint(equalToConstant: 100),
            groupCategoryRoleButton.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: groupCategoryRoleButton.leadingAnchor, constant: -10),
            
            userCategoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            userCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userCategoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configure() {
        guard let user = user else { return }
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        nameLabel.text = user.firstName! + " " + user.lastName!
        if user.category == .student {
            userCategoryLabel.text = user.profession! + ", " + user.speciality! + " · Student"
        } else {
            userCategoryLabel.text = user.profession! + ", " + user.speciality!
        }
    }
    
    func configureWithAdminRole(admin: UserGroup) {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        groupCategoryRoleButton.configuration?.attributedTitle = AttributedString(admin.memberType.memberTypeString, attributes: container)
        groupCategoryRoleButton.configuration?.baseBackgroundColor = primaryColor
    }
}


