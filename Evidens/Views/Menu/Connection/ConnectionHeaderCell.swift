//
//  ConnectionHeaderCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/10/23.
//

import UIKit

class ConnectionHeaderCell: UICollectionViewCell {
    
    private let padding: CGFloat = 10

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemFill
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 25, weight: .heavy)
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
        addSubviews(separator, titleLabel)
        
        NSLayoutConstraint.activate([
            separator.centerXAnchor.constraint(equalTo: centerXAnchor),
            separator.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            separator.heightAnchor.constraint(equalToConstant: 5),
            separator.widthAnchor.constraint(equalToConstant: 50),
            
            titleLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func set(user: User) {
        guard let connection = user.connection else { return }

        var text = user.firstName!
        
        switch connection.phase {
            
        case .connected:
            text += " " + AppStrings.Network.Connection.Profile.connected
        case .pending:
            text += " " + AppStrings.Network.Connection.Profile.pending
        case .received:
            text += " " + AppStrings.Network.Connection.Profile.received
        case .none, .withdraw, .rejected, .unconnect:
            text = AppStrings.Network.Connection.Profile.none + " " + text
        }
        
        titleLabel.text = text
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}
