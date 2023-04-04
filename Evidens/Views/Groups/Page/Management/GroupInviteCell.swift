//
//  GroupInviteCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/1/23.
//

import UIKit

class GroupInviteCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            selectionImageView.image = UIImage(systemName: isSelected ? "smallcircle.fill.circle.fill" : "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(primaryColor)
        }
    }
    
    //MARK: - Properties
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "user.profile")
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let userCategoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    private let selectionImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        selectionImageView.image = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(primaryColor)
        
        addSubviews(profileImageView, nameLabel, userCategoryLabel, selectionImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            
            selectionImageView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            selectionImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            selectionImageView.heightAnchor.constraint(equalToConstant: 20),
            selectionImageView.widthAnchor.constraint(equalToConstant: 20),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: selectionImageView.leadingAnchor, constant: -10),
            
            userCategoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            userCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userCategoryLabel.trailingAnchor.constraint(equalTo: selectionImageView.leadingAnchor, constant: -10),
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
    }
    
    
    //MARK: - Helpers
    
    func set(user: User) {
        nameLabel.text = user.firstName! + " " + user.lastName!
        if user.category == .student {
            userCategoryLabel.text = user.profession! + ", " + user.speciality! + " • Student"
        } else {
            userCategoryLabel.text = user.profession! + ", " + user.speciality!
        }
        
        if let imageUrl = user.profileImageUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
}


