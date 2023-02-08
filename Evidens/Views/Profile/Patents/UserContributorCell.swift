//
//  UserContributorCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/2/23.
//

import UIKit


class UserContributorCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    private var cellUser: User?
    
    //weak var delegate: UserContributorCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .quaternarySystemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .label
        label.textAlignment = .center
        label.layer.contentsGravity = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let professionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.textAlignment = .center
        label.layer.contentsGravity = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var xmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .gray
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white).scalePreservingAspectRatio(targetSize: CGSize(width: 12, height: 12))
        button.isUserInteractionEnabled = false
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubviews(profileImageView, nameLabel, professionLabel, xmarkButton)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 3),
            
            professionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            professionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            professionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            
            xmarkButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 2),
            xmarkButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -2),
            xmarkButton.heightAnchor.constraint(equalToConstant: 24),
            xmarkButton.widthAnchor.constraint(equalToConstant: 24)
        ])
        
        profileImageView.layer.cornerRadius = 60/2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(user: User) {
        nameLabel.text = user.firstName!
        professionLabel.text = user.profession
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        cellUser = user
    }
}


