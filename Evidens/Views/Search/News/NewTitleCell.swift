//
//  NewTitleCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/3/23.
//

import UIKit

class NewTitleCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 23, weight: .heavy)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let authorName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
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
        addSubviews(titleLabel, summaryLabel, timestampLabel, authorName)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            summaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            summaryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            authorName.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorName.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 20),
            authorName.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            timestampLabel.topAnchor.constraint(equalTo: authorName.bottomAnchor, constant: 5),
            timestampLabel.leadingAnchor.constraint(equalTo: summaryLabel.leadingAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: summaryLabel.trailingAnchor),
            timestampLabel.bottomAnchor.constraint(equalTo: bottomAnchor)  
        ])
        
        titleLabel.text = "Residents near Ohio train derailment diagnosed with ailments associated with chemical exposure, including bronchitis"
        summaryLabel.text = "Medical professionals suspect that some people's headaches, rashes and respiratory problems are related to the release of hazardous chemicals in East Palestine."
        authorName.text = "Aria Bendix"
        timestampLabel.text = "FEBRUARY 25, 2023, 1:00 PM CET"
    }
}
