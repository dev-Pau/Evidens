//
//  BaseGuidelineTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/12/23.
//

import UIKit

class BaseGuidelineTextCell: UICollectionViewCell {
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
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
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func set(content: String) {
        contentLabel.text = content
    }
}
