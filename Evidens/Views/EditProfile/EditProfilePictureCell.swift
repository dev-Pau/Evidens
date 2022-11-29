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
    
    private let cellContentView = UIView()
    
    weak var delegate: EditProfilePictureCellDelegate?
    
    lazy var bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = primaryColor.withAlphaComponent(0.5)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEditBannerImage)))
        return iv
    }()
    
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = primaryColor
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEditProfileImage)))
        return iv
    }()
    
    private var editImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        button.configuration?.baseForegroundColor = primaryColor
        button.configuration?.baseBackgroundColor = .white.withAlphaComponent(0.8)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        button.configuration?.baseForegroundColor = primaryColor
        button.configuration?.baseBackgroundColor = .white.withAlphaComponent(0.8)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .white
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        cellContentView.addSubviews(bannerImageView, editImageButton, profileImageView, editProfileButton)
        
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: 100),
            
            editImageButton.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            editImageButton.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            editImageButton.heightAnchor.constraint(equalToConstant: 30),
            editImageButton.widthAnchor.constraint(equalToConstant: 30),
            
            profileImageView.centerYAnchor.constraint(equalTo: bannerImageView.centerYAnchor, constant: 50),
            profileImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10),
            
            editProfileButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            editProfileButton.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            editProfileButton.heightAnchor.constraint(equalToConstant: 30),
            editProfileButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        profileImageView.layer.cornerRadius = 70/2
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func set(profileImageUrl: String) {
        profileImageView.sd_setImage(with: URL(string: profileImageUrl))
    }
    
    func set(bannerImageUrl: String) {
        bannerImageView.sd_setImage(with: URL(string: bannerImageUrl))
    }
    
    func hideBannerHint() {
        editImageButton.isHidden = true
    }
    
    func hideProfileHint() {
        editProfileButton.isHidden = true
    }
    
    @objc func handleEditProfileImage() {
        delegate?.didTapChangeProfilePicture()
    }
    
    @objc func handleEditBannerImage() {
        delegate?.didTapChangeBannerPicture()
    }
}
