//
//  TopEmptyContentCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/3/23.
//

import UIKit

class TopEmptyContentCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let resetContentButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Remove filters", attributes: container)
        
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
        backgroundColor = .systemBackground
        
        addSubviews(titleLabel, descriptionLabel)
        
        NSLayoutConstraint.activate([
            /*
            resetContentButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            resetContentButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            resetContentButton.widthAnchor.constraint(equalToConstant: 110),
            
            */
            titleLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -2),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            //descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50)
        ])
    }
    
    func set(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }
    

}



