//
//  ConnectionMenuCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/10/23.
//

import UIKit
import Firebase

class ConnectionMenuCell: UICollectionViewCell {
    
    private let padding: CGFloat = 10

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13, weight: .regular)
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
        addSubviews(contentLabel)

        NSLayoutConstraint.activate([

            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func set(user: User) {
        guard let connection = user.connection else { return }
        
        var text = ""
        let date = formatTimestamp(connection.timestamp)

        switch connection.phase {
            
        case .connected:
            text = AppStrings.Network.Connection.Profile.connectedContent + " " + date
        case .pending:
            text = AppStrings.Network.Connection.Profile.pendingContent + " " + date
        case .received:
            text = AppStrings.Network.Connection.Profile.receivedContent + " " + date
        case .none, .withdraw, .rejected, .unconnect:
            text = AppStrings.Network.Connection.Profile.noneContent
        }
        
        contentLabel.text = text
    }
    
    func formatTimestamp(_ timestamp: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current

        dateFormatter.dateFormat = "dd MMM"

        let date = timestamp.dateValue()

        let currentYear = calendar.component(.year, from: Date())

        let yearFromTimestamp = calendar.component(.year, from: date)

        if currentYear == yearFromTimestamp {
            return dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "dd MMM yyyy"
            return dateFormatter.string(from: date)
        }
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
