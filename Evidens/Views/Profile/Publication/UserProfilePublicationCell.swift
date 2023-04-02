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
    
    private let calendarImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "calendar")?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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
  
    private let urlImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "paperclip")?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let publicationUrlLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        addSubviews(publicationTitleLabel, collectionView, urlImage, publicationUrlLabel, calendarImage, publicationDateLabel, separatorView)
        
        NSLayoutConstraint.activate([
            publicationTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            publicationTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            publicationTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            urlImage.topAnchor.constraint(equalTo: publicationTitleLabel.bottomAnchor, constant: 5),
            urlImage.leadingAnchor.constraint(equalTo: publicationTitleLabel.leadingAnchor),
            urlImage.widthAnchor.constraint(equalToConstant: 15),
            urlImage.heightAnchor.constraint(equalToConstant: 15),
            
            publicationUrlLabel.centerYAnchor.constraint(equalTo: urlImage.centerYAnchor),
            publicationUrlLabel.leadingAnchor.constraint(equalTo: urlImage.trailingAnchor, constant: 10),
            publicationUrlLabel.trailingAnchor.constraint(equalTo: publicationTitleLabel.trailingAnchor),
            
            calendarImage.topAnchor.constraint(equalTo: publicationUrlLabel.bottomAnchor, constant: 5),
            calendarImage.leadingAnchor.constraint(equalTo: publicationTitleLabel.leadingAnchor),
            calendarImage.widthAnchor.constraint(equalToConstant: 15),
            calendarImage.heightAnchor.constraint(equalToConstant: 15),
            
            publicationDateLabel.centerYAnchor.constraint(equalTo: calendarImage.centerYAnchor),
            publicationDateLabel.leadingAnchor.constraint(equalTo: calendarImage.trailingAnchor, constant: 10),
            publicationDateLabel.trailingAnchor.constraint(equalTo: publicationTitleLabel.trailingAnchor),
            publicationDateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -52),
            
            collectionView.topAnchor.constraint(equalTo: publicationDateLabel.bottomAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: calendarImage.leadingAnchor),
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
        publicationUrlLabel.text = publication.url
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


