//
//  File.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/9/22.
//

import UIKit

class SettingsOptionCell: UITableViewCell {
    
    private let settingsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private let settingsImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysOriginal).withTintColor(lightGrayColor)
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(settingsImageView, settingsLabel, chevronImageView)
        
        NSLayoutConstraint.activate([
            settingsImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            settingsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            //settingsImageView.heightAnchor.constraint(equalToConstant: 25),
            //settingsImageView.widthAnchor.constraint(equalToConstant: 25),
            
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            settingsLabel.centerYAnchor.constraint(equalTo: settingsImageView.centerYAnchor),
            settingsLabel.leadingAnchor.constraint(equalTo: settingsImageView.trailingAnchor, constant: 20),
            //settingsLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -10)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(settingsTitle: String, settingsImage: String) {
        settingsLabel.text = settingsTitle
        settingsImageView.image = UIImage(systemName: settingsImage, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.black).scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
    }
}
