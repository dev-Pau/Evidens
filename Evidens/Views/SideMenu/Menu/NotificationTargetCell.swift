//
//  NotificationTargetCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import UIKit

class NotificationTargetCell: UICollectionViewCell {

    private let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let onOffLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let chevronImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(title, onOffLabel, chevronImage)
        NSLayoutConstraint.activate([
            
            chevronImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            chevronImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImage.widthAnchor.constraint(equalToConstant: 14),
            chevronImage.heightAnchor.constraint(equalToConstant: 17),
            
            onOffLabel.trailingAnchor.constraint(equalTo: chevronImage.leadingAnchor),
            onOffLabel.centerYAnchor.constraint(equalTo: chevronImage.centerYAnchor),
            onOffLabel.widthAnchor.constraint(equalToConstant: 30),
            
            title.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            title.trailingAnchor.constraint(equalTo: onOffLabel.leadingAnchor, constant: -10),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -13)
            
        ])
        
        chevronImage.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(separatorColor!)
    }
    
    func set(onOff: Bool) {
        onOffLabel.text = onOff ? AppStrings.Miscellaneous.on : AppStrings.Miscellaneous.off
    }
    
    func set(title: String) {
        self.title.text = title
    }
    
    func hide() {
        onOffLabel.isHidden = true
    }
}