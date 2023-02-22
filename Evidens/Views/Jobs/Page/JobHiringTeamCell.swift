//
//  JobHiringTeamCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/2/23.
//

import UIKit

class JobHiringTeamCell: UICollectionViewCell {
    
    var memberUid: String? {
        didSet {
            fetchUser()
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.text = "Hiring team"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var userInfoCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(titleLabel, profileImageView, nameLabel, userInfoCategoryLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            userInfoCategoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            userInfoCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userInfoCategoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            //userInfoCategoryLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
        
        profileImageView.layer.cornerRadius = 50 / 2
    }
    
    private func fetchUser() {
        guard let memberUid = memberUid else { return }
        UserService.fetchUser(withUid: memberUid) { user in
            self.profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
            self.nameLabel.text = user.firstName! + " " + user.lastName!
            self.userInfoCategoryLabel.text = user.profession! + " · " + user.speciality!
        }
    }
}
