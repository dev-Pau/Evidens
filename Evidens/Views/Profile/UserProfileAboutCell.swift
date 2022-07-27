//
//  UserProfileAboutCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/22.
//

import UIKit

class UserProfileAboutCell: UICollectionViewCell {
    
    private var sectionAboutTitle: UILabel = {
        let label = UILabel()
        label.text = "About"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        addSubviews(sectionAboutTitle, aboutInformationLabel)
        
        NSLayoutConstraint.activate([
            sectionAboutTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            sectionAboutTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            sectionAboutTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            aboutInformationLabel.topAnchor.constraint(equalTo: sectionAboutTitle.bottomAnchor, constant: 5),
            aboutInformationLabel.leadingAnchor.constraint(equalTo: sectionAboutTitle.leadingAnchor),
            aboutInformationLabel.trailingAnchor.constraint(equalTo: sectionAboutTitle.trailingAnchor),
            aboutInformationLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func set(body: String) {
        aboutInformationLabel.text = body
    }
}
