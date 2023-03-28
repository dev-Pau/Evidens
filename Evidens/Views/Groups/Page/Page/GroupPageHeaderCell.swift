//
//  GroupPageHeaderCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/12/22.
//

import UIKit

private let userCellReuseIdentifier = "UserCellReuseIdentifier"
private let userCountCellReuseIdentifier = "UserCountCellReuseIdentifier"

protocol GroupPageHeaderCellDelegate: AnyObject {
    func didTapGroupProfilePicture()
    func didTapGroupBannerPicture()
    func didTapInfoButton()
    func didTapActionButton(memberType: Group.MemberType)
    func didTapGroupOptions(option: Group.GroupManagement)
}

class GroupPageHeaderCell: UICollectionViewCell {
    
    var viewModel: GroupViewModel? {
        didSet {
            configureWithGroup()
        }
    }
    
    var users: [User]? {
        didSet {
            configureWithUser()
        }
    }
    
    var memberType: Group.MemberType? {
        didSet {
            configureActionButton()
        }
    }
    
    var isUpdatingJoiningState: Bool? {
        didSet {
            customUserButton.setNeedsUpdateConfiguration()
        }
    }
    
    weak var delegate: GroupPageHeaderCellDelegate?

    private let groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let groupDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let membersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var configurationButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.baseBackgroundColor = .systemBackground
        button.configuration?.buttonSize = .mini
        button.configuration?.background.strokeWidth = 1
        button.configuration?.background.strokeColor = .quaternarySystemFill
        button.configuration?.baseForegroundColor = .label
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("     About     ", attributes: container)
        
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleConfigurationButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var customUserButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 1
        button.configuration?.background.strokeColor = .quaternarySystemFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleActionButtonPressed), for: .touchUpInside)
        return button
        
        // ESTIC AQUÍ CREAR EL BOTÓ HORITZONTAL
        // SI ETS MANAGER POSAR MANAGE GROUP AL MENU POSAR LU DELS POSTS, MANAGE MEMBERS, EDIT GROUP ETC.
        // SI ETS USER NORMAL POSAR SETTINGS - A SETTIGNS POSAR BASICAMENT REPORT I LEAVE
        // SI ESTÀS FORA POSAR JOIN I A LL'APRETAR POSAR PENDING
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    private lazy var groupSizeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        return label
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
        isUpdatingJoiningState = false
        
        membersCollectionView.register(GroupUserCell.self, forCellWithReuseIdentifier: userCellReuseIdentifier)
        membersCollectionView.register(GroupSizeCell.self, forCellWithReuseIdentifier: userCountCellReuseIdentifier)
        membersCollectionView.delegate = self
        membersCollectionView.dataSource = self
        
        
        addSubviews(groupNameLabel, groupDescriptionLabel, configurationButton, membersCollectionView, customUserButton, groupSizeLabel, separatorView)
        NSLayoutConstraint.activate([
            groupNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            groupNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            groupNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            groupDescriptionLabel.leadingAnchor.constraint(equalTo: groupNameLabel.leadingAnchor),
            groupDescriptionLabel.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 5),
            groupDescriptionLabel.trailingAnchor.constraint(equalTo: groupNameLabel.trailingAnchor),
            //groupNameLabel.bottomAnchor.constraint(equalTo: groupProfileImageView.bottomAnchor),
            
            configurationButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            configurationButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            configurationButton.heightAnchor.constraint(equalToConstant: 30),
            configurationButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 3 - 30),
            
            customUserButton.topAnchor.constraint(equalTo: configurationButton.topAnchor),
            customUserButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 100),
            customUserButton.trailingAnchor.constraint(equalTo: configurationButton.leadingAnchor, constant: -10),
            customUserButton.heightAnchor.constraint(equalToConstant: 30),

            membersCollectionView.topAnchor.constraint(equalTo: groupDescriptionLabel.bottomAnchor, constant: 10),
            membersCollectionView.leadingAnchor.constraint(equalTo: groupDescriptionLabel.leadingAnchor),
            membersCollectionView.heightAnchor.constraint(equalToConstant: 32),
            membersCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            groupSizeLabel.topAnchor.constraint(equalTo: membersCollectionView.bottomAnchor),
            groupSizeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            groupSizeLabel.trailingAnchor.constraint(equalTo: membersCollectionView.leadingAnchor, constant: -5),
            groupSizeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        //groupProfileImageView.layer.cornerRadius = 7
        
        customUserButton.configurationUpdateHandler = { [unowned self] button in
            button.isUserInteractionEnabled = self.isUpdatingJoiningState! ? false : true
        }
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let memberType = memberType else { return nil }
        
        switch memberType {
        case .owner:
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: Group.GroupManagement.posts.rawValue, image: Group.GroupManagement.posts.groupManagementImage, handler: { _ in
                    self.delegate?.didTapGroupOptions(option: Group.GroupManagement.posts)
                }),
                UIAction(title: Group.GroupManagement.membership.rawValue, image: Group.GroupManagement.membership.groupManagementImage, handler: { _ in
                    self.delegate?.didTapGroupOptions(option: Group.GroupManagement.membership)
                }),
                UIAction(title: Group.GroupManagement.edit.rawValue, image: Group.GroupManagement.edit.groupManagementImage, handler: { _ in
                    self.delegate?.didTapGroupOptions(option: Group.GroupManagement.edit)
                })
            ])
            customUserButton.showsMenuAsPrimaryAction = true
            return menuItems
            
        case .admin:
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: Group.GroupManagement.posts.rawValue, image: Group.GroupManagement.posts.groupManagementImage, handler: { _ in
                    self.delegate?.didTapGroupOptions(option: Group.GroupManagement.posts)
                }),
                UIAction(title: Group.GroupManagement.membership.rawValue, image: Group.GroupManagement.membership.groupManagementImage, handler: { _ in
                    self.delegate?.didTapGroupOptions(option: Group.GroupManagement.membership)
                })
            ])
            customUserButton.showsMenuAsPrimaryAction = true
            return menuItems
        case .member:
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: Group.GroupManagement.leave.rawValue, image: Group.GroupManagement.leave.groupManagementImage, attributes: .destructive, handler: { _ in
                    self.delegate?.didTapGroupOptions(option: Group.GroupManagement.leave)
                }),
                UIAction(title: Group.GroupManagement.report.rawValue, image: Group.GroupManagement.report.groupManagementImage, handler: { _ in
                    self.delegate?.didTapGroupOptions(option: Group.GroupManagement.report)
                })
                
            ])
            customUserButton.showsMenuAsPrimaryAction = true
            return menuItems
        case .pending:
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: Group.GroupManagement.withdraw.rawValue, image: Group.GroupManagement.withdraw.groupManagementImage, handler: { _ in
                    self.delegate?.didTapGroupOptions(option: Group.GroupManagement.withdraw)
                }),
                UIAction(title: Group.GroupManagement.report.rawValue, image: Group.GroupManagement.report.groupManagementImage, handler: { _ in
                    self.delegate?.didTapGroupOptions(option: Group.GroupManagement.report)
                })
            ])
            customUserButton.showsMenuAsPrimaryAction = true
            return menuItems
        case .external:
            return nil
        case .invited:
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: Group.GroupManagement.accept.rawValue, image: Group.GroupManagement.accept.groupManagementImage, handler: { _ in
                    self.delegate?.didTapGroupOptions(option: Group.GroupManagement.accept)
                }),
                UIAction(title: Group.GroupManagement.ignore.rawValue, image: Group.GroupManagement.ignore.groupManagementImage, handler: { _ in
                    self.delegate?.didTapGroupOptions(option: Group.GroupManagement.ignore)
                }),
                UIAction(title: Group.GroupManagement.report.rawValue, image: Group.GroupManagement.report.groupManagementImage, handler: { _ in
                    self.delegate?.didTapGroupOptions(option: Group.GroupManagement.report)
                })
            ])
            customUserButton.showsMenuAsPrimaryAction = true
            return menuItems
        case .blocked:
            return nil
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                 //groupProfileImageView.layer.borderColor = UIColor.systemBackground.cgColor
             }
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
    
    private func configureWithUser() {
        membersCollectionView.reloadData()
    }
    
    private func configureWithGroup() {
        guard let viewModel = viewModel else { return }
        //groupBannerImageView.sd_setImage(with: URL(string: viewModel.groupBannerUrl!))
        //groupProfileImageView.sd_setImage(with: URL(string: viewModel.groupProfileUrl!))
        groupNameLabel.text = viewModel.groupName
        groupDescriptionLabel.text = viewModel.groupDescription
    }
    
    private func configureActionButton() {
        guard let memberType = memberType else { return }
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)

        customUserButton.configuration?.attributedTitle = AttributedString(memberType.buttonText, attributes: container)
        customUserButton.configuration?.baseBackgroundColor = memberType.buttonBackgroundColor
        customUserButton.configuration?.baseForegroundColor = memberType.buttonForegroundColor
        
        if memberType == .external { customUserButton.configuration?.background.strokeColor = .quaternarySystemFill }
        customUserButton.menu = addMenuItems()
    }
    
    @objc func handleBannerTap() {
        delegate?.didTapGroupBannerPicture()
    }
    
    @objc func handleProfileTap() {
        delegate?.didTapGroupProfilePicture()
    }
    
    @objc func handleConfigurationButtonTap() {
        delegate?.didTapInfoButton()
    }
    
    @objc func handleActionButtonPressed() {
        guard let memberType = memberType else { return }

        if memberType == .external {
            isUpdatingJoiningState = true
            delegate?.didTapActionButton(memberType: memberType)
        }
        /*else if memberType == .pending {
            //customUserButton.menu = addMenuItems()
            //customUserButton.showsMenuAsPrimaryAction = true
        } else {
            delegate?.didTapActionButton(memberType: memberType)
        }
         */

    }
}

extension GroupPageHeaderCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return users?.count ?? 0
            
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellReuseIdentifier, for: indexPath) as! GroupUserCell
            cell.set(user: users?[indexPath.row] ?? User(dictionary: [:]))
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCountCellReuseIdentifier, for: indexPath) as! GroupSizeCell
        if let viewModel = viewModel {
            cell.set(members: viewModel.groupSizeString)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: 32, height: 32)
        } else {
            return CGSize(width: 150, height: 25)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return -10
        }
        
        return 10
    }
}
