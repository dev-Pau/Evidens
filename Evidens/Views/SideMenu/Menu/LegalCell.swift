//
//  LegalCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/6/23.
//

import UIKit

class LegalCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 16.0, scaleStyle: .title3, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        return label
    }()
    
    private var clockwise: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews(label)
        
        NSLayoutConstraint.activate([

            label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func set(option: Legal) {
        label.text = option.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
