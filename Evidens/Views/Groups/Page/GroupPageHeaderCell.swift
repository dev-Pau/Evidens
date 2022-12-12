//
//  GroupPageHeaderCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/12/22.
//

import UIKit

private let userCellReuseIdentifier = "UserCellReuseIdentifier"

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
    
    private let groupBannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = primaryColor.withAlphaComponent(0.5)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let groupProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.white.cgColor
        iv.backgroundColor = lightGrayColor
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
    
    private let membersLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .black
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
    
    private let configurationButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.baseBackgroundColor = lightColor
        button.configuration?.buttonSize = .mini
        button.configuration?.baseForegroundColor = grayColor
        button.configuration?.cornerStyle = .medium
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
        backgroundColor = .white
        
        membersCollectionView.register(GroupUserCell.self, forCellWithReuseIdentifier: userCellReuseIdentifier)
        membersCollectionView.delegate = self
        membersCollectionView.dataSource = self
        
        addSubviews(groupBannerImageView, groupProfileImageView, groupNameLabel, membersLabel, configurationButton, membersCollectionView)
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
            
            membersLabel.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 5),
            membersLabel.leadingAnchor.constraint(equalTo: groupNameLabel.leadingAnchor),
            membersLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            membersLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            
            configurationButton.topAnchor.constraint(equalTo: groupBannerImageView.bottomAnchor, constant: 10),
            configurationButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            membersCollectionView.topAnchor.constraint(equalTo: membersLabel.bottomAnchor, constant: 5),
            membersCollectionView.leadingAnchor.constraint(equalTo: membersLabel.leadingAnchor),
            membersCollectionView.heightAnchor.constraint(equalToConstant: 25),
            membersCollectionView.trailingAnchor.constraint(equalTo: membersLabel.trailingAnchor),
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
        membersLabel.text = viewModel.groupSizeString
        configurationButton.configuration?.image = UIImage(systemName: viewModel.settingsButtonImageString)
    }
}

extension GroupPageHeaderCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellReuseIdentifier, for: indexPath) as! GroupUserCell
        cell.set(user: users?[indexPath.row] ?? User(dictionary: [:]))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 25, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return -7
    }
}
