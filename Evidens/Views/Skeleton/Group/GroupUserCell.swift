//
//  GroupUserCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/12/22.
//

import UIKit

class GroupUserCell: UICollectionViewCell {
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "profile.user")
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(profileImageView)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            profileImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        profileImageView.layer.cornerRadius = 27 / 2
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    func set(user: User) {
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
    }
}
