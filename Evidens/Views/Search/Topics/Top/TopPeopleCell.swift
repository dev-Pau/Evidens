//
//  TopCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/5/22.
//

import UIKit

protocol TopPeopleCellDelegate: AnyObject {
    func didTapProfile(forUid uid: String)
}

class TopPeopleCell: UITableViewCell {
    
    //MARK: - Properties
    
    var viewModel: UserCellViewModel? {
        didSet {
            configure()
        }
    }
    
    weak var delegate: TopPeopleCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = lightColor
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileTap)))
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textColor = grayColor

        return label
    }()
  
    private let userCategoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.heightAnchor.constraint(equalToConstant: 65).isActive = true
        
        contentView.addSubviews(profileImageView, nameLabel, userCategoryLabel)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            userCategoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            userCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userCategoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    func configure() {
        guard let viewModel = viewModel else { return }
        
        
        profileImageView.sd_setImage(with: viewModel.userProfileImageUrl)
        nameLabel.text = viewModel.fullName
        userCategoryLabel.text = viewModel.profession
    }
    
    
    @objc func handleProfileTap() {
        guard let viewModel = viewModel else { return }
        delegate?.didTapProfile(forUid: viewModel.uid)
    }
}
