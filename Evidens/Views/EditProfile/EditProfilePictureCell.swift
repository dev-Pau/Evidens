//
//  EditProfilePictureCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit

protocol EditProfilePictureCellDelegate: AnyObject {
    func didTapChangeProfilePicture()
    func didTapChangeBannerPicture()
}

class EditProfilePictureCell: UICollectionViewCell {
    
    weak var delegate: EditProfilePictureCellDelegate?
    
    lazy var bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = primaryColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEditBannerImage)))
        return iv
    }()
    
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 4
        iv.image = UIImage(named: AppStrings.Assets.profile)
        iv.layer.borderColor = UIColor.systemBackground.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEditProfileImage)))
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
        backgroundColor = .systemBackground
        
        addSubviews(bannerImageView, profileImageView)
        
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: frame.width / bannerAR),
            
            profileImageView.centerYAnchor.constraint(equalTo: bannerImageView.centerYAnchor, constant: 50),
            profileImageView.leadingAnchor.constraint(equalTo: bannerImageView.leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])

        profileImageView.layer.cornerRadius = 70/2
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 profileImageView.layer.borderColor = UIColor.systemBackground.cgColor
             }
         }
    }
    
    func set(user: User) {
        if let imageUrl = user.profileUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        if let bannerUrl = user.bannerUrl, bannerUrl != "" {
            bannerImageView.sd_setImage(with: URL(string: bannerUrl))
        }
    }
    
    @objc func handleEditProfileImage() {
        delegate?.didTapChangeProfilePicture()
    }
    
    @objc func handleEditBannerImage() {
        delegate?.didTapChangeBannerPicture()
    }
}
