//
//  UserProfileLanguageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

class UserProfileLanguageCell: UICollectionViewCell {
    
    private let languageTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "English"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let languageLevelLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = "Proficiency level"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lightGrayColor
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
        backgroundColor = .white
        addSubviews(languageTitleLabel, languageLevelLabel, separatorView)
        
        NSLayoutConstraint.activate([
            languageTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            languageTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            languageTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            languageLevelLabel.topAnchor.constraint(equalTo: languageTitleLabel.bottomAnchor, constant: 5),
            languageLevelLabel.leadingAnchor.constraint(equalTo: languageTitleLabel.leadingAnchor),
            languageLevelLabel.trailingAnchor.constraint(equalTo: languageTitleLabel.trailingAnchor),
            languageLevelLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: languageTitleLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: languageTitleLabel.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
 
        ])
    }
}
