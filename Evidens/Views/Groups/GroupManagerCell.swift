//
//  GroupManagerCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/11/22.
//

import UIKit

private let userCellReuseIdentifier = "UserCellReuseIdentifier"
private let userCountCellReuseIdentifier = "UserCountCellReuseIdentifier"

protocol GroupManagerCellDelegate: AnyObject {
    func didTapBrosweGroups()
    func didTapShowMembers(members: String)
    func didTapShowMenu()
}

class GroupManagerCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    
    var viewModel: GroupViewModel? {
        didSet {
            configureGroup()
        }
    }
    
    var users: [User]? {
        didSet {
            configureWithUser()
        }
    }
    
    private var groupUsers = [User]()
    
    weak var delegate: GroupManagerCellDelegate?
    
    private lazy var bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.backgroundColor = primaryColor.withAlphaComponent(0.5)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let profileGroupImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "user.profile")
        iv.layer.borderWidth = 2
        iv.backgroundColor = lightGrayColor
        iv.layer.borderColor = UIColor.white.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var dotsButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.black).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleShowGroupSettings), for: .touchUpInside)
        return button
    }()
    
    private lazy var groupNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = .black
        
        button.configuration?.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).scalePreservingAspectRatio(targetSize: CGSize(width: 18, height: 18))
        button.configuration?.imagePadding = 10
        button.configuration?.imagePlacement = .trailing
        
        button.contentHorizontalAlignment = .left
        button.tintAdjustmentMode = .normal
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleBrowseGroups), for: .touchUpInside)
        return button
    }()
    
    private let membersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var groupSizeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMembersTap)))
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
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        cellContentView.backgroundColor = .white
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        cellContentView.backgroundColor = .white
        cellContentView.addSubviews(bannerImageView, profileGroupImageView, dotsButton, groupNameButton, membersCollectionView, groupSizeLabel)
        
        membersCollectionView.register(GroupUserCell.self, forCellWithReuseIdentifier: userCellReuseIdentifier)
        membersCollectionView.register(GroupSizeCell.self, forCellWithReuseIdentifier: userCountCellReuseIdentifier)
        membersCollectionView.delegate = self
        membersCollectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: 70),

            profileGroupImageView.centerYAnchor.constraint(equalTo: bannerImageView.bottomAnchor),
            profileGroupImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            profileGroupImageView.heightAnchor.constraint(equalToConstant: 60),
            profileGroupImageView.widthAnchor.constraint(equalToConstant: 60),
            
            dotsButton.centerYAnchor.constraint(equalTo: groupNameButton.centerYAnchor),
            dotsButton.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            dotsButton.widthAnchor.constraint(equalToConstant: 20),
            dotsButton.heightAnchor.constraint(equalToConstant: 20),
            
            groupNameButton.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor),
            groupNameButton.leadingAnchor.constraint(equalTo: profileGroupImageView.trailingAnchor),
            groupNameButton.trailingAnchor.constraint(equalTo: dotsButton.leadingAnchor, constant: -10),
            
            membersCollectionView.topAnchor.constraint(equalTo: groupNameButton.bottomAnchor),
            membersCollectionView.leadingAnchor.constraint(equalTo: profileGroupImageView.trailingAnchor, constant: 12),
            membersCollectionView.heightAnchor.constraint(equalToConstant: 25),
            membersCollectionView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
           
            groupSizeLabel.centerYAnchor.constraint(equalTo: membersCollectionView.centerYAnchor),
            groupSizeLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            groupSizeLabel.trailingAnchor.constraint(equalTo: membersCollectionView.leadingAnchor, constant: -5),
            groupSizeLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -20)
        ])
    }
    
    func configureGroup() {
        guard let viewModel = viewModel else { return }
        //membersCollectionView.widthConstraint?.constant = CGFloat(min(viewModel.groupMembers, 3) * 25) //- spacing
        print(CGFloat(min(viewModel.groupMembers, 3)))
        //fetchGroupUsers()
        profileGroupImageView.sd_setImage(with: URL(string: viewModel.groupProfileUrl!))
        bannerImageView.sd_setImage(with: URL(string: viewModel.groupBannerUrl!))

        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .medium)
        groupNameButton.configuration?.attributedTitle = AttributedString(viewModel.groupName, attributes: container)

    }
    
    private func configureWithUser() {
        guard let users = users else { return }
        groupUsers = users
        membersCollectionView.reloadData()
    }
    
    @objc func handleBrowseGroups() {
        delegate?.didTapBrosweGroups()
    }
    
    @objc func handleMembersTap() {
        guard let viewModel = viewModel else { return }
        delegate?.didTapShowMembers(members: viewModel.groupSizeString)
    }
    
    @objc func handleShowGroupSettings() {
        delegate?.didTapShowMenu()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

extension GroupManagerCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return min(groupUsers.count, 3)
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellReuseIdentifier, for: indexPath) as! GroupUserCell
            cell.set(user: groupUsers[indexPath.row])
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCountCellReuseIdentifier, for: indexPath) as! GroupSizeCell
        if let viewModel = viewModel {
            cell.set(members: viewModel.groupSizeString)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        delegate?.didTapShowMembers(members: viewModel.groupSizeString)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: 25, height: 25)
        } else {
            return CGSize(width: 150, height: 25)
        }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return -7
        }
        
        return 10
    }
}
