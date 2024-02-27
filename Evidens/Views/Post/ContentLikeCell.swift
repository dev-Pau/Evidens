//
//  ContentLikeCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/6/22.
//

import UIKit

class ContentLikeCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            configureWithUser()
        }
    }
    
    private var profileImageView = ProfileImageView(frame: .zero)
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = primaryGray
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let disciplineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        
        let nameStackView = UIStackView(arrangedSubviews: [stackView, disciplineLabel])
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        nameStackView.axis = .vertical
        nameStackView.spacing = 5
        
        addSubviews(profileImageView, nameStackView, separatorView)

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: nameStackView.topAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 43),
            profileImageView.widthAnchor.constraint(equalToConstant: 43),
          
            nameStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            nameStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            nameStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),

            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        profileImageView.layer.cornerRadius = 43 / 2
    }
    
    private func configureWithUser() {
        guard let user = user else { return }
        
        profileImageView.addImage(forUser: user, size: 43)
       
        nameLabel.text = user.name()
        usernameLabel.text = user.getUsername()
        disciplineLabel.text = user.details()
    }
}
