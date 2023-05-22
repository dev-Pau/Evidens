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
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 2
        label.textColor = .label
        label.textAlignment = .center
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
        addSubview(specialityLabel)
        
        NSLayoutConstraint.activate([
            specialityLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            specialityLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            specialityLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            specialityLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5)
        ])
    }
    
    func configureWithDefaultSettings(_ text: String) {
        specialityLabel.text = text
        specialityLabel.textColor = .secondaryLabel
        backgroundColor = .systemBackground
        layer.cornerRadius = 0
    }
    
    func configureWithSpeciality(_ text: String) {
        backgroundColor = primaryColor
        specialityLabel.text = text
        specialityLabel.textColor = .white
        layer.cornerRadius = 15
    }
}
