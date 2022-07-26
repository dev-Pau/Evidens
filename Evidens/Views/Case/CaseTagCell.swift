//
//  CaseTagsCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/7/22.
//

//
//  SpecialitiesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/7/22.
//

import UIKit

class CaseTagCell: UICollectionViewCell {
    
    var tagsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
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
        layer.cornerRadius = 15
        backgroundColor = primaryColor
        addSubview(tagsLabel)
        
        NSLayoutConstraint.activate([
            tagsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            tagsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            tagsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            tagsLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5)
        ])
    }
}

