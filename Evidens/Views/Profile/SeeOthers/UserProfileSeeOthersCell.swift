//
//  SeeOthersCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

class UserProfileSeeOthersCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.layer.contentsGravity = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pau Fernández Solà"
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubviews(profileImageView, nameLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 3)
        ])
        
        profileImageView.layer.cornerRadius = 60/2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    func configure() {
        guard let viewModel = viewModel else { return }
        nameLabel.text = viewModel.firstName + " " + viewModel.lastName
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
    }
     */
}
