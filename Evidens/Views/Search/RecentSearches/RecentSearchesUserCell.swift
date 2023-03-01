//
//  RecentSearchesUserCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/2/23.
//

import UIKit


class RecentSearchesUserCell: UICollectionViewCell {

    //MARK: - Properties
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    private let specialityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubviews(profileImageView, nameLabel, specialityLabel)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            
            specialityLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            specialityLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            specialityLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])

        profileImageView.layer.cornerRadius = 40 / 2
            
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithUser(user: User) {
        nameLabel.text = user.firstName! + " " + user.lastName!
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        specialityLabel.text = user.profession!
    }
}

