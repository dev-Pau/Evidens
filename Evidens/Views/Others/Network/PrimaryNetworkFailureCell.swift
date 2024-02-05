//
//  PrimaryNetworkFailureCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/7/23.
//

import UIKit

protocol NetworkFailureCellDelegate: AnyObject {
    func didTapRefresh()
}
    
class PrimaryNetworkFailureCell: UICollectionViewCell {
    
    weak var delegate: NetworkFailureCellDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let tryButton: UIButton = {
        let button = UIButton()
        button.tintAdjustmentMode = .normal
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = primaryGray

        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular)
        
        config.attributedTitle = AttributedString(AppStrings.Network.Issues.tryAgain, attributes: container)
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20)
        
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
        
        addSubviews(titleLabel, tryButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            tryButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            tryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            tryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
        
        tryButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
    }
    
    func set(_ title: String) {
        titleLabel.text = title
    }
    
    @objc func handleRefresh() {
        delegate?.didTapRefresh()
    }
}
