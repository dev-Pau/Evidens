//
//  ChatCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/2/22.
//

import UIKit
import SDWebImage

/// The conversation type cell view to display conversations.
class ConversationCell: UICollectionViewCell {
    
    private var pinButtonTrailingAnchor: NSLayoutConstraint!

    var viewModel: ConversationViewModel? {
        didSet {
            configureWithConversation()
        }
    }
    
    //MARK: - Properties
    
    
    private let userImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .secondaryLabel
        iv.image = UIImage(named: "user.profile")
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 2
        return label
    }()
    
    
    private let lastMessageDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let pinMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.buttonSize = .mini
        button.configuration?.cornerStyle = .capsule
        button.isUserInteractionEnabled = false
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
        return button
    }()
    
    private let unreadMessages: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.isUserInteractionEnabled = false
        button.configuration?.baseBackgroundColor = .systemBlue
        button.configuration?.baseForegroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.buttonSize = .mini
        button.configuration?.cornerStyle = .capsule
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()
    
    //MARK: - Lifecycle
    
    /// Initializes a new instance of the view with the specified frame.
    ///
    /// - Parameters:
    ///   - frame: The frame rectangle for the view, measured in points.
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(userImageView, nameLabel, lastMessageDateLabel, pinMessageButton, unreadMessages, lastMessageLabel, separatorView)
        lastMessageDateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        lastMessageDateLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        pinButtonTrailingAnchor = pinMessageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        
        NSLayoutConstraint.activate([
            userImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            userImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            userImageView.heightAnchor.constraint(equalToConstant: 60),
            userImageView.widthAnchor.constraint(equalToConstant: 60),

            lastMessageDateLabel.topAnchor.constraint(equalTo: userImageView.topAnchor),
            lastMessageDateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            unreadMessages.topAnchor.constraint(equalTo: lastMessageDateLabel.bottomAnchor, constant: 5),
            unreadMessages.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            pinMessageButton.topAnchor.constraint(equalTo: lastMessageDateLabel.bottomAnchor),
            pinButtonTrailingAnchor,
            
            nameLabel.topAnchor.constraint(equalTo: userImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: lastMessageDateLabel.leadingAnchor, constant: -20),
            
            lastMessageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            lastMessageLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: -10),
            lastMessageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
        
        userImageView.layer.cornerRadius = (60) / 2
        
        let heighConstraint = heightAnchor.constraint(equalToConstant: 80)
        heighConstraint.priority = .defaultHigh
        heighConstraint.isActive = true
    }

    //MARK: - Helpers
    
    private func configureWithConversation() {
        guard let viewModel = viewModel else { return }
        
        viewModel.image(completion: { [weak self] image in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.userImageView.image = image
            }
        })
        
        nameLabel.text = viewModel.name
        lastMessageLabel.text = viewModel.lastMessage
        lastMessageDateLabel.text = viewModel.lastMessageDate
        lastMessageDateLabel.textColor = viewModel.messageColor
        
        if viewModel.unreadMessages > 0 {
            unreadMessages.isHidden = false
            var container = AttributeContainer()
            container.font = .systemFont(ofSize: 13, weight: .regular)
            unreadMessages.configuration?.attributedTitle = AttributedString(" \(viewModel.unreadMessages) ", attributes: container)
            
        } else {
            unreadMessages.isHidden = true
        }
        
        if viewModel.isPinned {
            pinMessageButton.isHidden = false
            pinMessageButton.configuration?.image = viewModel.pinImage
            if viewModel.unreadMessages > 0 {
                UIView.animate(withDuration: 0.3) {
                    self.pinButtonTrailingAnchor.constant = -25
                }
            }
        } else {
            pinMessageButton.isHidden = true
            pinButtonTrailingAnchor.constant = -5
        }
    }
}
