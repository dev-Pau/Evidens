//
//  CaseExploreCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/10/22.
//

import UIKit

class CaseExploreCell: UICollectionViewCell {
    
    private let name: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
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
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = separatorColor.cgColor

        addSubviews(name)
        NSLayoutConstraint.activate([
            name.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            name.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            name.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
    
    func set(discipline: Discipline) {
        name.text = discipline.name
    }
}
