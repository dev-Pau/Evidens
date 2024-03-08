//
//  ContextMenuCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/4/23.
//

import UIKit

class ContextMenuCell: UICollectionViewCell {
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 13.0, scaleStyle: .title3, weight: .regular)
       
        label.translatesAutoresizingMaskIntoConstraints = false
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
        addSubviews(contentLabel)
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
    func configure(withDescription description: String) {
        contentLabel.text = description
    }
}
