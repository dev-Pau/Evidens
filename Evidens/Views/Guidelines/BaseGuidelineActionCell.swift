//
//  BaseGuidelineActionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/12/23.
//

import UIKit

class BaseGuidelineActionCell: UICollectionViewCell {
    
    private let indexButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintAdjustmentMode = .normal
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
        configuration.cornerStyle = .capsule
        button.configuration = configuration
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 19, scaleStyle: .largeTitle, weight: .heavy, scales: false)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .regular, scales: false)
        label.textColor = primaryGray
        label.numberOfLines = 0
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
        backgroundColor = .systemBackground
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.secondaryLabel.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.cornerRadius = 10
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        
        addSubviews(indexButton, titleLabel, contentLabel)
        
        NSLayoutConstraint.activate([
            indexButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            indexButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            indexButton.heightAnchor.constraint(equalToConstant: 40),
            indexButton.widthAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: indexButton.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: indexButton.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            contentLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5)
        ])
    }
    
    func configure(_ guideline: CaseGuideline) {
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .largeTitle, weight: .black, scales: false)

        indexButton.configuration?.attributedTitle = AttributedString(String(guideline.rawValue + 1), attributes: container)
        titleLabel.text = guideline.title
        contentLabel.text = guideline.content
    }
    
    func configure(_ guideline: PostGuideline) {
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .largeTitle, weight: .black, scales: false)

        indexButton.configuration?.attributedTitle = AttributedString(String(guideline.rawValue + 1), attributes: container)
        titleLabel.text = guideline.title
        contentLabel.text = guideline.content
    }
}
