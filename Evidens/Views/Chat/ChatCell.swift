//
//  ChatCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/2/22.
//

import UIKit
import SDWebImage


class ChatCell: UICollectionViewCell {
    
    var viewModel: ConversationViewModel? {
        didSet {
            configure()
        }
    }
    
    //MARK: - Properties
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50/2
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "user.profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()
    
    private let messageUnreadImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10 / 2
        iv.backgroundColor = primaryColor
        return iv
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(profileImageView, usernameLabel, userMessageLabel, dateLabel, messageUnreadImage, separatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
        
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -5),
            
            userMessageLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor),
            userMessageLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            userMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            messageUnreadImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            messageUnreadImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            messageUnreadImage.widthAnchor.constraint(equalToConstant: 10),
            messageUnreadImage.heightAnchor.constraint(equalToConstant: 10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor)
        ])
    }

    //MARK: - Helpers
    
    public func configure() {
        guard let viewModel = viewModel else { return }
        dateLabel.text = viewModel.timestampString
        userMessageLabel.attributedText = viewModel.messageToDisplay()
        messageUnreadImage.isHidden = viewModel.isMessageRead
    }
    
    func set(user: User) {
        usernameLabel.text = user.firstName! + " " + user.lastName!
        if let imageUrl = user.profileImageUrl, imageUrl != "" {
           profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
}
