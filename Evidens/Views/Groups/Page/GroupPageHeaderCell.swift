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
    
    weak var delegate: GroupPageHeaderCellDelegate?
    
    private lazy var groupBannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = primaryColor.withAlphaComponent(0.5)
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBannerTap)))
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var groupProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.white.cgColor
        iv.backgroundColor = lightGrayColor
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileTap)))
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 27, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 4
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
        button.configuration?.baseBackgroundColor = lightColor
        button.configuration?.buttonSize = .mini
        button.configuration?.baseForegroundColor = grayColor
        button.configuration?.cornerStyle = .medium
        button.addTarget(self, action: #selector(handleConfigurationButtonTap), for: .touchUpInside)
        return button
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
        backgroundColor = .white
        
        membersCollectionView.register(GroupUserCell.self, forCellWithReuseIdentifier: userCellReuseIdentifier)
        membersCollectionView.register(GroupSizeCell.self, forCellWithReuseIdentifier: userCountCellReuseIdentifier)
        membersCollectionView.delegate = self
        membersCollectionView.dataSource = self
        
        addSubviews(groupBannerImageView, groupProfileImageView, groupNameLabel, configurationButton, membersCollectionView, groupSizeLabel)
        NSLayoutConstraint.activate([
            groupBannerImageView.topAnchor.constraint(equalTo: topAnchor),
            groupBannerImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            groupBannerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            groupBannerImageView.heightAnchor.constraint(equalToConstant: 100),
            
            groupProfileImageView.centerYAnchor.constraint(equalTo: groupBannerImageView.centerYAnchor, constant: 50),
            groupProfileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            groupProfileImageView.widthAnchor.constraint(equalToConstant: 110),
            groupProfileImageView.heightAnchor.constraint(equalToConstant: 110),
            
            groupNameLabel.leadingAnchor.constraint(equalTo: groupProfileImageView.leadingAnchor),
            groupNameLabel.topAnchor.constraint(equalTo: groupProfileImageView.bottomAnchor, constant: 10),
            groupNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            configurationButton.topAnchor.constraint(equalTo: groupBannerImageView.bottomAnchor, constant: 10),
            configurationButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            configurationButton.heightAnchor.constraint(equalToConstant: 25),
            configurationButton.widthAnchor.constraint(equalToConstant: 25),
            
            membersCollectionView.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 5),
            membersCollectionView.leadingAnchor.constraint(equalTo: groupNameLabel.leadingAnchor),
            membersCollectionView.heightAnchor.constraint(equalToConstant: 25),
            membersCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            groupSizeLabel.centerYAnchor.constraint(equalTo: membersCollectionView.centerYAnchor),
            groupSizeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            groupSizeLabel.trailingAnchor.constraint(equalTo: membersCollectionView.leadingAnchor, constant: -5),
            groupSizeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    private func configureWithUser() {
        membersCollectionView.reloadData()
    }
    
    private func configureWithGroup() {
        guard let viewModel = viewModel else { return }
        groupBannerImageView.sd_setImage(with: URL(string: viewModel.groupBannerUrl!))
        groupProfileImageView.sd_setImage(with: URL(string: viewModel.groupProfileUrl!))
        groupNameLabel.text = viewModel.groupName
      
        configurationButton.configuration?.image = UIImage(systemName: "info")
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
