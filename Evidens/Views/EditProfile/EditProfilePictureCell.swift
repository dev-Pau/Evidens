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
    
    lazy var profileImageView: ProfileImageView = {
        let iv = ProfileImageView(frame: .zero)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 4
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
        
        let size: CGFloat = UIDevice.isPad ? 120 : 70
        
        addSubviews(bannerImageView, profileImageView)
        
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: frame.width / bannerAR),

            profileImageView.centerYAnchor.constraint(equalTo: bannerImageView.bottomAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: bannerImageView.leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: size),
            profileImageView.widthAnchor.constraint(equalToConstant: size),
        ])
        
        let heightConstraint = heightAnchor.constraint(equalToConstant: frame.width / bannerAR + size / 2 + 20)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true

        profileImageView.layer.cornerRadius = size/2
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 profileImageView.layer.borderColor = UIColor.systemBackground.cgColor
             }
         }
    }
    
    func set(user: User) {
        let size: CGFloat = UIDevice.isPad ? 120 : 70
        
        profileImageView.addImage(forUser: user, size: size)
        
        if let bannerUrl = user.bannerUrl, bannerUrl != "" {
            bannerImageView.sd_setImage(with: URL(string: bannerUrl))
        } else {
            bannerImageView.image = nil
        }
    }
    
    func setImage(image: UIImage?) {
        profileImageView.hide()
        profileImageView.image = image
    }
    
    @objc func handleEditProfileImage() {
        delegate?.didTapChangeProfilePicture()
    }
    
    @objc func handleEditBannerImage() {
        delegate?.didTapChangeBannerPicture()
    }
}
