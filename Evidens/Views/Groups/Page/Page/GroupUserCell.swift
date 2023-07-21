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
        iv.image = UIImage(named: "user.profile")
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
        
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.systemBackground.cgColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                 profileImageView.layer.borderColor = UIColor.systemBackground.cgColor
             }
         }
    }
    
    func set(user: User) {
        if let imageUrl = user.profileUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
}
