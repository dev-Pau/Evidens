//
//  GroupManagerCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/11/22.
//

import UIKit

private let userCellReuseIdentifier = "UserCellReuseIdentifier"

protocol GroupManagerCellDelegate: AnyObject {
    func didTapBrosweGroups()
}

class GroupManagerCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    
    var viewModel: GroupViewModel? {
        didSet {
            configureGroup()
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
        layout.itemSize = CGSize(width: 25, height: 25)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let groupSizeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
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
        cellContentView.addSubviews(bannerImageView, profileGroupImageView, groupNameButton, groupSizeLabel, membersCollectionView)
        
        membersCollectionView.register(GroupUserCell.self, forCellWithReuseIdentifier: userCellReuseIdentifier)
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
            
            groupNameButton.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor),
            groupNameButton.leadingAnchor.constraint(equalTo: profileGroupImageView.trailingAnchor),
            groupNameButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 10 - 60 - 10),
            
            membersCollectionView.topAnchor.constraint(equalTo: groupNameButton.bottomAnchor),
            membersCollectionView.leadingAnchor.constraint(equalTo: profileGroupImageView.trailingAnchor, constant: 12),
            membersCollectionView.heightAnchor.constraint(equalToConstant: 25),
            membersCollectionView.widthAnchor.constraint(equalToConstant: 25),
           
            groupSizeLabel.centerYAnchor.constraint(equalTo: membersCollectionView.centerYAnchor),
            groupSizeLabel.leadingAnchor.constraint(equalTo: membersCollectionView.trailingAnchor, constant: 5),
            groupSizeLabel.trailingAnchor.constraint(equalTo: groupNameButton.trailingAnchor),
            groupSizeLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -15)
        ])
        
        profileGroupImageView.layer.cornerRadius = 60 / 2
    }
    
    func configureGroup() {
        guard let viewModel = viewModel else { return }
        fetchGroupUsers()
        profileGroupImageView.sd_setImage(with: URL(string: viewModel.groupProfileUrl!))
        bannerImageView.sd_setImage(with: URL(string: viewModel.groupBannerUrl!))
        groupSizeLabel.text = viewModel.groupSizeString
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .medium)
        groupNameButton.configuration?.attributedTitle = AttributedString(viewModel.groupName, attributes: container)
        
    }
    
    @objc func handleBrowseGroups() {
        delegate?.didTapBrosweGroups()
    }
    
    private func fetchGroupUsers() {
        guard let viewModel = viewModel else { return }
        DatabaseManager.shared.fetchFirstGroupUsers(forGroupId: viewModel.group.groupId) { uids in
            print(uids.count)
            UserService.fetchUsers(withUids: uids) { users in
                self.groupUsers = users
                //rint(self.groupUsers.count)
                self.membersCollectionView.widthConstraint?.constant = CGFloat(uids.count) * 25
                self.membersCollectionView.reloadData()
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
}

extension GroupManagerCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellReuseIdentifier, for: indexPath) as! GroupUserCell
        cell.set(user: groupUsers[indexPath.row])
        return cell
    }
}
