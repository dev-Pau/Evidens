//
//  SecondaryNetworkFailureCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/8/23.
//

import UIKit

class SecondaryNetworkFailureCell: UICollectionViewCell {
    
    weak var delegate: NetworkFailureCellDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .heavy)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let tryButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = primaryColor
        config.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .medium)
        
        config.attributedTitle = AttributedString(AppStrings.Network.Issues.tryAgain, attributes: container)
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        
        button.configuration = config
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
        titleLabel.text = AppStrings.Network.Issues.title
        contentLabel.text = AppStrings.Network.Issues.content
        
        addSubviews(titleLabel, contentLabel, tryButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            tryButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 5),
            tryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            tryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
        
        tryButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
    }
    
    @objc func handleRefresh() {
        delegate?.didTapRefresh()
    }
}
