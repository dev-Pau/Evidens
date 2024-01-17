//
//  SecondaryNetworkFailureCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/8/23.
//

import UIKit

class SecondaryNetworkFailureCell: UICollectionViewCell {
    
    weak var delegate: NetworkFailureCellDelegate?
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let tryButton: UIButton = {
        let button = UIButton()
        button.tintAdjustmentMode = .normal
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .secondaryLabel
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .semibold)
        config.attributedTitle = AttributedString(AppStrings.Network.Issues.tryAgain, attributes: container)
       
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
        addSubviews(contentLabel, tryButton)
        contentLabel.text = AppStrings.Network.Issues.Comments.title
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            tryButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor),
            tryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            tryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
        
        tryButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
    }
    
    @objc func handleRefresh() {
        delegate?.didTapRefresh()
    }
}
