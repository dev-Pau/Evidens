//
//  UserProfileHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/5/22.
//

import UIKit

protocol UserProfileHeaderCellDelegate: AnyObject {
    func headerCell(_ cell: UICollectionViewCell, didTapEditProfileFor user: User)
    func headerCell(didTapFollowingFollowersFor user: User)
}

class UserProfileHeaderCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    let screenSize = UIScreen.main.bounds.size.width
    private var profileIsConfigured: Bool = false
    
    weak var delegate: UserProfileHeaderCellDelegate?
    
    var viewModel: ProfileHeaderViewModel? {
        didSet {
            configure()
        }
    }
    
    var isUpdatingFollowState: Bool? {
        didSet {
            followButton.setNeedsUpdateConfiguration()
        }
    }
    
    var updateButtonAfterAction: Bool? {
        didSet {
            updateButton()
        }
    }

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 27, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        return label
    }()
    
    private let professionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .label
        return label
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.background.strokeWidth = 1
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleFollowEditProfile), for: .touchUpInside)
        return button
    }()
    
    lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowFollowingFollowers)))
        label.isUserInteractionEnabled = true
        return label
    }()

    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUpdatingFollowState = false
        
        backgroundColor = .systemBackground
        
        addSubviews(nameLabel, professionLabel, followButton, followersLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 75),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            professionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            professionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            professionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            followersLabel.topAnchor.constraint(equalTo: professionLabel.bottomAnchor, constant: 5),
            followersLabel.leadingAnchor.constraint(equalTo: professionLabel.leadingAnchor),
            followersLabel.trailingAnchor.constraint(equalTo: professionLabel.trailingAnchor),
            followersLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            followButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            followButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            followButton.heightAnchor.constraint(equalToConstant: 30),
            followButton.widthAnchor.constraint(equalToConstant: 100),
        ])

        followButton.configurationUpdateHandler = { [unowned self] button in
            button.isUserInteractionEnabled = self.isUpdatingFollowState! ? false : true
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
      
        nameLabel.text = viewModel.fullName
        professionLabel.text = viewModel.details

        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        followButton.configuration?.attributedTitle = AttributedString(viewModel.followText, attributes: container)
        followButton.configuration?.baseBackgroundColor = viewModel.followBackgroundColor
        followButton.configuration?.baseForegroundColor = viewModel.followTextColor
        followButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor

        followButton.menu = addMenuItems()
        
        followersLabel.attributedText = viewModel.followingFollowersText
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel, viewModel.user.isFollowed else { return nil }
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title:  AppStrings.Alerts.Actions.unfollow + " " + viewModel.firstName, image: UIImage(systemName: AppStrings.Icons.xmarkPersonFill, withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.headerCell(strongSelf, didTapEditProfileFor: viewModel.user)
            })
        ])
        
        followButton.showsMenuAsPrimaryAction = true
        return menuItems
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 guard let viewModel = viewModel else { return }
                 followButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
             }
         }
    }
    
    func updateButton() {
        guard let viewModel = viewModel else { return }
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        followButton.configuration?.attributedTitle = AttributedString(viewModel.followText, attributes: container)
        followButton.configuration?.baseBackgroundColor = viewModel.followBackgroundColor
        followButton.configuration?.baseForegroundColor = viewModel.followTextColor
        followButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
    }
    
    
    //MARK: - Actions
    
    @objc func handleFollowEditProfile() {
        guard let viewModel = viewModel else { return }
        if viewModel.user.isCurrentUser == false {
            isUpdatingFollowState = true
        }
        delegate?.headerCell(self, didTapEditProfileFor: viewModel.user)
    }
    
    @objc func handleShowFollowingFollowers() {
        guard let viewModel = viewModel else { return }
        delegate?.headerCell(didTapFollowingFollowersFor: viewModel.user)
    }
    
}
