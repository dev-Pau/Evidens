//
//  ApplicantHeaderCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/2/23.
//

import UIKit

class ApplicantHeaderCell: UICollectionViewCell {
    
    private lazy var profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "user.profile")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let userCategoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    private let emailImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "envelope.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        return iv
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let phoneImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "phone.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        return iv
    }()
    
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(profileImageView, nameLabel, userCategoryLabel, emailImageView, phoneImageView, emailLabel, phoneLabel, timestampLabel, separatorView)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
        
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            userCategoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            userCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userCategoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            emailImageView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 15),
            emailImageView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            emailImageView.heightAnchor.constraint(equalToConstant: 20),
            emailImageView.widthAnchor.constraint(equalToConstant: 20),
            
            emailLabel.centerYAnchor.constraint(equalTo: emailImageView.centerYAnchor),
            emailLabel.leadingAnchor.constraint(equalTo: emailImageView.trailingAnchor, constant: 10),
            emailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            phoneImageView.topAnchor.constraint(equalTo: emailImageView.bottomAnchor, constant: 10),
            phoneImageView.leadingAnchor.constraint(equalTo: emailImageView.leadingAnchor),
            phoneImageView.widthAnchor.constraint(equalToConstant: 20),
            phoneImageView.heightAnchor.constraint(equalToConstant: 20),
            
            phoneLabel.centerYAnchor.constraint(equalTo: phoneImageView.centerYAnchor),
            phoneLabel.leadingAnchor.constraint(equalTo: phoneImageView.trailingAnchor, constant: 10),
            phoneLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            timestampLabel.topAnchor.constraint(equalTo: phoneImageView.bottomAnchor, constant: 10),
            timestampLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            timestampLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
    }
    
    func configureWithUser(user: User, applicant: JobUserApplicant) {
        nameLabel.text = user.firstName! + " " + user.lastName!
        userCategoryLabel.text = user.profession! + " · " + user.speciality!
        emailLabel.text = user.email!
        phoneLabel.text = applicant.phoneNumber
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        timestampLabel.text = "Sent \(formatter.string(from: Date(milliseconds: Int(applicant.timestamp.milliseconds)), to: Date())!) ago"
        
        if let imageUrl = user.profileImageUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}
