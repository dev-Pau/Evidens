//
//  UserProfileAboutCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/22.
//

import UIKit

class UserProfileAboutCell: UICollectionViewCell {
    
    private var aboutInformationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 6
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
        backgroundColor = .white
        addSubviews(aboutInformationLabel)
        
        NSLayoutConstraint.activate([
            aboutInformationLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            aboutInformationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            aboutInformationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            aboutInformationLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func set(body: String) {
        aboutInformationLabel.text = body
    }
}
