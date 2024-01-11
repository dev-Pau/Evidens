//
//  ConnectionMenuCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/10/23.
//

import UIKit

class ConnectionMenuCell: UICollectionViewCell {
    
    private let padding: CGFloat = 20
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        
        addSubviews(button, titleLabel)
        
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    func set(user: User, menu: ConnectMenu) {
        switch menu {
        case .connect:
            guard let connection = user.connection else { return }
            
            switch connection.phase {
                
            case .connected:
                titleLabel.text = AppStrings.Alerts.Title.remove
                button.configuration?.image = UIImage(systemName: AppStrings.Icons.xmarkPersonFill, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            case .pending:
                titleLabel.text = AppStrings.Alerts.Title.withdraw
                button.configuration?.image = UIImage(systemName: AppStrings.Icons.clock, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            case .received:
                titleLabel.text = AppStrings.Network.Connection.received
                button.configuration?.image = UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            case .unconnect, .none, .rejected, .withdraw:
                titleLabel.text = AppStrings.Network.Connection.none
                button.configuration?.image = UIImage(systemName: AppStrings.Icons.fillPerson, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            }
        case .follow:
            titleLabel.text = user.isFollowed ? AppStrings.Alerts.Actions.unfollow : AppStrings.Alerts.Actions.follow
            button.configuration?.image = UIImage(systemName: user.isFollowed ? AppStrings.Icons.xmarkCircleFill : AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        case .report:
            titleLabel.text = AppStrings.Report.Opening.title
            button.configuration?.image = UIImage(systemName: AppStrings.Icons.fillFlag, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        }
    }
}

