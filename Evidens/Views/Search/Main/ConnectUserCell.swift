//
//  ConnectUserCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/2/23.
//

import UIKit

class ConnectUserCell: UICollectionViewCell {

    var viewModel: ConnectViewModel? {
        didSet {
            configureUser()
        }
    }
    
    private lazy var profileImageView = ProfileImageView(frame: .zero)
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
       
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = K.Colors.primaryGray
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let discipline: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
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

        let stackView = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        
        addSubviews(profileImageView, stackView, discipline, separator)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: K.Paddings.Content.verticalPadding),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: K.Paddings.Content.userImageSize),
            profileImageView.widthAnchor.constraint(equalToConstant: K.Paddings.Content.userImageSize),
            
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            discipline.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 5),
            discipline.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            discipline.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            discipline.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -K.Paddings.Content.verticalPadding),
            
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -K.Paddings.Content.horizontalPadding),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: K.Paddings.Content.horizontalPadding),
            separator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        profileImageView.layer.cornerRadius = K.Paddings.Content.userImageSize / 2
    }
    
    func configureUser() {
        guard let viewModel = viewModel else { return }

        profileImageView.addImage(forUser: viewModel.user, size: K.Paddings.Content.userImageSize)
        nameLabel.text = viewModel.name
        discipline.text = viewModel.details
        usernameLabel.text = viewModel.username
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 14, scaleStyle: .body, weight: .bold, scales: false)
    }
}
