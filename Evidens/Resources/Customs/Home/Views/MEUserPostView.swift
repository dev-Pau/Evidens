//
//  MEUserPostView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/6/22.
//

import UIKit

protocol MEUserPostViewDelegate: AnyObject {
    func didTapProfile()
    func didTapThreeDots()
}

class MEUserPostView: UIView {
    
    weak var delegate: MEUserPostViewDelegate?
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    private var symbolAttachment: NSTextAttachment?
    
    lazy var profileImageView = MEProfileImageView(frame: .zero)
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis")
        button.configuration?.baseForegroundColor = separatorColor
        button.configuration?.buttonSize = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleThreeDots), for: .touchUpInside)
        return button
    }()
    
    var userInfoCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private let clockImage: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.clock, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label).scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        return button
    }()
    
    let privacyImage: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        return button
    }()
    
    let postTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .label
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfile)))
        backgroundColor = .systemBackground
        addSubviews(profileImageView, nameLabel, dotsImageButton, userInfoCategoryLabel, clockImage, postTimeLabel, privacyImage)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddingLeft),
            profileImageView.heightAnchor.constraint(equalToConstant: 53),
            profileImageView.widthAnchor.constraint(equalToConstant: 53),
 
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: paddingLeft),
            nameLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -paddingLeft),
            
            dotsImageButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddingLeft),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 20),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 20),
            
            userInfoCategoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            userInfoCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userInfoCategoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
           
            clockImage.centerYAnchor.constraint(equalTo: postTimeLabel.centerYAnchor),
            clockImage.leadingAnchor.constraint(equalTo: userInfoCategoryLabel.leadingAnchor),
            clockImage.heightAnchor.constraint(equalToConstant: 11.6),
            clockImage.widthAnchor.constraint(equalToConstant: 11.6),
            
            postTimeLabel.topAnchor.constraint(equalTo: userInfoCategoryLabel.bottomAnchor),
            postTimeLabel.leadingAnchor.constraint(equalTo: clockImage.trailingAnchor, constant: 5),
            postTimeLabel.heightAnchor.constraint(equalToConstant: 20),
            
            privacyImage.centerYAnchor.constraint(equalTo: postTimeLabel.centerYAnchor),
            privacyImage.leadingAnchor.constraint(equalTo: postTimeLabel.trailingAnchor),
            privacyImage.heightAnchor.constraint(equalToConstant: 11.6),
            privacyImage.widthAnchor.constraint(equalToConstant: 11.6),  
        ])
        
        profileImageView.layer.cornerRadius = 53 / 2
    
    }
    
    func set(user: User, anonymous: Bool = false) {
        if anonymous {
            profileImageView.image = UIImage(named: "user.profile.privacy")
            nameLabel.text = "Shared Anonymously"
        } else {
            if let imageUrl = user.profileUrl, imageUrl != "" {
                profileImageView.sd_setImage(with: URL(string: imageUrl))
            }
            
            nameLabel.text = user.name()
        }
        
        userInfoCategoryLabel.text = user.details()
    }
    
    @objc func didTapProfile() {
        delegate?.didTapProfile()
    }
    
    @objc func handleThreeDots() {
        delegate?.didTapThreeDots()
    }
}
