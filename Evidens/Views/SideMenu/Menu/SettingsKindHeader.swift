//
//  SettingsKindHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/23.
//

import UIKit

class SettingsKindHeader: UICollectionReusableView {
    
    private let kindLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 13, scaleStyle: .title1, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(kindLabel, separator)
        
        NSLayoutConstraint.activate([
            kindLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            kindLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            kindLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            kindLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.4),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configure(with text: String) {
        kindLabel.text = text
    }
}
