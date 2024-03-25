//
//  PrivacyCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/3/24.
//


import UIKit

class PrivacyCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title3, weight: .semibold)
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

            label.topAnchor.constraint(equalTo: topAnchor, constant: K.Paddings.Settings.verticalPadding),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: K.Paddings.Settings.horizontalPadding),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Settings.horizontalPadding),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -K.Paddings.Settings.verticalPadding)
        ])
    }
    
    func set(option: LegalKind) {
        label.text = option.title
    }
    
    func set(option: PrivacyKind) {
        label.text = option.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
