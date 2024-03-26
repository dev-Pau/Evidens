//
//  ProfileNameView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/1/24.
//

import UIKit

protocol ProfileNameViewDelegate: AnyObject {
    func didTapNetwork()
    func didTapImage(kind: ImageKind)
    func didTapActionButton()
    func didTapWebsite()
    func didTapAbout()
}

class ProfileNameView: UIView {
    
    weak var delegate: ProfileNameViewDelegate?
    
    private var topAnchorAboutConstraint: NSLayoutConstraint!
    
    private let padding: CGFloat = 10
    
    private lazy var bannerImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = K.Colors.primaryColor
        iv.layer.borderColor = K.Colors.separatorColor.cgColor
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBannerTap)))
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var profileImage: ProfileImageView = {
        let iv = ProfileImageView(frame: .zero)
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .quaternarySystemFill
        iv.layer.borderWidth = 1
        iv.layer.borderColor = K.Colors.separatorColor.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileTap)))
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
    
    private let username: UILabel = {
        let label = UILabel()
        let smallFont: CGFloat = UIDevice.isPad ? 16 : 13
        label.font = UIFont.addFont(size: smallFont, scaleStyle: .largeTitle, weight: .regular, scales: false)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.isUserInteractionEnabled = false
        label.textColor = K.Colors.primaryGray
        return label
    }()
    
    private let discipline: UILabel = {
        let label = UILabel()
        let smallFont: CGFloat = UIDevice.isPad ? 16 : 13
        label.font = UIFont.addFont(size: smallFont, scaleStyle: .largeTitle, weight: .regular, scales: false)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.isUserInteractionEnabled = false
        label.textColor = K.Colors.primaryGray
        return label
    }()
    
    private lazy var connections: UILabel = {
        let label = UILabel()
        label.textColor = K.Colors.primaryGray
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
        configuration.image = UIImage(named: AppStrings.Assets.link)?.withRenderingMode(.alwaysOriginal).withTintColor(.label).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 25))
        configuration.imagePlacement = .leading
        configuration.imagePadding = 5
        
        button.configuration = configuration
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleWebsiteTap), for: .touchUpInside)
        return button
    }()
    
    private let aboutLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = K.Colors.primaryGray
            label.numberOfLines = 2
            label.isUserInteractionEnabled = true
            let smallFont: CGFloat = UIDevice.isPad ? 16 : 13
            label.font = UIFont.addFont(size: smallFont, scaleStyle: .largeTitle, weight: .regular)
            return label
        }()
    
    private let chevronImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.separatorColor)
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        
        let bannerHeight = (UIWindow.visibleScreenWidth - 20.0) / K.Ratio.bannerAR
        let imageHeight = UIDevice.isPad ? 110.0 : 75.0
       
        let disciplineStackView = UIStackView(arrangedSubviews: [discipline, connections])
        disciplineStackView.translatesAutoresizingMaskIntoConstraints = false
        disciplineStackView.axis = .vertical
        disciplineStackView.spacing = 0
        
        let usernameStackView = UIStackView(arrangedSubviews: [name, username])
        usernameStackView.translatesAutoresizingMaskIntoConstraints = false
        usernameStackView.axis = .vertical
        usernameStackView.spacing = 0
        
        let nameStackView = UIStackView(arrangedSubviews: [usernameStackView, disciplineStackView])
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        nameStackView.axis = .vertical
        nameStackView.spacing = 5

        topAnchorAboutConstraint = aboutLabel.topAnchor.constraint(equalTo: nameStackView.bottomAnchor)
        
        addSubviews(bannerImage, profileImage, nameStackView, websiteButton, actionButton, aboutLabel, chevronImage)
        
        NSLayoutConstraint.activate([
            bannerImage.topAnchor.constraint(equalTo: topAnchor),
            bannerImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: K.Paddings.Profile.horizontalPadding),
            bannerImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Profile.horizontalPadding),
            bannerImage.heightAnchor.constraint(equalToConstant: bannerHeight),

            profileImage.centerYAnchor.constraint(equalTo: nameStackView.centerYAnchor),
            profileImage.leadingAnchor.constraint(equalTo: bannerImage.leadingAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: imageHeight),
            profileImage.heightAnchor.constraint(equalToConstant: imageHeight),
            
            nameStackView.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: UIDevice.isPad ? 3 * padding : 2 * padding),
            nameStackView.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: K.Paddings.Profile.horizontalPadding),
            nameStackView.trailingAnchor.constraint(lessThanOrEqualTo: bannerImage.trailingAnchor),
            
            topAnchorAboutConstraint,
            aboutLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            aboutLabel.trailingAnchor.constraint(equalTo: chevronImage.leadingAnchor, constant: -10),
            
            chevronImage.trailingAnchor.constraint(lessThanOrEqualTo: bannerImage.trailingAnchor),
            chevronImage.centerYAnchor.constraint(equalTo: aboutLabel.centerYAnchor),
            chevronImage.widthAnchor.constraint(equalToConstant: 20),
            chevronImage.heightAnchor.constraint(equalToConstant: 20),
            
            websiteButton.topAnchor.constraint(greaterThanOrEqualTo: aboutLabel.bottomAnchor),
            websiteButton.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            websiteButton.trailingAnchor.constraint(lessThanOrEqualTo: bannerImage.trailingAnchor),

            actionButton.topAnchor.constraint(greaterThanOrEqualTo: nameStackView.bottomAnchor, constant: K.Paddings.Profile.horizontalPadding),
            actionButton.topAnchor.constraint(equalTo: websiteButton.bottomAnchor),
            actionButton.leadingAnchor.constraint(equalTo: bannerImage.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: bannerImage.trailingAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
        
        bannerImage.layer.cornerRadius = 12
        profileImage.layer.cornerRadius = imageHeight / 2

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleAboutTap(_:)))
        aboutLabel.addGestureRecognizer(gestureRecognizer)
        
        chevronImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAboutTap)))
    }
    
    func set(viewModel: UserProfileViewModel) {
        name.text = viewModel.user.name()
        discipline.text = viewModel.user.details()
        username.text = viewModel.user.getUsername()
        
        let imageHeight = UIDevice.isPad ? 110.0 : 75.0
        
        if viewModel.user.isCurrentUser {
            profileImage.addImage(forUrl: viewModel.user.profileUrl, size: imageHeight)
        } else {
            profileImage.addImage(forUser: viewModel.user, size: imageHeight)
        }
        
        if let banner = viewModel.user.bannerUrl, banner != "" {
            bannerImage.layer.borderWidth = 1
            bannerImage.sd_setImage(with: URL(string: banner))
        } else {
            bannerImage.layer.borderWidth = 1
            bannerImage.image = nil
        }
        
        websiteButton.isHidden = viewModel.website.isEmpty
        
        let buttonPadding: CGFloat = 2 * padding
        
        aboutLabel.text = viewModel.about
      
        websiteButton.configuration?.attributedTitle = viewModel.website(viewModel.website)
        
        let hasWebsite = !viewModel.website.isEmpty
        let hasAbout = !viewModel.about.isEmpty

        let topWebsitePadding = hasWebsite ? buttonPadding : 0
        let bottomWebsitePadding = hasWebsite ? buttonPadding : 0
        
        topAnchorAboutConstraint.constant = hasAbout ? buttonPadding : 0
        
        websiteButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: topWebsitePadding, leading: 0, bottom: bottomWebsitePadding, trailing: 0)

        aboutLabel.isHidden = !hasAbout
        chevronImage.isHidden = !hasAbout
        
        connections.isUserInteractionEnabled = viewModel.user.blockPhase != nil ? false : true
    }
    
    func configure(viewModel: ProfileHeaderViewModel) {
        connections.attributedText = viewModel.connectionsText
    }
    
    func configureActionButton(viewModel: ProfileHeaderViewModel) {
        let viewModel = ProfileHeaderViewModel(user: viewModel.user)
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .semibold, scales: false)
        
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = viewModel.connectBackgroundColor
        configuration.baseForegroundColor = viewModel.connectTextColor
        configuration.attributedTitle = AttributedString(viewModel.connectionText, attributes: container)
        configuration.background.strokeColor = viewModel.connectButtonBorderColor
        
        configuration.image = viewModel.connectImage
        configuration.imagePlacement = viewModel.connectImagePlacement
        configuration.imagePadding = 10

        if let phase = viewModel.user.blockPhase, phase == .blocked {
            actionButton.isHidden = true
        } else {
            actionButton.isHidden = false
        }

        actionButton.configuration = configuration
        actionButton.isUserInteractionEnabled = true
    }
    
    func actionEnabled(_ enabled: Bool) {
        actionButton.isUserInteractionEnabled = enabled
    }
    
    @objc func handleShowNetwork() {
        delegate?.didTapNetwork()
    }
    
    @objc func handleProfileTap() {
        delegate?.didTapImage(kind: .profile)
    }
    
    @objc func handleBannerTap() {
        guard let _ = bannerImage.image else { return }
        delegate?.didTapImage(kind: .banner)
    }
    
    @objc func handleActionButtonTap() {
        delegate?.didTapActionButton()
    }
    
    @objc func handleWebsiteTap() {
        delegate?.didTapWebsite()
    }
    
    @objc func handleAboutTap(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.didTapAbout()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let subview = super.hitTest(point, with: event)
        return subview != self ? subview : nil
    }
}
