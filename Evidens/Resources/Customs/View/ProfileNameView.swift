//
//  ProfileNameView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/1/24.
//

import UIKit

protocol ProfileNameViewDelegate: AnyObject {
    func didTapNetwork()
    func didTapProfileImage()
    func didTapActionButton()
    func didTapWebsite()
}

class ProfileNameView: UIView {
    
    weak var delegate: ProfileNameViewDelegate?
    
    private let padding: CGFloat = 10
    
    private let bannerImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = primaryColor
        iv.layer.borderColor = separatorColor.cgColor
        iv.isUserInteractionEnabled = false
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let name: UILabel = {
        let label = UILabel()
        let bigFont: CGFloat = UIDevice.isPad ? 25 : 23
        label.font = UIFont.addFont(size: bigFont, scaleStyle: .largeTitle, weight: .bold, scales: false)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()
    
    private lazy var profileImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .quaternarySystemFill
        iv.layer.borderWidth = 1
        iv.layer.borderColor = separatorColor.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
        iv.image = UIImage(named: AppStrings.Assets.profile)
        return iv
    }()
    
    private let discipline: UILabel = {
        let label = UILabel()
        let smallFont: CGFloat = UIDevice.isPad ? 16 : 13
        label.font = UIFont.addFont(size: smallFont, scaleStyle: .largeTitle, weight: .regular, scales: false)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.isUserInteractionEnabled = false
        label.textColor = primaryGray
        return label
    }()
    
    private lazy var connections: UILabel = {
        let label = UILabel()
        label.textColor = primaryGray
        let smallFont: CGFloat = UIDevice.isPad ? 16 : 13
        label.font = UIFont.addFont(size: smallFont, scaleStyle: .largeTitle, weight: .regular, scales: false)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowNetwork)))
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintAdjustmentMode = .normal
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
        configuration.cornerStyle = .capsule
        button.configuration = configuration
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleActionButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var websiteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintAdjustmentMode = .normal
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .label
        configuration.buttonSize = .mini
        configuration.image = UIImage(named: AppStrings.Assets.link)?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 25))
        configuration.imagePlacement = .leading
        configuration.imagePadding = 5
        button.configuration = configuration
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleWebsiteTap), for: .touchUpInside)
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
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        
        let bannerHeight = (UIScreen.main.bounds.width - 20.0) / bannerAR
        let imageHeight = UIDevice.isPad ? 120.0 : 75.0
        let buttonHeight = UIDevice.isPad ? 50.0 : 40.0
        
        let disciplineStackView = UIStackView(arrangedSubviews: [discipline, connections])
        disciplineStackView.translatesAutoresizingMaskIntoConstraints = false
        disciplineStackView.axis = .vertical
        disciplineStackView.spacing = 0
        
        let nameStackView = UIStackView(arrangedSubviews: [name, disciplineStackView])
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        nameStackView.axis = .vertical
        nameStackView.spacing = 5
        
        addSubviews(bannerImage, profileImage, nameStackView, websiteButton, actionButton)
        
        NSLayoutConstraint.activate([
            bannerImage.topAnchor.constraint(equalTo: topAnchor),
            bannerImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            bannerImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            bannerImage.heightAnchor.constraint(equalToConstant: bannerHeight),

            profileImage.centerYAnchor.constraint(equalTo: nameStackView.centerYAnchor),
            profileImage.leadingAnchor.constraint(equalTo: bannerImage.leadingAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: imageHeight),
            profileImage.heightAnchor.constraint(equalToConstant: imageHeight),
            
            nameStackView.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: 2 * padding),
            nameStackView.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: UIDevice.isPad ? 20 : 10),
            nameStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),

            websiteButton.topAnchor.constraint(greaterThanOrEqualTo: nameStackView.bottomAnchor),
            websiteButton.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            websiteButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),

            actionButton.topAnchor.constraint(equalTo: websiteButton.bottomAnchor),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            actionButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
        
        bannerImage.layer.cornerRadius = 12
        profileImage.layer.cornerRadius = imageHeight / 2
    }
    
    func set(viewModel: UserProfileViewModel) {
        name.text = viewModel.user.name()
        discipline.text = viewModel.user.details()
        
        if let url = viewModel.user.profileUrl, url != "" {
            profileImage.sd_setImage(with: URL(string: url))
            profileImage.layer.borderWidth = 1
        } else {
            profileImage.layer.borderWidth = 0.4
            profileImage.image = UIImage(named: AppStrings.Assets.profile)
        }
        
        if let banner = viewModel.user.bannerUrl, banner != "" {
            bannerImage.sd_setImage(with: URL(string: banner))
            bannerImage.layer.borderWidth = 1
        } else {
            bannerImage.layer.borderWidth = 0.4
            bannerImage.image = nil
        }
        
        websiteButton.isHidden = viewModel.website.isEmpty
        
        let buttonPadding: CGFloat = 2 * padding
        
        websiteButton.configuration?.attributedTitle = viewModel.website(viewModel.website)
        websiteButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: viewModel.website.isEmpty ? 0 : buttonPadding, leading: 0, bottom: viewModel.website.isEmpty ? buttonPadding / 2 : buttonPadding, trailing: 0)
    }
    
    func configure(viewModel: ProfileHeaderViewModel) {
        connections.attributedText = viewModel.connectionsText
    }
    
    func configureActionButton(viewModel: ProfileHeaderViewModel) {
        let viewModel = ProfileHeaderViewModel(user: viewModel.user)
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 16, scaleStyle: .largeTitle, weight: .bold, scales: false)
        
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = viewModel.connectBackgroundColor
        configuration.baseForegroundColor = viewModel.connectTextColor
        configuration.attributedTitle = AttributedString(viewModel.connectionText, attributes: container)
        configuration.background.strokeColor = viewModel.connectButtonBorderColor
        
        configuration.image = viewModel.connectImage
        configuration.imagePlacement = viewModel.connectImagePlacement
        configuration.imagePadding = 10
        
        actionButton.configuration = configuration
        actionButton.isUserInteractionEnabled = true
    }
    
    func actionEnabled(_ enabled: Bool) {
        actionButton.isUserInteractionEnabled = enabled
    }
    
    @objc func handleShowNetwork() {
        delegate?.didTapNetwork()
    }
    
    @objc func handleImageTap() {
        delegate?.didTapProfileImage()
    }
    
    @objc func handleActionButtonTap() {
        delegate?.didTapActionButton()
    }
    
    @objc func handleWebsiteTap() {
        delegate?.didTapWebsite()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let subview = super.hitTest(point, with: event)
        return subview != self ? subview : nil
    }
}
