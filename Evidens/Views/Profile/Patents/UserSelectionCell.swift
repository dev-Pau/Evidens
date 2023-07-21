//
//  UserSelectionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/2/23.
//

import Foundation

import UIKit
import SDWebImage


class UserSelectionCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    override var isSelected: Bool {
        didSet {
            selectionImageView.image = UIImage(systemName: isSelected ? "circle.inset.filled" : "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(primaryColor)
        }
    }
    
    private lazy var profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "user.profile")
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
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private let selectionImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(primaryColor)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(profileImageView, selectionImageView, nameLabel, userCategoryLabel, separatorView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .systemBackground
        
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
            userCategoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
    }
    
    //MARK: - Helpers

    func set(user: User) {
        nameLabel.text = user.firstName! + " " + user.lastName!
        if let imageUrl = user.profileUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }

        if user.kind == .student {
            userCategoryLabel.text = user.discipline!.name + ", " + user.speciality!.name + " • Student"
        } else {
            userCategoryLabel.text = user.discipline!.name + ", " + user.speciality!.name
        }
    }
}
