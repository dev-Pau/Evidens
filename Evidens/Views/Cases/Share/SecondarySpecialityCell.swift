//
//  SecondarySpecialityCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/7/22.
//

import UIKit

class SecondarySpecialityCell: UICollectionViewCell {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 17, scaleStyle: .largeTitle, weight: .regular)
        label.numberOfLines = 1
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
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5)
        ])
    }
    
    func configureWithDefaultSettings(_ text: String) {
        titleLabel.text = text
        titleLabel.textColor = .tertiaryLabel
        backgroundColor = .systemBackground
        layer.cornerRadius = 0
    }
    
    func configureWithSpeciality(_ speciality: Speciality) {
        backgroundColor = primaryColor
        titleLabel.text = "  " + speciality.name
        titleLabel.textColor = .white
        layer.cornerRadius = 15
    }
    
    func configureWithItem(_ item: CaseItem) {
        backgroundColor = primaryColor
        titleLabel.text = "  " + item.title
        titleLabel.textColor = .white
        layer.cornerRadius = 15
    }
}
