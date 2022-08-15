//
//  SeeOthersCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

protocol UserProfileSeeOthersCellDelegate: AnyObject {
    func didTapProfile(forUser user: User)
}

class UserProfileSeeOthersCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    private var cellUser: User?
    
    weak var delegate: UserProfileSeeOthersCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.layer.contentsGravity = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let professionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = primaryColor
        label.numberOfLines = 2
        label.textAlignment = .center
        label.layer.contentsGravity = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfile)))
        backgroundColor = .white
        addSubviews(profileImageView, nameLabel, professionLabel)
        
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
        ])
        
        profileImageView.layer.cornerRadius = 60/2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(user: User) {
        nameLabel.text = user.firstName! + " " + user.lastName!
        professionLabel.text = user.profession
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        cellUser = user
    }
    
    @objc func didTapProfile() {
        guard let cellUser = cellUser else { return }

        delegate?.didTapProfile(forUser: cellUser)
    }
     
}
