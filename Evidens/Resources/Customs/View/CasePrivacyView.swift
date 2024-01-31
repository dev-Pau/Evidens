//
//  CasePrivacyView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/12/23.
//

import UIKit

protocol CasePrivacyViewDelegate: AnyObject {
    func didTapPrivacy(_ view: CasePrivacyView)
}

class CasePrivacyView: UIView {
    
    weak var delegate: CasePrivacyViewDelegate?
    
    private let casePrivacy: CasePrivacy
    private let user: User?
    
    private let profileImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 22, scaleStyle: .title1, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
  
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Content.Case.Share.phaseContent
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.circle)?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(separatorColor)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let recommendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        var configuration = UIButton.Configuration.filled()
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = primaryColor
        configuration.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 12, scaleStyle: .title2, weight: .medium)
        configuration.attributedTitle = AttributedString(AppStrings.Global.recommended, attributes: container)
        
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        button.configuration = configuration

        return button
    }()
    
    init(casePrivacy: CasePrivacy, user: User? = nil) {
        self.casePrivacy = casePrivacy
        self.user = user
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        layer.cornerRadius = 10
        layer.borderColor = separatorColor.cgColor
        layer.borderWidth = 1

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privacyTap)))
                
        addSubviews(profileImage, titleLabel, contentLabel, checkmarkButton, recommendButton)
        
        let imageSize: CGFloat = UIDevice.isPad ? 50 : 40
        
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImage.widthAnchor.constraint(equalToConstant: imageSize),
            profileImage.heightAnchor.constraint(equalToConstant: imageSize),
            
            recommendButton.centerYAnchor.constraint(equalTo: checkmarkButton.centerYAnchor),
            recommendButton.trailingAnchor.constraint(equalTo: checkmarkButton.leadingAnchor, constant: -10),
            
            checkmarkButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            checkmarkButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 24),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
        recommendButton.isHidden = casePrivacy == .anonymous
        profileImage.layer.cornerRadius = imageSize / 2
        titleLabel.text = casePrivacy.title
        contentLabel.text = casePrivacy.content
        
        switch casePrivacy {
        case .regular:
            if let user = user, let image = user.profileUrl, !image.isEmpty {
                profileImage.sd_setImage(with: URL(string: image))
            } else {
                profileImage.image = UIImage(named: AppStrings.Assets.profile)
            }
        case .anonymous:
            profileImage.image = UIImage(named: AppStrings.Assets.privacyProfile)
        }
    }
    
    func reset() {
        checkmarkButton.configuration?.image = UIImage(systemName: AppStrings.Icons.circle)?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(separatorColor)
        layer.borderColor = separatorColor.cgColor
        layer.borderWidth = 1
        recommendButton.isHidden = true
    }
    
    @objc func privacyTap() {
        delegate?.didTapPrivacy(self)
        checkmarkButton.configuration?.image = UIImage(systemName: AppStrings.Icons.checkmarkCircleFill)?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor)
        recommendButton.isHidden = casePrivacy == .anonymous
        layer.borderColor = primaryColor.cgColor
        layer.borderWidth = 2
    }
}
