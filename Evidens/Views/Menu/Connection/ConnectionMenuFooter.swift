//
//  ConnectionMenuFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/10/23.
//

import UIKit

protocol ConnectionMenuFooterDelegate: AnyObject {
    func didTapMessage()
    func didTapConnection()
    func didTapFollow()
}

class ConnectionMenuFooter: UICollectionReusableView {
    
    weak var delegate: ConnectionMenuFooterDelegate?
    
    private var messageButton: UIButton!
    private var connectionButton: UIButton!
    private var followButton: UIButton!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 16, weight: .semibold)
        
        var messageConfiguration = UIButton.Configuration.filled()
        messageConfiguration.baseBackgroundColor = .systemBackground
        messageConfiguration.baseForegroundColor = primaryColor
        messageConfiguration.background.strokeColor = primaryColor
        messageConfiguration.background.strokeWidth = 2
        messageConfiguration.cornerStyle = .capsule
        messageConfiguration.attributedTitle = AttributedString(AppStrings.Network.Connection.message, attributes: container)
       
        messageButton = UIButton(type: .system)
        messageButton.configuration = messageConfiguration
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.addTarget(self, action: #selector(handleMessageTap), for: .touchUpInside)
        
        connectionButton = UIButton(type: .system)
        connectionButton.translatesAutoresizingMaskIntoConstraints = false
        connectionButton.addTarget(self, action: #selector(handleConnectionTap), for: .touchUpInside)
        
        followButton = UIButton(type: .system)
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.addTarget(self, action: #selector(handleFollowTap), for: .touchUpInside)
        
        addSubviews(messageButton, connectionButton, followButton)
        
        NSLayoutConstraint.activate([
            messageButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            messageButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            messageButton.heightAnchor.constraint(equalToConstant: 40),
            
            connectionButton.topAnchor.constraint(equalTo: messageButton.bottomAnchor, constant: 10),
            connectionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            connectionButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -10),
            connectionButton.heightAnchor.constraint(equalToConstant: 40),
            
            followButton.topAnchor.constraint(equalTo: messageButton.bottomAnchor, constant: 10),
            followButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 10),
            followButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            followButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    func set(user: User) {
        guard let connection = user.connection else { return }
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 16, weight: .semibold)
        
        
        var connectionConfiguration = UIButton.Configuration.filled()
        
        switch connection.phase {
            
        case .connected:
            connectionConfiguration.baseBackgroundColor = .white
            connectionConfiguration.baseForegroundColor = .systemRed
            connectionConfiguration.image = nil
            connectionConfiguration.background.strokeColor = .systemRed
            connectionConfiguration.background.strokeWidth = 2
            connectionConfiguration.attributedTitle = AttributedString(AppStrings.Global.withdraw, attributes: container)
        case .pending:
            connectionConfiguration.baseBackgroundColor = .quaternarySystemFill
            connectionConfiguration.baseForegroundColor = .label
            connectionConfiguration.image = UIImage(systemName: AppStrings.Icons.clock, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysTemplate).withTintColor(.label)
            connectionConfiguration.attributedTitle = AttributedString(connection.phase.title, attributes: container)
        case .received:
            connectionConfiguration.baseBackgroundColor = .quaternarySystemFill
            connectionConfiguration.baseForegroundColor = .label
            connectionConfiguration.image = UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysTemplate).withTintColor(.label)
            connectionConfiguration.attributedTitle = AttributedString(connection.phase.title, attributes: container)
        case .none, .withdraw, .rejected, .unconnect:
            connectionConfiguration.baseBackgroundColor = primaryColor
            connectionConfiguration.baseForegroundColor = .white
            connectionConfiguration.image = nil
            connectionConfiguration.attributedTitle = AttributedString(connection.phase.title, attributes: container)
        }
        
        connectionConfiguration.cornerStyle = .capsule
        connectionConfiguration.imagePlacement = .trailing
        connectionConfiguration.imagePadding = 10
        
        var followConfiguration = UIButton.Configuration.filled()
        followConfiguration.baseBackgroundColor = .systemBackground
        followConfiguration.baseForegroundColor = primaryColor
        followConfiguration.background.strokeColor = primaryColor
        followConfiguration.background.strokeWidth = 2
        followConfiguration.cornerStyle = .capsule
        followConfiguration.attributedTitle = AttributedString(user.isFollowed ? AppStrings.Alerts.Actions.unfollow : AppStrings.Alerts.Actions.follow, attributes: container)

        connectionButton.configuration = connectionConfiguration

        followButton.configuration = followConfiguration
    }
    
    @objc func handleConnectionTap() {
        delegate?.didTapConnection()
    }
    
    @objc func handleFollowTap() {
        delegate?.didTapFollow()
    }
    
    @objc func handleMessageTap() {
        delegate?.didTapMessage()
    }
}
