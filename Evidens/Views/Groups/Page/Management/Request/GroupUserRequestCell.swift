//
//  GroupUserRequestCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/1/23.
//

import UIKit

protocol GroupUserRequestCellDelegate: AnyObject {
    func didTapIgnore(_ cell: UICollectionViewCell, user: User)
    func didTapAccept(_ cell: UICollectionViewCell, user: User)
}

class GroupUserRequestCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            configureWithUser()
        }
    }
    
    weak var delegate: GroupUserRequestCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "user.profile")
        iv.clipsToBounds = true
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
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var acceptButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.buttonSize = .mini
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 1
        
        button.configuration?.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        
        button.addTarget(self, action: #selector(handleAcceptRequest), for: .touchUpInside)
        
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    private lazy var ignoreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()

        button.configuration?.baseForegroundColor = .secondaryLabel
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 1
        button.configuration?.buttonSize = .mini
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Ignore", attributes: container)
        
        button.addTarget(self, action: #selector(handleIgnoreRequest), for: .touchUpInside)
        
        button.isUserInteractionEnabled = true
        
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
        addSubviews(profileImageView, acceptButton, ignoreButton, nameLabel, userCategoryLabel)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            
            acceptButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            acceptButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            acceptButton.widthAnchor.constraint(equalToConstant: 30),
            acceptButton.heightAnchor.constraint(equalToConstant: 30),
            
            ignoreButton.centerYAnchor.constraint(equalTo: acceptButton.centerYAnchor),
            ignoreButton.trailingAnchor.constraint(equalTo: acceptButton.leadingAnchor, constant: -5),
            ignoreButton.widthAnchor.constraint(equalToConstant: 80),
            ignoreButton.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: ignoreButton.leadingAnchor, constant: -10),
            
            userCategoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            userCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userCategoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
    }
    
    private func configureWithUser() {
        guard let user = user else { return }
        nameLabel.text = user.firstName! + " " + user.lastName!
        if user.category == .student {
            userCategoryLabel.text = user.profession! + ", " + user.speciality! + " · Student"
        } else {
            userCategoryLabel.text = user.profession! + ", " + user.speciality!
        }
        
        if let imageUrl = user.profileImageUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
    
    @objc func handleIgnoreRequest() {
        guard let user = user else { return }
        delegate?.didTapIgnore(self, user: user)
    }
    
    @objc func handleAcceptRequest() {
        guard let user = user else { return }
        delegate?.didTapAccept(self, user: user)
    }
}
