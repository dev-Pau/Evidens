//
//  UserProfilePublicationCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

private let userCellReuseIdentifier = "UserCellReuseIdentifier"

protocol UserProfilePublicationCellDelegate: AnyObject {
    func didTapShowContributors(users: [User])
}

class UserProfilePublicationCell: UICollectionViewCell {
    
    private var users = [User]()
    weak var delegate: UserProfilePublicationCellDelegate?
    
    private let publicationTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let publicationDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
  
    private let publicationUrlButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "arrow.up.forward.app", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        button.configuration?.imagePlacement = .trailing
        button.configuration?.buttonSize = .mini
        button.configuration?.imagePadding = 5
        button.configuration?.background.strokeWidth = 1
        button.configuration?.background.strokeColor = .secondaryLabel
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .medium)
        container.foregroundColor = .secondaryLabel
        button.configuration?.attributedTitle = AttributedString(" Show publication ", attributes: container)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        collectionView.register(GroupUserCell.self, forCellWithReuseIdentifier: userCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        backgroundColor = .systemBackground
        addSubviews(publicationTitleLabel, collectionView, publicationUrlButton, publicationDateLabel, separatorView)
        
        NSLayoutConstraint.activate([
            publicationTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            publicationTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            publicationTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            publicationDateLabel.topAnchor.constraint(equalTo: publicationTitleLabel.bottomAnchor, constant: 2),
            publicationDateLabel.leadingAnchor.constraint(equalTo: publicationTitleLabel.leadingAnchor),
            publicationDateLabel.trailingAnchor.constraint(equalTo: publicationTitleLabel.trailingAnchor),
            publicationDateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -78),
            
            publicationUrlButton.topAnchor.constraint(equalTo: publicationDateLabel.bottomAnchor, constant: 5),
            publicationUrlButton.leadingAnchor.constraint(equalTo: publicationDateLabel.leadingAnchor),
            publicationUrlButton.heightAnchor.constraint(equalToConstant: 30),
            
            collectionView.topAnchor.constraint(equalTo: publicationUrlButton.bottomAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: publicationDateLabel.leadingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 32),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    func set(publication: Publication) {
        publicationTitleLabel.text = publication.title
        //publicationUrlLabel.text = publication.url
        publicationDateLabel.text = publication.date
        UserService.fetchUsers(withUids: publication.contributorUids) { users in
            self.users = users
            self.collectionView.reloadData()
        }
    }
}


extension UserProfilePublicationCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellReuseIdentifier, for: indexPath) as! GroupUserCell
        cell.set(user: users[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 32, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return -10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !users.isEmpty else { return }
        delegate?.didTapShowContributors(users: users)
    }
}


