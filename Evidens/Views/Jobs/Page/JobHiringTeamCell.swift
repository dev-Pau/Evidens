//
//  JobHiringTeamCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/2/23.
//

import UIKit

protocol JobHiringTeamCellDelegate: AnyObject {
    func didTapHiringMember(user: User)
}

class JobHiringTeamCell: UICollectionViewCell {
    weak var delegate: JobHiringTeamCellDelegate?
    
    var memberUid: String? {
        didSet {
            fetchUser()
        }
    }
    
    private var user: User?
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "user.profile")
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var userInfoCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 12, weight: .medium)
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
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHiringMember)))
        
        addSubviews(profileImageView, nameLabel, userInfoCategoryLabel)

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            userInfoCategoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            userInfoCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userInfoCategoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
        ])
        
        profileImageView.layer.cornerRadius = 50 / 2
    }
    
    private func fetchUser() {
        guard let memberUid = memberUid else { return }
        UserService.fetchUser(withUid: memberUid) { user in
            self.user = user
            self.nameLabel.text = user.firstName! + " " + user.lastName!
            self.userInfoCategoryLabel.text = user.profession! + " • " + user.speciality!
            if let imageUrl = user.profileImageUrl, imageUrl != "" {
                self.profileImageView.sd_setImage(with: URL(string: imageUrl))
            }
        }
    }
    
    @objc func didTapHiringMember() {
        guard let user = user else { return }
        delegate?.didTapHiringMember(user: user)
    }
}
