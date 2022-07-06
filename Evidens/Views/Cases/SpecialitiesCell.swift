//
//  SpecialitiesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/7/22.
//

import UIKit

class SpecialitiesCell: UICollectionViewCell {
    
    var specialityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.numberOfLines = 0
        label.textColor = .white
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
        backgroundColor = primaryColor
        addSubview(specialityLabel)
        NSLayoutConstraint.activate([
            specialityLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            specialityLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            specialityLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}
