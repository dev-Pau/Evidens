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
        //iv.backgroundColor = primaryColor.withAlphaComponent(0.5)
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
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 4
        iv.image = UIImage(named: "user.profile")
        iv.layer.borderColor = UIColor.systemBackground.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .systemGray4
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEditProfileImage)))
        return iv
    }()
    
    var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .large
        button.configuration?.baseBackgroundColor = .clear
        //button.configuration?.image = UIImage(systemName: "puzzlepiece.extension.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysOriginal).withTintColor(.systemGray)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let coverLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        cellContentView.addSubviews(bannerImageView, profileImageView, editProfileButton)
        
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: 100),
            
            profileImageView.centerYAnchor.constraint(equalTo: bannerImageView.centerYAnchor, constant: 50),
            profileImageView.leadingAnchor.constraint(equalTo: bannerImageView.leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10),

            editProfileButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            editProfileButton.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            editProfileButton.heightAnchor.constraint(equalToConstant: 70),
            editProfileButton.widthAnchor.constraint(equalToConstant: 70)
        ])

        profileImageView.layer.cornerRadius = 70/2

        /*
        DispatchQueue.main.async {
            self.coverLayer.frame = self.profileImageView.bounds;
            self.coverLayer.backgroundColor = UIColor.black.cgColor
            self.coverLayer.opacity = 0.5
            self.profileImageView.layer.addSublayer(self.coverLayer)
        }
         */

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                 profileImageView.layer.borderColor = UIColor.systemBackground.cgColor
             }
         }
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
        if profileImageUrl != "" {
           profileImageView.sd_setImage(with: URL(string: profileImageUrl))
        }
        //profileImageView.sd_setImage(with: URL(string: profileImageUrl))
    }
    
    func set(bannerImageUrl: String) {
        if bannerImageUrl != "" {
            bannerImageView.sd_setImage(with: URL(string: bannerImageUrl))
        }  
    }
    
    func hideProfileHint() {
        coverLayer.opacity = 0
        editProfileButton.isHidden = true
    }
    
    @objc func handleEditProfileImage() {
        delegate?.didTapChangeProfilePicture()
    }
    
    @objc func handleEditBannerImage() {
        delegate?.didTapChangeBannerPicture()
    }
}
