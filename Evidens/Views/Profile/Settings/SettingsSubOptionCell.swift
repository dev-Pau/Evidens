//
//  SettingsSubOptionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/9/22.
//

import UIKit

class SettingsSubOptionCell: UITableViewCell {
    
    private let settingsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysOriginal).withTintColor(.quaternarySystemFill)
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemBackground
        contentView.addSubviews(settingsLabel, chevronImageView)
        
        NSLayoutConstraint.activate([
            
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            settingsLabel.centerYAnchor.constraint(equalTo: chevronImageView.centerYAnchor),
            settingsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(settingsTitle: String) {
        settingsLabel.text = settingsTitle
    }
}

