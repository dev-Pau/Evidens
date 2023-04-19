//
//  ConfigureSectionTitleCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/7/22.
//

import UIKit

class ConfigureSectionTitleCell: UICollectionViewCell {
    
    private let titleSectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    private let sectionImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let chevronButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separatorView: UIView = {
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
        backgroundColor = .systemBackground
        
        addSubviews(titleSectionLabel, chevronButton, separatorView)
        
        NSLayoutConstraint.activate([
            //sectionImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            //sectionImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            //sectionImageView.heightAnchor.constraint(equalToConstant: 25),
            //sectionImageView.widthAnchor.constraint(equalToConstant: 25),
            
            chevronButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            chevronButton.heightAnchor.constraint(equalToConstant: 15),
            chevronButton.widthAnchor.constraint(equalToConstant: 15),
            
            titleSectionLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleSectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleSectionLabel.trailingAnchor.constraint(equalTo: chevronButton.leadingAnchor, constant: -10),
            //titleSectionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: titleSectionLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
        ])
    }
    
    func set(title: String, image: String) {
        titleSectionLabel.text = title
        sectionImageView.image = UIImage(systemName: image, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        
        chevronButton.configuration?.image = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.tertiaryLabel).scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15))
    }
}
